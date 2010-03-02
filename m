From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 02 Mar 2010 07:01:30 +0100
Message-ID: <1267509690.2843.5.camel@edumazet-laptop>
References: <20100301161658.5a61143b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65051 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab0CBGBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 01:01:35 -0500
Received: by bwz1 with SMTP id 1so827063bwz.21
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 22:01:34 -0800 (PST)
In-Reply-To: <20100301161658.5a61143b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 16:16 -0800, Stephen Hemminger a =C3=A9cri=
t :
> The shared packet statistics are a potential source of slow down
> on bridged traffic. Convert to per-cpu array, but only keep those
> statistics which change per-packet.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>=20
>  net/bridge/br_device.c  |   43 +++++++++++++++++++++++++++++++++++++=
+-----
>  net/bridge/br_if.c      |    6 ++++++
>  net/bridge/br_input.c   |    5 +++--
>  net/bridge/br_private.h |    8 ++++++++
>  4 files changed, 55 insertions(+), 7 deletions(-)
>=20
> --- a/net/bridge/br_device.c	2010-03-01 08:22:23.476657998 -0800
> +++ b/net/bridge/br_device.c	2010-03-01 15:31:36.737227465 -0800
> @@ -26,11 +26,12 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
>  	const unsigned char *dest =3D skb->data;
>  	struct net_bridge_fdb_entry *dst;
>  	struct net_bridge_mdb_entry *mdst;
> +	struct br_cpu_netstats *brstats =3D this_cpu_ptr(br->stats);
> =20
> -	BR_INPUT_SKB_CB(skb)->brdev =3D dev;
> +	brstats->tx_packets++;
> +	brstats->tx_bytes +=3D skb->len;


On TX path, this is not really necessary, since we already dirtied
txq->lock before calling br_dev_xmit(), we can use txq->tx_packets and
txq->tx_bytes for free ?

> =20
> -	dev->stats.tx_packets++;
> -	dev->stats.tx_bytes +=3D skb->len;
> +	BR_INPUT_SKB_CB(skb)->brdev =3D dev;
> =20
>  	skb_reset_mac_header(skb);
>  	skb_pull(skb, ETH_HLEN);
> @@ -81,6 +82,28 @@ static int br_dev_stop(struct net_device
>  	return 0;
>  }
> =20


