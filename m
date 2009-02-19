From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec and netfilter
Date: Thu, 19 Feb 2009 20:57:25 +0800
Message-ID: <20090219125725.GA10821@gondor.apana.org.au>
References: <alpine.LRH.2.00.0902101138380.21337@q7.q7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Pruett <joey@clean.q7.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46262 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758904AbZBSM5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 07:57:33 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.0902101138380.21337@q7.q7.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Pruett <joey@clean.q7.com> wrote:
>
> why aren't esp/ah packets run through netfilter again after 
> decryption/decapsulation?  in tunnel mode, packets do get sent in again, 
> but that is only because ip-ip does that, not the ipsec code.

They do go through netfilter again after decap in transport mode:

int xfrm4_transport_finish(struct sk_buff *skb, int async)
{
	struct iphdr *iph = ip_hdr(skb);

	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;

#ifndef CONFIG_NETFILTER
	if (!async)
		return -iph->protocol;
#endif

	__skb_push(skb, skb->data - skb_network_header(skb));
	iph->tot_len = htons(skb->len);
	ip_send_check(iph);

	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
		xfrm4_rcv_encap_finish);
	return 0;
}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
