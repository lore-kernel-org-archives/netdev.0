From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: plug skb leaks
Date: Wed, 19 Aug 2015 10:13:25 -0700
Message-ID: <55D4B935.5090400@cumulusnetworks.com>
References: <1439953949-23736-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34727 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbbHSRN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 13:13:29 -0400
Received: by paccq16 with SMTP id cq16so7259884pac.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 10:13:28 -0700 (PDT)
In-Reply-To: <1439953949-23736-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay:

On 8/18/15 8:12 PM, Nikolay Aleksandrov wrote:
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index ed208317cbb5..4aa06450fafa 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -97,6 +97,12 @@ static bool is_ip_rx_frame(struct sk_buff *skb)
>   	return false;
>   }
>
> +static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
> +{
> +	vrf_dev->stats.tx_errors++;
> +	kfree_skb(skb);
> +}
> +
>   /* note: already called with rcu_read_lock */
>   static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
>   {
> @@ -149,7 +155,8 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
>   static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
>   					   struct net_device *dev)
>   {
> -	return 0;
> +	vrf_tx_error(dev, skb);
> +	return NET_XMIT_DROP;
>   }
>
>   static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
> @@ -206,8 +213,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
>   out:
>   	return ret;
>   err:
> -	vrf_dev->stats.tx_errors++;
> -	kfree_skb(skb);
> +	vrf_tx_error(vrf_dev, skb);
>   	goto out;
>   }
>
> @@ -219,6 +225,7 @@ static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
>   	case htons(ETH_P_IPV6):
>   		return vrf_process_v6_outbound(skb, dev);
>   	default:
> +		vrf_tx_error(dev, skb);
>   		return NET_XMIT_DROP;
>   	}
>   }
>

Would be simpler to do the vrf_tx_error at the end of is_ip_tx_frame() 
if ret == NET_XMIT_DROP.

David
