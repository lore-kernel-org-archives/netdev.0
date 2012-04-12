From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Thu, 12 Apr 2012 18:08:00 +0200
Message-ID: <1334246880.5300.6736.camel@edumazet-glaptop>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
	 <1334222448.5300.6046.camel@edumazet-glaptop>
	 <20120412125355.GG16025@mudshark.cambridge.arm.com>
	 <1334235963.5300.6361.camel@edumazet-glaptop>
	 <20120412134757.GH16025@mudshark.cambridge.arm.com>
	 <1334239299.5300.6478.camel@edumazet-glaptop>
	 <20120412155409.GA28204@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63003 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932965Ab2DLQIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 12:08:05 -0400
Received: by bkcik5 with SMTP id ik5so1654675bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 09:08:04 -0700 (PDT)
In-Reply-To: <20120412155409.GA28204@mudshark.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 16:54 +0100, Will Deacon wrote:

> Gotcha, so I can lose the pull too. Here's an updated patch with log, thanks
> for the help.
> 
> Will
> 
> 
> Author: Will Deacon <will.deacon@arm.com>
> Date:   Thu Apr 12 13:54:17 2012 +0100
> 
>     net: smsc911x: fix skb handling in receive path
>     
>     The SMSC911x driver resets the ->head, ->data and ->tail pointers in the
>     skb on the reset path in order to avoid buffer overflow due to packet
>     padding performed by the hardware.
>     
>     This patch fixes the receive path so that the skb pointers are fixed up
>     after the data has been read from the device, The error path is also
>     fixed to use number of words consistently and prevent erroneous FIFO
>     fastforwarding when skipping over bad data.
>     
>     Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 4a69710..5aa2dbe 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -1166,10 +1166,8 @@ smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)
>  
>  /* Quickly dumps bad packets */
>  static void
> -smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
> +smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktwords)
>  {
> -	unsigned int pktwords = (pktbytes + NET_IP_ALIGN + 3) >> 2;
> -
>  	if (likely(pktwords >= 4)) {
>  		unsigned int timeout = 500;
>  		unsigned int val;
> @@ -1233,7 +1231,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>  			continue;
>  		}
>  
> -		skb = netdev_alloc_skb(dev, pktlength + NET_IP_ALIGN);
> +		skb = netdev_alloc_skb(dev, pktwords << 2);
>  		if (unlikely(!skb)) {
>  			SMSC_WARN(pdata, rx_err,
>  				  "Unable to allocate skb for rx packet");
> @@ -1243,14 +1241,12 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>  			break;
>  		}
>  
> -		skb->data = skb->head;
> -		skb_reset_tail_pointer(skb);
> +		pdata->ops->rx_readfifo(pdata,
> +				 (unsigned int *)skb->data, pktwords);
>  
>  		/* Align IP on 16B boundary */
>  		skb_reserve(skb, NET_IP_ALIGN);
>  		skb_put(skb, pktlength - 4);
> -		pdata->ops->rx_readfifo(pdata,
> -				 (unsigned int *)skb->head, pktwords);
>  		skb->protocol = eth_type_trans(skb, dev);
>  		skb_checksum_none_assert(skb);
>  		netif_receive_skb(skb);
> @@ -1565,7 +1561,7 @@ static int smsc911x_open(struct net_device *dev)
>  	smsc911x_reg_write(pdata, FIFO_INT, temp);
>  
>  	/* set RX Data offset to 2 bytes for alignment */
> -	smsc911x_reg_write(pdata, RX_CFG, (2 << 8));
> +	smsc911x_reg_write(pdata, RX_CFG, (NET_IP_ALIGN << 8));
>  
>  	/* enable NAPI polling before enabling RX interrupts */
>  	napi_enable(&pdata->napi);

Seems fine to me

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
