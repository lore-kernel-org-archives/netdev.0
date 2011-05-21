From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCHv2 09/14] virtio_net: fix TX capacity checks
	using new API
Date: Sat, 21 May 2011 11:43:19 +0930
Message-ID: <878vu0vm0w.fsf@rustcorp.com.au>
References: <cover.1305846412.git.mst@redhat.com>
	<42ca2494c92f572388e3ab4c6f613dd4f038361b.1305846412.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <42ca2494c92f572388e3ab4c6f613dd4f038361b.1305846412.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 20 May 2011 02:11:47 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> virtio net uses the number of sg entries to
> check for TX ring capacity freed. But this
> gives incorrect results when indirect buffers
> are used. Use the new capacity API instead.

OK, but this explanation needs enhancement, such as noting the actual
results of that miscalculation.  Something like:

 virtio_net uses the number of sg entries in the skb it frees to
 calculate how many descriptors in the ring have just been made
 available.  But this value is an overestimate: with indirect buffers
 each skb only uses one descriptor entry, meaning we may wake the queue
 only to find we still can't transmit anything.

 Using the new virtqueue_get_capacity() call, we can exactly determine
 the remaining capacity, so we should use that instead.

But, here's the side effect:
>  			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> +			free_old_xmit_skbs(vi);
> +			capacity = virtqueue_get_capacity(vi->svq);
>  			if (capacity >= 2+MAX_SKB_FRAGS) {

That capacity >= 2+MAX_SKB_FRAGS is too much for indirect buffers.  This
means we waste 20 entries in the ring, but OTOH if we hit OOM we fall
back to direct buffers and we *will* need this.

Which means this comment in the driver is now wrong:

	/* This can happen with OOM and indirect buffers. */
	if (unlikely(capacity < 0)) {
		if (net_ratelimit()) {
			if (likely(capacity == -ENOMEM)) {
				dev_warn(&dev->dev,
					 "TX queue failure: out of memory\n");
			} else {
				dev->stats.tx_fifo_errors++;
				dev_warn(&dev->dev,
					 "Unexpected TX queue failure: %d\n",
					 capacity);
			}
		}
		dev->stats.tx_dropped++;
		kfree_skb(skb);
		return NETDEV_TX_OK;
	}
	virtqueue_kick(vi->svq);

So I'm not applying this patch (nor the virtqueue_get_capacity
predeccessor) for the moment.

Thanks,
Rusty.
