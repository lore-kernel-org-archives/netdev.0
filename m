From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: Fix UDP early demux lookup with
 udp_l3mdev_accept=0
Date: Mon, 17 Apr 2017 14:52:40 -0700
Message-ID: <1492465960.10587.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492463503-3351-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, rshearma@brocade.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34452 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756576AbdDQVwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 17:52:42 -0400
Received: by mail-pg0-f67.google.com with SMTP id o123so29780577pga.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 14:52:42 -0700 (PDT)
In-Reply-To: <1492463503-3351-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 15:11 -0600, Subash Abhinov Kasiviswanathan wrote:
> David Ahern reported that 5425077d73e0c ("net: ipv6: Add early demux
> handler for UDP unicast") breaks udp_l3mdev_accept=0 since early
> demux for IPv6 UDP was doing a generic socket lookup which does not
> require an exact match. Fix this by making UDPv6 early demux match
> connected sockets only.
> 
> Fixes: 5425077d73e0c ("net: ipv6: Add early demux handler for UDP unicast")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/ipv6/udp.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index b793ed1..0e307e5 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -46,6 +46,7 @@
>  #include <net/tcp_states.h>
>  #include <net/ip6_checksum.h>
>  #include <net/xfrm.h>
> +#include <net/inet_hashtables.h>
>  #include <net/inet6_hashtables.h>
>  #include <net/busy_poll.h>
>  #include <net/sock_reuseport.h>
> @@ -864,21 +865,25 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  	return 0;
>  }
>  
> +
>  static struct sock *__udp6_lib_demux_lookup(struct net *net,
>  			__be16 loc_port, const struct in6_addr *loc_addr,
>  			__be16 rmt_port, const struct in6_addr *rmt_addr,
>  			int dif)
>  {
> +	unsigned short hnum = ntohs(loc_port);
> +	unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
> +	unsigned int slot2 = hash2 & udp_table.mask;
> +	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
> +	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
>  	struct sock *sk;
>  
> -	rcu_read_lock();
> -	sk = __udp6_lib_lookup(net, rmt_addr, rmt_port, loc_addr, loc_port,
> -			       dif, &udp_table, NULL);
> -	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> -		sk = NULL;
> -	rcu_read_unlock();
> -
> -	return sk;
> +	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
> +		if (INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
> +			return sk;
> +		break;
> +	}
> +	return NULL;
>  }
>  
>  static void udp_v6_early_demux(struct sk_buff *skb)


This can not be right.

You removed the atomic_inc_not_zero() call, meaning that this code will
release a live socket.
