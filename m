From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: macvlan: optimizing the receive path?
Date: Fri, 03 Oct 2014 12:16:23 -0400
Message-ID: <542ECBD7.7030807@gmail.com>
References: <542DB55D.3090601@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net
To: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34979 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbaJCQQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 12:16:27 -0400
Received: by mail-qc0-f173.google.com with SMTP id x13so1243538qcv.4
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 09:16:26 -0700 (PDT)
In-Reply-To: <542DB55D.3090601@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2014 04:28 PM, Jason Baron wrote:
> Hi,
> 
> I was just wondering why the netif_rx(skb) call in macvlan_handle_frame()
> was necessary? IE:
> 
> macvlan_handle_frame()
> {
>        ........
> 
>         skb->dev = dev;
>         skb->pkt_type = PACKET_HOST;
> 
> ****>ret = netif_rx(skb);
> 
> out:
>         macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
>         return RX_HANDLER_CONSUMED;
> }
> 
> 
> I think the point of going through netif_rx() is to ensure that we throttle
> incoming packets, but hasn't that already been accomplished in this path?
> That is if the packets are arriving from the physical NIC, we've already
> throttled them by this point. Otherwise, if they are coming via
> macvlan_queue_xmit(), it calls either 'dev_forward_skb()', which ends
> up calling netif_rx_internal(), or else in broadcast mode there is
> to be throttling via macvlan_broadcast_enqueue().
> 
> So I suspect there is a code path that I am missing but the netif_rx() call in
> question essentially re-queues packets coming from off the box. I've tried the
> simple patch below to optimize this path, and obviously performs a lot better
> in my limited testing.

Hi Jason

I think the patch below is fine and in this particular case, it's OK to do this.

-vlad

> 
> Thanks,
> 
> -Jason
> 
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -321,8 +321,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>         skb->dev = dev;
>         skb->pkt_type = PACKET_HOST;
>  
> -       ret = netif_rx(skb);
> -
> +      macvlan_count_rx(vlan, len, true, 0);
> +      return RX_HANDLER_ANOTHER;
>  out:
>         macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
>         return RX_HANDLER_CONSUMED;
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
