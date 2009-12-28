From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Mon, 28 Dec 2009 14:50:53 -0500
Message-ID: <20091228195053.GB18422@hmsreliant.think-freely.org>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	nhorman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44399 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbZL1TvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 14:51:00 -0500
Content-Disposition: inline
In-Reply-To: <20091228194834.GA18422@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies, Reposting, I had meant to cc the usual suspects, and completely
forgot

Neil


On Mon, Dec 28, 2009 at 02:48:34PM -0500, Neil Horman wrote:
> Hey all-
> 	A while back Eric submitted a patch for r8169 in which the proper
> allocated frame size was written to RXMaxSize to prevent the NIC from dmaing too
> much data.  This was done in commit fdd7b4c3302c93f6833e338903ea77245eb510b4.  A
> long time prior to that however, Francois posted
> 126fa4b9ca5d9d7cb7d46f779ad3bd3631ca387c, which expiclitly disabled the MaxSize
> setting due to the fact that the hardware behaved in odd ways when overlong
> frames were received on NIC's supported by this driver.  This was mentioned in a
> security conference recently:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> 
> It seems that if we can't enable frame size filtering, then, as Eric correctly
> noticed, we can find ourselves DMA-ing too much data to a buffer, causing
> corruption.  As a result is seems that we are forced to allocate a frame which
> is ready to handle a maximally sized receive.
> 
> I've not tested the below patch at all, and clearly it stinks to have to do.
> But I thought it would be worth posting to solicit comments on it.
> 
> Thanks & Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  r8169.c |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 60f96c4..42e3b22 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -63,6 +63,7 @@ static const int multicast_filter_limit = 32;
>  #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>  #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>  #define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
> +#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
>  #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
>  #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
>  
> @@ -3383,7 +3384,7 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
>  static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
>  {
>  	/* Low hurts. Let's disable the filtering. */
> -	RTL_W16(RxMaxSize, rx_buf_sz + 1);
> +	RTL_W16(RxMaxSize, 16383);
>  }
>  
>  static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
> @@ -3430,7 +3431,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
> +	rtl_set_rx_max_size(ioaddr);
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> @@ -3691,7 +3692,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
> +	rtl_set_rx_max_size(ioaddr);
>  
>  	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
>  
> @@ -3871,7 +3872,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
> +	rtl_set_rx_max_size(ioaddr);
>  
>  	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
>  
> @@ -3972,7 +3973,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
>  
>  	pad = align ? align : NET_IP_ALIGN;
>  
> -	skb = netdev_alloc_skb(dev, rx_buf_sz + pad);
> +	skb = netdev_alloc_skb(dev, 16383 + pad);
>  	if (!skb)
>  		goto err_out;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
