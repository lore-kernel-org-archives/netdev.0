From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 4/5] bnx2x: add gro_check
Date: Mon, 20 Feb 2012 21:59:11 +0200
Message-ID: <1329767952-12605-5-git-send-email-dmitry@broadcom.com>
References: <1329767952-12605-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4010 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab2BTUCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 15:02:24 -0500
In-Reply-To: <1329767952-12605-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch provides workaround for BUG in FW 7.2.16,
which in GRO mode may miscalculate buffer and
place on SGE one frag less than it could.
It may happen only for some MTUs, we mark these MTUs
with gro_check flag during device initialization or
MTU change.

Next FW should include fix for the issue and the
patch could be reverted.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   12 ++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    7 +++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 ++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 26cc954..b9b9888 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -341,6 +341,7 @@ union db_prod {
 #define SGE_PAGE_SIZE		PAGE_SIZE
 #define SGE_PAGE_SHIFT		PAGE_SHIFT
 #define SGE_PAGE_ALIGN(addr)	PAGE_ALIGN((typeof(PAGE_SIZE))(addr))
+#define SGE_PAGES		(SGE_PAGE_SIZE * PAGES_PER_SGE)
 
 /* SGE ring related macros */
 #define NUM_RX_SGE_PAGES	2
@@ -1210,6 +1211,7 @@ struct bnx2x {
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 /* TCP with Timestamp Option (32) + IPv6 (40) */
 #define ETH_MAX_TPA_HEADER_SIZE		72
+#define ETH_MIN_TPA_HEADER_SIZE		40
 
 	/* Max supported alignment is 256 (8 shift) */
 #define BNX2X_RX_ALIGN_SHIFT		min(8, L1_CACHE_SHIFT)
@@ -1329,6 +1331,8 @@ struct bnx2x {
 
 	u8			wol;
 
+	bool			gro_check;
+
 	int			rx_ring_size;
 
 	u16			tx_quick_cons_trip_int;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a45251..f82dfff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -330,6 +330,16 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 		u16 gro_size = le16_to_cpu(cqe->pkt_len_or_gro_seg_len);
 		tpa_info->full_page =
 			SGE_PAGE_SIZE * PAGES_PER_SGE / gro_size * gro_size;
+		/*
+		 * FW 7.2.16 BUG workaround:
+		 * if SGE size is (exactly) multiple gro_size
+		 * fw will place one less frag on SGE.
+		 * the calculation is done only for potentially
+		 * dangerous MTUs.
+		 */
+		if (unlikely(bp->gro_check))
+			if (!(SGE_PAGE_SIZE * PAGES_PER_SGE % gro_size))
+				tpa_info->full_page -= gro_size;
 		tpa_info->gro_size = gro_size;
 	}
 
@@ -3486,6 +3496,8 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	 */
 	dev->mtu = new_mtu;
 
+	bp->gro_check = bnx2x_need_gro_check(new_mtu);
+
 	return bnx2x_reload_if_running(dev);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index d2093ee..33aa7de 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1504,6 +1504,13 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
 	 */
 	return mtu <= SGE_PAGE_SIZE && (U_ETH_SGL_SIZE * fpp) <= MAX_SKB_FRAGS;
 }
+
+static inline bool bnx2x_need_gro_check(int mtu)
+{
+	return (SGE_PAGES / (mtu - ETH_MAX_TPA_HEADER_SIZE - 1)) !=
+		(SGE_PAGES / (mtu - ETH_MIN_TPA_HEADER_SIZE + 1));
+}
+
 /**
  * bnx2x_bz_fp - zero content of the fastpath structure.
  *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e9a6ffe..4630be2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10227,6 +10227,8 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (CHIP_IS_E3B0(bp))
 		bp->max_cos = BNX2X_MULTI_TX_COS_E3B0;
 
+	bp->gro_check = bnx2x_need_gro_check(bp->dev->mtu);
+
 	return rc;
 }
 
-- 
1.7.7.2
