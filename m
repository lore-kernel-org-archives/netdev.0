From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] e1000: add dummy allocator to fix race condition
 between mtu change and netpoll
Date: Wed, 25 Feb 2015 02:26:45 -0800
Message-ID: <1424860005.5565.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424858711-22879-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:50560 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbbBYK0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 05:26:48 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so35245060iga.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 02:26:47 -0800 (PST)
In-Reply-To: <1424858711-22879-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 11:05 +0100, Sabrina Dubroca wrote:
> There is a race condition between e1000_change_mtu's cleanups and
> netpoll, when we change the MTU across jumbo size:
...
> 
> Fixes: edbbb3ca1077 ("e1000: implement jumbo receive with partial descriptors")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 7f997d36948f..5af866150671 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -144,6 +144,9 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
>  static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>  				     struct e1000_rx_ring *rx_ring,
>  				     int *work_done, int work_to_do);
> +static void e1000_alloc_dummy_rx_buffers(struct e1000_adapter *adapter,
> +					 struct e1000_rx_ring *rx_ring,
> +					 int cleaned_count);

Why are you using a forward declaration ?

Simply put here the body of this (dummy) function.

>  static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
>  				   struct e1000_rx_ring *rx_ring,
>  				   int cleaned_count);
> @@ -3552,8 +3555,11 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
>  		msleep(1);
>  	/* e1000_down has a dependency on max_frame_size */
>  	hw->max_frame_size = max_frame;
> -	if (netif_running(netdev))
> +	if (netif_running(netdev)) {
> +		/* prevent buffers from being reallocated */
> +		adapter->alloc_rx_buf = e1000_alloc_dummy_rx_buffers;
>  		e1000_down(adapter);
> +	}
>  
>  	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
>  	 * means we reserve 2 more, this pushes us to allocate from the next
> @@ -4481,6 +4487,12 @@ next_desc:
>  	return cleaned;
>  }
>  
> +static void e1000_alloc_dummy_rx_buffers(struct e1000_adapter *adapter,
> +					 struct e1000_rx_ring *rx_ring,
> +					 int cleaned_count)
> +{
> +}
> +
>  /**
>   * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
>   * @adapter: address of board private structure
