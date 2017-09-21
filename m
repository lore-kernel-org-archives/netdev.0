From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 2/5] net: allow early demux to fetch noref
 socket
Date: Thu, 21 Sep 2017 11:13:11 +0200
Message-ID: <1505985191.2560.38.camel@redhat.com>
References: <cover.1505926196.git.pabeni@redhat.com>
         <db75c6a6872040712a9ab97b0bac04b697c42a4c.1505926196.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39122 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751548AbdIUJNN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 05:13:13 -0400
In-Reply-To: <db75c6a6872040712a9ab97b0bac04b697c42a4c.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 18:54 +0200, Paolo Abeni wrote:
> We must be careful to avoid leaking such sockets outside
> the RCU section containing the early demux call; we clear
> them on nonlocal delivery.
> 
> For ipv4 we must take care of local mcast delivery, too,
> since udp early demux works also for mcast addresses.
> 
> Also update all iptables/nftables extension that can
> happen in the input chain and can transmit the skb outside
> such patch, namely TEE, nft_dup and nfqueue.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/ip_input.c              | 12 ++++++++++++
>  net/ipv4/ipmr.c                  | 18 ++++++++++++++----
>  net/ipv4/netfilter/nf_dup_ipv4.c |  3 +++
>  net/ipv6/ip6_input.c             |  7 ++++++-
>  net/ipv6/netfilter/nf_dup_ipv6.c |  3 +++
>  net/netfilter/nf_queue.c         |  3 +++
>  6 files changed, 41 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index fa2dc8f692c6..e71abc8b698c 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -349,6 +349,18 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  				__NET_INC_STATS(net, LINUX_MIB_IPRPFILTER);
>  			goto drop;
>  		}
> +
> +		/* Since the sk has no reference to the socket, we must
> +		 * clear it before escaping this RCU section.
> +		 * The sk is just an hint and we know we are not going to use
> +		 * it outside the input path.
> +		 */
> +		if (skb_dst(skb)->input != ip_local_deliver
> +#ifdef CONFIG_IP_MROUTE
> +		    && skb_dst(skb)->input != ip_mr_input
> +#endif
> +		    )
> +			skb_clear_noref_sk(skb);
>  	}

The above is to allow early demux for multicast sockets even on hosts
acting as multicast router. This is probably overkill: an host will
probably act as a multicast router or receive large amount of locally
terminate mcast traffic.

We can instead preserve the sknoref only for ip_local_deliver(),
dropping the early demux optimization in the above scenario, which
should not be very relevant. Will simplify the above chunk and drop the
need for the ipmr.c changes below; overall this patch will become much
simpler.

Paolo
