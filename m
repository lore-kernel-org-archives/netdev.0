From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] ppp_generic: use stats from net_device structure
Date: Wed, 23 Apr 2008 18:46:51 +0300
Message-ID: <funllk$30g$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000706000208070700090803"
Cc: linux-ppp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42921 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023AbYDWPrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 11:47:12 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JohBe-0007Nl-AL
	for netdev@vger.kernel.org; Wed, 23 Apr 2008 15:47:10 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 15:47:10 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 15:47:10 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000706000208070700090803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use stats which now is in the net_device instead of one declared in
ppp structure.
Kill ppp_net_stats function, because by default it is used identical
internal_stats function from net/core/dev.c

Signed-of-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------000706000208070700090803
Content-Type: text/x-patch;
 name="ppp_stats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ppp_stats.patch"

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 4dc5b4b..d3207c0 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -123,7 +123,6 @@ struct ppp {
 	u32		minseq;		/* MP: min of most recent seqnos */
 	struct sk_buff_head mrq;	/* MP: receive reconstruction queue */
 #endif /* CONFIG_PPP_MULTILINK */
-	struct net_device_stats stats;	/* statistics */
 #ifdef CONFIG_PPP_FILTER
 	struct sock_filter *pass_filter;	/* filter for packets to pass */
 	struct sock_filter *active_filter;/* filter for pkts to reset idle */
@@ -914,18 +913,10 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
  outf:
 	kfree_skb(skb);
-	++ppp->stats.tx_dropped;
+	++ppp->dev->stats.tx_dropped;
 	return 0;
 }
 
-static struct net_device_stats *
-ppp_net_stats(struct net_device *dev)
-{
-	struct ppp *ppp = (struct ppp *) dev->priv;
-
-	return &ppp->stats;
-}
-
 static int
 ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -1095,8 +1086,8 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 #endif /* CONFIG_PPP_FILTER */
 	}
 
-	++ppp->stats.tx_packets;
-	ppp->stats.tx_bytes += skb->len - 2;
+	++ppp->dev->stats.tx_packets;
+	ppp->dev->stats.tx_bytes += skb->len - 2;
 
 	switch (proto) {
 	case PPP_IP:
@@ -1171,7 +1162,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
  drop:
 	if (skb)
 		kfree_skb(skb);
-	++ppp->stats.tx_errors;
+	++ppp->dev->stats.tx_errors;
 }
 
 /*
@@ -1409,7 +1400,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 	spin_unlock_bh(&pch->downl);
 	if (ppp->debug & 1)
 		printk(KERN_ERR "PPP: no memory (fragment)\n");
-	++ppp->stats.tx_errors;
+	++ppp->dev->stats.tx_errors;
 	++ppp->nxseq;
 	return 1;	/* abandon the frame */
 }
@@ -1538,7 +1529,7 @@ ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 
 	if (skb->len > 0)
 		/* note: a 0-length skb is used as an error indication */
-		++ppp->stats.rx_length_errors;
+		++ppp->dev->stats.rx_length_errors;
 
 	kfree_skb(skb);
 	ppp_receive_error(ppp);
@@ -1547,7 +1538,7 @@ ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 static void
 ppp_receive_error(struct ppp *ppp)
 {
-	++ppp->stats.rx_errors;
+	++ppp->dev->stats.rx_errors;
 	if (ppp->vj)
 		slhc_toss(ppp->vj);
 }
@@ -1627,8 +1618,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		break;
 	}
 
-	++ppp->stats.rx_packets;
-	ppp->stats.rx_bytes += skb->len - 2;
+	++ppp->dev->stats.rx_packets;
+	ppp->dev->stats.rx_bytes += skb->len - 2;
 
 	npi = proto_to_npindex(proto);
 	if (npi < 0) {
@@ -1806,7 +1797,7 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 	 */
 	if (seq_before(seq, ppp->nextseq)) {
 		kfree_skb(skb);
-		++ppp->stats.rx_dropped;
+		++ppp->dev->stats.rx_dropped;
 		ppp_receive_error(ppp);
 		return;
 	}
@@ -1928,7 +1919,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		/* Got a complete packet yet? */
 		if (lost == 0 && (p->BEbits & E) && (head->BEbits & B)) {
 			if (len > ppp->mrru + 2) {
-				++ppp->stats.rx_length_errors;
+				++ppp->dev->stats.rx_length_errors;
 				printk(KERN_DEBUG "PPP: reconstructed packet"
 				       " is too long (%d)\n", len);
 			} else if (p == head) {
@@ -1937,7 +1928,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 				skb = skb_get(p);
 				break;
 			} else if ((skb = dev_alloc_skb(len)) == NULL) {
-				++ppp->stats.rx_missed_errors;
+				++ppp->dev->stats.rx_missed_errors;
 				printk(KERN_DEBUG "PPP: no memory for "
 				       "reconstructed packet");
 			} else {
@@ -1966,7 +1957,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			if (ppp->debug & 1)
 				printk(KERN_DEBUG "  missed pkts %u..%u\n",
 				       ppp->nextseq, head->sequence-1);
-			++ppp->stats.rx_dropped;
+			++ppp->dev->stats.rx_dropped;
 			ppp_receive_error(ppp);
 		}
 
@@ -2377,12 +2368,12 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
 	struct slcompress *vj = ppp->vj;
 
 	memset(st, 0, sizeof(*st));
-	st->p.ppp_ipackets = ppp->stats.rx_packets;
-	st->p.ppp_ierrors = ppp->stats.rx_errors;
-	st->p.ppp_ibytes = ppp->stats.rx_bytes;
-	st->p.ppp_opackets = ppp->stats.tx_packets;
-	st->p.ppp_oerrors = ppp->stats.tx_errors;
-	st->p.ppp_obytes = ppp->stats.tx_bytes;
+	st->p.ppp_ipackets = ppp->dev->stats.rx_packets;
+	st->p.ppp_ierrors = ppp->dev->stats.rx_errors;
+	st->p.ppp_ibytes = ppp->dev->stats.rx_bytes;
+	st->p.ppp_opackets = ppp->dev->stats.tx_packets;
+	st->p.ppp_oerrors = ppp->dev->stats.tx_errors;
+	st->p.ppp_obytes = ppp->dev->stats.tx_bytes;
 	if (!vj)
 		return;
 	st->vj.vjs_packets = vj->sls_o_compressed + vj->sls_o_uncompressed;
@@ -2436,7 +2427,6 @@ ppp_create_interface(int unit, int *retp)
 	dev->priv = ppp;
 
 	dev->hard_start_xmit = ppp_start_xmit;
-	dev->get_stats = ppp_net_stats;
 	dev->do_ioctl = ppp_net_ioctl;
 
 	ret = -EEXIST;

--------------000706000208070700090803--

