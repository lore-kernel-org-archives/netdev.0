From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: netfront for review
Date: Wed, 02 May 2007 13:37:13 +1000
Message-ID: <1178077033.28659.173.camel@localhost.localdomain>
References: <4637D672.5030706@goop.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43520 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992678AbXEBDh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 23:37:29 -0400
In-Reply-To: <4637D672.5030706@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-01 at 17:08 -0700, Jeremy Fitzhardinge wrote:
> Add the Xen virtual network device driver.

(Herbert: there's a question for you: grep for Herbert)

OK, this is a remarkably non-trivial driver.  If the v0.1 of the driver
had been in the kernel, I'm sure it would have been about 1/4 the size
and far easier to review 8(

Nonetheless, I have scoured the entire thing.  It's not actually too
bad.

> struct netfront_cb {
>	struct page *page;
>	unsigned offset;
>};

Comment this please.  This is used when assembling incoming skbs, and
may well correspond to skb_shinfo(skb)->frags[0].page, but not always it
seems.

> struct netfront_info {
...
>	struct net_device *netdev;
...
>	unsigned int evtchn, irq;

The netdev has an irq field already.  Using it will probably help
ifconfig output, too.

>	u8 mac[ETH_ALEN];

You simply copy this into netdev->dev_addr: put it on the stack instead?

>	/*
>	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
>	 * is an index into a chain of free entries.
>	 */
> 	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];

This screams "union" to me, since you're stuffing ints into pointers.

> #define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)

This seems not to be used here, yet it's declared in the middle of the struct?

>	grant_ref_t gref_tx_head;
>	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
>	grant_ref_t gref_rx_head;
>	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];

There seems to be a correspondence between tx_skbs[], gref_tx_head and
grant_tx_ref[] - perhaps group them together with a nice comment?
Similarly the rx side.

> +/*
> + * Implement our own carrier flag: the network stack's version causes delays
> + * when the carrier is re-enabled (in particular, dev_activate() may not
> + * immediately be called, which can cause packet loss).
> + */
> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
> +#define netfront_carrier_ok(netif)	((netif)->carrier)

Well, you only call netfront_carrier_on() from one place, so it's pretty
easy to do "netif_carrier_on(); dev_activate();" there.

I don't think this is critical though.

> +			id  = txrsp->id;
> +			skb = np->tx_skbs[id];
> +			if (unlikely(gnttab_query_foreign_access(
> +				np->grant_tx_ref[id]) != 0)) {
> +				printk(KERN_ALERT "xennet_tx_buf_gc: warning "
> +				       "-- grant still in use by backend "
> +				       "domain.\n");
> +				BUG();
> +			}

I shall resist the urge to point out the can of worms that Xen opened by
trying to allow domains to directly access each others' memory.

> 	if ( nr_flips != 0 ) {

Style.

> +static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
> +			      struct netif_tx_request *tx)

This needs a big comment.  AFAICT, entries in the ring cannot cross page
boundaries.  And gso means that you have to put the first (partial) page
of the packet in the ring first, with the NETTXF_extra_info flag, then
the GSO stuff, then the rest of the packet.  This results in this
strange xennet_make_frags which does everything after the first packet
page (which may be only *part* of the skb head).

This also complicates xennet_get_responses(), where the loop is awkward
because it has to get the first bit, then do the loop.

>	skb_queue_head_init(&rxq);
>	skb_queue_head_init(&errq);
>	skb_queue_head_init(&tmpq);

I'd love a comment explaining exactly what these three queues are used
for.  It seems that rxq is the queue of received skbs (the result), tmpq
is parts of the current skb for multi-fragment skbs, and errq is skbs to
be discarded, which are kept around during the function because ? (we
may need to unmap the pages?)

> +		/*
> +		 * Truesize must approximates the size of true data plus

s/approximates/approximate/ or s/must //.

> +/*
> + * Nothing to do here. Virtual interface is point-to-point and the
> + * physical interface is probably promiscuous anyway.
> + */
> +static void xennet_set_multicast_list(struct net_device *dev)
> +{
> +}

Hmm, you can just leave this as NULL then.  It will fail if someone
tries to set multicast on it, but that's probably correct behaviour.

> +static int xennet_change_mtu(struct net_device *dev, int mtu)
> +{
> +	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> +
> +	if (mtu > max)
> +		return -EINVAL;
> +	dev->mtu = mtu;
> +	return 0;
> +}

This seems odd to me: just because a device does TSO should we really
allow huge mtu settings?  Herbert?

> +	/* Initialise {tx,rx}_skbs as a free chain containing every entry. */
> +	for (i = 0; i <= NET_TX_RING_SIZE; i++) {
> +		np->tx_skbs[i] = (void *)((unsigned long) i+1);
> +		np->grant_tx_ref[i] = GRANT_INVALID_REF;
> +	}
> +
> +	for (i = 0; i < NET_RX_RING_SIZE; i++) {
> +		np->rx_skbs[i] = NULL;
> +		np->grant_rx_ref[i] = GRANT_INVALID_REF;
> +	}

Yay, a comment!  Boo, it's wrong!  rx_skbs isn't a chain at all.

> static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev)
> {
> 	int i, err = 0;

I wouldn't initialize err here: you don't need it, and it just prevents
gcc from warning about uninitialized uses if someone screws up the code.

> +	for (i = 0; i < ETH_ALEN; i++) {
> +		mac[i] = simple_strtoul(s, &e, 16);
> +		if ((s == e) || (*e != ((i == ETH_ALEN-1) ? '\0' : ':'))) {
> +			kfree(macstr);
> +			return -ENOENT;
> +		}
> +		s = e+1;
> +	}

There are several places in the kernel which do this.  I think I'll
write a parse_macaddr() helper.  But that's an aside.

> +	txs = (struct netif_tx_sring *)get_zeroed_page(GFP_KERNEL);
> +	if (!txs) {
> +		err = -ENOMEM;
> +		xenbus_dev_fatal(dev, err, "allocating tx ring page");
> +		goto fail;
> +	}
> +	SHARED_RING_INIT(txs);
> +	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
> +
> +	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
> +	if (err < 0) {
> +		free_page((unsigned long)txs);
> +		goto fail;
> +	}
> +
> +	info->tx_ring_ref = err;
> +	rxs = (struct netif_rx_sring *)get_zeroed_page(GFP_KERNEL);
> +	if (!rxs) {
> +		err = -ENOMEM;
> +		xenbus_dev_fatal(dev, err, "allocating rx ring page");
> +		goto fail;

Why doesn't this (and the following) need to free txs?  Higher level
magic?  In general this function seems to lack cleanup.

> +	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
> +			   "feature-rx-copy", "%u", &feature_rx_copy);
> +	if (err != 1)
> +		feature_rx_copy = 0;
> +	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
> +			   "feature-rx-flip", "%u", &feature_rx_flip);
> +	if (err != 1)
> +		feature_rx_flip = 1;

This second one deserves a comment.  If it doesn't set feature_rx_flip
it's *on*?  Historical reasons?

> +	/*
> +	 * Recovery procedure:
> +	 *  NB. Freelist index entries are always going to be less than
> +	 *  PAGE_OFFSET, whereas pointers to skbs will always be equal or
> +	 *  greater than PAGE_OFFSET: we use this property to distinguish
> +	 *  them.
> +	 */

You know, this comment would be great near that union declaration.  Not
here where it's a long way from the code which uses that fact.

> +static int xennet_sysfs_addif(struct net_device *netdev)
> +{
> +	int i;
> +	int error = 0;

Again with the unused error initialization (plus, elsewhere it's "err").

> +static void xennet_sysfs_delif(struct net_device *netdev)
> +{
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(xennet_attrs); i++) {
> +		device_remove_file(&netdev->dev, &xennet_attrs[i]);
> +	}
> +}

Gratuitous braces around single line.

> +	printk(KERN_INFO "Initialising virtual ethernet driver.\n");

Some mention of Xen in this printk would be good, since we're already
have multiple virtual ethernet drivers.

Phew, that's the end.

Cheers!
Rusty.

