From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next 1/2] IP_GRE: Fix GRE_CSUM case.
Date: Mon, 25 Feb 2013 11:40:06 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1C01B740@SJEXCHMB06.corp.ad.broadcom.com>
References: <1361772305-1665-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Pravin B Shelar" <pshelar@nicira.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2158 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759652Ab3BYLkO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 06:40:14 -0500
In-Reply-To: <1361772305-1665-1-git-send-email-pshelar@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Pravin B Shelar [mailto:pshelar@nicira.com]
> Sent: Monday, February 25, 2013 8:05 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Pravin B Shelar
> Subject: [PATCH net-next 1/2] IP_GRE: Fix GRE_CSUM case.
> 
> commit "ip_gre: allow CSUM capable devices to handle packets"
> aa0e51cdda005cd37e2, broke GRE_CSUM case.
> GRE_CSUM needs checksum computed for inner packet. Therefore
> csum-calculation can not be offloaded if tunnel device requires
> GRE_CSUM.  Following patch fixes it by computing inner packet checksum
> for GRE_CSUM type, for all other type of GRE devices csum is offloaded.
> 
> CC: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_gre.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 5ef4da7..9b4996d 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -735,7 +735,7 @@ drop:
>  	return 0;
>  }
> 
> -static struct sk_buff *handle_offloads(struct sk_buff *skb)
> +static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel, struct sk_buff *skb)
>  {
>  	int err;
> 
> @@ -745,8 +745,12 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
>  			goto error;
>  		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
>  		return skb;
> -	}
> -	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +	} else if (skb->ip_summed == CHECKSUM_PARTIAL &&
> +		   tunnel->parms.o_flags&GRE_CSUM) {
> +		err = skb_checksum_help(skb);
> +		if (unlikely(err))
> +			goto error;
> +	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
>  		skb->ip_summed = CHECKSUM_NONE;
> 
>  	return skb;
> @@ -776,7 +780,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  	int    err;
>  	int    pkt_len;
> 
> -	skb = handle_offloads(skb);
> +	skb = handle_offloads(tunnel, skb);
>  	if (IS_ERR(skb)) {
>  		dev->stats.tx_dropped++;
>  		return NETDEV_TX_OK;
> --
> 1.7.1

Tested the series on two different devices

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
