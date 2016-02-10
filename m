From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost: disentangle vring endianness stuff from the
 core code
Date: Wed, 10 Feb 2016 13:48:09 +0200
Message-ID: <20160210132240-mutt-send-email-mst@redhat.com>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
 <20160113170947.23705.95216.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160113170947.23705.95216.stgit@bahia.huguette.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 06:09:47PM +0100, Greg Kurz wrote:
> The way vring endianness is being handled currently obfuscates
> the code in vhost_init_used().
> 
> This patch tries to fix that by doing the following:
> - move the the code that adjusts endianness to a dedicated helper
> - export this helper so that backends explicitely call it
> 
> No behaviour change.
> 
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> ---
>  drivers/vhost/net.c   |    3 +++
>  drivers/vhost/scsi.c  |    3 +++
>  drivers/vhost/test.c  |    2 ++
>  drivers/vhost/vhost.c |   16 +++++++++++-----
>  drivers/vhost/vhost.h |    1 +
>  5 files changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 9eda69e40678..df01c939cd00 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -917,6 +917,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  
>  		vhost_net_disable_vq(n, vq);
>  		vq->private_data = sock;
> +
> +		vhost_adjust_vring_endian(vq);
> +
>  		r = vhost_init_used(vq);
>  		if (r)
>  			goto err_used;


This is in fact a bug in existing code: if vhost_init_used
fails, it preferably should not have side-effects.
It's best to update it last thing.

> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index 29cfc57d496e..5a8363bfcb74 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1274,6 +1274,9 @@ vhost_scsi_set_endpoint(struct vhost_scsi *vs,
>  			vq = &vs->vqs[i].vq;
>  			mutex_lock(&vq->mutex);
>  			vq->private_data = vs_tpg;
> +
> +			vhost_adjust_vring_endian(vq);
> +
>  			vhost_init_used(vq);
>  			mutex_unlock(&vq->mutex);
>  		}
> diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> index f2882ac98726..75e3e0e9f5a8 100644
> --- a/drivers/vhost/test.c
> +++ b/drivers/vhost/test.c
> @@ -196,6 +196,8 @@ static long vhost_test_run(struct vhost_test *n, int test)
>  		oldpriv = vq->private_data;
>  		vq->private_data = priv;
>  
> +		vhost_adjust_vring_endian(vq);
> +
>  		r = vhost_init_used(&n->vqs[index]);
>  
>  		mutex_unlock(&vq->mutex);
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e02e06755ab7..b0a00340309e 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -123,6 +123,15 @@ static void vhost_disable_is_le(struct vhost_virtqueue *vq)
>  	vq->is_le = virtio_legacy_is_little_endian();
>  }
>  
> +void vhost_adjust_vring_endian(struct vhost_virtqueue *vq)
> +{
> +	if (!vq->private_data)
> +		vhost_disable_is_le(vq);
> +	else
> +		vhost_enable_is_le(vq);
> +}
> +EXPORT_SYMBOL_GPL(vhost_adjust_vring_endian);
> +
>  static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
>  			    poll_table *pt)
>  {

I'd prefer "vhost_update_is_le" here. "endian" might also mean
"user_be". But see below pls.


> @@ -1166,12 +1175,9 @@ int vhost_init_used(struct vhost_virtqueue *vq)
>  {
>  	__virtio16 last_used_idx;
>  	int r;
> -	if (!vq->private_data) {
> -		vhost_disable_is_le(vq);
> -		return 0;
> -	}
>  
> -	vhost_enable_is_le(vq);
> +	if (!vq->private_data)
> +		return 0;
>  
>  	r = vhost_update_used_flags(vq);
>  	if (r)

Looking at how callers use this, maybe we should just rename init_used
to vhost_vq_init_access. The _used suffix was a hint that we
access the vq used ring. But maybe what callers care about is
that it must be called after access_ok.

> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index d3f767448a72..88d86f45f756 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -162,6 +162,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
>  
>  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
>  		    unsigned int log_num, u64 len);
> +void vhost_adjust_vring_endian(struct vhost_virtqueue *vq);
>  
>  #define vq_err(vq, fmt, ...) do {                                  \
>  		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
