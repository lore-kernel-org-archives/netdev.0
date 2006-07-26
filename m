From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Wed, 26 Jul 2006 12:26:02 +1000
Message-ID: <E1G5Z62-00083O-00@gondolin.me.apana.org.au>
References: <20060725211725.GA24366@ms2.inr.ac.ru>
Cc: shemminger@osdl.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:31240 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030365AbWGZC0u
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 22:26:50 -0400
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
In-Reply-To: <20060725211725.GA24366@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> I think you mean this.
> 
> Note, it is real skb_clone(), not alloc_skb(). Equeued skb contains
> the whole half-prepared netlink message plus room for the rest.
> It could be also skb_copy(), if we want to be puristic about mangling
> cloned data, but original copy is really not going to be used.  

I like this.  However, since the cloned skb is either discarded in case
of error, or queued in which case the caller discards its reference right
away, wouldn't it be simpler to just do this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ba33f86..0a2af08 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1593,6 +1593,7 @@ int ipmr_get_route(struct sk_buff *skb, 
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
+		skb_get(skb);
 		skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 		skb->nh.iph->ihl = sizeof(struct iphdr)>>2;
 		skb->nh.iph->saddr = rt->rt_src;
