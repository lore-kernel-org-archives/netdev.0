From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/4] X25: Move qbit flag to bitfield
Date: Mon, 17 May 2010 18:59:41 +1000
Message-ID: <1274086781.4104.52.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:46380 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521Ab0EQI7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 04:59:48 -0400
Received: by pxi5 with SMTP id 5so2420405pxi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 01:59:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the X25 q bit flag from char into a bitfield to allow BKL cleanup.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 include/net/x25.h |    6 +++++-
 net/x25/af_x25.c  |   17 ++++++++++-------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 468551e..7b5795e 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -113,6 +113,9 @@ enum {
 #define X25_MAX_AE_LEN 		40			/* Max num of semi-octets in AE - OSI Nw */
 #define X25_MAX_DTE_FACIL_LEN	21			/* Max length of DTE facility params */
 
+/* Bitset in x25_sock->flags for misc flags */
+#define X25_Q_BIT_FLAG		0
+
 /**
  *	struct x25_route - x25 routing entry
  *	@node - entry in x25_list_lock
@@ -146,10 +149,11 @@ struct x25_sock {
 	struct x25_address	source_addr, dest_addr;
 	struct x25_neigh	*neighbour;
 	unsigned int		lci, cudmatchlength;
-	unsigned char		state, condition, qbitincl, intflag, accptapprv;
+	unsigned char		state, condition, intflag, accptapprv;
 	unsigned short		vs, vr, va, vl;
 	unsigned long		t2, t21, t22, t23;
 	unsigned short		fraglen;
+	unsigned long		flags;
 	struct sk_buff_head	ack_queue;
 	struct sk_buff_head	fragment_queue;
 	struct sk_buff_head	interrupt_in_queue;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 296e65e..720534c 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -465,7 +465,10 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	if (get_user(opt, (int __user *)optval))
 		goto out;
 
-	x25_sk(sk)->qbitincl = !!opt;
+	if (opt)
+		set_bit(X25_Q_BIT_FLAG, &x25_sk(sk)->flags);
+	else
+		clear_bit(X25_Q_BIT_FLAG, &x25_sk(sk)->flags);
 	rc = 0;
 out:
 	unlock_kernel();
@@ -496,7 +499,7 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	if (put_user(len, optlen))
 		goto out;
 
-	val = x25_sk(sk)->qbitincl;
+	val = test_bit(X25_Q_BIT_FLAG, &x25_sk(sk)->flags);
 	rc = copy_to_user(optval, &val, len) ? -EFAULT : 0;
 out:
 	unlock_kernel();
@@ -632,8 +635,8 @@ static struct sock *x25_make_new(struct sock *osk)
 	x25->t22        = ox25->t22;
 	x25->t23        = ox25->t23;
 	x25->t2         = ox25->t2;
+	x25->flags	= ox25->flags;
 	x25->facilities = ox25->facilities;
-	x25->qbitincl   = ox25->qbitincl;
 	x25->dte_facilities = ox25->dte_facilities;
 	x25->cudmatchlength = ox25->cudmatchlength;
 	x25->accptapprv = ox25->accptapprv;
@@ -1186,7 +1189,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	 *	If the Q BIT Include socket option is in force, the first
 	 *	byte of the user data is the logical value of the Q Bit.
 	 */
-	if (x25->qbitincl) {
+	if (test_bit(X25_Q_BIT_FLAG, &x25->flags)) {
 		qbit = skb->data[0];
 		skb_pull(skb, 1);
 	}
@@ -1242,7 +1245,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 		len = rc;
 		if (rc < 0)
 			kfree_skb(skb);
-		else if (x25->qbitincl)
+		else if (test_bit(X25_Q_BIT_FLAG, &x25->flags))
 			len++;
 	}
 
@@ -1307,7 +1310,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		/*
 		 *	No Q bit information on Interrupt data.
 		 */
-		if (x25->qbitincl) {
+		if (test_bit(X25_Q_BIT_FLAG, &x25->flags)) {
 			asmptr  = skb_push(skb, 1);
 			*asmptr = 0x00;
 		}
@@ -1325,7 +1328,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		skb_pull(skb, x25->neighbour->extended ?
 				X25_EXT_MIN_LEN : X25_STD_MIN_LEN);
 
-		if (x25->qbitincl) {
+		if (test_bit(X25_Q_BIT_FLAG, &x25->flags)) {
 			asmptr  = skb_push(skb, 1);
 			*asmptr = qbit;
 		}
-- 
1.5.6.5


