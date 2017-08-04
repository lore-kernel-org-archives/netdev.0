From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/1] netvsc: fix rtnl deadlock on unregister of vf
Date: Fri,  4 Aug 2017 12:14:00 -0700
Message-ID: <20170804191400.22471-2-sthemmin@microsoft.com>
References: <20170804191400.22471-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37042 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdHDTOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 15:14:05 -0400
Received: by mail-pg0-f45.google.com with SMTP id y129so11345428pgy.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 12:14:05 -0700 (PDT)
In-Reply-To: <20170804191400.22471-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With new transparent VF support, it is possible to get a deadlock
when some of the deferred work is running and the unregister_vf
is trying to cancel the work element. The solution is to use
trylock and reschedule (similar to bonding and team device).

Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Fixes: 0c195567a8f6 ("netvsc: transparent VF management")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c71728d82049..e75c0f852a63 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1601,7 +1601,11 @@ static void netvsc_vf_setup(struct work_struct *w)
 	struct net_device *ndev = hv_get_drvdata(ndev_ctx->device_ctx);
 	struct net_device *vf_netdev;
 
-	rtnl_lock();
+	if (!rtnl_trylock()) {
+		schedule_work(w);
+		return;
+	}
+
 	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
 	if (vf_netdev)
 		__netvsc_vf_setup(ndev, vf_netdev);
@@ -1655,7 +1659,11 @@ static void netvsc_vf_update(struct work_struct *w)
 	struct net_device *vf_netdev;
 	bool vf_is_up;
 
-	rtnl_lock();
+	if (!rtnl_trylock()) {
+		schedule_work(w);
+		return;
+	}
+
 	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
 	if (!vf_netdev)
 		goto unlock;
-- 
2.11.0
