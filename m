From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] openvswitch: fix a use after free
Date: Thu, 16 Oct 2014 07:12:27 -0700
Message-ID: <1413468747.28798.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413450075-5044-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39876 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbaJPOM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 10:12:28 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so3459616pab.26
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 07:12:28 -0700 (PDT)
In-Reply-To: <1413450075-5044-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-16 at 17:01 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() called by arphdr_ok can change skb->data, so put the arp
> setting after arphdr_ok to avoid the use the freed memory
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/openvswitch/flow.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 62db02b..b13ba5e 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -557,10 +557,11 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>  	} else if (key->eth.type == htons(ETH_P_ARP) ||
>  		   key->eth.type == htons(ETH_P_RARP)) {
>  		struct arp_eth_header *arp;
> +		bool arp_t = arphdr_ok(skb);

This is a strange name for a bool.  _t suffix is normally used by
typedef.

>  
>  		arp = (struct arp_eth_header *)skb_network_header(skb);
>  
> -		if (arphdr_ok(skb) &&
> +		if (arp_t &&
>  		    arp->ar_hrd == htons(ARPHRD_ETHER) &&
>  		    arp->ar_pro == htons(ETH_P_IP) &&
>  		    arp->ar_hln == ETH_ALEN &&

Fixes: 0714812134d7d ("openvswitch: Eliminate memset() from flow_extract.")

By doing this bug hunting, you also can CC bug author so that he knows
what happened. Maybe he will avoid similar mistakes in the future.
