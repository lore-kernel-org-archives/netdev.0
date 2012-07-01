From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] Add support for IPv6 and bounds checking to
 transmit hashing functions.
Date: Sun, 01 Jul 2012 00:33:36 -0700 (PDT)
Message-ID: <20120701.003336.2064499848873338094.davem@davemloft.net>
References: <cover.1341125875.git.linux@8192.net>
	<cover.1341125875.git.linux@8192.net>
	<9814878c9da75aaadfd70e0ea45b29c3ee8869a0.1341125875.git.linux@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab2GAHdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:33:37 -0400
In-Reply-To: <9814878c9da75aaadfd70e0ea45b29c3ee8869a0.1341125875.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>
Date: Sun,  1 Jul 2012 00:01:38 -0700

> -	if (skb->protocol == htons(ETH_P_IP)) {
> +	if (skb->protocol == htons(ETH_P_IP) &&
> +		skb_network_header_len(skb) >= sizeof(struct iphdr)) {

This is not indented properly, the goal isn't to use only TAB
characters to indent, the goal it to line things up right after
the openning parenthesis on the previous line, so this should
be:

	if (skb->protocol == htons(ETH_P_IP) &&
	    skb_network_header_len(skb) >= sizeof(struct iphdr)) {

> +	} else if (skb->protocol == htons(ETH_P_IPV6) &&
> +		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {

Likewise, in this case you even under-indented it.

> +		v6hash =
> +			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> +			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> +			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);

This is rediculous, just put &ipv6h->saddr into a local pointer named
's' and then you won't have use such gymnastics to indent the code.

>  		if (!ip_is_fragment(iph) &&
> -		    (iph->protocol == IPPROTO_TCP ||
> -		     iph->protocol == IPPROTO_UDP)) {
> +			(iph->protocol == IPPROTO_TCP ||
> +			iph->protocol == IPPROTO_UDP)) {

This is what _REALLY_ bothers me.  You took an existing conditional
which _WAS_ indented properly and you made erroneously re-indented.

In fact your only change here is to break the indentation.

Just remove these changes entirely.

> +			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
> +				skb_headlen(skb) - skb_network_offset(skb))

Similarly, this is indented improperly.

> +		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
> +			goto short_header;
>  		}

Single line basic blocks do not use openning and closing braces.

> -		return (layer4_xor ^
> -			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
> -
> +		return (layer4_xor ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;

Don't reindent code unless you can do it properly, now this line is way
over 80 columns.  The previous code was perfectly fine, leave it alone.

> +		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {

Line is too long, write it as:

		if (ipv6h->nexthdr == IPPROTO_TCP ||
		    ipv6h->nexthdr == IPPROTO_UDP) {

> +			__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));

Likewise, line is too long.  Just do the variable declaration seperate from the
assignment:
			__be16 *layer4hdrv6;

			layer4hdrv6 = BLAH BLAH BLAH;

> +			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
> +				skb_headlen(skb) - skb_network_offset(skb))

Improperly indented, fix.

> +		} else if (skb_network_header_len(skb) < sizeof(struct ipv6hdr)) {
> +			goto short_header;
> +		}

Since line basic block, no braces.

> +		layer4_xor ^=
> +			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> +			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> +			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);

This is gross, do as I said above using a local pointer variable.
