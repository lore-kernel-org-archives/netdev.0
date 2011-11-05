From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net v3 8/9] forcedeth: 64-bit stats
Date: Sat, 5 Nov 2011 09:34:44 -0700
Message-ID: <CAG88wWbCAX5zMn5DTO+r-NrHawng5=1_E5TmQ=8mLcE5XYDyiw@mail.gmail.com>
References: <cover.1320457247.git.david.decotigny@google.com>
 <4c77142ad7c6019e908884723d3c299163a55e2e.1320457247.git.david.decotigny@google.com>
 <1320478098.16609.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320478098.16609.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Eric, I will update this.

Please note that I am deferring 5 of the patches from this "v3"
patch-set for net-next: this patch is one of them.
Meanwhile, the most recent version of the remaining 4 patches is the
"v4" series I sent yesterday; they are limited to minor fixes.

Regards,

--
David Decotigny



On Sat, Nov 5, 2011 at 12:28 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 04 novembre 2011 =E0 18:53 -0700, David Decotigny a =E9cr=
it :
>> This converts forcedeth stats to be 64-bits. It also improves
>> accounting for dropped rx frames.
>>
>> Tested:
>> =A0 16-way SMP x86_64 ->
>> =A0 RX bytes:7244556582 (7.2 GB) =A0TX bytes:181904254 (181.9 MB)
>>
>>
>
> This changelog and patch title are misleading.
>
> On a 32bit x86, stats are still 32bit wide after your patch.
>
> On a 64bit x86_64, stats were already 64bit wide before your patch.
>
> So the real thing is about not using the embedded netdevice dev->stat=
s
> structure, to reduce false sharing.
>
>>
>> Signed-off-by: David Decotigny <david.decotigny@google.com>
>> ---
>> =A0drivers/net/ethernet/nvidia/forcedeth.c | =A0 69 ++++++++++++++++=
+++-----------
>> =A01 files changed, 44 insertions(+), 25 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/e=
thernet/nvidia/forcedeth.c
>> index 90cdf26..08c512b 100644
>> --- a/drivers/net/ethernet/nvidia/forcedeth.c
>> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
>> @@ -799,6 +799,8 @@ struct fe_priv {
>> =A0 =A0 =A0 struct timer_list stats_poll;
>> =A0 =A0 =A0 u32 nic_poll_irq;
>> =A0 =A0 =A0 int rx_ring_size;
>> + =A0 =A0 unsigned long stats_rx_dropped;
>> + =A0 =A0 unsigned long stats_rx_missed_errors;
>>
>> =A0 =A0 =A0 /* media detection workaround.
>> =A0 =A0 =A0 =A0* Locking: Within irq hander or disable_irq+spin_lock=
(&np->lock);
>> @@ -821,6 +823,7 @@ struct fe_priv {
>> =A0 =A0 =A0 struct nv_skb_map *tx_change_owner;
>> =A0 =A0 =A0 struct nv_skb_map *tx_end_flip;
>> =A0 =A0 =A0 int tx_stop;
>> + =A0 =A0 unsigned long stats_tx_dropped;
>>
>> =A0 =A0 =A0 /* msi/msi-x fields */
>> =A0 =A0 =A0 u32 msi_flags;
>> @@ -1700,33 +1703,47 @@ static void nv_get_hw_stats(struct net_devic=
e *dev)
>> =A0}
>>
>> =A0/*
>> - * nv_get_stats: dev->get_stats function
>> + * nv_get_stats: dev->ndo_get_stats64 function
>> =A0 * Get latest stats value from the nic.
>> =A0 * Called with read_lock(&dev_base_lock) held for read -
>> =A0 * only synchronized against unregister_netdevice.
>> =A0 */
>> -static struct net_device_stats *nv_get_stats(struct net_device *dev=
)
>> +static struct rtnl_link_stats64*
>> +nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *st=
orage)
>> =A0{
>> =A0 =A0 =A0 struct fe_priv *np =3D netdev_priv(dev);
>>
>> =A0 =A0 =A0 /* If the nic supports hw counters then retrieve latest =
values */
>> - =A0 =A0 if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATI=
STICS_V2|DEV_HAS_STATISTICS_V3)) {
>> + =A0 =A0 if (np->driver_data & (DEV_HAS_STATISTICS_V1
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| DEV_HAS_S=
TATISTICS_V2
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| DEV_HAS_S=
TATISTICS_V3)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nv_get_hw_stats(dev);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* copy to net_device stats */
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_packets =3D np->estats.tx_pa=
ckets;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_bytes =3D np->estats.rx_byte=
s;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_bytes =3D np->estats.tx_byte=
s;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_fifo_errors =3D np->estats.t=
x_fifo_errors;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_carrier_errors =3D np->estat=
s.tx_carrier_errors;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_crc_errors =3D np->estats.rx=
_crc_errors;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_over_errors =3D np->estats.r=
x_over_errors;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_fifo_errors =3D np->estats.r=
x_drop_frame;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_errors =3D np->estats.rx_err=
ors_total;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_errors =3D np->estats.tx_err=
ors_total;
>> - =A0 =A0 }
>> -
>> - =A0 =A0 return &dev->stats;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* generic stats */
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_packets =3D np->estats.rx_pack=
ets;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_packets =3D np->estats.tx_pack=
ets;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_bytes =A0 =3D np->estats.rx_by=
tes;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_bytes =A0 =3D np->estats.tx_by=
tes;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_errors =A0=3D np->estats.rx_er=
rors_total;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_errors =A0=3D np->estats.tx_er=
rors_total;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_dropped =3D np->stats_rx_dropp=
ed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_dropped =3D np->stats_tx_dropp=
ed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->multicast =A0=3D np->estats.rx_mu=
lticast;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* detailed rx_errors */
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_length_errors =3D np->estats.r=
x_length_error;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_over_errors =A0 =3D np->estats=
=2Erx_over_errors;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_crc_errors =A0 =A0=3D np->esta=
ts.rx_crc_errors;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_frame_errors =A0=3D np->estats=
=2Erx_frame_align_error;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_fifo_errors =A0 =3D np->estats=
=2Erx_drop_frame;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_missed_errors =3D np->stats_rx=
_missed_errors;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* detailed tx_errors */
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_carrier_errors =3D np->estats.=
tx_carrier_errors;
>> + =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_fifo_errors =A0 =A0=3D np->est=
ats.tx_fifo_errors;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return storage;
>> =A0}
>>
>> =A0/*
>> @@ -1759,8 +1776,10 @@ static int nv_alloc_rx(struct net_device *dev=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->put_=
rx.orig =3D np->first_rx.orig;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(np->put_rx_=
ctx++ =3D=3D np->last_rx_ctx))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->put_=
rx_ctx =3D np->first_rx_ctx;
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stats_rx_dropped++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return 0;
>> =A0}
>> @@ -1791,8 +1810,10 @@ static int nv_alloc_rx_optimized(struct net_d=
evice *dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->put_=
rx.ex =3D np->first_rx.ex;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(np->put_rx_=
ctx++ =3D=3D np->last_rx_ctx))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->put_=
rx_ctx =3D np->first_rx_ctx;
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stats_rx_dropped++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return 0;
>> =A0}
>> @@ -1928,7 +1949,7 @@ static void nv_drain_tx(struct net_device *dev=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->tx_ring.ex[i].buflow=
 =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nv_release_txskb(np, &np->tx_skb[i])=
)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_dropped++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stats_tx_dropped++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->tx_skb[i].dma =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->tx_skb[i].dma_len =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->tx_skb[i].dma_single =3D 0;
>> @@ -2651,7 +2672,7 @@ static int nv_rx_process(struct net_device *de=
v, int limit)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 /* the rest are hard errors */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 if (flags & NV_RX_MISSEDFRAME)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_missed_errors++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stats_rx_missed_errors++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 goto next_pkt;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 }
>> @@ -2694,7 +2715,6 @@ static int nv_rx_process(struct net_device *de=
v, int limit)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_put(skb, len);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_type_trans(skb, de=
v);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(&np->napi, skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++;
>> =A0next_pkt:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(np->get_rx.orig++ =3D=3D np=
->last_rx.orig))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->get_rx.orig =3D np->=
first_rx.orig;
>> @@ -2777,7 +2797,6 @@ static int nv_rx_process_optimized(struct net_=
device *dev, int limit)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __vlan_h=
waccel_put_tag(skb, vid);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(&np->na=
pi, skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -5199,7 +5218,7 @@ static int nv_close(struct net_device *dev)
>> =A0static const struct net_device_ops nv_netdev_ops =3D {
>> =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_open,
>> =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_close,
>> - =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D nv_get_stats,
>> + =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D nv_get_stats64,
>> =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D nv_start_xmit,
>> =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D nv_tx_timeout,
>> =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D nv_change_mtu,
>> @@ -5216,7 +5235,7 @@ static const struct net_device_ops nv_netdev_o=
ps =3D {
>> =A0static const struct net_device_ops nv_netdev_ops_optimized =3D {
>> =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_open,
>> =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_close,
>> - =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D nv_get_stats,
>> + =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D nv_get_stats64,
>> =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D nv_start_xmit_optimi=
zed,
>> =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D nv_tx_timeout,
>> =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D nv_change_mtu,
>
>
>
