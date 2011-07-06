From: =?iso-8859-1?Q?Penttil=E4_Mika?= <mika.penttila@ixonos.com>
Subject: FW: Re: [PATCH v3 4/4] packet: Add pre-defragmentation support for
 ipv4
Date: Wed, 6 Jul 2011 14:06:15 +0000
Message-ID: <1A61D8EA6755AF458F06EA669A4EC8182F05BCB0@JKLMAIL02.ixonos.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:56185
	"EHLO VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab1GFOGs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 10:06:48 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> +static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
> +{
> +	const struct iphdr *iph;
> +	u32 len;
> +
> +	if (skb->protocol != htons(ETH_P_IP))
> +		return skb;
> +
> +	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> +		return skb;
> +
> +	iph = ip_hdr(skb);
> +	if (iph->ihl < 5 || iph->version != 4)
> +		return skb;
> +	if (!pskb_may_pull(skb, iph->ihl*4))
> +		return skb;
> +	iph = ip_hdr(skb);
> +	len = ntohs(iph->tot_len);
> +	if (skb->len < len || len < (iph->ihl * 4))
> +		return skb;
> +
> +	if (ip_is_fragment(ip_hdr(skb))) {
> +		skb = skb_clone(skb, GFP_ATOMIC);

Isn't this leaking the original skb?

> +		if (skb) {
> +			if (pskb_trim_rcsum(skb, len))
> +				return skb;
> +			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +			if (ip_defrag(skb, IP_DEFRAG_AF_PACKET))
> +				return NULL;
> +			skb->rxhash = 0;
> +		}
> +	}
> +	return skb;
> +}

-Mika


