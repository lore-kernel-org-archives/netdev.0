From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [patch] r8169: fix crash when large packets are received
Date: Mon, 08 Jun 2009 21:40:38 -0400
Message-ID: <1244511638.30733.41.camel@localhost.localdomain>
References: <4A2D8B8B.80905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Tokarev <mjt@tls.msk.ru>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:53182 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbZFIBlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 21:41:12 -0400
In-Reply-To: <4A2D8B8B.80905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC -stable team - remote DoS with this hardware present.

On Tue, 2009-06-09 at 00:07 +0200, Eric Dumazet wrote:
> Michael Tokarev reported receiving a large packet could crash
> a machine with RTL8169 NIC.
> ( original thread at http://lkml.org/lkml/2009/6/8/192 )
> 
> Problem is this driver tells that NIC frames up to 16383 bytes
> can be received but provides skb to rx ring allocated with
> smaller sizes (1536 bytes in case standard 1500 bytes MTU is used)
> 
> When a frame larger than what was allocated by driver is received,
> dma transfert can occurs past the end of buffer and corrupt
> kernel memory.
> 
> Fix is to tell to NIC what is the maximum size a frame can be.
> 
> This bug is very old, (before git introduction, linux-2.6.10), and 
> should be backported to stable versions.
> 
> Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> ---
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 8247a94..3b19e0c 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -66,7 +66,6 @@ static const int multicast_filter_limit = 32;
>  #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>  #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>  #define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
> -#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
>  #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
>  #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
>  
> @@ -2357,10 +2356,10 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
>  	return cmd;
>  }
>  
> -static void rtl_set_rx_max_size(void __iomem *ioaddr)
> +static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
>  {
>  	/* Low hurts. Let's disable the filtering. */
> -	RTL_W16(RxMaxSize, 16383);
> +	RTL_W16(RxMaxSize, rx_buf_sz);
>  }
>  
>  static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
> @@ -2407,7 +2406,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> @@ -2668,7 +2667,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
>  
> @@ -2846,7 +2845,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

