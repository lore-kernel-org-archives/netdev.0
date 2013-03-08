From: Dan Williams <dcbw@redhat.com>
Subject: Re: RFC: [PATCH 1/3] usb: cdc_ncm: patch for VMware
Date: Fri, 08 Mar 2013 16:28:59 -0600
Message-ID: <1362781739.8581.5.camel@dcbw.foobar.com>
References: <20130308210319.GA4794@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Loic Domaigne <loic.domaigne@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab3CHW2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 17:28:20 -0500
In-Reply-To: <20130308210319.GA4794@feynman.loic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 22:03 +0100, Loic Domaigne wrote:
> This patch limits the Rx URB size to 16kB if the driver is compiled for a
> VMware environment. As of workstation 9, there are some major performance
> problems if the Rx URB size exceeds that limit.
> 
> This patch applies to longterm kernel version 3.4.35.
> 
> Signed-Off-By: Loic Domaigne <loic.domaigne@jambit.com> 
> 
> --- linux-3.4.35/drivers/net/usb/cdc_ncm.c.orig	2013-03-05 09:36:02.858740489 +0100
> +++ linux-3.4.35/drivers/net/usb/cdc_ncm.c	2013-03-05 10:20:18.092588668 +0100
> @@ -80,6 +80,23 @@
>  #define	CDC_NCM_TIMER_PENDING_CNT		2
>  #define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
>  
> +/* maximum Rx URB size */
> +/*
> + * in the original Linux driver, the rx urb size can be up to
> + * CDC_NCM_NTB_MAX_SIZE_RX.
> + *
> + * Under VMware (as of wks9), URB size greater than 16kB is a problem,
> + * so simply adjust this define when the driver is compiled for a VMware
> + * environment.
> + *
> + */
> +#ifdef VMWARE_BUG
> +#warning "Compiling for VMware"
> +#define CDC_NCM_MAX_RX_URB_SIZE     16384
> +#else
> +#define CDC_NCM_MAX_RX_URB_SIZE     CDC_NCM_NTB_MAX_SIZE_RX
> +#endif

I can't see how that is going to get past any sort of review.  Either
there's some other way of detecting that the CPU is the VMWare emulated
one or you're stuck with the bug until VMWare fixes it.

Dan

> +
>  /* The following macro defines the minimum header space */
>  #define	CDC_NCM_MIN_HDR_SIZE \
>  	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) + \
> @@ -589,6 +606,9 @@ advance:
>  		ctx->out_ep->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
>  	dev->status = ctx->status_ep;
>  	dev->rx_urb_size = ctx->rx_max;
> +	if (dev->rx_urb_size > CDC_NCM_MAX_RX_URB_SIZE)
> +		dev->rx_urb_size = CDC_NCM_MAX_RX_URB_SIZE;
> +	pr_debug("dev->rx_urb_size = %zu", dev->rx_urb_size);
>  
>  	/*
>  	 * We should get an event when network connection is "connected" or
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
