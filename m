From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 15:14:11 -0800
Message-ID: <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
	 <20141125224406.1867.97911.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35214 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaKYXON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 18:14:13 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so1609067ieb.17
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 15:14:13 -0800 (PST)
In-Reply-To: <20141125224406.1867.97911.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 14:44 -0800, Alexander Duyck wrote:
> Update the Intel Ethernet drivers to use eth_skb_pad() instead of doing
> their own implementations of the function.
> 
> Also this cleans up two other spots where skb_pad was called but the length
> and tail pointers were being manipulated directly instead of just having
> the padding length added via __skb_put.
> 
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
>  drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++--------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++--------
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
>  5 files changed, 14 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 24f3986..862d198 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3136,12 +3136,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
>  	 * packets may get corrupted during padding by HW.
>  	 * To WA this issue, pad all small packets manually.
>  	 */
> -	if (skb->len < ETH_ZLEN) {
> -		if (skb_pad(skb, ETH_ZLEN - skb->len))
> -			return NETDEV_TX_OK;
> -		skb->len = ETH_ZLEN;
> -		skb_set_tail_pointer(skb, ETH_ZLEN);
> -	}
> +	if (eth_skb_pad(skb))
> +		return NETDEV_TX_OK;
>  

Its a bit sad almost no driver increments some drop counter.

This probably could be generically done in eth_skb_pad()

atomic_long_inc(&skb->dev->tx_dropped)
