From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
	function for virtio
Date: Sun, 13 Dec 2009 12:26:33 +0200
Message-ID: <20091213102632.GB6789@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260534805.30371.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260534805.30371.10.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2009 at 04:33:25AM -0800, Shirley Ma wrote:
> Signed-off-by: <xma@us.ibm.com>
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

This is not the best way to split the patch,
as I commented separately: this adds static function
but no way to see whether it does what it should do.
If you think about it, free should always go into same patch
that does alloc.

> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index fbd2ecd..db83465 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -334,6 +334,29 @@ static bool vring_enable_cb(struct virtqueue *_vq)
>  	return true;
>  }
>  
> +static int vring_destroy_bufs(struct virtqueue *_vq, void (*destroy)(void *))
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	void *buf;
> +	unsigned int i;
> +	int freed = 0;
> +
> +	START_USE(vq);
> +
> +	for (i = 0; i < vq->vring.num; i++) {

I prefer ++i in such code personally.

> +		if (vq->data[i]) {
> +			/* detach_buf clears data, so grab it now. */
> +			buf = vq->data[i];
> +			detach_buf(vq, i);

Hmm, you are calling detach on a buffer which was not used.
It's not safe to call this while host might use buffers, is it?
Please document this and other assumptions you are making.

> +			destroy(buf);
> +			freed++;

++freed here as well.

> +		}
> +	}
> +

It's usually better not to put {} around single statement blocks.

> +	END_USE(vq);
> +	return freed;
> +}
> +
>  irqreturn_t vring_interrupt(int irq, void *_vq)
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
> @@ -360,6 +383,7 @@ static struct virtqueue_ops vring_vq_ops = {
>  	.kick = vring_kick,
>  	.disable_cb = vring_disable_cb,
>  	.enable_cb = vring_enable_cb,
> +	.destroy_bufs = vring_destroy_bufs,
>  };
>  
>  struct virtqueue *vring_new_virtqueue(unsigned int num,
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 057a2e0..e6d7d77 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -71,6 +71,7 @@ struct virtqueue_ops {
>  
>  	void (*disable_cb)(struct virtqueue *vq);
>  	bool (*enable_cb)(struct virtqueue *vq);
> +	int (*destroy_bufs)(struct virtqueue *vq, void (*destory)(void *));

Typo above.  Please document the new field.
Also please document assumptions about usage.

I think callback should get struct virtqueue *vq, and decrement num.
And destroy_bufs should return void, which is much more natural for a
destructor.


That said - do we have to use a callback?
I think destroy_buf which returns data pointer,
and which we call repeatedly until we get NULL
or error, would be an a better, more flexible API.
This is not critical though.


>  };
>  
>  /**
> 
