From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Fri, 20 Jul 2012 10:11:17 +0800
Message-ID: <3D5EE67D3FC948CAB5D11ABBBFD60A6F@realtek.com.tw>
References: <1342564781.2626.1264.camel@edumazet-glaptop> <20120717234037.GA26972@electric-eye.fr.zoreil.com> <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw> <20120718.092346.1263036873056516097.davem@davemloft.net> <20120718201201.GC14149@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:34384 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab2GTCLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 22:11:35 -0400
In-Reply-To: <20120718201201.GC14149@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> A part of the apparent problem may stem from the fact that 
> Realtek's 8168
> driver claims a modified length but it does not really skb_padto... 
> 
> Hayes, would the patch below fix the original problem ?

According to the response from our hw engineer, it still has the problem even
though you pad the packet to 60 bytes with zeroes. I would still test this patch
to verify it.

>  static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
> @@ -5797,7 +5804,8 @@ static netdev_tx_t 
> rtl8169_start_xmit(struct sk_buff *skb,
>  	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
>  	opts[0] = DescOwn;
>  
> -	rtl8169_tso_csum(tp, skb, opts);
> +	if (!rtl8169_tso_csum(tp, skb, opts))
> +		goto err_update_stats;
>  

I think you should check the length of opts1 of the descriptor, too. Besides,
how about the length of dma_map_xxx? Should it use the original length or the
modified length?

>  	frags = rtl8169_xmit_frags(tp, skb, opts);
>  	if (frags < 0)
> @@ -5853,6 +5861,7 @@ err_dma_1:
>  	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
>  err_dma_0:
>  	dev_kfree_skb(skb);
> +err_update_stats:
>  	dev->stats.tx_dropped++;
>  	return NETDEV_TX_OK;
>  
 
Best Regards,
Hayes
