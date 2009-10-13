From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Tue, 13 Oct 2009 15:12:02 -0700 (PDT)
Message-ID: <20091013.151202.207066823.davem@davemloft.net>
References: <4AD4F0BF.1040606@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56686
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760759AbZJMWMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 18:12:06 -0400
In-Reply-To: <4AD4F0BF.1040606@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <Joyce.Yu@Sun.COM>
Date: Tue, 13 Oct 2009 14:27:27 -0700

> @@ -3545,7 +3546,15 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
>  	rp->rcr_index = index;
>  
>  	skb_reserve(skb, NET_IP_ALIGN);
> -	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
> +	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
> +
> +	veth = (struct vlan_ethhdr *)skb->data;
> +	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
> +		skb->tail -= 4;
> +		skb->data_len += 4;
> +		skb_shinfo(skb)->frags[0].page_offset -= 4;
> +		skb_shinfo(skb)->frags[0].size += 4;
> +	}

So you guys spent an enormous amount of time trying to figure out
why just a plain '__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));'
doesn't work.

Don't you think the full details of your discovery might be relevant
either in the commit message or a comment?

Otherwise, how is anyone else in the world going to figure out why you
had to do these frag list adjustments?
