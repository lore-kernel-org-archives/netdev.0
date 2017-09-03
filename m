From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/6] net: qualcomm: rmnet: Fix memory corruption if mux_id is greater than 32
Date: Sat,  2 Sep 2017 23:30:41 -0600
Message-ID: <1504416646-9527-2-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42600 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdICFbv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:51 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rmnet_rtnl_validate() was checking for upto mux_id 254, however the
rmnet_devices devices could hold upto 32 entries only. Fix this by
increasing the size of the rmnet_devices.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h  | 3 +--
 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h | 1 -
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c     | 2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 985d372..40b6b32 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -19,7 +19,6 @@
 #define _RMNET_CONFIG_H_
 
 #define RMNET_MAX_LOGICAL_EP 255
-#define RMNET_MAX_VND        32
 
 /* Information about the next device to deliver the packet to.
  * Exact usage of this parameter depends on the rmnet_mode.
@@ -39,7 +38,7 @@ struct rmnet_real_dev_info {
 	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
 	u32 ingress_data_format;
 	u32 egress_data_format;
-	struct net_device *rmnet_devices[RMNET_MAX_VND];
+	struct net_device *rmnet_devices[RMNET_MAX_LOGICAL_EP];
 	u8 nr_rmnet_devs;
 };
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
index ed820b5..7967198 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
@@ -13,7 +13,6 @@
 #ifndef _RMNET_PRIVATE_H_
 #define _RMNET_PRIVATE_H_
 
-#define RMNET_MAX_VND              32
 #define RMNET_MAX_PACKET_SIZE      16384
 #define RMNET_DFLT_PACKET_SIZE     1500
 #define RMNET_NEEDED_HEADROOM      16
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index bf7455f..0e0001b 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -112,7 +112,7 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 
 int rmnet_vnd_dellink(u8 id, struct rmnet_real_dev_info *r)
 {
-	if (id >= RMNET_MAX_VND || !r->rmnet_devices[id])
+	if (id >= RMNET_MAX_LOGICAL_EP || !r->rmnet_devices[id])
 		return -EINVAL;
 
 	r->rmnet_devices[id] = NULL;
-- 
1.9.1
