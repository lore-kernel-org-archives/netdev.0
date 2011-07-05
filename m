From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 06:33:49 +0200
Message-ID: <1309840429.2720.26.camel@edumazet-laptop>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:55539 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab1GEEdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:33:53 -0400
Received: by wwg11 with SMTP id 11so1940103wwg.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 21:33:52 -0700 (PDT)
In-Reply-To: <20110704.212014.236340473910292460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 21:20 -0700, David Miller a =C3=A9crit =
:
> Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
> sockets.  Two fanout policies are implemented:
>=20
> 1) Hashing based upon skb->rxhash
>=20
> 2) Pure round-robin
>=20
> An AF_PACKET socket must be fully bound before it tries to add itself
> to a fanout.  All AF_PACKET sockets trying to join the same fanout
> must all have the same bind settings.
>=20
> Fanouts are identified (within a network namespace) by a 16-bit ID.
> The first socket to try to add itself to a fanout with a particular
> ID, creates that fanout.  When the last socket leaves the fanout
> (which happens only when the socket is closed), that fanout is
> destroyed.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/if_packet.h |    4 +
>  net/packet/af_packet.c    |  250 +++++++++++++++++++++++++++++++++++=
+++++++++-
>  2 files changed, 249 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
> index 7b31863..1efa1cb 100644
> --- a/include/linux/if_packet.h
> +++ b/include/linux/if_packet.h
> @@ -49,6 +49,10 @@ struct sockaddr_ll {
>  #define PACKET_VNET_HDR			15
>  #define PACKET_TX_TIMESTAMP		16
>  #define PACKET_TIMESTAMP		17
> +#define PACKET_FANOUT			18
> +
> +#define PACKET_FANOUT_HASH		0
> +#define PACKET_FANOUT_LB		1
> =20
>  struct tpacket_stats {
>  	unsigned int	tp_packets;
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index bb281bf..7db1e12 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -187,9 +187,11 @@ static int tpacket_snd(struct packet_sock *po, s=
truct msghdr *msg);
> =20
>  static void packet_flush_mclist(struct sock *sk);
> =20
> +struct packet_fanout;
>  struct packet_sock {
>  	/* struct sock has to be the first member of packet_sock */
>  	struct sock		sk;
> +	struct packet_fanout	*fanout;
>  	struct tpacket_stats	stats;
>  	struct packet_ring_buffer	rx_ring;
>  	struct packet_ring_buffer	tx_ring;
> @@ -212,6 +214,24 @@ struct packet_sock {
>  	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
>  };
> =20
> +#define PACKET_FANOUT_MAX	2048
> +
> +struct packet_fanout {
> +#ifdef CONFIG_NET_NS
> +	struct net		*net;
> +#endif
> +	int			num_members;
> +	u16			id;
> +	u8			type;
> +	u8			pad;
> +	atomic_t		rr_cur;
> +	struct list_head	list;
> +	struct sock		*arr[PACKET_FANOUT_MAX];

Thats about 16Kbytes, yet you use kzalloc()

> +	spinlock_t		lock;
> +	atomic_t		sk_ref;
> +	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
> +};
> +

Maybe use a dynamic array ? I suspect most uses wont even reach 16
sockets anyway...

