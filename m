From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET/ROM locking
Date: Wed, 2 Mar 2005 09:02:46 +0000
Message-ID: <20050302090246.GA6844@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix deadlock in NET/ROM due to double locking.

Index: bk-afu/net/netrom/nr_in.c
===================================================================
--- bk-afu.orig/net/netrom/nr_in.c	2005-02-05 22:16:25.553987776 +0000
+++ bk-afu/net/netrom/nr_in.c	2005-02-05 22:16:25.555987472 +0000
@@ -74,7 +74,6 @@
 static int nr_state1_machine(struct sock *sk, struct sk_buff *skb,
 	int frametype)
 {
-	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNACK: {
 		nr_cb *nr = nr_sk(sk);
@@ -103,8 +102,6 @@
 	default:
 		break;
 	}
-	bh_unlock_sock(sk);
-
 	return 0;
 }
 
@@ -116,7 +113,6 @@
 static int nr_state2_machine(struct sock *sk, struct sk_buff *skb,
 	int frametype)
 {
-	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNACK | NR_CHOKE_FLAG:
 		nr_disconnect(sk, ECONNRESET);
@@ -132,8 +128,6 @@
 	default:
 		break;
 	}
-	bh_unlock_sock(sk);
-
 	return 0;
 }
 
@@ -154,7 +148,6 @@
 	nr = skb->data[18];
 	ns = skb->data[17];
 
-	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNREQ:
 		nr_write_internal(sk, NR_CONNACK);
@@ -265,12 +258,10 @@
 	default:
 		break;
 	}
-	bh_unlock_sock(sk);
-
 	return queued;
 }
 
-/* Higher level upcall for a LAPB frame */
+/* Higher level upcall for a LAPB frame - called with sk locked */
 int nr_process_rx_frame(struct sock *sk, struct sk_buff *skb)
 {
 	nr_cb *nr = nr_sk(sk);
