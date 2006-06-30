From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5] tg3: Add TSO workaround using GSO
Date: Thu, 29 Jun 2006 18:29:27 -0700
Message-ID: <1151630967.21798.20.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jk@blackdown.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:12037 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751386AbWF3B2T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:28:19 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use GSO to workaround a rare TSO bug on some chips.  This hardware
bug may be triggered when the TSO header size is greater than 80
bytes.  When this condition is detected in a TSO packet, the driver
will use GSO to segment the packet to workaround the hardware bug.

Thanks to Juergen Kreileder <jk@blackdown.de> for reporting the
problem and collecting traces to help debug the problem.

And thanks to Herbert Xu <herbert@gondor.apana.org.au> for providing
the GSO mechanism that happens to be the perfect workaround for this
problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2c36e70..63d4b2c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3880,6 +3880,40 @@ out_unlock:
 	return NETDEV_TX_OK;
 }
 
+#if TG3_TSO_SUPPORT != 0
+static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
+
+/* Use GSO to workaround a rare TSO bug that may be triggered when the
+ * TSO header is greater than 80 bytes.
+ */
+static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
+{
+	struct sk_buff *segs, *nskb;
+
+	/* Estimate the number of fragments in the worst case */
+	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
+		netif_stop_queue(tp->dev);
+		return NETDEV_TX_BUSY;
+	}
+
+	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
+	if (unlikely(IS_ERR(segs)))
+		goto tg3_tso_bug_end;
+
+	do {
+		nskb = segs;
+		segs = segs->next;
+		nskb->next = NULL;
+		tg3_start_xmit_dma_bug(nskb, tp->dev);
+	} while (segs);
+
+tg3_tso_bug_end:
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+#endif
+
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
  */
@@ -3916,7 +3950,7 @@ static int tg3_start_xmit_dma_bug(struct
 	mss = 0;
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
 	    (mss = skb_shinfo(skb)->gso_size) != 0) {
-		int tcp_opt_len, ip_tcp_len;
+		int tcp_opt_len, ip_tcp_len, hdr_len;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -3927,11 +3961,16 @@ static int tg3_start_xmit_dma_bug(struct
 		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
 		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 
+		hdr_len = ip_tcp_len + tcp_opt_len;
+		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
+			     (tp->tg3_flags2 & TG3_FLG2_HW_TSO_1_BUG))
+			return (tg3_tso_bug(tp, skb));
+
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
 		skb->nh.iph->check = 0;
-		skb->nh.iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
+		skb->nh.iph->tot_len = htons(mss + hdr_len);
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 			skb->h.th->check = 0;
 			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
@@ -10192,8 +10231,14 @@ static int __devinit tg3_get_invariants(
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
-		} else
-			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1;
+		} else {
+			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 |
+					  TG3_FLG2_HW_TSO_1_BUG;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
+				ASIC_REV_5750 &&
+	     		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
+				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_1_BUG;
+		}
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705 &&
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 97a8604..ba2c987 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -125,6 +125,7 @@
 #define  CHIPREV_ID_5750_A0		 0x4000
 #define  CHIPREV_ID_5750_A1		 0x4001
 #define  CHIPREV_ID_5750_A3		 0x4003
+#define  CHIPREV_ID_5750_C2		 0x4202
 #define  CHIPREV_ID_5752_A0_HW		 0x5000
 #define  CHIPREV_ID_5752_A0		 0x6000
 #define  CHIPREV_ID_5752_A1		 0x6001
@@ -2193,7 +2194,7 @@ struct tg3 {
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;
 #define TG3_FLG2_RESTART_TIMER		0x00000001
-/*					0x00000002 available */
+#define TG3_FLG2_HW_TSO_1_BUG		0x00000002
 #define TG3_FLG2_NO_ETH_WIRE_SPEED	0x00000004
 #define TG3_FLG2_IS_5788		0x00000008
 #define TG3_FLG2_MAX_RXPEND_64		0x00000010


