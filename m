From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
Date: Mon, 30 Sep 2013 23:21:55 +0200
Message-ID: <20130930212155.GG10771@order.stressinduktion.org>
References: <1380549038-6291-1-git-send-email-jiri@resnulli.us> <20130930175640.GF10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32796 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917Ab3I3VV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 17:21:56 -0400
Content-Disposition: inline
In-Reply-To: <20130930175640.GF10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 30, 2013 at 07:56:40PM +0200, Hannes Frederic Sowa wrote:
> Hmm, I wonder if we need the same change in ipv6/raw.c.

Nope, ipv6/raw.c is fine.

> Looks good at first sight, but I need to do some more tests.

Strange, loopback traffic is not bound by the frag_size. This fixes it but
should not be necessary. Don't know the reason, yet.

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a54c45c..9dd136e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -124,7 +124,14 @@ static int ip6_finish_output2(struct sk_buff *skb)
 
 static int ip6_finish_output(struct sk_buff *skb)
 {
-	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
+	int mtu;
+	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+
+	mtu = ip6_skb_dst_mtu(skb);
+	if (np && np->frag_size && np->frag_size < mtu)
+		mtu = np->frag_size;
+
+	if ((skb->len > mtu && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)))
 		return ip6_fragment(skb, ip6_finish_output2);
 	else


Regarding your patch, this is fine by me:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
