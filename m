From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Mon, 15 Sep 2003 20:13:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916031355.GC7982@gaz.sfgoth.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com> <20030913080252.GE94744@gaz.sfgoth.com> <20030913110353.B23840@electric-eye.fr.zoreil.com> <20030913201559.GI94744@gaz.sfgoth.com> <20030914125549.A7790@electric-eye.fr.zoreil.com> <20030914112628.GD42531@gaz.sfgoth.com> <20030915155652.3e5e89a0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, romieu@fr.zoreil.com
Content-Disposition: inline
In-Reply-To: <20030915155652.3e5e89a0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> When you guys decide on a final patch let me know, the semantic
> parts of Mitchell's changes look perfectly fine to me.

How about something like the following.  It expands the comment but turns
that bit of code into an inline function so we onlt have to explain it
once.

Untested, but compiles fine.

-Mitch

--- linux-2.6.0-test5-VIRGIN/net/packet/af_packet.c	2003-09-08 12:39:53.000000000 -0700
+++ linux-2.6.0-test5mnb1/net/packet/af_packet.c	2003-09-15 10:56:26.313218168 -0700
@@ -381,6 +381,23 @@
 }
 #endif
 
+static inline unsigned run_filter(struct sk_buff *skb, struct sock *sk, unsigned res)
+{
+	struct sk_filter *filter;
+
+	bh_lock_sock(sk);
+	filter = sk->sk_filter;
+	/*
+	 * Our caller already checked that filter != NULL but we need to
+	 * verify that under bh_lock_sock() to be safe
+	 */
+	if (likely(filter != NULL))
+		res = sk_run_filter(skb, filter->insns, filter->len);
+	bh_unlock_sock(sk);
+
+	return res;
+}
+
 /*
    This function makes lazy skb cloning in hope that most of packets
    are discarded by BPF.
@@ -429,15 +446,7 @@
 	snaplen = skb->len;
 
 	if (sk->sk_filter) {
-		unsigned res = snaplen;
-		struct sk_filter *filter;
-
-		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
-		bh_unlock_sock(sk);
-
+		unsigned res = run_filter(skb, sk, snaplen);
 		if (res == 0)
 			goto drop_n_restore;
 		if (snaplen > res)
@@ -533,15 +542,7 @@
 	snaplen = skb->len;
 
 	if (sk->sk_filter) {
-		unsigned res = snaplen;
-		struct sk_filter *filter;
-
-		bh_lock_sock(sk);
-		if ((filter = sk->sk_filter) != NULL)
-			res = sk_run_filter(skb, sk->sk_filter->insns,
-					    sk->sk_filter->len);
-		bh_unlock_sock(sk);
-
+		unsigned res = run_filter(skb, sk, snaplen);
 		if (res == 0)
 			goto drop_n_restore;
 		if (snaplen > res)
