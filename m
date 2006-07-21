From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 2/2] myri10ge - Write the firmware in 256-bytes chunks
Date: Fri, 21 Jul 2006 22:11:20 +0200
Message-ID: <200607212211.21043.mb@bu3sch.de>
References: <44C12D14.7050509@myri.com> <44C12FD9.3050001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:2967
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751122AbWGUUMO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 16:12:14 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44C12FD9.3050001@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 July 2006 21:49, Brice Goglin wrote:
> When writing the firmware to the NIC, the FIFO is 256-bytes long,
> so we use 256-bytes chunks and a read to wait until the previous
> write is done.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)
> 
> Index: linux-mm/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:17:55.000000000 -0400
> +++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:19:44.000000000 -0400
> @@ -448,6 +448,7 @@
>  	struct mcp_gen_header *hdr;
>  	size_t hdr_offset;
>  	int status;
> +	unsigned i;
>  
>  	if ((status = request_firmware(&fw, mgp->fw_name, dev)) < 0) {
>  		dev_err(dev, "Unable to load %s firmware image via hotplug\n",
> @@ -479,18 +480,13 @@
>  		goto abort_with_fw;
>  
>  	crc = crc32(~0, fw->data, fw->size);
> -	if (mgp->tx.boundary == 2048) {
> -		/* Avoid PCI burst on chipset with unaligned completions. */
> -		int i;
> -		__iomem u32 *ptr = (__iomem u32 *) (mgp->sram +
> -						    MYRI10GE_FW_OFFSET);
> -		for (i = 0; i < fw->size / 4; i++) {
> -			__raw_writel(((u32 *) fw->data)[i], ptr + i);
> -			wmb();
> -		}
> -	} else {
> -		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET, fw->data,
> -				  fw->size);
> +	for (i = 0; i < fw->size; i += 256) {
> +		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET + i,
> +				  fw->data + i,
> +				  min(256U, (unsigned)(fw->size - i)));
> +		mb();
> +		readb(mgp->sram);
> +		mb();

Why two mb() here?
I would say actually none is needed.
The readb fully synchronizes the previous writes on bus level
(and so on CPU level, too).

-- 
Greetings Michael.
