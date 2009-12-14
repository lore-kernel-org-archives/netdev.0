From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers function for virtio
Date: Mon, 14 Dec 2009 13:55:59 +1030
Message-ID: <200912141355.59678.rusty@rustcorp.com.au>
References: <1258697359.7416.14.camel@localhost.localdomain> <1260534506.30371.6.camel@localhost.localdomain> <1260534805.30371.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52568 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbZLND0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 22:26:09 -0500
In-Reply-To: <1260534805.30371.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Dec 2009 11:03:25 pm Shirley Ma wrote:
> Signed-off-by: <xma@us.ibm.com>

Hi Shirley,

   These patches look quite close.  More review to follow :)

   This title needs revision.  It should start with virtio: (all the virtio
patches do, for easy identification after merge), eg:

	Subject: virtio: Add destroy callback for unused buffers

It also needs a commit message which explains the problem and the solution.
Something like this:

	There's currently no way for a virtio driver to ask for unused
	buffers, so it has to keep a list itself to reclaim them at shutdown.
	This is redundant, since virtio_ring stores that information.  So
	add a new hook to do this: virtio_net will be the first user.

> -------------
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c708ecc..bb5eb7b 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -107,6 +107,16 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
>  	return p;
>  }
>  
> +static void virtio_net_free_pages(void *buf)
> +{
> +	struct page *page, *next;
> +
> +	for (page = buf; page; page = next) {
> +		next = (struct page *)page->private;
> +		__free_pages(page, 0);
> +	}
> +}
> +
>  static void skb_xmit_done(struct virtqueue *svq)
>  {
>  	struct virtnet_info *vi = svq->vdev->priv;

This belongs in one of the future patches: it will cause an unused warning
and is logically not part of this patch anyway.

> +static int vring_destroy_bufs(struct virtqueue *_vq, void (*destroy)(void *))
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	void *buf;
> +	unsigned int i;
> +	int freed = 0;

unsigned int for return and freed counter?  Means changing prototype, but
negative return isn't useful here.

> +
> +	START_USE(vq);
> +
> +	for (i = 0; i < vq->vring.num; i++) {
> +		if (vq->data[i]) {
> +			/* detach_buf clears data, so grab it now. */
> +			buf = vq->data[i];
> +			detach_buf(vq, i);
> +			destroy(buf);
> +			freed++;

You could simplify this a bit, since the queue must be inactive:

	destroy(vq->data[i]);
	detach_buf(vq, i);
	freed++;

> +		}
> +	}
> +
> +	END_USE(vq);
> +	return freed;

Perhaps add a:
	/* That should have freed everything. */
	BUG_ON(vq->num_free != vq->vring.num)

>  	void (*disable_cb)(struct virtqueue *vq);
>  	bool (*enable_cb)(struct virtqueue *vq);
> +	int (*destroy_bufs)(struct virtqueue *vq, void (*destory)(void *));

destory typo :)

Cheers,
Rusty.
