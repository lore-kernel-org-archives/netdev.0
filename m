From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 3/4] X25: Move accept approve flag to bitfield
Date: Mon, 17 May 2010 19:00:27 +1000
Message-ID: <1274086827.4104.54.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:33810 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab0EQJAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 05:00:33 -0400
Received: by pwi5 with SMTP id 5so361792pwi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 02:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Moves the x25 accept approve flag from char into bitfield.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 include/net/x25.h |    5 ++---
 net/x25/af_x25.c  |   12 ++++++------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 1576e92..1479cb4 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -80,8 +80,6 @@ enum {
 #define	X25_DEFAULT_PACKET_SIZE	X25_PS128		/* Default Packet Size */
 #define	X25_DEFAULT_THROUGHPUT	0x0A			/* Deafult Throughput */
 #define	X25_DEFAULT_REVERSE	0x00			/* Default Reverse Charging */
-#define X25_DENY_ACCPT_APPRV   0x01			/* Default value */
-#define X25_ALLOW_ACCPT_APPRV  0x00			/* Control enabled */
 
 #define X25_SMODULUS 		8
 #define	X25_EMODULUS		128
@@ -116,6 +114,7 @@ enum {
 /* Bitset in x25_sock->flags for misc flags */
 #define X25_Q_BIT_FLAG		0
 #define X25_INTERRUPT_FLAG	1
+#define X25_ACCPT_APPRV_FLAG	2
 
 /**
  *	struct x25_route - x25 routing entry
@@ -150,7 +149,7 @@ struct x25_sock {
 	struct x25_address	source_addr, dest_addr;
 	struct x25_neigh	*neighbour;
 	unsigned int		lci, cudmatchlength;
-	unsigned char		state, condition, accptapprv;
+	unsigned char		state, condition;
 	unsigned short		vs, vr, va, vl;
 	unsigned long		t2, t21, t22, t23;
 	unsigned short		fraglen;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 3d97b8c..e5c1e32 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -586,7 +586,7 @@ static int x25_create(struct net *net, struct socket *sock, int protocol,
 	x25->t2    = sysctl_x25_ack_holdback_timeout;
 	x25->state = X25_STATE_0;
 	x25->cudmatchlength = 0;
-	x25->accptapprv = X25_DENY_ACCPT_APPRV;		/* normally no cud  */
+	set_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);	/* normally no cud  */
 							/* on call accept   */
 
 	x25->facilities.winsize_in  = X25_DEFAULT_WINDOW_SIZE;
@@ -639,7 +639,6 @@ static struct sock *x25_make_new(struct sock *osk)
 	x25->facilities = ox25->facilities;
 	x25->dte_facilities = ox25->dte_facilities;
 	x25->cudmatchlength = ox25->cudmatchlength;
-	x25->accptapprv = ox25->accptapprv;
 
 	clear_bit(X25_INTERRUPT_FLAG, &x25->flags);
 	x25_init_timers(sk);
@@ -1057,8 +1056,8 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	makex25->vc_facil_mask &= ~X25_MASK_CALLING_AE;
 	makex25->cudmatchlength = x25_sk(sk)->cudmatchlength;
 
-	/* Normally all calls are accepted immediatly */
-	if(makex25->accptapprv & X25_DENY_ACCPT_APPRV) {
+	/* Normally all calls are accepted immediately */
+	if (test_bit(X25_ACCPT_APPRV_FLAG, &makex25->flags)) {
 		x25_write_internal(make, X25_CALL_ACCEPTED);
 		makex25->state = X25_STATE_3;
 	}
@@ -1580,7 +1579,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -EINVAL;
 			if (sk->sk_state != TCP_CLOSE)
 				break;
-			x25->accptapprv = X25_ALLOW_ACCPT_APPRV;
+			clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
 			rc = 0;
 			break;
 		}
@@ -1589,7 +1588,8 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -EINVAL;
 			if (sk->sk_state != TCP_ESTABLISHED)
 				break;
-			if (x25->accptapprv)	/* must call accptapprv above */
+			/* must call accptapprv above */
+			if (test_bit(X25_ACCPT_APPRV_FLAG, &x25->flags))
 				break;
 			x25_write_internal(sk, X25_CALL_ACCEPTED);
 			x25->state = X25_STATE_3;
-- 
1.5.6.5


