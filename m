From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] [resend] fix non-mergeable buffers packet too large
	error handling
Date: Tue, 18 May 2010 04:53:34 +0300
Message-ID: <20100518015334.GA22478@redhat.com>
References: <1274130996.8492.7.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261Ab0ERB5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 21:57:40 -0400
Content-Disposition: inline
In-Reply-To: <1274130996.8492.7.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 17, 2010 at 02:16:36PM -0700, David L Stevens wrote:
> This patch enforces single-buffer allocation when
> mergeable rx buffers is not enabled.
> 
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Thanks! Why are you resending?

> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 309c570..c346304 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -361,13 +361,21 @@ static void handle_rx(struct vhost_net *net)
>  			break;
>  		}
>  		/* TODO: Should check and handle checksum. */
> -		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
> -		    memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
> -				      offsetof(typeof(hdr), num_buffers),
> -				      sizeof hdr.num_buffers)) {
> -			vq_err(vq, "Failed num_buffers write");
> +		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
> +			if (memcpy_toiovecend(vq->hdr,
> +					      (unsigned char *)&headcount,
> +					      offsetof(typeof(hdr),
> +					      num_buffers),
> +					      sizeof hdr.num_buffers)) {
> +				vq_err(vq, "Failed num_buffers write");
> +				vhost_discard_desc(vq, headcount);
> +				break;
> +			}
> +		} else if (headcount > 1) {
> +			vq_err(vq, "rx packet too large (%d) for guest",
> +			       sock_len);
>  			vhost_discard_desc(vq, headcount);
> -			break;
> +			continue;
>  		}
>  		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
>  					    headcount);
> 
