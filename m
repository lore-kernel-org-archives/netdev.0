From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Sun, 16 Apr 2017 20:59:44 -0600
Message-ID: <e8f9b5aa-4f17-478c-bc2c-51757e86683d@cumulusnetworks.com>
References: <3639a683-2839-4363-2cd2-c2a040402c93@cumulusnetworks.com>
 <1492389870-22733-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34262 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932401AbdDQC7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 22:59:51 -0400
Received: by mail-pg0-f44.google.com with SMTP id z127so2102642pgb.1
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 19:59:51 -0700 (PDT)
In-Reply-To: <1492389870-22733-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/16/17 6:44 PM, Subash Abhinov Kasiviswanathan wrote:
> Can you try this
> 
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
> 

That works for me. Thanks for the fast turn around.
