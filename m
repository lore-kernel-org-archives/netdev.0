From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Thu, 21 Aug 2014 22:51:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35921 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753138AbaHUTxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 15:53:03 -0400
In-Reply-To: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 21 Aug 2014, Johannes Berg wrote:

> From: Johannes Berg <johannes.berg@intel.com>
> 
> RFC 1122 says that unicast packets encapsulated in broadcast
> link-layer packets should be dropped. Implement that, but also
> extend it to link-layer multicast packets.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/ipv4/route.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index eaa4b000c7b4..c374fcc73ee0 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1710,6 +1710,23 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  		goto no_route;
>  	}
>  
> +	/* RFC 1122 3.3.6:
> +	 *
> +	 *   When a host sends a datagram to a link-layer broadcast address,
> +	 *   the IP destination address MUST be a legal IP broadcast or IP
> +	 *   multicast address.
> +	 *
> +	 *   A host SHOULD silently discard a datagram that is received via
> +	 *   a link-layer broadcast (see Section 2.4) but does not specify
> +	 *   an IP multicast or broadcast destination address.
> +	 *
> +	 * We also do this for link-layer multicast.
> +	 */
> +	if ((skb->pkt_type == PACKET_BROADCAST ||
> +	     skb->pkt_type == PACKET_MULTICAST) &&
> +	    res.type != RTN_BROADCAST)
> +		goto e_inval;

	This place is ok for IP context but ip_route_input
is also called from ARP context and other places.
You are using pkt_type in route.c for first time.
At least inet_rtm_getroute() does not set it. You
have to audit all call sites, may be skb->protocol check
can be needed too, I guess ARP is broken otherwise.
And I'm not sure if skb->protocol is actual in
ip4ip6_err() after decapsulation. Adding more skb
fields to check is risky due to such places.

	OTOH, the receive routines for protocols like
UDP, TCP, SCTP already have pkt_type checks. As result,
this is an extra check for them.

	You should also consider that this change breaks
CLUSTERIP which uses multicast link-layer address and
local (shared) IP.

>  	if (res.type == RTN_BROADCAST)
>  		goto brd_input;

	Is this place better, after checking for RTN_BROADCAST?

	/* ARP link-layer broadcasts are acceptable here */
	if ((skb->pkt_type == PACKET_BROADCAST ||
	     skb->pkt_type == PACKET_MULTICAST) &&
	    skb->protocol == htons(ETH_P_IP))
		goto e_inval;

Regards

--
Julian Anastasov <ja@ssi.bg>
