From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] [NET] Do pmtu check in transport layer
Date: Mon, 09 Apr 2007 10:40:14 +0200
Message-ID: <4619FBEE.70103@trash.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64061 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbXDIIkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 04:40:22 -0400
In-Reply-To: <11746948063923-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Check the pmtu check at the transport layer (for UDP, ICMP and raw), and
> send a local error if socket is PMTUDISC_DO and packet is too big.  This is
> actually a pure bugfix for ipv6.  For ipv4, it allows us to do pmtu checks
> in the same way as for ipv6.
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index d096332..593acf7 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -822,7 +822,9 @@ int ip_append_data(struct sock *sk,
>  	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
>  	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
>  
> -	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
> +	if (inet->cork.length + length > 0xFFFF - fragheaderlen ||
> +	    (inet->pmtudisc >= IP_PMTUDISC_DO &&
> +	     inet->cork.length + length > mtu)) {
>  		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
>  		return -EMSGSIZE;
>  	}


This makes ping report an incorrect MTU when IPsec is used since we're
only accounting for the additional header_len, not the trailer_len
(which is not easily changeable). Additionally it will report different
MTUs for the first and following fragments when the socket is corked
because only the first fragment includes the header_len. It also can't
deal with things like NAT and routing by fwmark that change the route.
The old behaviour was that we get an ICMP frag. required with the MTU
of the final route, while this will always report the MTU of the
initially chosen route.

For all these reasons I think it should be reverted to the old
behaviour.

