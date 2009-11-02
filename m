From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] ipv6: no more dev_put() in
	datagram_send_ctl()
Date: Mon, 2 Nov 2009 14:35:25 -0800
Message-ID: <20091102223525.GC6795@linux.vnet.ibm.com>
References: <4AEEC0A2.1070502@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:48110 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756899AbZKBWfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 17:35:21 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nA2IVpPx027521
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 13:31:51 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA2MZPpI1241238
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 17:35:25 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA2MZPrn016755
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 17:35:25 -0500
Content-Disposition: inline
In-Reply-To: <4AEEC0A2.1070502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 12:21:06PM +0100, Eric Dumazet wrote:
> Avoids touching device refcount in datagram_send_ctl(), thanks to RCU

Quite a series of patches!!!  I am impressed!!!

							Thanx, Paul

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv6/datagram.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 9f70452..e6f9cdf 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -537,12 +537,17 @@ int datagram_send_ctl(struct net *net,
> 
>  			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
> 
> +			rcu_read_lock();
>  			if (fl->oif) {
> -				dev = dev_get_by_index(net, fl->oif);
> -				if (!dev)
> +				dev = dev_get_by_index_rcu(net, fl->oif);
> +				if (!dev) {
> +					rcu_read_unlock();
>  					return -ENODEV;
> -			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
> +				}
> +			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +				rcu_read_unlock();
>  				return -EINVAL;
> +			}
> 
>  			if (addr_type != IPV6_ADDR_ANY) {
>  				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
> @@ -553,8 +558,7 @@ int datagram_send_ctl(struct net *net,
>  					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
>  			}
> 
> -			if (dev)
> -				dev_put(dev);
> +			rcu_read_unlock();
> 
>  			if (err)
>  				goto exit_f;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
