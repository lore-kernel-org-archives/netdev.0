From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] Fix ax25_get_socket locking
Date: Mon, 14 Mar 2005 08:37:44 +0000
Message-ID: <20050314083744.GA12765@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In an attempt to return a locked socket ax25_get_socket() was calling
lock_sock() with a spinlock held, bad idea.  Making matters worse it's
only user is running in bottom half context resulting in a potencial
attempt to sleep in bottom half context, so fix the locking there as well.

Index: bk-afu/net/ax25/ax25_in.c
===================================================================
--- bk-afu.orig/net/ax25/ax25_in.c	2005-03-14 00:20:42.153164936 +0000
+++ bk-afu/net/ax25/ax25_in.c	2005-03-14 00:21:07.469316296 +0000
@@ -275,6 +275,7 @@
 			/* Now find a suitable dgram socket */
 			sk = ax25_get_socket(&dest, &src, SOCK_DGRAM);
 			if (sk != NULL) {
+				bh_lock_sock(sk);
 				if (atomic_read(&sk->sk_rmem_alloc) >=
 				    sk->sk_rcvbuf) {
 					kfree_skb(skb);
@@ -286,7 +287,8 @@
 					if (sock_queue_rcv_skb(sk, skb) != 0)
 						kfree_skb(skb);
 				}
-				release_sock(sk);
+				bh_unlock_sock(sk);
+				sock_put(sk);
 			} else {
 				kfree_skb(skb);
 			}
Index: bk-afu/net/ax25/af_ax25.c
===================================================================
--- bk-afu.orig/net/ax25/af_ax25.c	2005-03-14 00:21:03.757880520 +0000
+++ bk-afu/net/ax25/af_ax25.c	2005-03-14 00:21:07.471315992 +0000
@@ -180,8 +180,7 @@
 		    !ax25cmp(&s->dest_addr, dest_addr) &&
 		    s->sk->sk_type == type) {
 			sk = s->sk;
-			/* XXX Sleeps with spinlock held, use refcounts instead. XXX */
-			lock_sock(sk);
+			sock_hold(sk);
 			break;
 		}
 	}
