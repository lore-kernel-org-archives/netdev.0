From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 7/9] forcedeth: implement ndo_get_stats64()
 API
Date: Thu, 17 Nov 2011 07:34:38 +0100
Message-ID: <1321511678.3274.30.camel@edumazet-laptop>
References: <cover.1321481064.git.david.decotigny@google.com>
	 <185a0f33c69ff07e8fe3482828b368371420bf47.1321481064.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49937 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab1KQGep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 01:34:45 -0500
In-Reply-To: <185a0f33c69ff07e8fe3482828b368371420bf47.1321481064.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 novembre 2011 =C3=A0 14:15 -0800, David Decotigny a =C3=A9=
crit :
> This commit implements the ndo_get_stats64() API for forcedeth. Since
> hardware stats are being updated from different contexts (process and
> timer), this commit adds synchronization. For software stats, it
> relies on the u64_stats_sync.h API.
>=20
> Tested:
>   - 16-way SMP x86_64 ->
>     RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)
>   - pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/tx_=
packets
>=20
>=20
>=20
> Signed-off-by: David Decotigny <david.decotigny@google.com>
> ---
>  drivers/net/ethernet/nvidia/forcedeth.c |  197 +++++++++++++++++++++=
++--------
>  1 files changed, 146 insertions(+), 51 deletions(-)
>=20


> +static struct rtnl_link_stats64*
> +nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *sto=
rage)
> +	__acquires(&netdev_priv(dev)->hwstats_lock)
> +	__releases(&netdev_priv(dev)->hwstats_lock)
>  {
>  	struct fe_priv *np =3D netdev_priv(dev);
> +	unsigned int syncp_start;
> +
> +	/*
> +	 * Note: because HW stats are not always available and for
> +	 * consistency reasons, the following ifconfig stats are
> +	 * managed by software: rx_bytes, tx_bytes, rx_packets and
> +	 * tx_packets. The related hardware stats reported by ethtool
> +	 * should be equivalent to these ifconfig stats, with 4
> +	 * additional bytes per packet (Ethernet FCS CRC), except for
> +	 * tx_packets when TSO kicks in.
> +	 */
> +
> +	/* software stats */
> +	do {
> +		syncp_start =3D u64_stats_fetch_begin(&np->swstats_rx_syncp);
> +		storage->rx_packets       =3D np->stat_rx_packets;
> +		storage->rx_bytes         =3D np->stat_rx_bytes;
> +		storage->rx_missed_errors =3D np->stat_rx_missed_errors;
> +	} while (u64_stats_fetch_retry(&np->swstats_rx_syncp, syncp_start))=
;
> +
> +	do {
> +		syncp_start =3D u64_stats_fetch_begin(&np->swstats_tx_syncp);
> +		storage->tx_packets =3D np->stat_tx_packets;
> +		storage->tx_bytes   =3D np->stat_tx_bytes;
> +		storage->tx_dropped =3D np->stat_tx_dropped;
> +	} while (u64_stats_fetch_retry(&np->swstats_tx_syncp, syncp_start))=
;
> =20

I have no idea why you think u64_stats_fetch_begin() is safe on 32bit
arch here.

Hint : On CONFIG_SMP=3Dn build, only preemption is disabled in
u64_stats_fetch_begin()

So an interrupt could come and change your counters while you were
reading them.

Its very unlikely, but its possible.

You should use the _bh variants.
