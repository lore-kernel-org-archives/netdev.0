From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Wed, 3 Apr 2013 02:38:03 +0200
Message-ID: <20130403003803.GA20292@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com> <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com> <20130402211524.GE4924@order.stressinduktion.org> <1364940038.5113.187.camel@edumazet-glaptop> <20130402221520.GF4924@order.stressinduktion.org> <1364942093.5113.189.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47521 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756197Ab3DCAiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 20:38:04 -0400
Content-Disposition: inline
In-Reply-To: <1364942093.5113.189.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 03:34:53PM -0700, Eric Dumazet wrote:
> Really I don't understand why people use u16 instead of u32.
> 
> u16 is slower most of the time, and more prone to overflows.
> 
> diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> index 7e0a822..48ac487 100644
> --- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> +++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> @@ -1569,18 +1569,17 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
>  {
>  	int i = 0;
>  	u16 tpd_req = 1;
> -	u16 fg_size = 0;
> -	u16 proto_hdr_len = 0;
>  
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		fg_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> +		u32 fg_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> +
>  		tpd_req += ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_SHIFT);
>  	}
>  
>  	if (skb_is_gso(skb)) {
>  		if (skb->protocol == htons(ETH_P_IP) ||
>  		   (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6)) {
> -			proto_hdr_len = skb_transport_offset(skb) +
> +			u32 proto_hdr_len = skb_transport_offset(skb) +
>  					tcp_hdrlen(skb);
>  			if (proto_hdr_len < skb_headlen(skb)) {
>  				tpd_req += ((skb_headlen(skb) - proto_hdr_len +
> @@ -1670,7 +1669,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
>  {
>  	struct atl1e_tpd_desc *use_tpd = NULL;
>  	struct atl1e_tx_buffer *tx_buffer = NULL;
> -	u16 buf_len = skb_headlen(skb);
> +	u32 buf_len = skb_headlen(skb);
>  	u16 map_len = 0;
>  	u16 mapped_len = 0;
>  	u16 hdr_len = 0;
> 

I tested this patch ontop of the patch which reduces gso max size to 0x3c00.
If you want to submit the patch you could add my acked-by.

Thanks,

  Hannes
