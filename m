From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 6 Feb 2009 00:01:49 +1100
Message-ID: <20090205130149.GA28152@gondor.apana.org.au>
References: <20090126.213112.197185044.davem@davemloft.net> <20090127075356.GA6255@alice> <20090128093507.GA15956@gondor.apana.org.au> <20090129.174954.263448549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: snakebyte@gmx.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38168 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754691AbZBENB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 08:01:59 -0500
Content-Disposition: inline
In-Reply-To: <20090129.174954.263448549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2009 at 05:49:54PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 28 Jan 2009 20:35:07 +1100
> 
> > Any volunteers to fix this?
> 
> I'll try to take a stab at it later tonight.

I took a stab at it.

ipv6: Copy cork options in ip6_append_data

As the options passed to ip6_append_data may be ephemeral, we need
to duplicate it for corking.  This patch applies the simplest fix
which is to memdup all the relevant bits.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4b15938..9fb49c3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1105,6 +1105,18 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	return err;
 }
 
+static inline struct ipv6_opt_hdr *ip6_opt_dup(struct ipv6_opt_hdr *src,
+					       gfp_t gfp)
+{
+	return src ? kmemdup(src, (src->hdrlen + 1) * 8, gfp) : NULL;
+}
+
+static inline struct ipv6_rt_hdr *ip6_rthdr_dup(struct ipv6_rt_hdr *src,
+						gfp_t gfp)
+{
+	return src ? kmemdup(src, (src->hdrlen + 1) * 8, gfp) : NULL;
+}
+
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
@@ -1130,17 +1142,37 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		 * setup for corking
 		 */
 		if (opt) {
-			if (np->cork.opt == NULL) {
-				np->cork.opt = kmalloc(opt->tot_len,
-						       sk->sk_allocation);
-				if (unlikely(np->cork.opt == NULL))
-					return -ENOBUFS;
-			} else if (np->cork.opt->tot_len < opt->tot_len) {
-				printk(KERN_DEBUG "ip6_append_data: invalid option length\n");
+			if (WARN_ON(np->cork.opt))
 				return -EINVAL;
-			}
-			memcpy(np->cork.opt, opt, opt->tot_len);
-			inet->cork.flags |= IPCORK_OPT;
+
+			np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);
+			if (unlikely(np->cork.opt == NULL))
+				return -ENOBUFS;
+
+			np->cork.opt->tot_len = opt->tot_len;
+			np->cork.opt->opt_flen = opt->opt_flen;
+			np->cork.opt->opt_nflen = opt->opt_nflen;
+
+			np->cork.opt->dst0opt = ip6_opt_dup(opt->dst0opt,
+							    sk->sk_allocation);
+			if (opt->dst0opt && !np->cork.opt->dst0opt)
+				return -ENOBUFS;
+
+			np->cork.opt->dst1opt = ip6_opt_dup(opt->dst1opt,
+							    sk->sk_allocation);
+			if (opt->dst1opt && !np->cork.opt->dst1opt)
+				return -ENOBUFS;
+
+			np->cork.opt->hopopt = ip6_opt_dup(opt->hopopt,
+							   sk->sk_allocation);
+			if (opt->hopopt && !np->cork.opt->hopopt)
+				return -ENOBUFS;
+
+			np->cork.opt->srcrt = ip6_rthdr_dup(opt->srcrt,
+							    sk->sk_allocation);
+			if (opt->srcrt && !np->cork.opt->srcrt)
+				return -ENOBUFS;
+
 			/* need source address above miyazawa*/
 		}
 		dst_hold(&rt->u.dst);
@@ -1167,8 +1199,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	} else {
 		rt = (struct rt6_info *)inet->cork.dst;
 		fl = &inet->cork.fl;
-		if (inet->cork.flags & IPCORK_OPT)
-			opt = np->cork.opt;
+		opt = np->cork.opt;
 		transhdrlen = 0;
 		exthdrlen = 0;
 		mtu = inet->cork.fragsize;
@@ -1407,9 +1438,15 @@ error:
 
 static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 {
-	inet->cork.flags &= ~IPCORK_OPT;
-	kfree(np->cork.opt);
-	np->cork.opt = NULL;
+	if (np->cork.opt) {
+		kfree(np->cork.opt->dst0opt);
+		kfree(np->cork.opt->dst1opt);
+		kfree(np->cork.opt->hopopt);
+		kfree(np->cork.opt->srcrt);
+		kfree(np->cork.opt);
+		np->cork.opt = NULL;
+	}
+
 	if (inet->cork.dst) {
 		dst_release(inet->cork.dst);
 		inet->cork.dst = NULL;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
