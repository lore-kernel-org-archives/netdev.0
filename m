From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] PPP handling fragmented skbuff's
Date: Fri, 27 Jun 2003 16:35:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627163524.347b2c8e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't think this ever happens today, but if PPP ever gets a fragmented a skbuff
and decides to copy it then bad things will happen.  The following replaces the
places that memcpy() with skb_copy_bits().

Please review carefully before applying, it builds and runs but can't really force
these code path to occur under normal systems and devices.

diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	Fri Jun 27 16:13:38 2003
+++ b/drivers/net/ppp_generic.c	Fri Jun 27 16:13:38 2003
@@ -844,7 +844,7 @@
 		if (ns == 0)
 			goto outf;
 		skb_reserve(ns, dev->hard_header_len);
-		memcpy(skb_put(ns, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(ns, skb->len), skb->len);
 		kfree_skb(skb);
 		skb = ns;
 	}
@@ -1455,7 +1455,7 @@
 				goto err;
 			}
 			skb_reserve(ns, 2);
-			memcpy(skb_put(ns, skb->len), skb->data, skb->len);
+			skb_copy_bits(skb, 0, skb_put(ns, skb->len), skb->len);
 			kfree_skb(skb);
 			skb = ns;
 		}
@@ -1826,7 +1826,7 @@
 		if (head != tail)
 			/* copy to a single skb */
 			for (p = head; p != tail->next; p = p->next)
-				memcpy(skb_put(skb, p->len), p->data, p->len);
+				skb_copy_bits(p, 0, skb_put(skb, p->len), p->len);
 		ppp->nextseq = tail->sequence + 1;
 		head = tail->next;
 	}
