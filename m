From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] macvlan: implement VEPA and private mode
Date: Wed, 18 Nov 2009 07:42:21 +0100
Message-ID: <4B03974D.3010708@gmail.com>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41166 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbZKRGmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 01:42:42 -0500
In-Reply-To: <1258497551-25959-3-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann a =E9crit :
> This allows each macvlan slave device to be in one
> of three modes, depending on the use case:
>=20
> MACVLAN_MODE_PRIVATE:
>   The device never communicates with any other device
>   on the same upper_dev. This even includes frames
>   coming back from a reflective relay, where supported
>   by the adjacent bridge.
>=20
> MACVLAN_MODE_VEPA:
>   The new Virtual Ethernet Port Aggregator (VEPA) mode,
>   we assume that the adjacent bridge returns all frames
>   where both source and destination are local to the
>   macvlan port, i.e. the bridge is set up as a reflective
>   relay.
>   Broadcast frames coming in from the upper_dev get
>   flooded to all macvlan interfaces in VEPA mode.
>   We never deliver any frames locally.
>=20
> MACVLAN_MODE_BRIDGE:
>   We provide the behavior of a simple bridge between
>   different macvlan interfaces on the same port. Frames
>   from one interface to another one get delivered directly
>   and are not sent out externally. Broadcast frames get
>   flooded to all other bridge ports and to the external
>   interface, but when they come back from a reflective
>   relay, we don't deliver them again.
>   Since we know all the MAC addresses, the macvlan bridge
>   mode does not require learning or STP like the bridge
>   module does.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---


>  	if (is_multicast_ether_addr(eth->h_dest)) {
> -		macvlan_broadcast(skb, port, NULL);
> +		src =3D macvlan_hash_lookup(port, eth->h_source);
> +		if (!src)
> +			/* frame comes from an external address */


> +			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_VEPA
> +				| MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);

typo here, you probably meant MACVLAN_PRIVATE | MACVLAN_VEPA | MACVLAN_=
BRIDGE=20

> +		else if (src->mode =3D=3D MACVLAN_MODE_VEPA)
> +			/* flood to everyone except source */
> +			macvlan_broadcast(skb, port, src->dev,
> +				MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
> +		else if (src->mode =3D=3D MACVLAN_MODE_BRIDGE)
> +			/* flood only to VEPA ports, bridge ports
> +			   already saw the frame */
> +			macvlan_broadcast(skb, port, src->dev,
> +				MACVLAN_MODE_VEPA);
>  		return skb;
>  	}
> =20

