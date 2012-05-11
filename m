From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5] tilegx network driver: initial support
Date: Fri, 11 May 2012 14:54:05 +0100
Message-ID: <1336744445.2874.57.camel@bwh-desktop.uk.solarflarecom.com>
References: <201205011759.q41HxR21020043@farm-0012.internal.tilera.com>
	 <20120503.014156.149171097979026872.davem@davemloft.net>
	 <201205031936.q43Ja9Xb031644@lab-41.internal.tilera.com>
	 <20120504.024216.1730395431103337434.davem@davemloft.net>
	 <201205091452.q49EqcO7005975@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <arnd@arndb.de>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46900 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759847Ab2EKNyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 09:54:12 -0400
In-Reply-To: <201205091452.q49EqcO7005975@farm-0027.internal.tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's another very incomplete review for you.

On Wed, 2012-05-09 at 06:42 -0400, Chris Metcalf wrote:
> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/tile/tilegx.c
[...]
> +/* Define to support GSO. */
> +#undef TILE_NET_GSO

GSO is always enabled by the networking core.

> +/* Define to support TSO. */
> +#define TILE_NET_TSO

No, put NETIF_F_TSO in hw_features so it can be switched at run-time.

(Currently that won't work if you don't set dev->ethtool_ops, but that's
a bug that can be fixed.)

> +/* Use 3000 to enable the Linux Traffic Control (QoS) layer, else 0. */
> +#define TILE_NET_TX_QUEUE_LEN 0

This can be changed through sysfs, so there is no need for a compile-
time option.

> +/* Define to dump packets (prints out the whole packet on tx and rx). */
> +#undef TILE_NET_DUMP_PACKETS

Should really be controlled through a 'debug' module parameter (see
netif_msg_init(), netif_msg_pktdata(), etc.)

[...]
> +/* Total header bytes per equeue slot.  Must be big enough for 2 bytes
> + * of NET_IP_ALIGN alignment, plus 14 bytes (?) of L2 header, plus up to
> + * 60 bytes of actual TCP header.  We round up to align to cache lines.
> + */
> +#define HEADER_BYTES 128
> +
> +/* Maximum completions per cpu per device (must be a power of two).
> + * ISSUE: What is the right number here?
> + */
> +#define TILE_NET_MAX_COMPS 64
> +
> +#define MAX_FRAGS (65536 / PAGE_SIZE + 2 + 1)

Should be MAX_SKB_FRAGS + 1.

[...]
> +/* Help the kernel transmit a packet. */
> +static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct tile_net_priv *priv = netdev_priv(dev);
> +
> +	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
> +
> +	struct tile_net_egress *egress = &egress_for_echannel[priv->echannel];
> +	gxio_mpipe_equeue_t *equeue = egress->equeue;
> +
> +	struct tile_net_comps *comps =
> +		info->comps_for_echannel[priv->echannel];
> +
> +	struct skb_shared_info *sh = skb_shinfo(skb);
> +
> +	unsigned int len = skb->len;
> +	unsigned char *data = skb->data;
> +
> +	unsigned int num_frags;
> +	struct frag frags[MAX_FRAGS];
> +	gxio_mpipe_edesc_t edescs[MAX_FRAGS];
> +
> +	unsigned int i;
> +
> +	int cid;
> +
> +	s64 slot;
> +
> +	unsigned long irqflags;

Please, no blank lines between your declarations.

[...]
> +	/* Reserve slots, or return NETDEV_TX_BUSY if "full". */
> +	slot = gxio_mpipe_equeue_try_reserve(equeue, num_frags);
> +	if (slot < 0) {
> +		local_irq_restore(irqflags);
> +		/* ISSUE: "Virtual device xxx asks to queue packet". */
> +		return NETDEV_TX_BUSY;
> +	}

You're supposed to stop queues when they're full.  And since that state
appears to be per-CPU, I think this device needs to be multiqueue with
one TX queue per CPU and ndo_select_queue defined accordingly.

> +	for (i = 0; i < num_frags; i++)
> +		gxio_mpipe_equeue_put_at(equeue, edescs[i], slot + i);
> +
> +	/* Wait for a free completion entry.
> +	 * ISSUE: Is this the best logic?
> +	 * ISSUE: Can this cause undesirable "blocking"?
> +	 */
> +	while (comps->comp_next - comps->comp_last >= TILE_NET_MAX_COMPS - 1)
> +		tile_net_free_comps(equeue, comps, 32, false);

I'm not convinced you should be processing completions here at all.  But
certainly you should have stopped the queue earlier rather than having
to wait here.

> +	/* Update the completions array. */
> +	cid = comps->comp_next % TILE_NET_MAX_COMPS;
> +	comps->comp_queue[cid].when = slot + num_frags;
> +	comps->comp_queue[cid].skb = skb;
> +	comps->comp_next++;
> +
> +	/* HACK: Track "expanded" size for short packets (e.g. 42 < 60). */
> +	atomic_add(1, (atomic_t *)&priv->stats.tx_packets);
> +	atomic_add((len >= ETH_ZLEN) ? len : ETH_ZLEN,
> +		   (atomic_t *)&priv->stats.tx_bytes);

You mustn't treat random fields to atomic_t.  For one thing, atomic_t
contains an int while stats are unsigned long...

Also, you're adding cache contention between all your CPUs here.  You
should maintain these stats per-CPU and then sum them in
tile_net_get_stats().  Then you can just use ordinary additions.

[...]
> +/* Ioctl commands. */
> +static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	return -EOPNOTSUPP;
> +}

So why define it at all?

[...]
> +static void tile_net_dev_init(const char *name, const uint8_t *mac)
> +{
[...]
> +	/* Register the network device. */
> +	ret = register_netdev(dev);
> +	if (ret) {
> +		netdev_err(dev, "register_netdev failed %d\n", ret);
> +		free_netdev(dev);
> +		return;
> +	}
> +
> +	/* Get the MAC address and set it in the device struct; this must
> +	 * be done before the device is opened.
[...]

So you had better do this before calling register_netdev(), as the
device can be opened immediately after that...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
