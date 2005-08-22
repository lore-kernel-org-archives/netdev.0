From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] [NET] mv643xx: add workaround for HW checksum generation bug
Date: Mon, 22 Aug 2005 15:53:29 -0700
Message-ID: <20050822225329.GA25560@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[PATCH] [NET] mv643xx: add workaround for HW checksum generation bug

The hardware checksum generator on the mv64xxx occasionally generates
an incorrect checksum.  This patch works around the issue and enables
hardware checksum generation.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---
commit 42b926194c0e88445e654b8f11faf199d1409650
tree 0dfda571d490d3d67ee5fc14f473390efeabef84
parent f6fdd7d9c273bb2a20ab467cb57067494f932fa3
author Dale Farnsworth <dale@farnsworth.org> Mon, 22 Aug 2005 15:43:49 -0700
committer Dale Farnsworth <dale@farnsworth.org> Mon, 22 Aug 2005 15:43:49 -0700

 drivers/net/mv643xx_eth.c |   29 ++++++++++++++++++-----------
 drivers/net/mv643xx_eth.h |    4 +++-
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1157,16 +1157,20 @@ static int mv643xx_eth_start_xmit(struct
 	if (!skb_shinfo(skb)->nr_frags) {
 linear:
 		if (skb->ip_summed != CHECKSUM_HW) {
+			/* Errata BTS #50, IHL must be 5 if no HW checksum */
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
+					   ETH_TX_FIRST_DESC |
+					   ETH_TX_LAST_DESC |
+					   5 << ETH_TX_IHL_SHIFT;
 			pkt_info.l4i_chk = 0;
 		} else {
-			u32 ipheader = skb->nh.iph->ihl << 11;
 
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC |
-					ETH_GEN_TCP_UDP_CHECKSUM |
-					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+					   ETH_TX_FIRST_DESC |
+					   ETH_TX_LAST_DESC |
+					   ETH_GEN_TCP_UDP_CHECKSUM |
+					   ETH_GEN_IP_V_4_CHECKSUM |
+					   skb->nh.iph->ihl << ETH_TX_IHL_SHIFT;
 			/* CPU already calculated pseudo header checksum. */
 			if (skb->nh.iph->protocol == IPPROTO_UDP) {
 				pkt_info.cmd_sts |= ETH_UDP_FRAME;
@@ -1193,7 +1197,6 @@ linear:
 		stats->tx_bytes += pkt_info.byte_cnt;
 	} else {
 		unsigned int frag;
-		u32 ipheader;
 
 		/* Since hardware can't handle unaligned fragments smaller
 		 * than 9 bytes, if we find any, we linearize the skb
@@ -1222,12 +1225,16 @@ linear:
 							DMA_TO_DEVICE);
 		pkt_info.l4i_chk = 0;
 		pkt_info.return_info = 0;
-		pkt_info.cmd_sts = ETH_TX_FIRST_DESC;
 
-		if (skb->ip_summed == CHECKSUM_HW) {
-			ipheader = skb->nh.iph->ihl << 11;
-			pkt_info.cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+		if (skb->ip_summed != CHECKSUM_HW)
+			/* Errata BTS #50, IHL must be 5 if no HW checksum */
+			pkt_info.cmd_sts = ETH_TX_FIRST_DESC |
+					   5 << ETH_TX_IHL_SHIFT;
+		else {
+			pkt_info.cmd_sts = ETH_TX_FIRST_DESC |
+					   ETH_GEN_TCP_UDP_CHECKSUM |
+					   ETH_GEN_IP_V_4_CHECKSUM |
+					   skb->nh.iph->ihl << ETH_TX_IHL_SHIFT;
 			/* CPU already calculated pseudo header checksum. */
 			if (skb->nh.iph->protocol == IPPROTO_UDP) {
 				pkt_info.cmd_sts |= ETH_UDP_FRAME;
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
--- a/drivers/net/mv643xx_eth.h
+++ b/drivers/net/mv643xx_eth.h
@@ -49,7 +49,7 @@
 /* Checksum offload for Tx works for most packets, but
  * fails if previous packet sent did not use hw csum
  */
-#undef	MV643XX_CHECKSUM_OFFLOAD_TX
+#define	MV643XX_CHECKSUM_OFFLOAD_TX
 #define	MV643XX_NAPI
 #define	MV643XX_TX_FAST_REFILL
 #undef	MV643XX_RX_QUEUE_FILL_ON_TASK	/* Does not work, yet */
@@ -217,6 +217,8 @@
 #define ETH_TX_ENABLE_INTERRUPT			(BIT23)
 #define ETH_AUTO_MODE				(BIT30)
 
+#define ETH_TX_IHL_SHIFT			11
+
 /* typedefs */
 
 typedef enum _eth_func_ret_status {
