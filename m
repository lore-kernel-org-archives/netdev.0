From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 4/4] rose check error on memcpy_fromiovec (resend)
Date: Fri, 16 Jan 2004 14:28:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116142821.V19023@osdlab.pdx.osdl.net>
References: <20040116142502.B19034@osdlab.pdx.osdl.net> <20040116142614.T19023@osdlab.pdx.osdl.net> <20040116142723.U19023@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040116142723.U19023@osdlab.pdx.osdl.net>; from chrisw@osdl.org on Fri, Jan 16, 2004 at 02:27:23PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the return value on memcpy_fromiovec().

 net/rose/af_rose.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

===== net/rose/af_rose.c 1.37 vs edited =====
--- 1.37/net/rose/af_rose.c	Fri Jan  9 01:56:39 2004
+++ edited/net/rose/af_rose.c	Fri Jan 16 14:15:17 2004
@@ -1083,7 +1083,11 @@
 
 	asmptr = skb->h.raw = skb_put(skb, len);
 
-	memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	err = memcpy_fromiovec(asmptr, msg->msg_iov, len);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
 
 	/*
 	 *	If the Q BIT Include socket option is in force, the first
@@ -1133,8 +1137,10 @@
 		frontlen = skb_headroom(skb);
 
 		while (skb->len > 0) {
-			if ((skbn = sock_alloc_send_skb(sk, frontlen + ROSE_PACLEN, 0, &err)) == NULL)
+			if ((skbn = sock_alloc_send_skb(sk, frontlen + ROSE_PACLEN, 0, &err)) == NULL) {
+				kfree_skb(skb);
 				return err;
+			}
 
 			skbn->sk   = sk;
 			skbn->free = 1;
@@ -1159,7 +1165,7 @@
 		}
 
 		skb->free = 1;
-		kfree_skb(skb, FREE_WRITE);
+		kfree_skb(skb);
 	} else {
 		skb_queue_tail(&sk->sk_write_queue, skb);		/* Throw it on the queue */
 	}
