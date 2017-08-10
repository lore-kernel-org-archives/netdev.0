From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 01/10] netvsc: delay setup of VF device
Date: Wed,  9 Aug 2017 17:46:03 -0700
Message-ID: <20170810004612.22163-2-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34497 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHJAqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:16 -0400
Received: by mail-pg0-f51.google.com with SMTP id u185so34511425pgb.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:16 -0700 (PDT)
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VF device is discovered, delay bring it automatically up in
order to allow userspace to some simple changes (like renaming).

Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  2 +-
 drivers/net/hyperv/netvsc_drv.c | 15 ++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index d1ea99a12cf2..f620c90307ed 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -723,7 +723,7 @@ struct net_device_context {
 	/* State to manage the associated VF interface. */
 	struct net_device __rcu *vf_netdev;
 	struct netvsc_vf_pcpu_stats __percpu *vf_stats;
-	struct work_struct vf_takeover;
+	struct delayed_work vf_takeover;
 
 	/* 1: allocated, serial number is valid. 0: not allocated */
 	u32 vf_alloc;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index eb0023f55fe1..e059375a6d8c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -47,6 +47,7 @@
 
 #define RING_SIZE_MIN 64
 #define LINKCHANGE_INT (2 * HZ)
+#define VF_TAKEOVER_INT (HZ / 10)
 
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
@@ -1559,7 +1560,9 @@ static int netvsc_vf_join(struct net_device *vf_netdev,
 	/* set slave flag before open to prevent IPv6 addrconf */
 	vf_netdev->flags |= IFF_SLAVE;
 
-	schedule_work(&ndev_ctx->vf_takeover);
+	schedule_delayed_work(&ndev_ctx->vf_takeover, VF_TAKEOVER_INT);
+
+	call_netdevice_notifiers(NETDEV_JOIN, vf_netdev);
 
 	netdev_info(vf_netdev, "joined to %s\n", ndev->name);
 	return 0;
@@ -1575,8 +1578,6 @@ static void __netvsc_vf_setup(struct net_device *ndev,
 {
 	int ret;
 
-	call_netdevice_notifiers(NETDEV_JOIN, vf_netdev);
-
 	/* Align MTU of VF with master */
 	ret = dev_set_mtu(vf_netdev, ndev->mtu);
 	if (ret)
@@ -1597,12 +1598,12 @@ static void __netvsc_vf_setup(struct net_device *ndev,
 static void netvsc_vf_setup(struct work_struct *w)
 {
 	struct net_device_context *ndev_ctx
-		= container_of(w, struct net_device_context, vf_takeover);
+		= container_of(w, struct net_device_context, vf_takeover.work);
 	struct net_device *ndev = hv_get_drvdata(ndev_ctx->device_ctx);
 	struct net_device *vf_netdev;
 
 	if (!rtnl_trylock()) {
-		schedule_work(w);
+		schedule_delayed_work(&ndev_ctx->vf_takeover, 0);
 		return;
 	}
 
@@ -1706,7 +1707,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 		return NOTIFY_DONE;
 
 	net_device_ctx = netdev_priv(ndev);
-	cancel_work_sync(&net_device_ctx->vf_takeover);
+	cancel_delayed_work_sync(&net_device_ctx->vf_takeover);
 
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 
@@ -1748,7 +1749,7 @@ static int netvsc_probe(struct hv_device *dev,
 
 	spin_lock_init(&net_device_ctx->lock);
 	INIT_LIST_HEAD(&net_device_ctx->reconfig_events);
-	INIT_WORK(&net_device_ctx->vf_takeover, netvsc_vf_setup);
+	INIT_DELAYED_WORK(&net_device_ctx->vf_takeover, netvsc_vf_setup);
 
 	net_device_ctx->vf_stats
 		= netdev_alloc_pcpu_stats(struct netvsc_vf_pcpu_stats);
-- 
2.11.0
