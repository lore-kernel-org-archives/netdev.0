From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: max s/g to match qemu
Date: Tue, 14 Sep 2010 18:01:02 +0200
Message-ID: <20100914160102.GA13560@redhat.com>
References: <20100914155305.3293.92519.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100914155305.3293.92519.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2010 at 11:53:05PM +0800, Jason Wang wrote:
> Qemu supports up to UIO_MAXIOV s/g so we have to match that because guest
> drivers may rely on this.
> 
> Allocate indirect and log arrays dynamically to avoid using too much contigious
> memory and make the length of hdr array to match the header length since each
> iovec entry has a least one byte.
> 
> Test with copying large files w/ and w/o migration in both linux and windows
> guests.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Looks good, I'll queue this up for 2.6.37.
Thanks!

> ---
>  drivers/vhost/net.c   |    2 +-
>  drivers/vhost/vhost.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  drivers/vhost/vhost.h |   18 ++++++++----------
>  3 files changed, 57 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 29e850a..e828ef1 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -243,7 +243,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
>  	int r, nlogs = 0;
>  
>  	while (datalen > 0) {
> -		if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
> +		if (unlikely(headcount >= UIO_MAXIOV)) {
>  			r = -ENOBUFS;
>  			goto err;
>  		}
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index c579dcc..a45270e 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -212,6 +212,45 @@ static int vhost_worker(void *data)
>  	}
>  }
>  
> +/* Helper to allocate iovec buffers for all vqs. */
> +static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
> +{
> +	int i;
> +	for (i = 0; i < dev->nvqs; ++i) {
> +		dev->vqs[i].indirect = kmalloc(sizeof *dev->vqs[i].indirect *
> +					       UIO_MAXIOV, GFP_KERNEL);
> +		dev->vqs[i].log = kmalloc(sizeof *dev->vqs[i].log * UIO_MAXIOV,
> +					  GFP_KERNEL);
> +		dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads *
> +					    UIO_MAXIOV, GFP_KERNEL);
> +
> +		if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
> +			!dev->vqs[i].heads)
> +			goto err_nomem;
> +	}
> +	return 0;
> +err_nomem:
> +	for (; i >= 0; --i) {
> +		kfree(dev->vqs[i].indirect);
> +		kfree(dev->vqs[i].log);
> +		kfree(dev->vqs[i].heads);

We probably want to assign NULL values here, same as below.
I have fixed this up in my tree.

> +	}
> +	return -ENOMEM;
> +}
> +
> +static void vhost_dev_free_iovecs(struct vhost_dev *dev)
> +{
> +	int i;
> +	for (i = 0; i < dev->nvqs; ++i) {
> +		kfree(dev->vqs[i].indirect);
> +		dev->vqs[i].indirect = NULL;
> +		kfree(dev->vqs[i].log);
> +		dev->vqs[i].log = NULL;
> +		kfree(dev->vqs[i].heads);
> +		dev->vqs[i].heads = NULL;
> +	}
> +}
> +
>  long vhost_dev_init(struct vhost_dev *dev,
>  		    struct vhost_virtqueue *vqs, int nvqs)
>  {
> @@ -229,6 +268,9 @@ long vhost_dev_init(struct vhost_dev *dev,
>  	dev->worker = NULL;
>  
>  	for (i = 0; i < dev->nvqs; ++i) {
> +		dev->vqs[i].log = NULL;
> +		dev->vqs[i].indirect = NULL;
> +		dev->vqs[i].heads = NULL;
>  		dev->vqs[i].dev = dev;
>  		mutex_init(&dev->vqs[i].mutex);
>  		vhost_vq_reset(dev, dev->vqs + i);
> @@ -295,6 +337,10 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
>  	if (err)
>  		goto err_cgroup;
>  
> +	err = vhost_dev_alloc_iovecs(dev);
> +	if (err)
> +		goto err_cgroup;
> +
>  	return 0;
>  err_cgroup:
>  	kthread_stop(worker);
> @@ -345,6 +391,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
>  			fput(dev->vqs[i].call);
>  		vhost_vq_reset(dev, dev->vqs + i);
>  	}
> +	vhost_dev_free_iovecs(dev);
>  	if (dev->log_ctx)
>  		eventfd_ctx_put(dev->log_ctx);
>  	dev->log_ctx = NULL;
> @@ -946,7 +993,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  	}
>  
>  	ret = translate_desc(dev, indirect->addr, indirect->len, vq->indirect,
> -			     ARRAY_SIZE(vq->indirect));
> +			     UIO_MAXIOV);
>  	if (unlikely(ret < 0)) {
>  		vq_err(vq, "Translation failure %d in indirect.\n", ret);
>  		return ret;
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index afd7729..edc8929 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -15,11 +15,6 @@
>  
>  struct vhost_device;
>  
> -enum {
> -	/* Enough place for all fragments, head, and virtio net header. */
> -	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
> -};
> -
>  struct vhost_work;
>  typedef void (*vhost_work_fn_t)(struct vhost_work *work);
>  
> @@ -93,12 +88,15 @@ struct vhost_virtqueue {
>  	bool log_used;
>  	u64 log_addr;
>  
> -	struct iovec indirect[VHOST_NET_MAX_SG];
> -	struct iovec iov[VHOST_NET_MAX_SG];
> -	struct iovec hdr[VHOST_NET_MAX_SG];
> +	struct iovec iov[UIO_MAXIOV];
> +	/* hdr is used to store the virtio header.
> +	 * Since each iovec has >= 1 byte length, we never need more than
> +	 * header length entries to store the header. */
> +	struct iovec hdr[sizeof(struct virtio_net_hdr_mrg_rxbuf)];
> +	struct iovec *indirect;
>  	size_t vhost_hlen;
>  	size_t sock_hlen;
> -	struct vring_used_elem heads[VHOST_NET_MAX_SG];
> +	struct vring_used_elem *heads;
>  	/* We use a kind of RCU to access private pointer.
>  	 * All readers access it from worker, which makes it possible to
>  	 * flush the vhost_work instead of synchronize_rcu. Therefore readers do
> @@ -109,7 +107,7 @@ struct vhost_virtqueue {
>  	void *private_data;
>  	/* Log write descriptors */
>  	void __user *log_base;
> -	struct vhost_log log[VHOST_NET_MAX_SG];
> +	struct vhost_log *log;
>  };
>  
>  struct vhost_dev {
