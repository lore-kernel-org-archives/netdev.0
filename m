From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Wed, 23 Jan 2013 23:00:48 +0900
Message-ID: <50FFED10.30700@linux-ipv6.org>
References: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38433 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755290Ab3AWOAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:00:51 -0500
In-Reply-To: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pravin B Shelar wrote:
> Fixed code indentation according to comments from David Miller.
> 
> --8<--------------------------cut here-------------------------->8--
> Due to GSO support, GRE can recieve non linear skb which
> results in panic in case of GRE_CSUM.
> Following patch fixes it by using correct csum API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_gre.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 303012a..8179e066 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -964,7 +964,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  		}
>  		if (tunnel->parms.o_flags&GRE_CSUM) {
>  			*ptr = 0;
> -			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
> +			*(__sum16 *)ptr = csum_fold(skb_checksum(skb,
> +						    skb_transport_offset(skb),
> +						    skb->len - skb_transport_offset(skb),
> +						    0));

IMHO, arguments for skb_checksum() should be aligned:

			*(__sum16 *)ptr = csum_fold(skb_checksum(skb,
								 skb_transport_offset(skb),
								 skb->len - skb_transport_offset(skb),
								 0));

--yoshfuji
