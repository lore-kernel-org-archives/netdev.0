From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v4 5/8] forcedeth: implement ndo_get_stats64() API
Date: Tue, 15 Nov 2011 14:01:01 -0800
Message-ID: <CAG88wWYyJa+W6SoHTgLZ5yr84V632S9EK1b_Ta6oLtUxxxco4w@mail.gmail.com>
References: <cover.1321384662.git.david.decotigny@google.com> <6c785722f068deef5ff546f53b8011ecff43a4c1.1321384662.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49858 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757450Ab1KOWBX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 17:01:23 -0500
Received: by yenq3 with SMTP id q3so1160686yen.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 14:01:22 -0800 (PST)
In-Reply-To: <6c785722f068deef5ff546f53b8011ecff43a4c1.1321384662.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,


I'm afraid this version (http://patchwork.ozlabs.org/patch/125861/) is =
wrong.

Each software stat field is updated by one single writer. But these
different stats are guarded by a single seqcount, so effectively
different writers are fiddling with the same seqcount. Question is: is
it Ok for the seqcount to be updated concurrently without protection?
Is the seqcount guaranteed to be correctly updated from the readers'
perspective? Or should I serialize the sections that update the
seqcount?

If I should protect it, then I need to revisit that patch again: I'd
prefer not to lock in the fast paths just because of the stats. I
could for example revert to v3 (using atomic_t stats). Would you have
any recommendation/suggestion?

Thanks! Regards,

--
David Decotigny



On Tue, Nov 15, 2011 at 11:25 AM, David Decotigny
<david.decotigny@google.com> wrote:
> This commit implements the ndo_get_stats64() API for forcedeth. Since
> hardware stats are being updated from different contexts (process and
> timer), this commit adds protection (locking + atomic variables). For
> software stats, it relies on the u64_stats_sync.h API.
>
> Tested:
> =A0- 16-way SMP x86_64 ->
> =A0 =A0RX bytes:7244556582 (7.2 GB) =A0TX bytes:181904254 (181.9 MB)
> =A0- pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/tx=
_packets
>
>
>
> Signed-off-by: David Decotigny <david.decotigny@google.com>
> ---
> =A0drivers/net/ethernet/nvidia/forcedeth.c | =A0195 +++++++++++++++++=
++++++--------
> =A01 files changed, 144 insertions(+), 51 deletions(-)
>
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/et=
hernet/nvidia/forcedeth.c
> index ee8cce5..ff01d5e 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -65,7 +65,8 @@
> =A0#include <linux/slab.h>
> =A0#include <linux/uaccess.h>
> =A0#include <linux/prefetch.h>
> -#include =A0<linux/io.h>
> +#include <linux/u64_stats_sync.h>
> +#include <linux/io.h>
>
> =A0#include <asm/irq.h>
> =A0#include <asm/system.h>
> @@ -736,6 +737,18 @@ struct nv_skb_map {
> =A0* - tx setup is lockless: it relies on netif_tx_lock. Actual submi=
ssion
> =A0* =A0 =A0 needs netdev_priv(dev)->lock :-(
> =A0* - set_multicast_list: preparation lockless, relies on netif_tx_l=
ock.
> + *
> + * Hardware stats updates are protected by hwstats_lock:
> + * - updated by nv_do_stats_poll (timer). This is meant to avoid
> + * =A0 integer wraparound in the NIC stats registers, at low frequen=
cy
> + * =A0 (0.1 Hz)
> + * - updated by nv_get_ethtool_stats + nv_get_stats64
> + *
> + * Software stats are accessed only through a 64b synchronization
> + * point and are not subject to other synchronization techniques (on=
e
> + * unique updating thread for each stat [single queue RX/TX fast
> + * paths], or callers already synchronized [for tx_dropped, except f=
rom
> + * nv_open/nv_close]).
> =A0*/
>
> =A0/* in dev: base, irq */
> @@ -745,9 +758,13 @@ struct fe_priv {
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0struct napi_struct napi;
>
> - =A0 =A0 =A0 /* General data:
> - =A0 =A0 =A0 =A0* Locking: spin_lock(&np->lock); */
> + =A0 =A0 =A0 /* hardware stats are updated in syscall and timer */
> + =A0 =A0 =A0 spinlock_t hwstats_lock;
> =A0 =A0 =A0 =A0struct nv_ethtool_stats estats;
> +
> + =A0 =A0 =A0 /* software stats are accessed through a 64b synchroniz=
ation point */
> + =A0 =A0 =A0 struct u64_stats_sync swstats_syncp;
> +
> =A0 =A0 =A0 =A0int in_shutdown;
> =A0 =A0 =A0 =A0u32 linkspeed;
> =A0 =A0 =A0 =A0int duplex;
> @@ -798,6 +815,11 @@ struct fe_priv {
> =A0 =A0 =A0 =A0u32 nic_poll_irq;
> =A0 =A0 =A0 =A0int rx_ring_size;
>
> + =A0 =A0 =A0 /* RX software stats */
> + =A0 =A0 =A0 u64 stat_rx_packets;
> + =A0 =A0 =A0 u64 stat_rx_bytes; /* not always available in HW */
> + =A0 =A0 =A0 u64 stat_rx_missed_errors;
> +
> =A0 =A0 =A0 =A0/* media detection workaround.
> =A0 =A0 =A0 =A0 * Locking: Within irq hander or disable_irq+spin_lock=
(&np->lock);
> =A0 =A0 =A0 =A0 */
> @@ -820,6 +842,11 @@ struct fe_priv {
> =A0 =A0 =A0 =A0struct nv_skb_map *tx_end_flip;
> =A0 =A0 =A0 =A0int tx_stop;
>
> + =A0 =A0 =A0 /* TX software stats */
> + =A0 =A0 =A0 u64 stat_tx_packets; /* not always available in HW */
> + =A0 =A0 =A0 u64 stat_tx_bytes;
> + =A0 =A0 =A0 u64 stat_tx_dropped;
> +
> =A0 =A0 =A0 =A0/* msi/msi-x fields */
> =A0 =A0 =A0 =A0u32 msi_flags;
> =A0 =A0 =A0 =A0struct msix_entry msi_x_entry[NV_MSI_X_MAX_VECTORS];
> @@ -1635,11 +1662,19 @@ static void nv_mac_reset(struct net_device *d=
ev)
> =A0 =A0 =A0 =A0pci_push(base);
> =A0}
>
> -static void nv_get_hw_stats(struct net_device *dev)
> +/* Caller must appropriately lock netdev_priv(dev)->hwstats_lock */
> +static void nv_update_stats(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fe_priv *np =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0u8 __iomem *base =3D get_hwbase(dev);
>
> + =A0 =A0 =A0 /* If it happens that this is run in top-half context, =
then
> + =A0 =A0 =A0 =A0* replace the spin_lock of hwstats_lock with
> + =A0 =A0 =A0 =A0* spin_lock_irqsave() in calling functions. */
> + =A0 =A0 =A0 WARN_ONCE(in_irq(), "forcedeth: estats spin_lock(_bh) f=
rom top-half");
> + =A0 =A0 =A0 assert_spin_locked(&np->hwstats_lock);
> +
> + =A0 =A0 =A0 /* query hardware */
> =A0 =A0 =A0 =A0np->estats.tx_bytes +=3D readl(base + NvRegTxCnt);
> =A0 =A0 =A0 =A0np->estats.tx_zero_rexmt +=3D readl(base + NvRegTxZero=
ReXmt);
> =A0 =A0 =A0 =A0np->estats.tx_one_rexmt +=3D readl(base + NvRegTxOneRe=
Xmt);
> @@ -1698,40 +1733,67 @@ static void nv_get_hw_stats(struct net_device=
 *dev)
> =A0}
>
> =A0/*
> - * nv_get_stats: dev->get_stats function
> + * nv_get_stats64: dev->ndo_get_stats64 function
> =A0* Get latest stats value from the nic.
> =A0* Called with read_lock(&dev_base_lock) held for read -
> =A0* only synchronized against unregister_netdevice.
> =A0*/
> -static struct net_device_stats *nv_get_stats(struct net_device *dev)
> +static struct rtnl_link_stats64*
> +nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *sto=
rage)
> + =A0 =A0 =A0 __acquires(&netdev_priv(dev)->hwstats_lock)
> + =A0 =A0 =A0 __releases(&netdev_priv(dev)->hwstats_lock)
> =A0{
> =A0 =A0 =A0 =A0struct fe_priv *np =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned int syncp_start;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Note: because HW stats are not always available an=
d for
> + =A0 =A0 =A0 =A0* consistency reasons, the following ifconfig stats =
are
> + =A0 =A0 =A0 =A0* managed by software: rx_bytes, tx_bytes, rx_packet=
s and
> + =A0 =A0 =A0 =A0* tx_packets. The related hardware stats reported by=
 ethtool
> + =A0 =A0 =A0 =A0* should be equivalent to these ifconfig stats, with=
 4
> + =A0 =A0 =A0 =A0* additional bytes per packet (Ethernet FCS CRC).
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 /* software stats */
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 syncp_start =3D u64_stats_fetch_begin(&=
np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_packets =A0 =A0 =A0 =3D np-=
>stat_rx_packets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_packets =A0 =A0 =A0 =3D np-=
>stat_tx_packets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_bytes =A0 =A0 =A0 =A0 =3D n=
p->stat_rx_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_bytes =A0 =A0 =A0 =A0 =3D n=
p->stat_tx_bytes;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_dropped =A0 =A0 =A0 =3D np-=
>stat_tx_dropped;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_missed_errors =3D np->stat_=
rx_missed_errors;
> + =A0 =A0 =A0 } while (u64_stats_fetch_retry(&np->swstats_syncp, sync=
p_start));
>
> =A0 =A0 =A0 =A0/* If the nic supports hw counters then retrieve lates=
t values */
> - =A0 =A0 =A0 if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_ST=
ATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nv_get_hw_stats(dev);
> + =A0 =A0 =A0 if (np->driver_data & DEV_HAS_STATISTICS_V123) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_bh(&np->hwstats_lock);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Note: because HW stats are not alw=
ays available and
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* for consistency reasons, the follo=
wing ifconfig
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* stats are managed by software: rx_=
bytes, tx_bytes,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rx_packets and tx_packets. The rel=
ated hardware
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* stats reported by ethtool should b=
e equivalent to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* these ifconfig stats, with 4 addit=
ional bytes per
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* packet (Ethernet FCS CRC).
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nv_update_stats(dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* generic stats */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_errors =3D np->estats.rx_er=
rors_total;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_errors =3D np->estats.tx_er=
rors_total;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* meaningful only when NIC supports st=
ats v3 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->multicast =3D np->estats.rx_mu=
lticast;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* detailed rx_errors */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_length_errors =3D np->estat=
s.rx_length_error;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_over_errors =A0 =3D np->est=
ats.rx_over_errors;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_crc_errors =A0 =A0=3D np->e=
stats.rx_crc_errors;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_frame_errors =A0=3D np->est=
ats.rx_frame_align_error;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->rx_fifo_errors =A0 =3D np->est=
ats.rx_drop_frame;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* copy to net_device stats */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_fifo_errors =3D np->estat=
s.tx_fifo_errors;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_carrier_errors =3D np->es=
tats.tx_carrier_errors;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_crc_errors =3D np->estats=
=2Erx_crc_errors;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_over_errors =3D np->estat=
s.rx_over_errors;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_fifo_errors =3D np->estat=
s.rx_drop_frame;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_errors =3D np->estats.rx_=
errors_total;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_errors =3D np->estats.tx_=
errors_total;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* detailed tx_errors */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_carrier_errors =3D np->esta=
ts.tx_carrier_errors;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 storage->tx_fifo_errors =A0 =A0=3D np->=
estats.tx_fifo_errors;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&np->hwstats_lock);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 return &dev->stats;
> + =A0 =A0 =A0 return storage;
> =A0}
>
> =A0/*
> @@ -1932,8 +1994,11 @@ static void nv_drain_tx(struct net_device *dev=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->tx_ring.ex[i].bufh=
igh =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->tx_ring.ex[i].bufl=
ow =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nv_release_txskb(np, &np->tx_skb[i]=
))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.tx_dropped++=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nv_release_txskb(np, &np->tx_skb[i]=
)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(=
&np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_tx_dropped++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&n=
p->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->tx_skb[i].dma =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->tx_skb[i].dma_len =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->tx_skb[i].dma_single =3D 0;
> @@ -2390,11 +2455,14 @@ static int nv_tx_done(struct net_device *dev,=
 int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (np->desc_ver =3D=3D DESC_VER_1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (flags & NV_TX_LAST=
PACKET) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (fl=
ags & NV_TX_ERROR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if ((flags & NV_TX_RETRYERROR) && !(flags & NV_TX_RETRYCOUNT_M=
ASK))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if ((flags & NV_TX_RETRYERROR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 && !(flags & NV_TX_RETRYCOUNT_MASK))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0nv_legacybackoff_reseed(dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else=
 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.tx_packets++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_begin(&np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_end(&np->swstats_syncp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kf=
ree_skb_any(np->get_tx_ctx->skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->ge=
t_tx_ctx->skb =3D NULL;
> @@ -2403,11 +2471,14 @@ static int nv_tx_done(struct net_device *dev,=
 int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (flags & NV_TX2_LAS=
TPACKET) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (fl=
ags & NV_TX2_ERROR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT=
_MASK))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if ((flags & NV_TX2_RETRYERROR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 && !(flags & NV_TX2_RETRYCOUNT_MASK))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0nv_legacybackoff_reseed(dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else=
 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.tx_packets++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_begin(&np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_end(&np->swstats_syncp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kf=
ree_skb_any(np->get_tx_ctx->skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->ge=
t_tx_ctx->skb =3D NULL;
> @@ -2441,15 +2512,18 @@ static int nv_tx_done_optimized(struct net_de=
vice *dev, int limit)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (flags & NV_TX2_LASTPACKET) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (flags & NV_TX2_ERR=
OR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((fl=
ags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MASK)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((fl=
ags & NV_TX2_RETRYERROR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 && !(flags & NV_TX2_RETRYCOUNT_MASK)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0if (np->driver_data & DEV_HAS_GEAR_MODE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0nv_gear_backoff_reseed(dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0nv_legacybackoff_reseed(dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->st=
ats.tx_packets++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->st=
ats.tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_begin(&np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->stat_tx_bytes +=3D np->get_tx_ctx->skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 u64_stats_update_end(&np->swstats_syncp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb_any(np->=
get_tx_ctx->skb);
> @@ -2662,8 +2736,11 @@ static int nv_rx_process(struct net_device *de=
v, int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* the rest are hard errors */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & NV_RX_MISSEDFRAME)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_missed_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & NV_RX_MISSEDFRAME) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(&np->sw=
stats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_rx_missed_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&np->swst=
ats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0goto next_pkt;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0}
> @@ -2706,8 +2783,10 @@ static int nv_rx_process(struct net_device *de=
v, int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_put(skb, len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, =
dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_gro_receive(&np->napi, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_bytes +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(&np->swstats_syn=
cp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_rx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_rx_bytes +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&np->swstats_syncp=
);
> =A0next_pkt:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(np->get_rx.orig++ =3D=3D =
np->last_rx.orig))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0np->get_rx.orig =3D np=
->first_rx.orig;
> @@ -2790,8 +2869,10 @@ static int nv_rx_process_optimized(struct net_=
device *dev, int limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__vlan=
_hwaccel_put_tag(skb, vid);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_gro_receive(&np->=
napi, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_packets++=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_bytes +=3D=
 len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(=
&np->swstats_syncp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_rx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 np->stat_rx_bytes +=3D =
len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&n=
p->swstats_syncp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -4000,11 +4081,18 @@ static void nv_poll_controller(struct net_dev=
ice *dev)
> =A0#endif
>
> =A0static void nv_do_stats_poll(unsigned long data)
> + =A0 =A0 =A0 __acquires(&netdev_priv(dev)->hwstats_lock)
> + =A0 =A0 =A0 __releases(&netdev_priv(dev)->hwstats_lock)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev =3D (struct net_device *) data;
> =A0 =A0 =A0 =A0struct fe_priv *np =3D netdev_priv(dev);
>
> - =A0 =A0 =A0 nv_get_hw_stats(dev);
> + =A0 =A0 =A0 /* If lock is currently taken, the stats are being refr=
eshed
> + =A0 =A0 =A0 =A0* and hence fresh enough */
> + =A0 =A0 =A0 if (spin_trylock(&np->hwstats_lock)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nv_update_stats(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&np->hwstats_lock);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (!np->in_shutdown)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mod_timer(&np->stats_poll,
> @@ -4711,14 +4799,18 @@ static int nv_get_sset_count(struct net_devic=
e *dev, int sset)
> =A0 =A0 =A0 =A0}
> =A0}
>
> -static void nv_get_ethtool_stats(struct net_device *dev, struct etht=
ool_stats *estats, u64 *buffer)
> +static void nv_get_ethtool_stats(struct net_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct ethtool_stats *estats, u64 *buffer)
> + =A0 =A0 =A0 __acquires(&netdev_priv(dev)->hwstats_lock)
> + =A0 =A0 =A0 __releases(&netdev_priv(dev)->hwstats_lock)
> =A0{
> =A0 =A0 =A0 =A0struct fe_priv *np =3D netdev_priv(dev);
>
> - =A0 =A0 =A0 /* update stats */
> - =A0 =A0 =A0 nv_get_hw_stats(dev);
> -
> - =A0 =A0 =A0 memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_=
SS_STATS)*sizeof(u64));
> + =A0 =A0 =A0 spin_lock_bh(&np->hwstats_lock);
> + =A0 =A0 =A0 nv_update_stats(dev);
> + =A0 =A0 =A0 memcpy(buffer, &np->estats,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0nv_get_sset_count(dev, ETH_SS_STATS)*siz=
eof(u64));
> + =A0 =A0 =A0 spin_unlock_bh(&np->hwstats_lock);
> =A0}
>
> =A0static int nv_link_test(struct net_device *dev)
> @@ -5362,7 +5454,7 @@ static int nv_close(struct net_device *dev)
> =A0static const struct net_device_ops nv_netdev_ops =3D {
> =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_open,
> =A0 =A0 =A0 =A0.ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_close,
> - =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D nv_get_stats,
> + =A0 =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D nv_get_stats64,
> =A0 =A0 =A0 =A0.ndo_start_xmit =A0 =A0 =A0 =A0 =3D nv_start_xmit,
> =A0 =A0 =A0 =A0.ndo_tx_timeout =A0 =A0 =A0 =A0 =3D nv_tx_timeout,
> =A0 =A0 =A0 =A0.ndo_change_mtu =A0 =A0 =A0 =A0 =3D nv_change_mtu,
> @@ -5379,7 +5471,7 @@ static const struct net_device_ops nv_netdev_op=
s =3D {
> =A0static const struct net_device_ops nv_netdev_ops_optimized =3D {
> =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_open,
> =A0 =A0 =A0 =A0.ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D nv_close,
> - =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D nv_get_stats,
> + =A0 =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D nv_get_stats64,
> =A0 =A0 =A0 =A0.ndo_start_xmit =A0 =A0 =A0 =A0 =3D nv_start_xmit_opti=
mized,
> =A0 =A0 =A0 =A0.ndo_tx_timeout =A0 =A0 =A0 =A0 =3D nv_tx_timeout,
> =A0 =A0 =A0 =A0.ndo_change_mtu =A0 =A0 =A0 =A0 =3D nv_change_mtu,
> @@ -5418,6 +5510,7 @@ static int __devinit nv_probe(struct pci_dev *p=
ci_dev, const struct pci_device_i
> =A0 =A0 =A0 =A0np->dev =3D dev;
> =A0 =A0 =A0 =A0np->pci_dev =3D pci_dev;
> =A0 =A0 =A0 =A0spin_lock_init(&np->lock);
> + =A0 =A0 =A0 spin_lock_init(&np->hwstats_lock);
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(dev, &pci_dev->dev);
>
> =A0 =A0 =A0 =A0init_timer(&np->oom_kick);
> --
> 1.7.3.1
>
>
