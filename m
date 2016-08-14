From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/1] VSOCK: remove more space available check filling
 TX vq
Date: Mon, 15 Aug 2016 02:16:51 +0300
Message-ID: <20160815021607-mutt-send-email-mst@kernel.org>
References: <20160810152434.14346-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stefanha@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbcHNXQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Aug 2016 19:16:55 -0400
Content-Disposition: inline
In-Reply-To: <20160810152434.14346-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 05:24:34PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
> 
> Remove unnecessary use of enable/disable callback notifications
> and the incorrect more space available check.
> 
> The virtio_transport_tx_work handles when the TX virtqueue
> has more buffers available.
> 
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Acked-by: Stefan Hajnoczi <stefanha@redhat.com>

Generally enable/disable is a worthwhile optimization,
but if Stefan wants to keep code simple for now,
I don't have a problem with that.

> ---
> 
> v2:
>  * Comment style.
> 
>  net/vmw_vsock/virtio_transport.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
> index 699dfab..936d7ee 100644
> --- a/net/vmw_vsock/virtio_transport.c
> +++ b/net/vmw_vsock/virtio_transport.c
> @@ -87,9 +87,6 @@ virtio_transport_send_pkt_work(struct work_struct *work)
>  
>  	vq = vsock->vqs[VSOCK_VQ_TX];
>  
> -	/* Avoid unnecessary interrupts while we're processing the ring */
> -	virtqueue_disable_cb(vq);
> -
>  	for (;;) {
>  		struct virtio_vsock_pkt *pkt;
>  		struct scatterlist hdr, buf, *sgs[2];
> @@ -99,7 +96,6 @@ virtio_transport_send_pkt_work(struct work_struct *work)
>  		spin_lock_bh(&vsock->send_pkt_list_lock);
>  		if (list_empty(&vsock->send_pkt_list)) {
>  			spin_unlock_bh(&vsock->send_pkt_list_lock);
> -			virtqueue_enable_cb(vq);
>  			break;
>  		}
>  
> @@ -118,13 +114,13 @@ virtio_transport_send_pkt_work(struct work_struct *work)
>  		}
>  
>  		ret = virtqueue_add_sgs(vq, sgs, out_sg, in_sg, pkt, GFP_KERNEL);
> +		/* Usually this means that there is no more space available in
> +		 * the vq
> +		 */
>  		if (ret < 0) {
>  			spin_lock_bh(&vsock->send_pkt_list_lock);
>  			list_add(&pkt->list, &vsock->send_pkt_list);
>  			spin_unlock_bh(&vsock->send_pkt_list_lock);
> -
> -			if (!virtqueue_enable_cb(vq) && ret == -ENOSPC)
> -				continue; /* retry now that we have more space */
>  			break;
>  		}
>  
> -- 
> 2.9.1
