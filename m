From: Thomas Graf <tgraf@suug.ch>
Subject: [NET] atm: Fix build errors after conversion to pr_debug()
Date: Mon, 27 Aug 2007 10:05:37 +0200
Message-ID: <20070827080536.GC894@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43911 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbXH0IFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 04:05:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes ancient ATM debug code to at least compile again.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/atm/signaling.c
===================================================================
--- net-2.6.24.orig/net/atm/signaling.c	2007-08-27 09:53:40.000000000 +0200
+++ net-2.6.24/net/atm/signaling.c	2007-08-27 09:55:16.000000000 +0200
@@ -89,9 +89,9 @@ static int sigd_send(struct atm_vcc *vcc
 
 	msg = (struct atmsvc_msg *) skb->data;
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
-	pr_debug("sigd_send %d (0x%lx)\n",(int) msg->type,
-	  (unsigned long) msg->vcc);
 	vcc = *(struct atm_vcc **) &msg->vcc;
+	pr_debug("sigd_send %d (0x%lx)\n",(int) msg->type,
+	  (unsigned long) vcc);
 	sk = sk_atm(vcc);
 
 	switch (msg->type) {
Index: net-2.6.24/net/atm/common.c
===================================================================
--- net-2.6.24.orig/net/atm/common.c	2007-08-27 09:56:06.000000000 +0200
+++ net-2.6.24/net/atm/common.c	2007-08-27 09:56:16.000000000 +0200
@@ -497,7 +497,7 @@ int vcc_recvmsg(struct kiocb *iocb, stru
 	if (error)
 		return error;
 	sock_recv_timestamp(msg, sk, skb);
-	pr_debug("RcvM %d -= %d\n", atomic_read(&sk->rmem_alloc), skb->truesize);
+	pr_debug("RcvM %d -= %d\n", atomic_read(&sk->sk_rmem_alloc), skb->truesize);
 	atm_return(vcc, skb->truesize);
 	skb_free_datagram(sk, skb);
 	return copied;
Index: net-2.6.24/net/atm/raw.c
===================================================================
--- net-2.6.24.orig/net/atm/raw.c	2007-08-27 09:57:56.000000000 +0200
+++ net-2.6.24/net/atm/raw.c	2007-08-27 09:58:09.000000000 +0200
@@ -32,8 +32,8 @@ static void atm_pop_raw(struct atm_vcc *
 {
 	struct sock *sk = sk_atm(vcc);
 
-	pr_debug("APopR (%d) %d -= %d\n", vcc->vci, sk->sk_wmem_alloc,
-		skb->truesize);
+	pr_debug("APopR (%d) %d -= %d\n", vcc->vci,
+		atomic_read(&sk->sk_wmem_alloc), skb->truesize);
 	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
 	sk->sk_write_space(sk);
Index: net-2.6.24/net/atm/pppoatm.c
===================================================================
--- net-2.6.24.orig/net/atm/pppoatm.c	2007-08-27 10:01:34.000000000 +0200
+++ net-2.6.24/net/atm/pppoatm.c	2007-08-27 10:02:05.000000000 +0200
@@ -165,9 +165,8 @@ static void pppoatm_push(struct atm_vcc 
 			pvcc->chan.mtu += LLC_LEN;
 			break;
 		}
-		pr_debug("(unit %d): Couldn't autodetect yet "
+		pr_debug("Couldn't autodetect yet "
 		    "(skb: %02X %02X %02X %02X %02X %02X)\n",
-		    pvcc->chan.unit,
 		    skb->data[0], skb->data[1], skb->data[2],
 		    skb->data[3], skb->data[4], skb->data[5]);
 		goto error;
@@ -195,8 +194,7 @@ static int pppoatm_send(struct ppp_chann
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
-	pr_debug("(unit %d): pppoatm_send (skb=0x%p, vcc=0x%p)\n",
-	    pvcc->chan.unit, skb, pvcc->atmvcc);
+	pr_debug("pppoatm_send (skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
 		(void) skb_pull(skb, 1);
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
@@ -221,16 +219,14 @@ static int pppoatm_send(struct ppp_chann
 			goto nospace;
 		break;
 	case e_autodetect:
-		pr_debug("(unit %d): Trying to send without setting encaps!\n",
-		    pvcc->chan.unit);
+		pr_debug("Trying to send without setting encaps!\n");
 		kfree_skb(skb);
 		return 1;
 	}
 
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
-	pr_debug("(unit %d): atm_skb(%p)->vcc(%p)->dev(%p)\n",
-	    pvcc->chan.unit, skb, ATM_SKB(skb)->vcc,
+	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, ATM_SKB(skb)->vcc,
 	    ATM_SKB(skb)->vcc->dev);
 	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
 	    ? DROP_PACKET : 1;
