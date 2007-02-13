From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Tue, 13 Feb 2007 13:50:16 +1000
Message-ID: <45D13578.8040405@snapgear.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	isely@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:54661 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965477AbXBMERZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 23:17:25 -0500
In-Reply-To: <20061204000327.GE3625@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Two thirds of packets are lost because of misalignment. Users of
> Asus laptop did apparently not notice it.
> 
> Reported on Gigabyte GA-945GM-S2.
> 
> Fix for http://bugzilla.kernel.org/show_bug.cgi?id=7517
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 0b57050..2379d83 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2018,7 +2018,7 @@ static int rtl8169_alloc_rx_skb(struct p
>  	if (!skb)
>  		goto err_out;
>  
> -	skb_reserve(skb, align);
> +	skb_reserve(skb, (align - 1) & (u32)skb->data);
>  	*sk_buff = skb;
>  
>  	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
> @@ -2486,7 +2486,7 @@ static inline int rtl8169_try_rx_copy(st
>  
>  		skb = dev_alloc_skb(pkt_size + align);
>  		if (skb) {
> -			skb_reserve(skb, align);
> +			skb_reserve(skb, (align - 1) & (u32)skb->data);
>  			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
>  			*sk_buff = skb;
>  			rtl8169_mark_to_asic(desc, rx_buf_sz);

This patch caused a drop in throughput from 178 Mbits/sec to 135 Mbits/sec
on an Intel XScale IXP465.

It seems like there is some confusion about what the align parameter
here means. It was originally an offset from an aligned address so that
the IP header aligned, and this patch changes it to the alignment of the
ethernet header. But align is still set to NET_IP_ALIGN for some chips.
