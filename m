From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: rearrange dma descriptor
Date: Fri, 18 Apr 2014 20:59:36 +0900
Message-ID: <000601cf5afd$ab2e55c0$018b0140$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch moves cksum_ctl to tx_rd_des23 from cksum_pktlen for correct checksum 
offloading and modifies size for Tx/Rx descriptor.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c |    4 +--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h |   39 ++++++++++-------------
 2 files changed, 19 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
index e896dbb..d71691b 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
@@ -45,10 +45,10 @@ static void sxgbe_prepare_tx_desc(struct sxgbe_tx_norm_desc *p, u8 is_fd,
 	p->tdes23.tx_rd_des23.first_desc = is_fd;
 	p->tdes23.tx_rd_des23.buf1_size = buf1_len;
 
-	p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.total_pkt_len = pkt_len;
+	p->tdes23.tx_rd_des23.tx_pkt_len.pkt_len.total_pkt_len = pkt_len;
 
 	if (cksum)
-		p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.cksum_ctl = cic_full;
+		p->tdes23.tx_rd_des23.cksum_ctl = cic_full;
 }
 
 /* Set VLAN control information */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
index 838cb9f..0226300 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
@@ -39,22 +39,22 @@ struct sxgbe_tx_norm_desc {
 			u32 int_on_com:1;
 			/* TDES3 */
 			union {
-				u32 tcp_payload_len:18;
+				u16 tcp_payload_len;
 				struct {
 					u32 total_pkt_len:15;
 					u32 reserved1:1;
-					u32 cksum_ctl:2;
-				} cksum_pktlen;
+				} pkt_len;
 			} tx_pkt_len;
 
-			u32 tse_bit:1;
-			u32 tcp_hdr_len:4;
-			u32 sa_insert_ctl:3;
-			u32 crc_pad_ctl:2;
-			u32 last_desc:1;
-			u32 first_desc:1;
-			u32 ctxt_bit:1;
-			u32 own_bit:1;
+			u16 cksum_ctl:2;
+			u16 tse_bit:1;
+			u16 tcp_hdr_len:4;
+			u16 sa_insert_ctl:3;
+			u16 crc_pad_ctl:2;
+			u16 last_desc:1;
+			u16 first_desc:1;
+			u16 ctxt_bit:1;
+			u16 own_bit:1;
 		} tx_rd_des23;
 
 		/* tx write back Desc 2,3 */
@@ -70,25 +70,20 @@ struct sxgbe_tx_norm_desc {
 
 struct sxgbe_rx_norm_desc {
 	union {
-		u32 rdes0; /* buf1 address */
-		struct {
+		u64 rdes01; /* buf1 address */
+		union {
 			u32 out_vlan_tag:16;
 			u32 in_vlan_tag:16;
-		} wb_rx_des0;
-	} rd_wb_des0;
-
-	union {
-		u32 rdes1;	/* buf2 address or buf1[63:32] */
-		u32 rss_hash;	/* Write-back RX */
-	} rd_wb_des1;
+			u32 rss_hash;
+		} rx_wb_des01;
+	} rdes01;
 
 	union {
 		/* RX Read format Desc 2,3 */
 		struct{
 			/* RDES2 */
-			u32 buf2_addr;
+			u64 buf2_addr:62;
 			/* RDES3 */
-			u32 buf2_hi_addr:30;
 			u32 int_on_com:1;
 			u32 own_bit:1;
 		} rx_rd_des23;
-- 
1.7.10.4
