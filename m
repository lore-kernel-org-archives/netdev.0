From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 23:23:37 +0100
Message-ID: <1354919017.9124.33.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_223020_561049_DB965D43) <1354916502.9124.18.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_224129_500056_6617D80D) <1354918363.9124.29.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_231231_221604_E7B34625)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric@regit.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:58890 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971Ab2LGWXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 17:23:17 -0500
In-Reply-To: <1354918363.9124.29.camel@jlt4.sipsolutions.net> (sfid-20121207_231231_221604_E7B34625)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh I should say ... IP is like black magic to me ;-)

> -	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> +	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
>  		return skb;
>  
> -	iph = ip_hdr(skb);
> -	if (iph->ihl < 5 || iph->version != 4)
> +	if (iph.ihl < 5 || iph.version != 4)
>  		return skb;
> -	if (!pskb_may_pull(skb, iph->ihl*4))
> -		return skb;
> -	iph = ip_hdr(skb);
> -	len = ntohs(iph->tot_len);
> -	if (skb->len < len || len < (iph->ihl * 4))
> +
> +	len = ntohs(iph.tot_len);
> +	if (skb->len < len || len < (iph.ihl * 4))
>  		return skb;
>  
> -	if (ip_is_fragment(ip_hdr(skb))) {
> +	if (ip_is_fragment(&iph)) {
>  		skb = skb_share_check(skb, GFP_ATOMIC);
>  		if (skb) {
> +			if (!pskb_may_pull(skb, iph.ihl*4))
> +				return skb;

I moved this here but I have no idea what it does. Asking if we can pull
this here seems a bit pointless, and in the previous place it seemed
similarly pointless since we only use the static part of the IP header
and don't look at any options... So to me it seems this pskb_may_pull()
could just be removed, and that most likely means I'm messing with code
I don't understand :-)

johannes
