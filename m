From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] tiny af_packet.c cleanup
Date: Fri, 12 Sep 2003 22:50:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913055033.GB94744@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In both places af_packet.c calls sk_run_filter() it does a "filter =
sk->sk_filter" to store the pointer in a local variable.  However, it
never actually uses this variable for anything -- it always refers to
the filter as sk->sk_filter instead.  Clearly this wasn't intentional.

This patch fixes up both of those cases and cleans up the code a tiny bit.

Patch is versus 2.6.0-test5.

-Mitch

--- linux-2.6.0-test5-VIRGIN/net/packet/af_packet.c	2003-09-08 12:39:53.000000000 -0700
+++ linux-2.6.0-test5mnb1/net/packet/af_packet.c	2003-09-12 13:28:53.857179768 -0700
@@ -433,9 +433,9 @@
 		struct sk_filter *filter;
 
 		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
+		filter = sk->sk_filter;
+		if (likely(filter != NULL))	/* re-check under lock */
+			res = sk_run_filter(skb, filter->insns, filter->len);
 		bh_unlock_sock(sk);
 
 		if (res == 0)
@@ -537,9 +537,9 @@
 		struct sk_filter *filter;
 
 		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
+		filter = sk->sk_filter;
+		if (likely(filter != NULL))	/* re-check under lock */
+			res = sk_run_filter(skb, filter->insns, filter->len);
 		bh_unlock_sock(sk);
 
 		if (res == 0)
