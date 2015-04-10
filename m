From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2
 multicast
Date: Fri, 10 Apr 2015 15:19:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54213 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754830AbbDJMVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 08:21:54 -0400
In-Reply-To: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 10 Apr 2015, Johannes Berg wrote:

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In order to solve a problem with 802.11, the so-called hole-196 attack,
> add an option (sysctl) called "drop_unicast_in_l2_multicast" which, if
> enabled, causes the stack to drop IPv4 unicast packets encapsulated in
> link-layer multi- or broadcast frames. Such frames can (as an attack)
> be created by any member of the same wireless network and transmitted
> as valid encrypted frames since the symmetric key for broadcast frames
> is shared between all stations.
> 
> Additionally, enabling this option provides compliance with a SHOULD
> clause of RFC 1122.
> 

> +++ b/net/ipv4/route.c
> @@ -1727,6 +1727,26 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  	if (res.type == RTN_BROADCAST)
>  		goto brd_input;
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
> +	 * This doesn't explicitly say L2 *broadcast*, but broadcast is in a
> +	 * way a form of multicast and the most common use case for this is
> +	 * 802.11 protecting against cross-station spoofing (the so-called
> +	 * "hole-196" attack) so do it for both.
> +	 */
> +	if (IN_DEV_CONF_GET(in_dev, DROP_UNICAST_IN_L2_MULTICAST) &&

	For this flag IN_DEV_ORCONF can be used, by this way
all/drop_unicast_in_l2_multicast=1 can enable it for all
interfaces.

> +	    (skb->pkt_type == PACKET_BROADCAST ||
> +	     skb->pkt_type == PACKET_MULTICAST))
> +		goto e_inval;
> +

	So, this is the same patch as the 2014-Aug version
but this time with flag? But how the previous problems were
addressed? May be something is changed in kernel afterwards?

	So, if your are back at step 1 can you check again
the problems with this implementation?:

http://marc.info/?l=linux-netdev&m=140865079120355&w=2

Thread:
http://marc.info/?t=140864197300004&r=1&w=2

	In short:

- no way to select correct skb->pkt_type in inet_rtm_getroute
before ip_route_input, this is a chiken-egg problem, of course,
skb->pkt_type = PACKET_HOST can work for now

- ip_route_input is called also for ARP, so incoming ARP
broadcasts are not replied anymore

- CLUSTERIP

Regards

--
Julian Anastasov <ja@ssi.bg>
