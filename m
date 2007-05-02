From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: netfront for review
Date: Wed, 02 May 2007 12:47:12 -0700
Message-ID: <4638EAC0.7020107@goop.org>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1766842AbXEBTsM@vger.kernel.org>
In-Reply-To: <1178077033.28659.173.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Gerd, Herbert: there's some questions directed to you down there.)

Rusty Russell wrote:
>> 	/*
>> 	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
>> 	 * is an index into a chain of free entries.
>> 	 */
>> 	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
>>     
>
> This screams "union" to me, since you're stuffing ints into pointers.
>   

This was a useful cleanup, and I think it revealed a bug.

Gerd, in change 11196:b85da7cd9ea5 "front: Fix rx buffer leak when
tearing down an interface." you added a call to
"add_id_to_freelist(np->rx_skbs, id);".  However, rx_skbs doesn't have
an extra entry for the list head, and there's never any corresponding
get_id_from_freelist(np->rx_skbs).  What should it be?

>> 	grant_ref_t gref_tx_head;
>> 	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
>> 	grant_ref_t gref_rx_head;
>> 	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
>>     
>
> There seems to be a correspondence between tx_skbs[], gref_tx_head and
> grant_tx_ref[] - perhaps group them together with a nice comment?
> Similarly the rx side.
>   

Yep, rearranged.  And I added an explicit separate freelist head for
tx_skbs, so it matches the grant side (which doesn't need the +1 as a
result).

>> +/*
>> + * Implement our own carrier flag: the network stack's version causes delays
>> + * when the carrier is re-enabled (in particular, dev_activate() may not
>> + * immediately be called, which can cause packet loss).
>> + */
>> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
>> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
>> +#define netfront_carrier_ok(netif)	((netif)->carrier)
>>     
>
> Well, you only call netfront_carrier_on() from one place, so it's pretty
> easy to do "netif_carrier_on(); dev_activate();" there.
>
> I don't think this is critical though.
>   

Are you saying that we wouldn't need to have a private carrier flag if
we do the "netif_carrier_on(); dev_activate()" sequence instead?

>> +static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
>> +			      struct netif_tx_request *tx)
>>     
>
> This needs a big comment.  AFAICT, entries in the ring cannot cross page
> boundaries.  And gso means that you have to put the first (partial) page
> of the packet in the ring first, with the NETTXF_extra_info flag, then
> the GSO stuff, then the rest of the packet.  This results in this
> strange xennet_make_frags which does everything after the first packet
> page (which may be only *part* of the skb head).
>
> This also complicates xennet_get_responses(), where the loop is awkward
> because it has to get the first bit, then do the loop.
>
>   
>> 	skb_queue_head_init(&rxq);
>> 	skb_queue_head_init(&errq);
>> 	skb_queue_head_init(&tmpq);
>>     
>
> I'd love a comment explaining exactly what these three queues are used
> for.  It seems that rxq is the queue of received skbs (the result), tmpq
> is parts of the current skb for multi-fragment skbs, and errq is skbs to
> be discarded, which are kept around during the function because ? (we
> may need to unmap the pages?)
>   

Um, Herbert?

>> +	txs = (struct netif_tx_sring *)get_zeroed_page(GFP_KERNEL);
>> +	if (!txs) {
>> +		err = -ENOMEM;
>> +		xenbus_dev_fatal(dev, err, "allocating tx ring page");
>> +		goto fail;
>> +	}
>> +	SHARED_RING_INIT(txs);
>> +	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
>> +
>> +	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
>> +	if (err < 0) {
>> +		free_page((unsigned long)txs);
>> +		goto fail;
>> +	}
>> +
>> +	info->tx_ring_ref = err;
>> +	rxs = (struct netif_rx_sring *)get_zeroed_page(GFP_KERNEL);
>> +	if (!rxs) {
>> +		err = -ENOMEM;
>> +		xenbus_dev_fatal(dev, err, "allocating rx ring page");
>> +		goto fail;
>>     
>
> Why doesn't this (and the following) need to free txs?  Higher level
> magic?  In general this function seems to lack cleanup.
>   

Yes, I need to look at this more closely.  It does seem that txs and rxs
will get leaked.

>> +	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>> +			   "feature-rx-copy", "%u", &feature_rx_copy);
>> +	if (err != 1)
>> +		feature_rx_copy = 0;
>> +	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>> +			   "feature-rx-flip", "%u", &feature_rx_flip);
>> +	if (err != 1)
>> +		feature_rx_flip = 1;
>>     
>
> This second one deserves a comment.  If it doesn't set feature_rx_flip
> it's *on*?  Historical reasons

Guess so.  It defaults to flip.  I simplified the rx_copy/flip module
parameter to a simple rx_mode=0/1, but this is preserved from the
original.  My guess is that originally there was only flip, and copy was
added later.


    J
