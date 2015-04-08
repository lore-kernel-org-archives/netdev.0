From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net] be2net: Fix a bug in Rx buffer posting
Date: Wed, 8 Apr 2015 16:59:48 -0500
Message-ID: <20150408215948.GA8248@OptiPlex>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:46332 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbbDHWAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 18:00:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The numPosted field in the ERX Doorbell register is 8-bits wide.
So the max buffers that we can post at a time is 255 and not 256
which we are doing currently.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 27b9fe9..204ec43 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -97,6 +97,7 @@
 #define BE_NAPI_WEIGHT		64
 #define MAX_RX_POST		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
+#define MAX_NUM_POST_ERX_DB	255u
 
 #define MAX_VFS			30 /* Max VFs supported by BE3 FW */
 #define FW_VER_LEN		32
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e6b790f..ad2b509 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2032,7 +2032,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp, u32 frags_needed)
 		if (rxo->rx_post_starved)
 			rxo->rx_post_starved = false;
 		do {
-			notify = min(256u, posted);
+			notify = min(MAX_NUM_POST_ERX_DB, posted);
 			be_rxq_notify(adapter, rxq->id, notify);
 			posted -= notify;
 		} while (posted);
-- 
2.1.0
