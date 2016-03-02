From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] net: ezchip: adapt driver to little endian architecture
Date: Wed, 02 Mar 2016 21:07:37 +0100
Message-ID: <3132255.zs1gQSacSZ@wuerfel>
References: <1456943884-29149-1-git-send-email-ltrimas@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>
To: Lada Trimasova <Lada.Trimasova@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:53607 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbcCBUHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:07:43 -0500
In-Reply-To: <1456943884-29149-1-git-send-email-ltrimas@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 March 2016 21:38:04 Lada Trimasova wrote:
> Since ezchip network driver is written with big endian EZChip platform it
> is necessary to add support for little endian architecture.
> 
> The first issue is that the order of the bits in a bit field is
> implementation specific. So all the bit fields are removed.
> Named constants are used to access necessary fields.
> 
> And the second one is that network byte order is big endian.
> For example, data on ethernet is transmitted with most-significant
> octet (byte) first. So in case of little endian architecture
> it is important to swap data byte order when we read it from
> register. In case of unaligned access we can use "get_unaligned_be32"
> and in other case we should use function "be32_to_cpu" as we read from
> peripheral to CPU.
> 
> And then when we are going to write data to register we need to restore
> byte order using the function "put_unaligned_be32" in case of
> unaligned access and in other case "cpu_to_be32" as
> we write from CPU to peripheral.
> 
> The last little fix is a space between type and pointer to observe
> coding style.
> 
> Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>
> Cc: Alexey Brodkin <abrodkin@synopsys.com>
> Cc: Noam Camus <noamc@ezchip.com>
> Cc: Tal Zilcer <talz@ezchip.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Looks much better already.

> index b102668..9a5a3bf 100644
> --- a/drivers/net/ethernet/ezchip/nps_enet.c
> +++ b/drivers/net/ethernet/ezchip/nps_enet.c
> @@ -44,19 +44,22 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
>  
>  	/* In case dst is not aligned we need an intermediate buffer */
>  	if (dst_is_aligned)
> -		for (i = 0; i < len; i++, reg++)
> +		for (i = 0; i < len; i++, reg++) {
> +			/* In case of LE we need to swap bytes */
>  			*reg = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
> +			*reg = be32_to_cpu(*reg);
> +		}

This is still not right: please build this with

make C=2 CF="-D__CHECK_ENDIAN__" drivers/net/ethernet/ezchip/nps_enet.o

What is going on here is that NPS_ENET_REG_RX_BUF seems to be
some kind of FIFO register rather than an MMIO register, so
the swap in ioread32be() is wrong.

What you should do instead is to replace the loop
with a call to ioread32_rep(), which will be more efficient
and endian-safe.

	Arnd
