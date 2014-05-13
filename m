From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1] vhost: avoid large order allocations
Date: Tue, 13 May 2014 11:40:49 +0300
Message-ID: <20140513084049.GE29442@redhat.com>
References: <1399970133-46783-1-git-send-email-mimu@linux.vnet.ibm.com>
	<1399970133-46783-2-git-send-email-mimu@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ddongch@cn.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	borntraeger@de.ibm.com
To: Michael Mueller <mimu@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1399970133-46783-2-git-send-email-mimu@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 10:35:33AM +0200, Michael Mueller wrote:
> From: Dong Dong Chen <ddongch@cn.ibm.com>
> 
> Under memory pressure we observe load issues with module vhost_net, as the
> vhost setup code will try to do an order 4 allocation for the device.
> The likeliness of this issue to occur can be reduced when the statically
> allocated variable "iov" in "struct vhost_virtqueue" is dynamically allocated
> with exactly the required size, reducing this to an order 2 allocation.
> 
> Signed-off-by: Dong Dong Chen <ddongch@cn.ibm.com>
> Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> Reviewed-by: Michael Mueller <mimu@linux.vnet.ibm.com>

Please dont' do this, extra indirection hurts performance.
Instead, please change vhost_net_open and scsi to allocate the whole
structure with vmalloc if kmalloc fails, along the lines of
74d332c13b2148ae934ea94dac1745ae92efe8e5

> ---
>  drivers/vhost/net.c   | 4 ++--
>  drivers/vhost/scsi.c  | 4 ++--
>  drivers/vhost/test.c  | 2 +-
>  drivers/vhost/vhost.c | 6 +++++-
>  drivers/vhost/vhost.h | 2 +-
>  5 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index be414d2..e3a9a68 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -374,7 +374,7 @@ static void handle_tx(struct vhost_net *net)
>  			break;
>  
>  		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> +					 UIO_MAXIOV,
>  					 &out, &in,
>  					 NULL, NULL);
>  		/* On error, stop handling until the next kick. */
> @@ -506,7 +506,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
>  			goto err;
>  		}
>  		r = vhost_get_vq_desc(vq->dev, vq, vq->iov + seg,
> -				      ARRAY_SIZE(vq->iov) - seg, &out,
> +				      UIO_MAXIOV - seg, &out,
>  				      &in, log, log_num);
>  		if (unlikely(r < 0))
>  			goto err;
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index cf50ce9..a70f1d9 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -607,7 +607,7 @@ tcm_vhost_do_evt_work(struct vhost_scsi *vs, struct tcm_vhost_evt *evt)
>  again:
>  	vhost_disable_notify(&vs->dev, vq);
>  	head = vhost_get_vq_desc(&vs->dev, vq, vq->iov,
> -			ARRAY_SIZE(vq->iov), &out, &in,
> +			UIO_MAXIOV, &out, &in,
>  			NULL, NULL);
>  	if (head < 0) {
>  		vs->vs_events_missed = true;
> @@ -946,7 +946,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
>  
>  	for (;;) {
>  		head = vhost_get_vq_desc(&vs->dev, vq, vq->iov,
> -					ARRAY_SIZE(vq->iov), &out, &in,
> +					UIO_MAXIOV, &out, &in,
>  					NULL, NULL);
>  		pr_debug("vhost_get_vq_desc: head: %d, out: %u in: %u\n",
>  					head, out, in);
> diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> index c2a54fb..2e01920 100644
> --- a/drivers/vhost/test.c
> +++ b/drivers/vhost/test.c
> @@ -54,7 +54,7 @@ static void handle_vq(struct vhost_test *n)
>  
>  	for (;;) {
>  		head = vhost_get_vq_desc(&n->dev, vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> +					 UIO_MAXIOV,
>  					 &out, &in,
>  					 NULL, NULL);
>  		/* On error, stop handling until the next kick. */
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 78987e4..9017a55 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -251,6 +251,8 @@ static int vhost_worker(void *data)
>  
>  static void vhost_vq_free_iovecs(struct vhost_virtqueue *vq)
>  {
> +	kfree(vq->iov);
> +	vq->iov = NULL;
>  	kfree(vq->indirect);
>  	vq->indirect = NULL;
>  	kfree(vq->log);
> @@ -267,11 +269,12 @@ static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
>  
>  	for (i = 0; i < dev->nvqs; ++i) {
>  		vq = dev->vqs[i];
> +		vq->iov = kmalloc(sizeof(*vq->iov) * UIO_MAXIOV, GFP_KERNEL);
>  		vq->indirect = kmalloc(sizeof *vq->indirect * UIO_MAXIOV,
>  				       GFP_KERNEL);
>  		vq->log = kmalloc(sizeof *vq->log * UIO_MAXIOV, GFP_KERNEL);
>  		vq->heads = kmalloc(sizeof *vq->heads * UIO_MAXIOV, GFP_KERNEL);
> -		if (!vq->indirect || !vq->log || !vq->heads)
> +		if (!vq->iov || !vq->indirect || !vq->log || !vq->heads)
>  			goto err_nomem;
>  	}
>  	return 0;
> @@ -310,6 +313,7 @@ void vhost_dev_init(struct vhost_dev *dev,
>  	for (i = 0; i < dev->nvqs; ++i) {
>  		vq = dev->vqs[i];
>  		vq->log = NULL;
> +		vq->iov = NULL;
>  		vq->indirect = NULL;
>  		vq->heads = NULL;
>  		vq->dev = dev;
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 35eeb2a..541f757 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -100,7 +100,7 @@ struct vhost_virtqueue {
>  	bool log_used;
>  	u64 log_addr;
>  
> -	struct iovec iov[UIO_MAXIOV];
> +	struct iovec *iov;
>  	struct iovec *indirect;
>  	struct vring_used_elem *heads;
>  	/* Protected by virtqueue mutex. */
> -- 
> 1.8.3.1
