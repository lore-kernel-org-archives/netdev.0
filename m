From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Wed, 06 Jan 2010 06:54:20 +0100
Message-ID: <4B44258C.2050302@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45911 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744Ab0AFFy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 00:54:29 -0500
In-Reply-To: <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 02:32, Tom Herbert a =E9crit :
> Here's an RPS updated patch with some minor fixes, sorry for the long
> turnaround.  This addresses most of the comments for last patch:
>=20
> - Moved shared fields in softnet_data into a separate cacheline
> - Make hashrnd __read_mostly
> - Removed extra "hash" variable in get_rps_cpu
> - Allow use of RPS from netif_rx (we have a use case where this is ne=
eded)
> - In net_rps_action clear each cpu in the mask before calling the
> function, I believe this prevents race condition

Hmm, I cant see a race condition here, could you elaborate on this ?
mask is local to this cpu, and we cannot re-enter a function that could
change some bits under us (we are called from net_rx_action())
If you believe there is a race condition, I suspect race is still there=
=2E

>=20
> I still don't have a better way to do a per-napi RPS mask than using =
a
> single variable in sysfs under the device.  It still seems like we'd
> want a file or even directory for each napi instance, but that looks
> like some major changes.
>=20
> Also, we found that a few drivers are calling napi_gro_receive in lie=
u
> of netif_receive_skb (tg3, e1000e for example).  The patch does not
> support that, so there is no benefit for them with RPS :-(.  The GRO
> path looks pretty intertwined with the receive although way through
> TCP so I'm not sure it will be easy to retrofit.  We changed e1000e t=
o
> call netif_receive_skb and top netperf RR throughput went for 85K tps
> to 241K tps, and for our workloads at least this is may be the bigger
> win.

Did you tested with VLANS too ? (with/without hardware support)

>=20
> Tom

Excellent, but I suspect big win comes from using few NICS.
(number_of(NICS) < num_online_cpus)

(in the reverse case, possible contention on queue->csd)

>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 97873e3..7107b13 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -676,6 +676,29 @@ struct net_device_ops {
>  };
>=20
>  /*
> + * Structure for Receive Packet Steering.  Length of map and array o=
f CPU ID's.
> + */
> +struct rps_map {
> +	int len;
> +	u16 map[0];
> +};
> +
> +/*
> + * Structure that contains the rps maps for various NAPI instances o=
f a device.
> + */
> +struct dev_rps_maps {
> +	int num_maps;
> +	struct rcu_head rcu;
> +	struct rps_map maps[0];
> +};

I feel uneasy about this, because of kmalloc() max size and rounding to=
 power of two effects.
It also uses a single node in NUMA setups.
> +
> +/* Bound number of CPUs that can be in an rps map */
> +#define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus(=
) : 256)
> +
> +/* Maximum size of RPS map (for allocation) */
> +#define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * sizeo=
f(u16)))
> +
> +/*
>   *	The DEVICE structure.
>   *	Actually, this whole structure is a big mistake.  It mixes I/O
>   *	data with strictly "high-level" data, and it has to know about
> @@ -861,6 +884,9 @@ struct net_device {
>=20
>  	struct netdev_queue	rx_queue;
>=20
> +	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
> +						   receive packet steeing */
> +


If you store rps_map pointer into napi itself, you could avoid this MAX=
_RPS_CPUS thing
and really dynamically allocate the structure with the number of online=
 cpus mentioned
in the map.

But yes, it makes store_rps_cpus() more complex :(

This probably can be done later, this Version 4 of RPS looks very good,=
 thanks !
I am going to test it today on my dev machine before giving an Acked-by=
 :)

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


