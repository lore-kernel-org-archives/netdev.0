From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Mon, 25 Sep 2006 22:15:30 +1000
Message-ID: <20060925121530.GC18667@gondor.apana.org.au>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35595 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750951AbWIYMPz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 08:15:55 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20060901162248.GI19284@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 06:22:48PM +0200, cagri coltekin wrote:
>
> The second causes the system to give the bug a couple of seconds
> after bind starts, and loads the zones, without any traffic going
> on. BTW, patch applied with some offset difference (3 for the
> first -48 for the other two changes), on a pristine 2.6.17.11
> source tree.

Well the good news is that I found a bug with MSG_PROBE that can
cause exactly what you're seeing.  The bad news is that bind doesn't
use MSG_PROBE :)

So please try this patch to narrow the problem down further.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6671691..637b5c4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -990,8 +990,10 @@ int ip6_append_data(struct sock *sk, int
 	int offset = 0;
 	int csummode = CHECKSUM_NONE;
 
-	if (flags&MSG_PROBE)
+	if (flags&MSG_PROBE) {
+		WARN_ON(1);
 		return 0;
+	}
 	if (skb_queue_empty(&sk->sk_write_queue)) {
 		/*
 		 * setup for corking
@@ -1013,6 +1015,7 @@ int ip6_append_data(struct sock *sk, int
 		dst_hold(&rt->u.dst);
 		np->cork.rt = rt;
 		inet->cork.fl = *fl;
+		BUG_ON(!fl->proto);
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
 		mtu = dst_mtu(rt->u.dst.path);
@@ -1032,6 +1035,7 @@ int ip6_append_data(struct sock *sk, int
 	} else {
 		rt = np->cork.rt;
 		fl = &inet->cork.fl;
+		BUG_ON(!fl->proto);
 		if (inet->cork.flags & IPCORK_OPT)
 			opt = np->cork.opt;
 		transhdrlen = 0;
@@ -1285,6 +1289,7 @@ int ip6_push_pending_frames(struct sock 
 
 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
+	BUG_ON(!proto);
 	tail_skb = &(skb_shinfo(skb)->frag_list);
 
 	/* move skb->data to ip header from ext header */
