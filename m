From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] (3/3) Convert PPPoE to new style protocol (redeux)
Date: Fri, 20 Jun 2003 17:32:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620173208.56a8a00c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, paulus@au.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Andi Kleen <ak@muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This a redo of Andi's patch to support new style protocol for PPPoE,
but without linearizing.  Basically, it pushes the pullup logic down into ppp_generic,
where needed and adds a length check in the receive path.  For the normal case of PPPoE
which is uncompressed, it should pass the non-linear socket buffer through to IP.
But for the compressed cases, the skbuff is effectively linearized.

Tested on 8-way SMP server with one client.
diff -urNp -X dontdiff linux-2.5-pppoe/drivers/net/ppp_generic.c pppoe-2.5/drivers/net/ppp_generic.c
--- linux-2.5-pppoe/drivers/net/ppp_generic.c	2003-06-20 16:53:43.000000000 -0700
+++ pppoe-2.5/drivers/net/ppp_generic.c	2003-06-20 16:54:51.000000000 -0700
@@ -1348,11 +1348,18 @@ ppp_input(struct ppp_channel *chan, stru
 	struct channel *pch = chan->ppp;
 	int proto;
 
-	if (pch == 0 || skb->len == 0) {
-		kfree_skb(skb);
-		return;
-	}
+	if (pch == 0)
+		goto drop;
 
+	/* need to have PPP header */
+	if (!pskb_may_pull(skb, 2)) {
+		if (pch->ppp) {
+			++pch->ppp->stats.rx_length_errors;
+			ppp_receive_error(pch->ppp);
+		}
+		goto drop;
+	}
+	
 	proto = PPP_PROTO(skb);
 	read_lock_bh(&pch->upl);
 	if (pch->ppp == 0 || proto >= 0xc000 || proto == PPP_CCPFRAG) {
@@ -1367,6 +1374,10 @@ ppp_input(struct ppp_channel *chan, stru
 		ppp_do_recv(pch->ppp, skb, pch);
 	}
 	read_unlock_bh(&pch->upl);
+	return;
+ drop:
+	kfree_skb(skb);
+	return;
 }
 
 /* Put a 0-length skb in the receive queue as an error indication */
@@ -1398,23 +1409,13 @@ ppp_input_error(struct ppp_channel *chan
 static void
 ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
-	if (skb->len >= 2) {
 #ifdef CONFIG_PPP_MULTILINK
-		/* XXX do channel-level decompression here */
-		if (PPP_PROTO(skb) == PPP_MP)
-			ppp_receive_mp_frame(ppp, skb, pch);
-		else
+	/* XXX do channel-level decompression here */
+	if (PPP_PROTO(skb) == PPP_MP)
+		ppp_receive_mp_frame(ppp, skb, pch);
+	else
 #endif /* CONFIG_PPP_MULTILINK */
-			ppp_receive_nonmp_frame(ppp, skb);
-		return;
-	}
-
-	if (skb->len > 0)
-		/* note: a 0-length skb is used as an error indication */
-		++ppp->stats.rx_length_errors;
-
-	kfree_skb(skb);
-	ppp_receive_error(ppp);
+		ppp_receive_nonmp_frame(ppp, skb);
 }
 
 static void
@@ -1446,7 +1447,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
 		/* decompress VJ compressed packets */
 		if (ppp->vj == 0 || (ppp->flags & SC_REJ_COMP_TCP))
 			goto err;
-		if (skb_tailroom(skb) < 124) {
+
+		if (skb_tailroom(skb) < 124 || skb_is_nonlinear(skb) ) {
 			/* copy to a new sk_buff with more tailroom */
 			ns = dev_alloc_skb(skb->len + 128);
 			if (ns == 0) {
@@ -1474,6 +1476,13 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
 	case PPP_VJC_UNCOMP:
 		if (ppp->vj == 0 || (ppp->flags & SC_REJ_COMP_TCP))
 			goto err;
+		
+		/* Until we fix the decompressor need to make sure
+		 * data portion is linear.
+		 */
+		if (!pskb_may_pull(skb, skb->len)) 
+			goto err;
+
 		if (slhc_remember(ppp->vj, skb->data + 2, skb->len - 2) <= 0) {
 			printk(KERN_ERR "PPP: VJ uncompressed error\n");
 			goto err;
@@ -1551,6 +1560,12 @@ ppp_decompress_frame(struct ppp *ppp, st
 	struct sk_buff *ns;
 	int len;
 
+	/* Until we fix all the decompressor's need to make sure
+	 * data portion is linear.
+	 */
+	if (!pskb_may_pull(skb, skb->len))
+		goto err;
+
 	if (proto == PPP_COMP) {
 		ns = dev_alloc_skb(ppp->mru + PPP_HDRLEN);
 		if (ns == 0) {
@@ -1603,7 +1618,7 @@ ppp_receive_mp_frame(struct ppp *ppp, st
 	struct list_head *l;
 	int mphdrlen = (ppp->flags & SC_MP_SHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
 
-	if (skb->len < mphdrlen + 1 || ppp->mrru == 0)
+	if (!pskb_may_pull(skb, mphdrlen + 1) || ppp->mrru == 0)
 		goto err;		/* no good, throw it away */
 
 	/* Decode sequence number and begin/end bits */
@@ -2021,7 +2036,7 @@ ppp_ccp_peek(struct ppp *ppp, struct sk_
 	unsigned char *dp = skb->data + 2;
 	int len;
 
-	if (skb->len < CCP_HDRLEN + 2
+	if (!pskb_may_pull(skb, CCP_HDRLEN + 2)
 	    || skb->len < (len = CCP_LENGTH(dp)) + 2)
 		return;		/* too short */
 
@@ -2056,6 +2071,10 @@ ppp_ccp_peek(struct ppp *ppp, struct sk_
 	case CCP_CONFACK:
 		if ((ppp->flags & (SC_CCP_OPEN | SC_CCP_UP)) != SC_CCP_OPEN)
 			break;
+
+		if (!pskb_may_pull(skb, len))
+			break;
+
 		dp += CCP_HDRLEN;
 		len -= CCP_HDRLEN;
 		if (len < CCP_OPT_MINLEN || len < CCP_OPT_LENGTH(dp))
diff -urNp -X dontdiff linux-2.5-pppoe/drivers/net/pppoe.c pppoe-2.5/drivers/net/pppoe.c
--- linux-2.5-pppoe/drivers/net/pppoe.c	2003-06-20 17:14:14.000000000 -0700
+++ pppoe-2.5/drivers/net/pppoe.c	2003-06-20 17:16:10.000000000 -0700
@@ -333,7 +333,11 @@ static int pppoe_rcv_core(struct sock *s
 	struct pppox_opt *relay_po = NULL;
 
 	if (sk->sk_state & PPPOX_BOUND) {
+		struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
+		int len = ntohs(ph->length);
 		skb_pull(skb, sizeof(struct pppoe_hdr));
+		skb_trim(skb, len);
+
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
 		relay_po = get_item_by_addr(&po->pppoe_relay);
@@ -371,17 +375,22 @@ static int pppoe_rcv(struct sk_buff *skb
 		     struct packet_type *pt)
 
 {
-	struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
+	struct pppoe_hdr *ph;
 	struct pppox_opt *po;
-	struct sock *sk ;
+	struct sock *sk;
 	int ret;
 
-	po = get_item((unsigned long) ph->sid, skb->mac.ethernet->h_source);
+	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
+		goto drop;
 
-	if (!po) {
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
+	if (!(skb = skb_share_check(skb, GFP_ATOMIC))) 
+		goto out;
+
+	ph = (struct pppoe_hdr *) skb->nh.raw;
+
+	po = get_item((unsigned long) ph->sid, skb->mac.ethernet->h_source);
+	if (!po) 
+		goto drop;
 
 	sk = po->sk;
 	bh_lock_sock(sk);
@@ -398,6 +407,10 @@ static int pppoe_rcv(struct sk_buff *skb
 	sock_put(sk);
 
 	return ret;
+drop:
+	kfree_skb(skb);
+out:
+	return NET_RX_DROP;
 }
 
 /************************************************************************
@@ -411,9 +424,16 @@ static int pppoe_disc_rcv(struct sk_buff
 			  struct packet_type *pt)
 
 {
-	struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
+	struct pppoe_hdr *ph;
 	struct pppox_opt *po;
 
+	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
+		goto abort;
+
+	if (!(skb = skb_share_check(skb, GFP_ATOMIC))) 
+		goto out;
+
+	ph = (struct pppoe_hdr *) skb->nh.raw;
 	if (ph->code != PADT_CODE)
 		goto abort;
 
@@ -441,17 +461,20 @@ static int pppoe_disc_rcv(struct sk_buff
 
 abort:
 	kfree_skb(skb);
+out:
 	return NET_RX_SUCCESS; /* Lies... :-) */
 }
 
 static struct packet_type pppoes_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
+	.data   = (void *)1,
 };
 
 static struct packet_type pppoed_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
+	.data   = (void *)1,
 };
 
 /***********************************************************************
