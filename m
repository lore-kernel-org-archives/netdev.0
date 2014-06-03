From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v4 1/2] sfc: use 64-bit writes for PIO.
Date: Tue, 03 Jun 2014 20:45:35 +0400
Message-ID: <538DFBAF.2030703@cogentembedded.com>
References: <538D9D1E.3090608@solarflare.com> <538D9DB3.4080905@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:57276 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933566AbaFCQpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 12:45:33 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so3580654lbg.2
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 09:45:31 -0700 (PDT)
In-Reply-To: <538D9DB3.4080905@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/03/2014 02:04 PM, Shradha Shah wrote:

> From: Jon Cooper <jcooper@solarflare.com>

> Patch to open-code the memory copy routines.
> 32bit writes over the PCI bus causes data corruption.

> Fixes:ee45fd92c739
> ("sfc: Use TX PIO for sufficiently small packets")

> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> ---
>   drivers/net/ethernet/sfc/tx.c | 24 +++++++++++++++++++-----
>   1 file changed, 19 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index fa94753..d2c9ca0 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -189,6 +189,20 @@ struct efx_short_copy_buffer {
>   	u8 buf[L1_CACHE_BYTES];
>   };
>
> +/* Copy in explicit 64-bit writes. */
> +static void efx_memcpy_64(void __iomem *dest, void *src, size_t len)
> +{
> +	u64 *src64 = src, __iomem *dest64 = dest;
> +	size_t i, l64 = len / 8;
> +
> +	WARN_ON_ONCE(len % 8 != 0);
> +	WARN_ON_ONCE(((u8 __iomem *)dest - (u8 __iomem *)0) % 8 != 0);
> +	BUILD_BUG_ON(sizeof(uint64_t) != 8);
> +
> +	for (i = 0; i < l64; ++i)
> +		writeq(src64[i], dest64+i);

    Could you please surround + by spaces for consistency?

> +}
> +

WBR, Sergei
