From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] loopback: better handling of packet drops
Date: Fri, 17 Apr 2009 07:58:01 -0700
Message-ID: <20090417075801.2f9fe64e@nehalam>
References: <49E78DE5.10104@hartkopp.net>
	<20090417.013853.04495551.davem@davemloft.net>
	<49E84459.1060507@cosmosbay.com>
	<20090417.015914.09817926.davem@davemloft.net>
	<49E84B99.1080502@cosmosbay.com>
	<49E854A4.1010204@cosmosbay.com>
	<49E85AFD.6080407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43841 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757500AbZDQO6J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:58:09 -0400
In-Reply-To: <49E85AFD.6080407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2009 12:33:33 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Eric Dumazet a =C3=A9crit :
> >> David Miller a =C3=A9crit :
> >>> From: Eric Dumazet <dada1@cosmosbay.com>
> >>> Date: Fri, 17 Apr 2009 10:56:57 +0200
> >>>
> >>>> We can in some situations drop packets in netif_rx()
> >>>>
> >>>> loopback driver does not report these (unlikely) drops to its st=
ats,
> >>>> and incorrectly change packets/bytes counts.
> >>>>
> >>>> After this patch applied, "ifconfig lo" can reports these drops =
as in :
> >>>>
> >>>> # ifconfig lo
> >>>> lo        Link encap:Local Loopback
> >>>>           inet addr:127.0.0.1  Mask:255.0.0.0
> >>>>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
> >>>>           RX packets:692562900 errors:0 dropped:0 overruns:0 fra=
me:0
> >>>>           TX packets:692562900 errors:3228 dropped:3228 overruns=
:0 carrier:0
> >>>>           collisions:0 txqueuelen:0
> >>>>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.=
6 GiB)
> >>>>
> >>>> I chose to reflect those errors only in tx_dropped/tx_errors, an=
d not mirror
> >>>> these errors in rx_dropped/rx_errors.
> >>>>
> >>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> >>> Well, logically the receive is what failed, not the transmit.
> >>>
> >>> I think it's therefore misleading to count it as a TX drop.
> >>>
> >>> Do you feel strongly about this?
> >> Not at all, but my plan was to go a litle bit further, ie being ab=
le to=20
> >> return from loopback_xmit() with a non null value.
> >>
> >=20
> > Something like this :
>=20
> I just noticed NETDEV_TX_BUSY & NETDEV_TX_OK, so here is an updated v=
ersion
> using these macros instead of 0 & 1
>=20
> [PATCH] loopback: better handling of packet drops
>=20
> We can in some situations drop packets in netif_rx()
>=20
> loopback driver does not report these (unlikely) drops to its stats,
> and incorrectly change packets/bytes counts. Also upper layers are
> not warned of these transmit failures.
>=20
> After this patch applied, "ifconfig lo" can reports these drops as in=
 :
>=20
> # ifconfig lo
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:692562900 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:692562900 errors:3228 dropped:3228 overruns:0 ca=
rrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 GiB=
)
>=20
> More over, loopback_xmit() can now return to its caller the indicatio=
n that
> packet was not transmitted for better queue management and error hand=
ling.
>=20
> I chose to reflect those errors only in tx_dropped/tx_errors, and not=
 mirror
> them in rx_dropped/rx_errors.
>=20
> Splitting netif_rx() with a helper function boosts tbench performance=
 by 1%,
> because we can avoid two tests (about netpoll and timestamping)
>=20
> Tested with /proc/sys/net/core/netdev_max_backlog set to 0, tbench
> can run at full speed even with some 'losses' on loopback. No more
> tcp stalls...
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  drivers/net/loopback.c    |   24 +++++++++---
>  include/linux/netdevice.h |    1
>  net/core/dev.c            |   68 +++++++++++++++++++++++------------=
-
>  3 files changed, 62 insertions(+), 31 deletions(-)
>=20
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index b7d438a..101a3bc 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -62,6 +62,7 @@
>  struct pcpu_lstats {
>  	unsigned long packets;
>  	unsigned long bytes;
> +	unsigned long drops;
>  };
> =20
>  /*
> @@ -71,20 +72,25 @@ struct pcpu_lstats {
>  static int loopback_xmit(struct sk_buff *skb, struct net_device *dev=
)
>  {
>  	struct pcpu_lstats *pcpu_lstats, *lb_stats;
> +	int len;
> =20
>  	skb_orphan(skb);
> =20
> -	skb->protocol =3D eth_type_trans(skb,dev);
> +	skb->protocol =3D eth_type_trans(skb, dev);
> =20
>  	/* it's OK to use per_cpu_ptr() because BHs are off */
>  	pcpu_lstats =3D dev->ml_priv;
>  	lb_stats =3D per_cpu_ptr(pcpu_lstats, smp_processor_id());
> -	lb_stats->bytes +=3D skb->len;
> -	lb_stats->packets++;
> =20
> -	netif_rx(skb);
> +	len =3D skb->len;
> +	if (likely(__netif_rx(skb) =3D=3D NET_RX_SUCCESS)) {
> +		lb_stats->bytes +=3D len;
> +		lb_stats->packets++;
> +		return NETDEV_TX_OK;
> +	}
> +	lb_stats->drops++;
> =20
> -	return 0;
> +	return NETDEV_TX_BUSY;
>  }

If you return NETDEV_TX_BUSY, then the xmit logic will retry
so it is not really a drop but a stall. I think it is confusing
to call this a packet loss.
