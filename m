From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH] [DM9000] Add support for big-endian hosts
Date: Tue, 14 Aug 2007 19:25:58 +0100
Message-ID: <20070814182558.GA12547@fluff.org.uk>
References: <200708141322.32473.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:56508 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665AbXHNS0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 14:26:01 -0400
Content-Disposition: inline
In-Reply-To: <200708141322.32473.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 01:22:32PM +0200, Laurent Pinchart wrote:
> This patch splits the receive status in 8bit wide fields and convert the
> packet length from little endian to CPU byte order.

Which version of the the kernel was this against, it applies with
fuzz to 2.6.23-rc3:

$ patch -p1 < ~/dm9000-fix-endianness.patch 
patching file drivers/net/dm9000.c
Hunk #1 succeeded at 894 (offset 15 lines).
Hunk #2 succeeded at 936 (offset 15 lines).
Hunk #3 succeeded at 948 (offset 15 lines).

> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/dm9000.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 264fa0e..ee578d9 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -879,7 +879,8 @@ dm9000_timer(unsigned long data)
>  }
>  
>  struct dm9000_rxhdr {
> -	u16	RxStatus;
> +	u8	RxPktReady;
> +	u8	RxStatus;
>  	u16	RxLen;
>  } __attribute__((__packed__));
>  
> @@ -920,7 +921,7 @@ dm9000_rx(struct net_device *dev)
>  
>  		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
>  
> -		RxLen = rxhdr.RxLen;
> +		RxLen = le16_to_cpu(rxhdr.RxLen);
>  
>  		/* Packet Status check */
>  		if (RxLen < 0x40) {
> @@ -932,17 +933,17 @@ dm9000_rx(struct net_device *dev)
>  			PRINTK1("RST: RX Len:%x\n", RxLen);
>  		}
>  
> -		if (rxhdr.RxStatus & 0xbf00) {
> +		if (rxhdr.RxStatus & 0xbf) {
>  			GoodPacket = false;
> -			if (rxhdr.RxStatus & 0x100) {
> +			if (rxhdr.RxStatus & 0x01) {
>  				PRINTK1("fifo error\n");
>  				db->stats.rx_fifo_errors++;
>  			}
> -			if (rxhdr.RxStatus & 0x200) {
> +			if (rxhdr.RxStatus & 0x02) {
>  				PRINTK1("crc error\n");
>  				db->stats.rx_crc_errors++;
>  			}
> -			if (rxhdr.RxStatus & 0x8000) {
> +			if (rxhdr.RxStatus & 0x80) {
>  				PRINTK1("length error\n");
>  				db->stats.rx_length_errors++;
>  			}
> -- 
> 1.5.0


-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
