From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 2/4] X25: Move interrupt flag to bitfield
Date: Mon, 17 May 2010 19:00:02 +1000
Message-ID: <1274086802.4104.53.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:46380 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420Ab0EQJAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 05:00:07 -0400
Received: by mail-px0-f174.google.com with SMTP id 5so2420405pxi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 02:00:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the x25 interrupt flag from char into bitfield.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 include/net/x25.h |    3 ++-
 net/x25/af_x25.c  |    1 +
 net/x25/x25_in.c  |    2 +-
 net/x25/x25_out.c |    5 +++--
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 7b5795e..1576e92 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -115,6 +115,7 @@ enum {
 
 /* Bitset in x25_sock->flags for misc flags */
 #define X25_Q_BIT_FLAG		0
+#define X25_INTERRUPT_FLAG	1
 
 /**
  *	struct x25_route - x25 routing entry
@@ -149,7 +150,7 @@ struct x25_sock {
 	struct x25_address	source_addr, dest_addr;
 	struct x25_neigh	*neighbour;
 	unsigned int		lci, cudmatchlength;
-	unsigned char		state, condition, intflag, accptapprv;
+	unsigned char		state, condition, accptapprv;
 	unsigned short		vs, vr, va, vl;
 	unsigned long		t2, t21, t22, t23;
 	unsigned short		fraglen;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 720534c..3d97b8c 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -641,6 +641,7 @@ static struct sock *x25_make_new(struct sock *osk)
 	x25->cudmatchlength = ox25->cudmatchlength;
 	x25->accptapprv = ox25->accptapprv;
 
+	clear_bit(X25_INTERRUPT_FLAG, &x25->flags);
 	x25_init_timers(sk);
 out:
 	return sk;
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 372ac22..6317896 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -273,7 +273,7 @@ static int x25_state3_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			break;
 
 		case X25_INTERRUPT_CONFIRMATION:
-			x25->intflag = 0;
+			clear_bit(X25_INTERRUPT_FLAG, &x25->flags);
 			break;
 
 		case X25_INTERRUPT:
diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
index 52351a2..d00649f 100644
--- a/net/x25/x25_out.c
+++ b/net/x25/x25_out.c
@@ -148,8 +148,9 @@ void x25_kick(struct sock *sk)
 	/*
 	 *	Transmit interrupt data.
 	 */
-	if (!x25->intflag && skb_peek(&x25->interrupt_out_queue) != NULL) {
-		x25->intflag = 1;
+	if (skb_peek(&x25->interrupt_out_queue) != NULL &&
+		!test_and_set_bit(X25_INTERRUPT_FLAG, &x25->flags)) {
+
 		skb = skb_dequeue(&x25->interrupt_out_queue);
 		x25_transmit_link(skb, x25->neighbour);
 	}
-- 
1.5.6.5


