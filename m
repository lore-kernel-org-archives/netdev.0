From: Ralf Baechle <ralf@linux-mips.org>
Subject: Off by one buglets
Date: Fri, 30 Jun 2006 15:29:01 +0100
Message-ID: <20060630142901.GA13898@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:63378 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932717AbWF3O3E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 10:29:04 -0400
Received: from localhost.localdomain ([127.0.0.1]:35531 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3686806AbWF3O3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 15:29:02 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ages ago, changeset

http://www.kernel.org/git/?p=linux/kernel/git/tglx/history.git;a=commit;h=22d864d542a0b92116751186f1794c7d0f1ca1b9

which converted several protocols from using open coded comparisons to
use the helper function sk_acceptq_is_full() did introduce a bunch of
off by one errors - sk_acceptq_is_full checks for
sk_ack_backlog > sk_max_ack_backlog but it replaced >= or == comparisons.

Below patch is really only meant to illustrate the change, not to be
applied.

  Ralf

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/atm/signaling.c     |    3 ++-
 net/ax25/ax25_in.c      |    2 +-
 net/decnet/dn_nsp_in.c  |    2 +-
 net/netrom/af_netrom.c  |    2 +-
 net/rose/af_rose.c      |    2 +-
 net/sctp/sm_statefuns.c |    2 +-
 net/x25/af_x25.c        |    2 +-
 7 files changed, 8 insertions(+), 7 deletions(-)

Index: linux-net/net/atm/signaling.c
===================================================================
--- linux-net.orig/net/atm/signaling.c	2006-06-29 17:11:33.000000000 +0100
+++ linux-net/net/atm/signaling.c	2006-06-30 15:11:53.000000000 +0100
@@ -132,7 +132,8 @@ static int sigd_send(struct atm_vcc *vcc
 			sk = sk_atm(vcc);
 			DPRINTK("as_indicate!!!\n");
 			lock_sock(sk);
-			if (sk_acceptq_is_full(sk)) {
+			if (vcc->sk->sk_ack_backlog ==
+			    vcc->sk->sk_max_ack_backlog) {
 				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
 				dev_kfree_skb(skb);
 				goto as_indicate_complete;
Index: linux-net/net/ax25/ax25_in.c
===================================================================
--- linux-net.orig/net/ax25/ax25_in.c	2006-06-29 17:11:33.000000000 +0100
+++ linux-net/net/ax25/ax25_in.c	2006-06-30 15:11:53.000000000 +0100
@@ -351,7 +351,7 @@ static int ax25_rcv(struct sk_buff *skb,
 
 	if (sk != NULL) {
 		bh_lock_sock(sk);
-		if (sk_acceptq_is_full(sk) ||
+		if (sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
 		    (make = ax25_make_new(sk, ax25_dev)) == NULL) {
 			if (mine)
 				ax25_return_dm(dev, &src, &dest, &dp);
Index: linux-net/net/decnet/dn_nsp_in.c
===================================================================
--- linux-net.orig/net/decnet/dn_nsp_in.c	2006-06-29 17:11:33.000000000 +0100
+++ linux-net/net/decnet/dn_nsp_in.c	2006-06-30 15:11:53.000000000 +0100
@@ -324,7 +324,7 @@ err_out:
 
 static void dn_nsp_conn_init(struct sock *sk, struct sk_buff *skb)
 {
-	if (sk_acceptq_is_full(sk)) {
+	if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
 		kfree_skb(skb);
 		return;
 	}
Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c	2006-06-30 14:46:42.000000000 +0100
+++ linux-net/net/netrom/af_netrom.c	2006-06-30 15:11:53.000000000 +0100
@@ -933,7 +933,7 @@ int nr_rx_frame(struct sk_buff *skb, str
 
 	user = (ax25_address *)(skb->data + 21);
 
-	if (sk == NULL || sk_acceptq_is_full(sk) ||
+	if (sk == NULL || sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
 	    (make = nr_make_new(sk)) == NULL) {
 		nr_transmit_refusal(skb, 0);
 		if (sk)
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c	2006-06-30 14:49:03.000000000 +0100
+++ linux-net/net/rose/af_rose.c	2006-06-30 15:11:53.000000000 +0100
@@ -948,7 +948,7 @@ int rose_rx_call_request(struct sk_buff 
 	/*
 	 * We can't accept the Call Request.
 	 */
-	if (sk == NULL || sk_acceptq_is_full(sk) ||
+	if (sk == NULL || sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
 	    (make = rose_make_new(sk)) == NULL) {
 		rose_transmit_clear_request(neigh, lci, ROSE_NETWORK_CONGESTION, 120);
 		return 0;
Index: linux-net/net/sctp/sm_statefuns.c
===================================================================
--- linux-net.orig/net/sctp/sm_statefuns.c	2006-06-29 17:11:33.000000000 +0100
+++ linux-net/net/sctp/sm_statefuns.c	2006-06-30 15:11:53.000000000 +0100
@@ -282,7 +282,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 	 */
 	if (!sctp_sstate(sk, LISTENING) ||
 	    (sctp_style(sk, TCP) &&
-	     sk_acceptq_is_full(sk)))
+	     (sk->sk_ack_backlog >= sk->sk_max_ack_backlog)))
 		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
 
 	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
Index: linux-net/net/x25/af_x25.c
===================================================================
--- linux-net.orig/net/x25/af_x25.c	2006-06-29 17:11:33.000000000 +0100
+++ linux-net/net/x25/af_x25.c	2006-06-30 15:11:53.000000000 +0100
@@ -879,7 +879,7 @@ int x25_rx_call_request(struct sk_buff *
 	/*
 	 *	We can't accept the Call Request.
 	 */
-	if (sk == NULL || sk_acceptq_is_full(sk))
+	if (sk == NULL || sk->sk_ack_backlog == sk->sk_max_ack_backlog)
 		goto out_clear_request;
 
 	/*
