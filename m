From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 01:21:06 +0100
Message-ID: <1340151666.6871.81.camel@deadeye.wl.decadent.org.uk>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37515 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751944Ab2FTAVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 20:21:10 -0400
In-Reply-To: <20120619.163911.2094057156011157978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 16:39 -0700, David Miller wrote:
> Input packet processing for local sockets involves two major demuxes.
> One for the route and one for the socket.
> 
> But we can optimize this down to one demux for certain kinds of local
> sockets.
[...]
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -324,19 +324,34 @@ static int ip_rcv_finish(struct sk_buff *skb)
>  	 *	how the packet travels inside Linux networking.
>  	 */
>  	if (skb_dst(skb) == NULL) {
> -		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
> -					       iph->tos, skb->dev);
> -		if (unlikely(err)) {
> -			if (err == -EHOSTUNREACH)
> -				IP_INC_STATS_BH(dev_net(skb->dev),
> -						IPSTATS_MIB_INADDRERRORS);
> -			else if (err == -ENETUNREACH)
> -				IP_INC_STATS_BH(dev_net(skb->dev),
> -						IPSTATS_MIB_INNOROUTES);
> -			else if (err == -EXDEV)
> -				NET_INC_STATS_BH(dev_net(skb->dev),
> -						 LINUX_MIB_IPRPFILTER);
> -			goto drop;
> +		const struct net_protocol *ipprot;
> +		int protocol = iph->protocol;
> +		int hash, err;
> +
> +		hash = protocol & (MAX_INET_PROTOS - 1);
[...]

This 'hashing' threw me when I read v1, because nowhere do we actually
check that the protocol (as opposed to hash) matches that for the
selected ipprot.  (And this also turns out to be true for the current
receive path.)

This works only because MAX_INET_PROTOS is defined as 256, so that hash
== protocol.  If we were ever to change MAX_INET_PROTOS then we would
need to add a whole lot of protocol checks, but this isn't particularly
obvious!  Perhaps it would be better to remove the 'hashing' altogether?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
