From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] netdev: bfin_mac: avoid tx skb overflows in the
 tx DMA ring
Date: Mon, 10 May 2010 04:40:35 -0700 (PDT)
Message-ID: <20100510.044035.199023238.davem@davemloft.net>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
	<1273400337-26501-6-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753282Ab0EJLk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:40:28 -0400
In-Reply-To: <1273400337-26501-6-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Sun,  9 May 2010 06:18:52 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

This should never ever happen, it's a bug and you should print a warning
message when and if it does actually occur.

At any point where your ->next pointer hits tx_list_head, the queue
should have been stopped by your driver and therefore the networking
core will never pass another packet to you.

If this condition is actually triggering, it means you're not locking
properly or you have some race.

> ---
>  drivers/net/bfin_mac.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 6d69bbb..0b5ea01 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -920,6 +920,9 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
>  	u32 data_align = (unsigned long)(skb->data) & 0x3;
>  	union skb_shared_tx *shtx = skb_tx(skb);
>  
> +	if (current_tx_ptr->next == tx_list_head)
> +		return NETDEV_TX_BUSY;
> +
>  	current_tx_ptr->skb = skb;
>  
>  	if (data_align == 0x2) {
> -- 
> 1.7.1
> 
