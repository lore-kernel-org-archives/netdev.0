From: Marcus Meissner <meissner@suse.de>
Subject: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 5 Jul 2004 13:09:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705110949.GA1092@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

This patch makes the files /proc/net/tcp and /proc/net/tcp6 not acquire
the readlock for every bucket.

On ppc64 and ia64 the readlocks are so expensive, that reading /proc/net/tcp
takes 0.25 seconds on a usual p670 LPAR.

And it locks 65536 buckets where just 20 chains are used at all in a normal
non-netserver setup.

Ciao, Marcus

Changelog:
	Readlock only non-empty hash chains to avoid 65536 readlocks.

	Signed-Off-By: Marcus Meissner <meissner@suse.de>

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tcp-proc-walk

--- linux-2.6.5/net/ipv4/tcp_ipv4.c.xx	2004-07-04 13:39:51.000000000 +0200
+++ linux-2.6.5/net/ipv4/tcp_ipv4.c	2004-07-04 13:51:57.000000000 +0200
@@ -2255,6 +2255,12 @@
 		struct hlist_node *node;
 		struct tcp_tw_bucket *tw;
 	       
+		/* Avoid taking the readlock cost if we know the chain is empty,
+		 * we have a lot of buckets.
+		 */
+		if (hlist_empty(&tcp_ehash[st->bucket].chain) &&
+		    hlist_empty(&tcp_ehash[st->bucket+tcp_ehash_size].chain))
+			continue;
 		read_lock(&tcp_ehash[st->bucket].lock);
 		sk_for_each(sk, node, &tcp_ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family) {
@@ -2301,13 +2307,17 @@
 		}
 		read_unlock(&tcp_ehash[st->bucket].lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
-		if (++st->bucket < tcp_ehash_size) {
-			read_lock(&tcp_ehash[st->bucket].lock);
-			sk = sk_head(&tcp_ehash[st->bucket].chain);
-		} else {
+
+		while ((++st->bucket < tcp_ehash_size) &&
+		       hlist_empty(&tcp_ehash[st->bucket].chain) &&
+		       hlist_empty(&tcp_ehash[st->bucket+tcp_ehash_size].chain))
+			/*empty*/;
+		if (st->bucket >= tcp_ehash_size) {
 			cur = NULL;
 			goto out;
 		}
+		read_lock(&tcp_ehash[st->bucket].lock);
+		sk = sk_head(&tcp_ehash[st->bucket].chain);
 	} else
 		sk = sk_next(sk);
 

--ew6BAiZeqk4r7MaW--
