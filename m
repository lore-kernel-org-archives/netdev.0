From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] tulip: Fix for MTU problems with 802.1q tagged frames
Date: Fri, 6 Mar 2009 11:13:22 -0700
Message-ID: <20090306181322.GA3616@colo.lackof.org>
References: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@mcmartin.ca, Tomasz Lemiech <szpajder@staszic.waw.pl>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:38611 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbZCFSNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 13:13:47 -0500
Content-Disposition: inline
In-Reply-To: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2009 at 11:21:34AM +0100, Ivan Vecera wrote:
> The original patch was submitted last year but wasn't discussed or applied
> because of missing maintainer's CCs. I only fixed some formatting errors,
> but as I saw tulip is very badly formatted and needs further work.
> 
> Original description:
> This patch fixes MTU problem, which occurs when using 802.1q VLANs. We
> should allow receiving frames of up to 1518 bytes in length, instead of
> 1514.
> 
> Based on patch written by Ben McKeegan for 2.4.x kernels. It is archived
> at http://www.candelatech.com/~greear/vlan/howto.html#tulip
> I've adjusted a few things to make it apply on 2.6.x kernels.
> 
> Tested on D-Link DFE-570TX quad-fastethernet card.
> 
> Signed-off-by: Tomasz Lemiech <szpajder@staszic.waw.pl>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

I reviewed this earlier in the week (offlist email) and it looks
fine to me too.

And while I agree the white space isn't uhm, "optimal", I didn't
feel it was worthwhile to generate a massive white space diff.

thanks,
grant

> ---
>  drivers/net/tulip/interrupt.c |   84 +++++++++++++++++++++++++++--------------
>  drivers/net/tulip/tulip.h     |   32 +++++++++++++++-
>  2 files changed, 86 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
> index 6c3428a..c21193b 100644
> --- a/drivers/net/tulip/interrupt.c
> +++ b/drivers/net/tulip/interrupt.c
> @@ -140,6 +140,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
>                 /* If we own the next entry, it is a new packet. Send it up. */
>                 while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
>                         s32 status = le32_to_cpu(tp->rx_ring[entry].status);
> +		       short pkt_len;
>  
>                         if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
>                                 break;
> @@ -151,8 +152,28 @@ int tulip_poll(struct napi_struct *napi, int budget)
>  		       if (++work_done >= budget)
>                                 goto not_done;
>  
> -                       if ((status & 0x38008300) != 0x0300) {
> -                               if ((status & 0x38000300) != 0x0300) {
> +		       /*
> +			* Omit the four octet CRC from the length.
> +			* (May not be considered valid until we have
> +			* checked status for RxLengthOver2047 bits)
> +			*/
> +		       pkt_len = ((status >> 16) & 0x7ff) - 4;
> +
> +		       /*
> +			* Maximum pkt_len is 1518 (1514 + vlan header)
> +			* Anything higher than this is always invalid
> +			* regardless of RxLengthOver2047 bits
> +			*/
> +
> +		       if ((status & (RxLengthOver2047 |
> +				      RxDescCRCError |
> +				      RxDescCollisionSeen |
> +				      RxDescRunt |
> +				      RxDescDescErr |
> +				      RxWholePkt)) != RxWholePkt
> +			   || pkt_len > 1518) {
> +			       if ((status & (RxLengthOver2047 |
> +					      RxWholePkt)) != RxWholePkt) {
>                                  /* Ingore earlier buffers. */
>                                         if ((status & 0xffff) != 0x7fff) {
>                                                 if (tulip_debug > 1)
> @@ -161,30 +182,23 @@ int tulip_poll(struct napi_struct *napi, int budget)
>                                                                dev->name, status);
>                                                 tp->stats.rx_length_errors++;
>                                         }
> -                               } else if (status & RxDescFatalErr) {
> +			       } else {
>                                  /* There was a fatal error. */
>                                         if (tulip_debug > 2)
>                                                 printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
>                                                        dev->name, status);
>                                         tp->stats.rx_errors++; /* end of a packet.*/
> -                                       if (status & 0x0890) tp->stats.rx_length_errors++;
> +				       if (pkt_len > 1518 ||
> +					   (status & RxDescRunt))
> +					       tp->stats.rx_length_errors++;
> +
>                                         if (status & 0x0004) tp->stats.rx_frame_errors++;
>                                         if (status & 0x0002) tp->stats.rx_crc_errors++;
>                                         if (status & 0x0001) tp->stats.rx_fifo_errors++;
>                                 }
>                         } else {
> -                               /* Omit the four octet CRC from the length. */
> -                               short pkt_len = ((status >> 16) & 0x7ff) - 4;
>                                 struct sk_buff *skb;
>  
> -#ifndef final_version
> -                               if (pkt_len > 1518) {
> -                                       printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
> -                                              dev->name, pkt_len, pkt_len);
> -                                       pkt_len = 1518;
> -                                       tp->stats.rx_length_errors++;
> -                               }
> -#endif
>                                 /* Check if the packet is long enough to accept without copying
>                                    to a minimally-sized skbuff. */
>                                 if (pkt_len < tulip_rx_copybreak
> @@ -356,14 +370,35 @@ static int tulip_rx(struct net_device *dev)
>  	/* If we own the next entry, it is a new packet. Send it up. */
>  	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
>  		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
> +		short pkt_len;
>  
>  		if (tulip_debug > 5)
>  			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
>  				   dev->name, entry, status);
>  		if (--rx_work_limit < 0)
>  			break;
> -		if ((status & 0x38008300) != 0x0300) {
> -			if ((status & 0x38000300) != 0x0300) {
> +
> +		/*
> +		  Omit the four octet CRC from the length.
> +		  (May not be considered valid until we have
> +		  checked status for RxLengthOver2047 bits)
> +		*/
> +		pkt_len = ((status >> 16) & 0x7ff) - 4;
> +		/*
> +		  Maximum pkt_len is 1518 (1514 + vlan header)
> +		  Anything higher than this is always invalid
> +		  regardless of RxLengthOver2047 bits
> +		*/
> +
> +		if ((status & (RxLengthOver2047 |
> +			       RxDescCRCError |
> +			       RxDescCollisionSeen |
> +			       RxDescRunt |
> +			       RxDescDescErr |
> +			       RxWholePkt))        != RxWholePkt
> +		     || pkt_len > 1518) {
> +			if ((status & (RxLengthOver2047 |
> +			     RxWholePkt))         != RxWholePkt) {
>  				/* Ingore earlier buffers. */
>  				if ((status & 0xffff) != 0x7fff) {
>  					if (tulip_debug > 1)
> @@ -372,31 +407,22 @@ static int tulip_rx(struct net_device *dev)
>  							   dev->name, status);
>  					tp->stats.rx_length_errors++;
>  				}
> -			} else if (status & RxDescFatalErr) {
> +			} else {
>  				/* There was a fatal error. */
>  				if (tulip_debug > 2)
>  					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
>  						   dev->name, status);
>  				tp->stats.rx_errors++; /* end of a packet.*/
> -				if (status & 0x0890) tp->stats.rx_length_errors++;
> +				if (pkt_len > 1518 ||
> +				    (status & RxDescRunt))
> +					tp->stats.rx_length_errors++;
>  				if (status & 0x0004) tp->stats.rx_frame_errors++;
>  				if (status & 0x0002) tp->stats.rx_crc_errors++;
>  				if (status & 0x0001) tp->stats.rx_fifo_errors++;
>  			}
>  		} else {
> -			/* Omit the four octet CRC from the length. */
> -			short pkt_len = ((status >> 16) & 0x7ff) - 4;
>  			struct sk_buff *skb;
>  
> -#ifndef final_version
> -			if (pkt_len > 1518) {
> -				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
> -					   dev->name, pkt_len, pkt_len);
> -				pkt_len = 1518;
> -				tp->stats.rx_length_errors++;
> -			}
> -#endif
> -
>  			/* Check if the packet is long enough to accept without copying
>  			   to a minimally-sized skbuff. */
>  			if (pkt_len < tulip_rx_copybreak
> diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
> index 19abbc3..0afa2d4 100644
> --- a/drivers/net/tulip/tulip.h
> +++ b/drivers/net/tulip/tulip.h
> @@ -201,8 +201,38 @@ enum desc_status_bits {
>  	DescStartPkt = 0x20000000,
>  	DescEndRing  = 0x02000000,
>  	DescUseLink  = 0x01000000,
> -	RxDescFatalErr = 0x008000,
> +
> +	/*
> +	 * Error summary flag is logical or of 'CRC Error', 'Collision Seen',
> +	 * 'Frame Too Long', 'Runt' and 'Descriptor Error' flags generated
> +	 * within tulip chip.
> +	 */
> +	RxDescErrorSummary = 0x8000,
> +	RxDescCRCError = 0x0002,
> +	RxDescCollisionSeen = 0x0040,
> +
> +	/*
> +	 * 'Frame Too Long' flag is set if packet length including CRC exceeds
> +	 * 1518.  However, a full sized VLAN tagged frame is 1522 bytes
> +	 * including CRC.
> +	 *
> +	 * The tulip chip does not block oversized frames, and if this flag is
> +	 * set on a receive descriptor it does not indicate the frame has been
> +	 * truncated.  The receive descriptor also includes the actual length.
> +	 * Therefore we can safety ignore this flag and check the length
> +	 * ourselves.
> +	 */
> +	RxDescFrameTooLong = 0x0080,
> +	RxDescRunt = 0x0800,
> +	RxDescDescErr = 0x4000,
>  	RxWholePkt   = 0x00000300,
> +	/*
> +	 * Top three bits of 14 bit frame length (status bits 27-29) should
> +	 * never be set as that would make frame over 2047 bytes. The Receive
> +	 * Watchdog flag (bit 4) may indicate the length is over 2048 and the
> +	 * length field is invalid.
> +	 */
> +	RxLengthOver2047 = 0x38000010
>  };
>  
>  
> -- 
> 1.6.0.4
