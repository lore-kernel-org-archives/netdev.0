From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix data corruption with OOM
Date: Mon, 26 Oct 2009 11:07:13 +0200
Message-ID: <20091026090713.GA23510@redhat.com>
References: <20091025170340.GA22099@redhat.com> <200910261211.52148.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754999AbZJZJJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 05:09:41 -0400
Content-Disposition: inline
In-Reply-To: <200910261211.52148.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 12:11:51PM +1030, Rusty Russell wrote:
> On Mon, 26 Oct 2009 03:33:40 am Michael S. Tsirkin wrote:
> > virtio net used to unlink skbs from send queues on error,
> > but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
> > we do not do this. This causes guest data corruption and crashes
> > with vhost since net core can requeue the skb or free it without
> > it being taken off the list.
> > 
> > This patch fixes this by queueing the skb after successfull
> > transmit.
> 
> I originally thought that this was racy: as soon as we do add_buf, we need to
> make sure we're ready for the callback (for virtio_pci, it's ->kick, but we
> shouldn't rely on that).
> 
> So a comment would be nice.  How's this?
> 
> Subject: virtio-net: fix data corruption with OOM
> Date: Sun, 25 Oct 2009 19:03:40 +0200
> From: "Michael S. Tsirkin" <mst@redhat.com>

Another, and hopefully the last, note, is that
git-am can only handle Subject/From lines
at the beginning of the message.
So git style of the mail would be

	Subject: XXX
	From: YYY

	Description

	---

	Discussion and notes.

I think it's weird. We could invent some kind of separator
that would make git-am accept Subject/From/Date lines in
the middle of the message, so that discussion can come before
the description. Worth it?

> 
> virtio net used to unlink skbs from send queues on error,
> but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
> we do not do this. This causes guest data corruption and crashes
> with vhost since net core can requeue the skb or free it without
> it being taken off the list.
> 
> This patch fixes this by queueing the skb after successful
> transmit.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (+ comment)
> ---
> 
> Rusty, here's a fix for another data corrupter I saw.
> This fixes a regression from 2.6.31, so definitely
> 2.6.32 I think. Comments?
> 
>  drivers/net/virtio_net.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -516,8 +516,7 @@ again:
>  	/* Free up any pending old buffers before queueing new ones. */
>  	free_old_xmit_skbs(vi);
>  
> -	/* Put new one in send queue and do transmit */
> -	__skb_queue_head(&vi->send, skb);
> +	/* Try to transmit */
>  	capacity = xmit_skb(vi, skb);
>  
>  	/* This can happen with OOM and indirect buffers. */
> @@ -531,8 +530,17 @@ again:
>  		}
>  		return NETDEV_TX_BUSY;
>  	}
> +	vi->svq->vq_ops->kick(vi->svq);
>  
> -	vi->svq->vq_ops->kick(vi->svq);
> +	/*
> +	 * Put new one in send queue.  You'd expect we'd need this before
> +	 * xmit_skb calls add_buf(), since the callback can be triggered
> +	 * immediately after that.  But since the callback just triggers
> +	 * another call back here, normal network xmit locking prevents the
> +	 * race.
> +	 */
> +	__skb_queue_head(&vi->send, skb);
> +
>  	/* Don't wait up for transmitted skbs to be freed. */
>  	skb_orphan(skb);
>  	nf_reset(skb);
