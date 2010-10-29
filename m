From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Fri, 29 Oct 2010 20:17:24 +1030
Message-ID: <201010292017.25099.rusty@rustcorp.com.au>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46418 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216Ab0J2Jrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 05:47:32 -0400
In-Reply-To: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010 03:40:36 pm Krishna Kumar wrote:
> I get many queue full errors being wrongly reported when running
> parallel netperfs:
> 
> Oct 17 10:22:40 localhost kernel: net eth0: Unexpected TX queue failure: -28
> Oct 17 10:28:22 localhost kernel: net eth0: Unexpected TX queue failure: -28
> Oct 17 10:35:58 localhost kernel: net eth0: Unexpected TX queue failure: -28
> Oct 17 10:41:06 localhost kernel: net eth0: Unexpected TX queue failure: -28
> 
> I initially changed the check from -ENOMEM to -ENOSPC, but
> virtqueue_add_buf can return only -ENOSPC when it doesn't have
> space for new request.  Patch removes redundant checks but
> displays the failure errno.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  drivers/net/virtio_net.c |   15 ++++-----------
>  1 file changed, 4 insertions(+), 11 deletions(-)
> 
> diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> --- org/drivers/net/virtio_net.c	2010-10-11 10:20:02.000000000 +0530
> +++ new/drivers/net/virtio_net.c	2010-10-21 17:37:45.000000000 +0530
> @@ -570,17 +570,10 @@ static netdev_tx_t start_xmit(struct sk_
>  
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
> -		if (net_ratelimit()) {
> -			if (likely(capacity == -ENOMEM)) {
> -				dev_warn(&dev->dev,
> -					 "TX queue failure: out of memory\n");
> -			} else {
> -				dev->stats.tx_fifo_errors++;
> -				dev_warn(&dev->dev,
> -					 "Unexpected TX queue failure: %d\n",
> -					 capacity);
> -			}
> -		}
> +		if (net_ratelimit())
> +			dev_warn(&dev->dev,
> +				 "TX queue failure (%d): out of memory\n",
> +				 capacity); 

Hold on... you were getting -ENOSPC, which shouldn't happen.  What makes you
think it's out of memory?

Confused,
Rusty.
