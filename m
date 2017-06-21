From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/2] hv_netvsc: Fix the carrier state error when data path is off
Date: Wed, 21 Jun 2017 16:40:47 -0700
Message-ID: <1498088447-27282-2-git-send-email-haiyangz@exchange.microsoft.com>
References: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

When the VF NIC is opened, the synthetic NIC's carrier state is set to
off. This tells the host to transitions data path to the VF device. But
if startup script or user manipulates the admin state of the netvsc
device directly for example:
        # ifconfig eth0 down
	# ifconfig eth0 up
Then the carrier state of the synthetic NIC would be on, even though the
data path was still over the VF NIC. This patch sets the carrier state
of synthetic NIC with consideration of the related VF state.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 ++
 drivers/net/hyperv/netvsc.c     |    2 ++
 drivers/net/hyperv/netvsc_drv.c |    8 +++++---
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index ced947d..d6c2558 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -717,6 +717,8 @@ struct net_device_context {
 	u32 vf_alloc;
 	/* Serial number of the VF to team with */
 	u32 vf_serial;
+
+	bool datapath;	/* 0 - synthetic, 1 - VF nic */
 };
 
 /* Per channel data */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 7c5ed8f..0a9167d 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -57,6 +57,8 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 			       sizeof(struct nvsp_message),
 			       (unsigned long)init_pkt,
 			       VM_PKT_DATA_INBAND, 0);
+
+	net_device_ctx->datapath = vf;
 }
 
 static struct netvsc_device *alloc_net_device(void)
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9a6c586..9913721 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -68,7 +68,8 @@ static void netvsc_set_multicast_list(struct net_device *net)
 
 static int netvsc_open(struct net_device *net)
 {
-	struct netvsc_device *nvdev = net_device_to_netvsc_device(net);
+	struct net_device_context *ndev_ctx = netdev_priv(net);
+	struct netvsc_device *nvdev = ndev_ctx->nvdev;
 	struct rndis_device *rdev;
 	int ret = 0;
 
@@ -84,7 +85,7 @@ static int netvsc_open(struct net_device *net)
 	netif_tx_wake_all_queues(net);
 
 	rdev = nvdev->extension;
-	if (!rdev->link_state)
+	if (!rdev->link_state && !ndev_ctx->datapath)
 		netif_carrier_on(net);
 
 	return ret;
@@ -1284,7 +1285,8 @@ static void netvsc_link_change(struct work_struct *w)
 	case RNDIS_STATUS_MEDIA_CONNECT:
 		if (rdev->link_state) {
 			rdev->link_state = false;
-			netif_carrier_on(net);
+			if (!ndev_ctx->datapath)
+				netif_carrier_on(net);
 			netif_tx_wake_all_queues(net);
 		} else {
 			notify = true;
-- 
1.7.1
