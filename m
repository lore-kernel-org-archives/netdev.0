From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_*
	API
Date: Mon, 12 Apr 2010 20:35:36 +0100
Message-ID: <20100412193536.GO3048@n2100.arm.linux.org.uk>
References: <20100405123847C.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33383 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615Ab0DLTgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 15:36:08 -0400
Content-Disposition: inline
In-Reply-To: <20100405123847C.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 12:39:32PM +0900, FUJITA Tomonori wrote:
> I don't have arm hardware that uses dmabounce so I can't confirm the
> problem but seems that dmabounce doesn't work for some drivers...

Patch reviews fine, except for one niggle.  I too don't have hardware
I can test (well, I do except the kernel stopped supporting the UDA1341
audio codec on the SA1110 Neponset.)

> @@ -171,10 +172,17 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
>  	read_lock_irqsave(&device_info->lock, flags);
>  
>  	list_for_each_entry(b, &device_info->safe_buffers, node)
> -		if (b->safe_dma_addr == safe_dma_addr) {
> -			rb = b;
> -			break;
> -		}
> +		if (for_sync) {
> +			if (b->safe_dma_addr <= safe_dma_addr &&
> +			    safe_dma_addr < b->safe_dma_addr + b->size) {
> +				rb = b;
> +				break;
> +			}
> +		} else
> +			if (b->safe_dma_addr == safe_dma_addr) {
> +				rb = b;
> +				break;
> +			}

This is the niggle; I don't like this indentation style.  If you want to
indent this if () statement, then please format like this:

		} else {
			if (b->safe...) {
				...
			}
		}

or format it as:

		} else if (b->safe...) {
			...
		}
