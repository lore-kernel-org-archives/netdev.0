From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH net-next 2/3] bnx2x: remove gro workaround
Date: Mon, 23 Apr 2012 16:05:11 +0300
Message-ID: <1335186311.14229.27.camel@lb-tlvb-barak.il.broadcom.com>
Reply-To: barak@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4268 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab2DWNJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 09:09:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Removes GRO workaround, as issue is fixed in FW 7.2.51.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    4 ----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   12 ------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    7 -------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 --
 4 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0a59243..42bb145 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -349,7 +349,6 @@ union db_prod {
 #define SGE_PAGE_SIZE		PAGE_SIZE
 #define SGE_PAGE_SHIFT		PAGE_SHIFT
 #define SGE_PAGE_ALIGN(addr)	PAGE_ALIGN((typeof(PAGE_SIZE))(addr))
-#define SGE_PAGES		(SGE_PAGE_SIZE * PAGES_PER_SGE)
 
 /* SGE ring related macros */
 #define NUM_RX_SGE_PAGES	2
@@ -1240,7 +1239,6 @@ struct bnx2x {
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 /* TCP with Timestamp Option (32) + IPv6 (40) */
 #define ETH_MAX_TPA_HEADER_SIZE		72
-#define ETH_MIN_TPA_HEADER_SIZE		40
 
 	/* Max supported alignment is 256 (8 shift) */
 #define BNX2X_RX_ALIGN_SHIFT		min(8, L1_CACHE_SHIFT)
@@ -1362,8 +1360,6 @@ struct bnx2x {
 
 	u8			wol;
 
-	bool			gro_check;
-
 	int			rx_ring_size;
 
 	u16			tx_quick_cons_trip_int;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 484e632..60d5b54 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -328,16 +328,6 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 		u16 gro_size = le16_to_cpu(cqe->pkt_len_or_gro_seg_len);
 		tpa_info->full_page =
 			SGE_PAGE_SIZE * PAGES_PER_SGE / gro_size * gro_size;
-		/*
-		 * FW 7.2.16 BUG workaround:
-		 * if SGE size is (exactly) multiple gro_size
-		 * fw will place one less frag on SGE.
-		 * the calculation is done only for potentially
-		 * dangerous MTUs.
-		 */
-		if (unlikely(bp->gro_check))
-			if (!(SGE_PAGE_SIZE * PAGES_PER_SGE % gro_size))
-				tpa_info->full_page -= gro_size;
 		tpa_info->gro_size = gro_size;
 	}
 
@@ -3525,8 +3515,6 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	 */
 	dev->mtu = new_mtu;
 
-	bp->gro_check = bnx2x_need_gro_check(new_mtu);
-
 	return bnx2x_reload_if_running(dev);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 3b1bc6d..cec993b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1544,13 +1544,6 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
 	 */
 	return mtu <= SGE_PAGE_SIZE && (U_ETH_SGL_SIZE * fpp) <= MAX_SKB_FRAGS;
 }
-
-static inline bool bnx2x_need_gro_check(int mtu)
-{
-	return (SGE_PAGES / (mtu - ETH_MAX_TPA_HEADER_SIZE - 1)) !=
-		(SGE_PAGES / (mtu - ETH_MIN_TPA_HEADER_SIZE + 1));
-}
-
 /**
  * bnx2x_bz_fp - zero content of the fastpath structure.
  *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index bc9fbd6..aeb6de4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10982,8 +10982,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (CHIP_IS_E3B0(bp))
 		bp->max_cos = BNX2X_MULTI_TX_COS_E3B0;
 
-	bp->gro_check = bnx2x_need_gro_check(bp->dev->mtu);
-
 	return rc;
 }
 
-- 
1.7.1
