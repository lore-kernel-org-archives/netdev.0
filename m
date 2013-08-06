From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Tue, 06 Aug 2013 05:22:17 -0700
Message-ID: <1375791737.4457.98.camel@edumazet-glaptop>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	 <1375750370-18194-5-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:53340 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab3HFMWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:22:19 -0400
In-Reply-To: <1375750370-18194-5-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 08:52 +0800, Ming Lei wrote:
> This patch enables 'can_dma_sg' flag for ax88179_178a device
> if the attached host controller supports building packet from
> discontinuous buffers(DMA SG is possible), so TSO can be enabled
> and skb fragment buffers can be passed to usb stack via urb->sg
> directly.
> 
> With the patch, system CPU utilization decreased ~50% and throughput
> increased by ~10% when doing iperf client test on one ARM A15 dual
> core board.
> 

Nice ;)

>  	       AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> @@ -1310,6 +1318,10 @@ static int ax88179_reset(struct usbnet *dev)
>  
>  	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  				 NETIF_F_RXCSUM;
> +	if (dev->can_dma_sg) {
> +		dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
> +		dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
> +	}
>  

My concern with setting TSO on reset() is the following :

Admin can disable TSO with

ethtool -K ethX tso off


Then, one hour later, or one month later, a reset happens, and this code
magically re-enables TSO

So, I really think this part should be removed from your patch.
