From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] VSOCK: fix vhost virtio_vsock_pkt use-after-free
Date: Thu, 4 Aug 2016 19:34:43 +0300
Message-ID: <20160804193338-mutt-send-email-mst@kernel.org>
References: <1470318773-10414-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095AbcHDQeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 12:34:44 -0400
Content-Disposition: inline
In-Reply-To: <1470318773-10414-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 04, 2016 at 02:52:53PM +0100, Stefan Hajnoczi wrote:
> Stash the packet length in a local variable before handing over
> ownership of the packet to virtio_transport_recv_pkt() or
> virtio_transport_free_pkt().
> 
> This patch solves the use-after-free since pkt is no longer guaranteed
> to be alive.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>


Thanks!
I'd prefer a lower-case prefix, mentioning vhost, such as vhost/vsock.
I'll tweak it for now.

> ---
>  drivers/vhost/vsock.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 0ddf3a2..e3b30ea 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -307,6 +307,8 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
>  
>  	vhost_disable_notify(&vsock->dev, vq);
>  	for (;;) {
> +		u32 len;
> +
>  		if (!vhost_vsock_more_replies(vsock)) {
>  			/* Stop tx until the device processes already
>  			 * pending replies.  Leave tx virtqueue
> @@ -334,13 +336,15 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
>  			continue;
>  		}
>  
> +		len = pkt->len;
> +
>  		/* Only accept correctly addressed packets */
>  		if (le64_to_cpu(pkt->hdr.src_cid) == vsock->guest_cid)
>  			virtio_transport_recv_pkt(pkt);
>  		else
>  			virtio_transport_free_pkt(pkt);
>  
> -		vhost_add_used(vq, head, sizeof(pkt->hdr) + pkt->len);
> +		vhost_add_used(vq, head, sizeof(pkt->hdr) + len);
>  		added = true;
>  	}
>  
> -- 
> 2.7.4
