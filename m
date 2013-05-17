From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: use ipv6_dup_options() from ip6_append_data()
Date: Thu, 16 May 2013 17:27:32 -0700
Message-ID: <1368750452.3301.74.camel@edumazet-glaptop>
References: <1368742990.3301.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40047 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226Ab3EQA1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 20:27:36 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp6so3020313pab.35
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 17:27:36 -0700 (PDT)
In-Reply-To: <1368742990.3301.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 15:23 -0700, Eric Dumazet wrote:
> Hi Herbert
> 
> Looking at the code added in commit 0178b695fd6b40a62a215cb
> ("ipv6: Copy cork options in ip6_append_data") it looks like we can have
> either a memleak or corruption (later in ip6_cork_release()) in case one
> of the sub-allocation (ip6_opt_dup()/ip6_rthdr_dup()) fails.
> 
> I would at least use a kzalloc() instead of kmalloc() in 
> 
> np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);
> 
> Or maybe better, reuse the code in  ipv6_dup_options() so that we
> perform a single memory allocation ?

Something like following maybe ?

[PATCH net-next] ipv6: use ipv6_dup_options() from ip6_append_data()

commit 0178b695fd6b4 ("ipv6: Copy cork options in ip6_append_data")
added some code duplication and bad error recovery, leading to potential
crash.

Allow ipv6_dup_options() to be called with a NULL socket argument
so that we can reuse it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Neal Cardwell <ncardwell@google.com>
---
Only compile-tested, I would appreciate a review from Herbert and/or
Hideaki

 net/ipv6/exthdrs.c    |    6 +++++-
 net/ipv6/ip6_output.c |   38 ++++----------------------------------
 2 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 07a7d65..905ec23 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -721,7 +721,11 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 {
 	struct ipv6_txoptions *opt2;
 
-	opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
+	if (sk)
+		opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
+	else
+		opt2 = kmalloc(opt->tot_len, GFP_ATOMIC);
+
 	if (opt2) {
 		long dif = (char *)opt2 - (char *)opt;
 		memcpy(opt2, opt, opt->tot_len);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d2eedf1..fd44b9c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1147,32 +1147,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			if (WARN_ON(np->cork.opt))
 				return -EINVAL;
 
-			np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);
-			if (unlikely(np->cork.opt == NULL))
-				return -ENOBUFS;
-
-			np->cork.opt->tot_len = opt->tot_len;
-			np->cork.opt->opt_flen = opt->opt_flen;
-			np->cork.opt->opt_nflen = opt->opt_nflen;
-
-			np->cork.opt->dst0opt = ip6_opt_dup(opt->dst0opt,
-							    sk->sk_allocation);
-			if (opt->dst0opt && !np->cork.opt->dst0opt)
-				return -ENOBUFS;
-
-			np->cork.opt->dst1opt = ip6_opt_dup(opt->dst1opt,
-							    sk->sk_allocation);
-			if (opt->dst1opt && !np->cork.opt->dst1opt)
-				return -ENOBUFS;
-
-			np->cork.opt->hopopt = ip6_opt_dup(opt->hopopt,
-							   sk->sk_allocation);
-			if (opt->hopopt && !np->cork.opt->hopopt)
-				return -ENOBUFS;
-
-			np->cork.opt->srcrt = ip6_rthdr_dup(opt->srcrt,
-							    sk->sk_allocation);
-			if (opt->srcrt && !np->cork.opt->srcrt)
+			np->cork.opt = ipv6_dup_options(NULL, opt);
+			if (unlikely(!np->cork.opt))
 				return -ENOBUFS;
 
 			/* need source address above miyazawa*/
@@ -1463,14 +1439,8 @@ EXPORT_SYMBOL_GPL(ip6_append_data);
 
 static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 {
-	if (np->cork.opt) {
-		kfree(np->cork.opt->dst0opt);
-		kfree(np->cork.opt->dst1opt);
-		kfree(np->cork.opt->hopopt);
-		kfree(np->cork.opt->srcrt);
-		kfree(np->cork.opt);
-		np->cork.opt = NULL;
-	}
+	kfree(np->cork.opt);
+	np->cork.opt = NULL;
 
 	if (inet->cork.base.dst) {
 		dst_release(inet->cork.base.dst);
