From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] vhost: move acked_features to VQs
Date: Thu, 5 Jun 2014 15:16:16 +0300
Message-ID: <20140605121616.GA17665@redhat.com>
References: <1401962195-15066-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1401962195-15066-1-git-send-email-mst@redhat.com>
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

On Thu, Jun 05, 2014 at 01:44:14PM +0300, Michael S. Tsirkin wrote:
> Refactor code to make sure features are only accessed
> under VQ mutex. This makes everything simpler, no need
> for RCU here anymore.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Ouch, I sent out wrong version of the patch.
Self-NACK, will repost.
Sorry about the noise.

> ---
> 
> This is on top of the recent pull request that I sent.
> 
>  drivers/vhost/vhost.h | 11 +++--------
>  drivers/vhost/net.c   |  8 +++-----
>  drivers/vhost/scsi.c  | 22 +++++++++++++---------
>  drivers/vhost/test.c  |  9 ++++++---
>  drivers/vhost/vhost.c | 31 ++++++++++++++++---------------
>  5 files changed, 41 insertions(+), 40 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 35eeb2a..ff454a0 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -105,6 +105,7 @@ struct vhost_virtqueue {
>  	struct vring_used_elem *heads;
>  	/* Protected by virtqueue mutex. */
>  	void *private_data;
> +	unsigned acked_features;
>  	/* Log write descriptors */
>  	void __user *log_base;
>  	struct vhost_log *log;
> @@ -117,7 +118,6 @@ struct vhost_dev {
>  	struct vhost_memory __rcu *memory;
>  	struct mm_struct *mm;
>  	struct mutex mutex;
> -	unsigned acked_features;
>  	struct vhost_virtqueue **vqs;
>  	int nvqs;
>  	struct file *log_file;
> @@ -174,13 +174,8 @@ enum {
>  			 (1ULL << VHOST_F_LOG_ALL),
>  };
>  
> -static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
> +static inline int vhost_has_feature(struct vhost_virtqueue *vq, int bit)
>  {
> -	unsigned acked_features;
> -
> -	/* TODO: check that we are running from vhost_worker or dev mutex is
> -	 * held? */
> -	acked_features = rcu_dereference_index_check(dev->acked_features, 1);
> -	return acked_features & (1 << bit);
> +	return vq->acked_features & (1 << bit);
>  }
>  #endif
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index e489161..7635b59 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -585,9 +585,9 @@ static void handle_rx(struct vhost_net *net)
>  	vhost_hlen = nvq->vhost_hlen;
>  	sock_hlen = nvq->sock_hlen;
>  
> -	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
> +	vq_log = unlikely(vhost_has_feature(vq, VHOST_F_LOG_ALL)) ?
>  		vq->log : NULL;
> -	mergeable = vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF);
> +	mergeable = vhost_has_feature(vq, VIRTIO_NET_F_MRG_RXBUF);
>  
>  	while ((sock_len = peek_head_len(sock->sk))) {
>  		sock_len += sock_hlen;
> @@ -1051,15 +1051,13 @@ static int vhost_net_set_features(struct vhost_net *n, u64 features)
>  		mutex_unlock(&n->dev.mutex);
>  		return -EFAULT;
>  	}
> -	n->dev.acked_features = features;
> -	smp_wmb();
>  	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
>  		mutex_lock(&n->vqs[i].vq.mutex);
> +		n->vqs[i].acked_features = features;
>  		n->vqs[i].vhost_hlen = vhost_hlen;
>  		n->vqs[i].sock_hlen = sock_hlen;
>  		mutex_unlock(&n->vqs[i].vq.mutex);
>  	}
> -	vhost_net_flush(n);
>  	mutex_unlock(&n->dev.mutex);
>  	return 0;
>  }
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index cf50ce9..f1f284f 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1373,6 +1373,9 @@ err_dev:
>  
>  static int vhost_scsi_set_features(struct vhost_scsi *vs, u64 features)
>  {
> +	struct vhost_virtqueue *vq;
> +	int i;
> +
>  	if (features & ~VHOST_SCSI_FEATURES)
>  		return -EOPNOTSUPP;
>  
> @@ -1382,9 +1385,13 @@ static int vhost_scsi_set_features(struct vhost_scsi *vs, u64 features)
>  		mutex_unlock(&vs->dev.mutex);
>  		return -EFAULT;
>  	}
> -	vs->dev.acked_features = features;
> -	smp_wmb();
> -	vhost_scsi_flush(vs);
> +
> +	for (i = 0; i < VHOST_SCSI_MAX_VQ; i++) {
> +		vq = &vs->vqs[i].vq;
> +		mutex_lock(&vq->mutex);
> +		vq->acked_features = features;
> +		mutex_unlock(&vq->mutex);
> +	}
>  	mutex_unlock(&vs->dev.mutex);
>  	return 0;
>  }
> @@ -1591,10 +1598,6 @@ tcm_vhost_do_plug(struct tcm_vhost_tpg *tpg,
>  		return;
>  
>  	mutex_lock(&vs->dev.mutex);
> -	if (!vhost_has_feature(&vs->dev, VIRTIO_SCSI_F_HOTPLUG)) {
> -		mutex_unlock(&vs->dev.mutex);
> -		return;
> -	}
>  
>  	if (plug)
>  		reason = VIRTIO_SCSI_EVT_RESET_RESCAN;
> @@ -1603,8 +1606,9 @@ tcm_vhost_do_plug(struct tcm_vhost_tpg *tpg,
>  
>  	vq = &vs->vqs[VHOST_SCSI_VQ_EVT].vq;
>  	mutex_lock(&vq->mutex);
> -	tcm_vhost_send_evt(vs, tpg, lun,
> -			VIRTIO_SCSI_T_TRANSPORT_RESET, reason);
> +	if (vhost_has_feature(vq, VIRTIO_SCSI_F_HOTPLUG))
> +		tcm_vhost_send_evt(vs, tpg, lun,
> +				   VIRTIO_SCSI_T_TRANSPORT_RESET, reason);
>  	mutex_unlock(&vq->mutex);
>  	mutex_unlock(&vs->dev.mutex);
>  }
> diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> index c2a54fb..6fa3bf8 100644
> --- a/drivers/vhost/test.c
> +++ b/drivers/vhost/test.c
> @@ -241,15 +241,18 @@ done:
>  
>  static int vhost_test_set_features(struct vhost_test *n, u64 features)
>  {
> +	struct vhost_virtqueue *vq;
> +
>  	mutex_lock(&n->dev.mutex);
>  	if ((features & (1 << VHOST_F_LOG_ALL)) &&
>  	    !vhost_log_access_ok(&n->dev)) {
>  		mutex_unlock(&n->dev.mutex);
>  		return -EFAULT;
>  	}
> -	n->dev.acked_features = features;
> -	smp_wmb();
> -	vhost_test_flush(n);
> +	vq = &n->vqs[VHOST_TEST_VQ];
> +	mutex_lock(&vq->mutex);
> +	vq->acked_features = features;
> +	mutex_unlock(&vq->mutex);
>  	mutex_unlock(&n->dev.mutex);
>  	return 0;
>  }
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 1c05e60..9183f0b 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -524,11 +524,13 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
>  
>  	for (i = 0; i < d->nvqs; ++i) {
>  		int ok;
> +		bool log;
> +
>  		mutex_lock(&d->vqs[i]->mutex);
> +		log = log_all || vhost_has_feature(d->vqs[i], VHOST_F_LOG_ALL);
>  		/* If ring is inactive, will check when it's enabled. */
>  		if (d->vqs[i]->private_data)
> -			ok = vq_memory_access_ok(d->vqs[i]->log_base, mem,
> -						 log_all);
> +			ok = vq_memory_access_ok(d->vqs[i]->log_base, mem, log);
>  		else
>  			ok = 1;
>  		mutex_unlock(&d->vqs[i]->mutex);
> @@ -538,12 +540,12 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
>  	return 1;
>  }
>  
> -static int vq_access_ok(struct vhost_dev *d, unsigned int num,
> +static int vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
>  			struct vring_desc __user *desc,
>  			struct vring_avail __user *avail,
>  			struct vring_used __user *used)
>  {
> -	size_t s = vhost_has_feature(d, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> +	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>  	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
>  	       access_ok(VERIFY_READ, avail,
>  			 sizeof *avail + num * sizeof *avail->ring + s) &&
> @@ -565,16 +567,16 @@ EXPORT_SYMBOL_GPL(vhost_log_access_ok);
>  
>  /* Verify access for write logging. */
>  /* Caller should have vq mutex and device mutex */
> -static int vq_log_access_ok(struct vhost_dev *d, struct vhost_virtqueue *vq,
> +static int vq_log_access_ok(struct vhost_virtqueue *vq,
>  			    void __user *log_base)
>  {
>  	struct vhost_memory *mp;
> -	size_t s = vhost_has_feature(d, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> +	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>  
>  	mp = rcu_dereference_protected(vq->dev->memory,
>  				       lockdep_is_held(&vq->mutex));
>  	return vq_memory_access_ok(log_base, mp,
> -			    vhost_has_feature(vq->dev, VHOST_F_LOG_ALL)) &&
> +				   vhost_has_feature(vq, VHOST_F_LOG_ALL)) &&
>  		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
>  					sizeof *vq->used +
>  					vq->num * sizeof *vq->used->ring + s));
> @@ -584,8 +586,8 @@ static int vq_log_access_ok(struct vhost_dev *d, struct vhost_virtqueue *vq,
>  /* Caller should have vq mutex and device mutex */
>  int vhost_vq_access_ok(struct vhost_virtqueue *vq)
>  {
> -	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used) &&
> -		vq_log_access_ok(vq->dev, vq, vq->log_base);
> +	return vq_access_ok(vq, vq->num, vq->desc, vq->avail, vq->used) &&
> +		vq_log_access_ok(vq, vq->log_base);
>  }
>  EXPORT_SYMBOL_GPL(vhost_vq_access_ok);
>  
> @@ -612,8 +614,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
>  		return -EFAULT;
>  	}
>  
> -	if (!memory_access_ok(d, newmem,
> -			      vhost_has_feature(d, VHOST_F_LOG_ALL))) {
> +	if (!memory_access_ok(d, newmem, 0)) {
>  		kfree(newmem);
>  		return -EFAULT;
>  	}
> @@ -1434,11 +1435,11 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	 * interrupts. */
>  	smp_mb();
>  
> -	if (vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY) &&
> +	if (vhost_has_feature(vq, VIRTIO_F_NOTIFY_ON_EMPTY) &&
>  	    unlikely(vq->avail_idx == vq->last_avail_idx))
>  		return true;
>  
> -	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
> +	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
>  		__u16 flags;
>  		if (__get_user(flags, &vq->avail->flags)) {
>  			vq_err(vq, "Failed to get flags");
> @@ -1499,7 +1500,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
>  		return false;
>  	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
> -	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
> +	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
>  		r = vhost_update_used_flags(vq);
>  		if (r) {
>  			vq_err(vq, "Failed to enable notification at %p: %d\n",
> @@ -1536,7 +1537,7 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
>  		return;
>  	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
> -	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
> +	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
>  		r = vhost_update_used_flags(vq);
>  		if (r)
>  			vq_err(vq, "Failed to enable notification at %p: %d\n",
> -- 
> MST
> 
