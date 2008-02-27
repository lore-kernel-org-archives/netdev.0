From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 10/12][BNX2X]: Fix Xmit bugs
Date: Wed, 27 Feb 2008 14:25:01 +0200
Message-ID: <1204115101.8232.365.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1070 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451AbYB0MZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:25:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: Fix Xmit bugs

Several endianity corrections in start_xmit()
Fixed TSO bug where packets were missing the TCP flags.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |   12 +++++++-----
 drivers/net/bnx2x.h |    3 +++
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index d21599c..2db0427 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -9269,7 +9269,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* for now NS flag is not used in Linux */
 		pbd->global_data = (len |
-				    ((skb->protocol == ETH_P_8021Q) <<
+				    ((skb->protocol == ntohs(ETH_P_8021Q)) <<
 				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
 		pbd->ip_hlen = ip_hdrlen(skb) / 2;
 		pbd->total_hlen = cpu_to_le16(len + pbd->ip_hlen);
@@ -9278,7 +9278,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			tx_bd->bd_flags.as_bitfield |=
 						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->tcp_flags = htonl(tcp_flag_word(skb)) & 0xFFFF;
+			pbd->tcp_flags = pbd_tcp_flags(skb);
 			pbd->total_hlen += cpu_to_le16(tcp_hdrlen(skb) / 2);
 			pbd->tcp_pseudo_csum = swab16(th->check);
 
@@ -9322,7 +9322,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb_shinfo(skb)->gso_size &&
 	    (skb->len > (bp->dev->mtu + ETH_HLEN))) {
-		int hlen = 2 * le32_to_cpu(pbd->total_hlen);
+		int hlen = 2 * le16_to_cpu(pbd->total_hlen);
 
 		DP(NETIF_MSG_TX_QUEUED,
 		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
@@ -9439,9 +9439,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %u  bd %d\n", nbd, bd_prod);
 
-	fp->hw_tx_prods->bds_prod += cpu_to_le16(nbd);
+	fp->hw_tx_prods->bds_prod =
+		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod += cpu_to_le32(1);
+	fp->hw_tx_prods->packets_prod =
+		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
 	DOORBELL(bp, fp_index, 0);
 
 	mmiowb();
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 6a86afb..4f0c0d3 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -869,6 +869,9 @@ struct bnx2x {
 #define PCICFG_LINK_SPEED_SHIFT		16
 
 #define BMAC_CONTROL_RX_ENABLE		2
+
+#define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 & 0xff)
+
 /* stuff added to make the code fit 80Col */
 
 #define TPA_TYPE_START  		ETH_FAST_PATH_RX_CQE_START_FLG
-- 
1.5.3.2




