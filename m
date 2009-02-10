From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Mon, 9 Feb 2009 17:01:20 -0800
Message-ID: <20090209170120.85e192be.akpm@linux-foundation.org>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: Risto Suominen <risto.suominen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40472 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbZBJBCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 20:02:23 -0500
In-Reply-To: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(cc netdev, and maintainer)

On Sat, 7 Feb 2009 23:30:40 +0200
Risto Suominen <risto.suominen@gmail.com> wrote:

> Add a configurable Descriptor Skip Length for systems that lack cache coherence.
> 
> Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
> ---
> The testing is done on kernel version 2.6.18.
> 
> --- drivers/net/tulip/Kconfig.org	2006-09-20 06:42:06.000000000 +0300
> +++ drivers/net/tulip/Kconfig	2009-02-07 20:48:17.000000000 +0200

Please prefer to prepare patches in `patch -p1' form:

--- a/drivers/net/tulip/Kconfig
+++ a/drivers/net/tulip/Kconfig

> @@ -27,6 +27,18 @@ config DE2104X
>  	  To compile this driver as a module, choose M here. The module will
>  	  be called de2104x.
> 
> +config DE2104X_DSL
> +	int "Descriptor Skip Length in 32 bit longwords"
> +	depends on DE2104X
> +	range 0 31
> +	default 0
> +	help
> +	  Setting this value allows to align ring buffer descriptors into their
> +	  own cache lines. Value of 4 corresponds to the typical 32 byte line
> +	  (the descriptor is 16 bytes). This is necessary on systems that lack
> +	  cache coherence, an example is PowerMac 5500. Otherwise 0 is safe.
> +	  Default is 0, and range is 0 to 31.
> +
>  config TULIP
>  	tristate "DECchip Tulip (dc2114x) PCI support"
>  	depends on PCI
> --- drivers/net/tulip/de2104x.c.org	2006-09-20 06:42:06.000000000 +0300
> +++ drivers/net/tulip/de2104x.c	2009-02-07 15:04:04.000000000 +0200
> @@ -82,6 +82,13 @@ MODULE_PARM_DESC (rx_copybreak, "de2104x
>  				 NETIF_MSG_RX_ERR	| \
>  				 NETIF_MSG_TX_ERR)
> 
> +/* Descriptor skip length in 32 bit longwords. */
> +#ifndef CONFIG_DE2104X_DSL
> +#define DSL			0
> +#else
> +#define DSL			CONFIG_DE2104X_DSL
> +#endif

I think CONFIG_DE2104X_DSL is always defined if this driver is being
compiled.  So the Kconfig `default' should suffice here?  In which case
we can do

#define DSL CONFIG_DE2104X_DSL

and leave it at that.

>  #define DE_RX_RING_SIZE		64
>  #define DE_TX_RING_SIZE		64
>  #define DE_RING_BYTES		\
> @@ -153,6 +160,7 @@ enum {
>  	CmdReset		= (1 << 0),
>  	CacheAlign16		= 0x00008000,
>  	BurstLen4		= 0x00000400,
> +	DescSkipLen		= (DSL << 2),

In which case we can do away with DSL everywhere and just use
CONFIG_DE2104X_DSL here.


But really, we shouldn't do this at configuration time at all.  It
would be much better to do it at runtime, via a module parameter.

And it would be much^2 better to do it automatically, based upon the
chip probing information or whatever.  That's probably hard.


>  	/* Rx/TxPoll bits */
>  	NormalTxPoll		= (1 << 0),
> @@ -246,7 +254,7 @@ static const u32 de_intr_mask =
>   * Set the programmable burst length to 4 longwords for all:
>   * DMA errors result without these values. Cache align 16 long.
>   */
> -static const u32 de_bus_mode = CacheAlign16 | BurstLen4;
> +static const u32 de_bus_mode = CacheAlign16 | BurstLen4 | DescSkipLen;
> 
>  struct de_srom_media_block {
>  	u8			opts;
> @@ -266,6 +274,9 @@ struct de_desc {
>  	__le32			opts2;
>  	__le32			addr1;
>  	__le32			addr2;
> +#if DSL
> +	__le32			skip[DSL];
> +#endif
>  };

Can remove the ifdefs here.  A zero-length array is OK, and will
consume zero space.

