From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Fri, 1 Sep 2006 17:05:57 +1000
Message-ID: <20060901070557.GA15731@gondor.apana.org.au>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63242 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751258AbWIAHGH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 03:06:07 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20060831151243.GJ3590@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2006 at 05:12:43PM +0200, cagri coltekin wrote:
> 
> It took a while to find equipment for test environment, but now I
> have a test environment that I can test.
> 
> Here is the result:
> 
> ---------------------------------------------------------------------------
> [17180051.768000] ip6_fragment: hlen = 0x818, len = 0x7ce, nexthdr=4

Thanks for the result.  It looks like something is screwed up with the
extension headers.  What version of bind are you using?

Please try the following patch instead to see if we can further isolate
the problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4fb47a2..e5ba216 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -508,6 +508,10 @@ static int ip6_fragment(struct sk_buff *
 	dev = rt->u.dst.dev;
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
+	if (unlikely(hlen > skb->len)) {
+		printk(KERN_CRIT "ip6_fragment: hlen = 0x%x, len = 0x%x, nexthdr = %d\n", hlen, skb->len, skb->nh.ipv6h->nexthdr);
+		BUG();
+	}
 
 	mtu = dst_mtu(&rt->u.dst);
 	if (np && np->frag_size < mtu) {
@@ -1204,6 +1208,8 @@ int ip6_push_pending_frames(struct sock 
 	struct flowi *fl = &inet->cork.fl;
 	unsigned char proto = fl->proto;
 	int err = 0;
+	u8 *prevhdr;
+	unsigned int hlen;
 
 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
@@ -1249,6 +1255,14 @@ int ip6_push_pending_frames(struct sock 
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
+
+	hlen = ip6_find_1stfragopt(skb, &prevhdr);
+	if (unlikely(hlen > skb->len)) {
+		printk(KERN_CRIT "ip6_push: hlen = 0x%x, len = 0x%x, nexthdr1 = %d, nexthdr2 = %d, proto = %d\n", hlen, skb->len, skb->nh.ipv6h->nexthdr, *prevhdr, proto);
+		printk(KERN_CRIT "ip6_push: opt = 0x%x, flen = %d, nflen = %d\n", (unsigned int)opt, opt ? opt->opt_flen : 0, opt ? opt->opt_nflen : 0);
+		BUG();
+	}
+
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
