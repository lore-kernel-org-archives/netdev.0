From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: virtio: remove obsolete virtqueue_get_queue_index()
Date: Fri, 22 Mar 2013 10:10:09 +0100
Message-ID: <20130322101009.6076b0ba@gondolin>
References: <878v5hp6hc.fsf@rustcorp.com.au>
	<20130321100146.7a741c75@gondolin>
	<87ehf8fftt.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:41379 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936Ab3CVJKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 05:10:30 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cornelia.huck@de.ibm.com>;
	Fri, 22 Mar 2013 09:07:31 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2D7B81B08061
	for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 09:10:20 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2M9AAaZ40370408
	for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 09:10:10 GMT
Received: from d06av08.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2M9AJfM013487
	for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 03:10:19 -0600
In-Reply-To: <87ehf8fftt.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Mar 2013 10:47:34 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> virtio: remove obsolete virtqueue_get_queue_index()
> 
> You can access it directly now, since 3.8: v3.7-rc1-13-g06ca287
> 'virtio: move queue_index and num_free fields into core struct
> virtqueue.'
> 
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>

Acked-by: Cornelia Huck <cornelia.huck@de.ibm.com>

> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index d88d436..24fc9f5 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -153,7 +153,7 @@ struct padded_vnet_hdr {
>   */
>  static int vq2txq(struct virtqueue *vq)
>  {
> -	return (virtqueue_get_queue_index(vq) - 1) / 2;
> +	return (vq->index - 1) / 2;
>  }
> 
>  static int txq2vq(int txq)
> @@ -163,7 +163,7 @@ static int txq2vq(int txq)
> 
>  static int vq2rxq(struct virtqueue *vq)
>  {
> -	return virtqueue_get_queue_index(vq) / 2;
> +	return vq->index / 2;
>  }
> 
>  static int rxq2vq(int rxq)
> diff --git a/drivers/s390/kvm/virtio_ccw.c b/drivers/s390/kvm/virtio_ccw.c
> index 2029b6c..a7eddc7 100644
> --- a/drivers/s390/kvm/virtio_ccw.c
> +++ b/drivers/s390/kvm/virtio_ccw.c
> @@ -166,7 +166,7 @@ static void virtio_ccw_kvm_notify(struct virtqueue *vq)
> 
>  	vcdev = to_vc_device(info->vq->vdev);
>  	ccw_device_get_schid(vcdev->cdev, &schid);
> -	do_kvm_notify(schid, virtqueue_get_queue_index(vq));
> +	do_kvm_notify(schid, vq->index);
>  }
> 
>  static int virtio_ccw_read_vq_conf(struct virtio_ccw_device *vcdev,
> @@ -188,7 +188,7 @@ static void virtio_ccw_del_vq(struct virtqueue *vq, struct ccw1 *ccw)
>  	unsigned long flags;
>  	unsigned long size;
>  	int ret;
> -	unsigned int index = virtqueue_get_queue_index(vq);
> +	unsigned int index = vq->index;
> 
>  	/* Remove from our list. */
>  	spin_lock_irqsave(&vcdev->lock, flags);
> @@ -610,7 +610,7 @@ static struct virtqueue *virtio_ccw_vq_by_ind(struct virtio_ccw_device *vcdev,
>  	vq = NULL;
>  	spin_lock_irqsave(&vcdev->lock, flags);
>  	list_for_each_entry(info, &vcdev->virtqueues, node) {
> -		if (virtqueue_get_queue_index(info->vq) == index) {
> +		if (info->vq->index == index) {
>  			vq = info->vq;
>  			break;
>  		}
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 833f17b..9ff8645 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -76,12 +76,6 @@ void *virtqueue_detach_unused_buf(struct virtqueue *vq);
> 
>  unsigned int virtqueue_get_vring_size(struct virtqueue *vq);
> 
> -/* FIXME: Obsolete accessor, but required for virtio_net merge. */
> -static inline unsigned int virtqueue_get_queue_index(struct virtqueue *vq)
> -{
> -	return vq->index;
> -}
> -
>  /**
>   * virtio_device - representation of a device using virtio
>   * @index: unique position on the virtio bus
> 
