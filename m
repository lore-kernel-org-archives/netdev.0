From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 08:55:41 +0200
Message-ID: <1407308141.14097.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:46671 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbaHFGzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 02:55:46 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so2146019wgh.14
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 23:55:44 -0700 (PDT)
In-Reply-To: <1407204710-21778-6-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-04 at 22:11 -0400, Willem de Bruijn wrote:
> TCP timestamping extends SO_TIMESTAMPING to bytestreams.

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 9d2118e..744af67 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -426,6 +426,15 @@ void tcp_init_sock(struct sock *sk)
>  }
>  EXPORT_SYMBOL(tcp_init_sock);
>  
> +void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct skb_shared_info *shinfo = skb_shinfo(skb);
> +
> +	sock_tx_timestamp(sk, &shinfo->tx_flags);

Arg, this breaks SKBTX_SHARED_FRAG support.

And sock_tx_timestamp() is quite expensive for TCP where only
SKBTX_ACK_TSTAMP could possibly be supported ?

> +	if (shinfo->tx_flags & SKBTX_ANY_SW_TSTAMP)
> +		shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
> +}


static void tcp_tx_timestamp(const struct sock *sk, struct sk_buff *skb)

I'll send a cumulative patch.
