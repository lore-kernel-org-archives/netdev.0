From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: clean up tcp_v6_early_demux() icsk variable
Date: Fri, 05 Oct 2012 15:56:05 +0200
Message-ID: <1349445365.21172.74.camel@edumazet-glaptop>
References: <1349443284-14640-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40032 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab2JEN4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 09:56:10 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so944684bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 06:56:08 -0700 (PDT)
In-Reply-To: <1349443284-14640-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-05 at 09:21 -0400, Neal Cardwell wrote:
> Remove an icsk variable, which by convention should refer to an
> inet_connection_sock rather than an inet_sock. In the process, make
> the tcp_v6_early_demux() code and formatting a bit more like
> tcp_v4_early_demux(), to ease comparisons and maintenance.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv6/tcp_ipv6.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 49c8903..491c41b 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1740,11 +1740,11 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
>  		skb->destructor = sock_edemux;
>  		if (sk->sk_state != TCP_TIME_WAIT) {
>  			struct dst_entry *dst = sk->sk_rx_dst;
> -			struct inet_sock *icsk = inet_sk(sk);
> +
>  			if (dst)
>  				dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
>  			if (dst &&
> -			    icsk->rx_dst_ifindex == skb->skb_iif)
> +			    inet_sk(sk)->rx_dst_ifindex == skb->skb_iif)
>  				skb_dst_set_noref(skb, dst);
>  		}
>  	}

Hi Neal

I would wait net-next being opened, and do a full merge/cleanup

For example ipv6 uses :

if (!pskb_may_pull(skb, skb_transport_offset(skb) + 
                   sizeof(struct tcphdr))) 
th = tcp_hdr(skb);

while ipv4 uses :

if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));

It would be good to use the ipv6 variant (its less instructions and
cleaner)

Same for the "struct net *net = dev_net(skb->dev);" used in ipv4, while
ipv6 doesnt need this extra net variable.

Thanks
