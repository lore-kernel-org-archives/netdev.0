From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net v2 1/3] packet: do skb_probe_transport_header when we
 actually have data
Date: Wed, 11 Nov 2015 13:07:46 +0800
Message-ID: <5642CD22.5050600@redhat.com>
References: <cover.1447191361.git.daniel@iogearbox.net>
 <a81140c47ff908cfe86c51e6355876ebeda479c5.1447191361.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730AbbKKFHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 00:07:55 -0500
In-Reply-To: <a81140c47ff908cfe86c51e6355876ebeda479c5.1447191361.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/11/2015 06:03 AM, Daniel Borkmann wrote:
> In tpacket_fill_skb() commit c1aad275b029 ("packet: set transport
> header before doing xmit") and later on 40893fd0fd4e ("net: switch
> to use skb_probe_transport_header()") was probing for a transport
> header on the skb from a ring buffer slot, but at a time, where
> the skb has _not even_ been filled with data yet. So that call into
> the flow dissector is pretty useless. Lets do it after we've set
> up the skb frags.
>
> Fixes: c1aad275b029 ("packet: set transport header before doing xmit")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Jason Wang <jasowang@redhat.com>
> ---
>  net/packet/af_packet.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index af399ca..80c36c0 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2368,8 +2368,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  	skb_reserve(skb, hlen);
>  	skb_reset_network_header(skb);
>  
> -	if (!packet_use_direct_xmit(po))
> -		skb_probe_transport_header(skb, 0);
>  	if (unlikely(po->tp_tx_has_off)) {
>  		int off_min, off_max, off;
>  		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
> @@ -2449,6 +2447,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  		len = ((to_write > len_max) ? len_max : to_write);
>  	}
>  
> +	if (!packet_use_direct_xmit(po))
> +		skb_probe_transport_header(skb, 0);
> +
>  	return tp_len;
>  }
>  

Acked-by: Jason Wang <jasowang@redhat.com>
