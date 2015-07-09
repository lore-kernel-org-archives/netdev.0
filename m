From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [RFC PATCH net-next] sctp: fix src address selection if using
 secondary addresses
Date: Thu, 9 Jul 2015 13:54:58 -0300
Message-ID: <20150709165458.GA1855@localhost.localdomain>
References: <81786a31f7f143e1d229de9a9f909d5f83fa9bb2.1436279035.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, tuexen@fh-muenster.de
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbbGIQzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 12:55:02 -0400
Content-Disposition: inline
In-Reply-To: <81786a31f7f143e1d229de9a9f909d5f83fa9bb2.1436279035.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing Michael too.

On Tue, Jul 07, 2015 at 02:42:25PM -0300, Marcelo Ricardo Leitner wrote:
> Hi folks,
> 
> This is an attempt to better choose a src address for sctp packets as
> peers with rp_filter could be dropping our packets in some situations.
> With this patch, we try to respect and use a src address that belongs to
> the interface we are putting the packet out.
> 
> I have that feeling that there is be a better way to do this, but I
> just couldn't see it.
> 
> This patch has been tested with and without gateways between the peers
> and also just two peers connected via two subnets and results were
> pretty good.
> 
> One could think that this limits the address combination we can use, but
> such combinations probably are just bogus anyway. Like, if you have an
> host with address A1 and B1 and another with A2 and B2, you cannot
> expect that A can use A1 to reach B2 through subnet B, because the
> return path would be via the other link which, when this switch happens,
> we are thinking it's broken.
> 
> Thanks,
> Marcelo
> 
> ---8<---
> 
> In short, sctp is likely to incorrectly choose src address if socket is
> bound to secondary addresses. This patch fixes it by adding a new check
> that tries to anticipate if the src address would be expected by the
> next hop/peer on this interface by doing reverse routing.
> 
> Also took the shot to reduce the indentation level on this code.
> 
> Details:
> 
> Currently, sctp will do a routing attempt without specifying the src
> address and compare the returned value (preferred source) with the
> addresses that the socket is bound to. When using secondary addresses,
> this will not match.
> 
> Then it will try specifying each of the addresses that the socket is
> bound to and re-routing, checking if that address is valid as src for
> that dst. Thing is, this check alone is weak:
> 
> # ip r l
> 192.168.100.0/24 dev eth1  proto kernel  scope link  src 192.168.100.149
> 192.168.122.0/24 dev eth0  proto kernel  scope link  src 192.168.122.147
> 
> # ip a l
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
>     link/ether 52:54:00:15:18:6a brd ff:ff:ff:ff:ff:ff
>     inet 192.168.122.147/24 brd 192.168.122.255 scope global dynamic eth0
>        valid_lft 2160sec preferred_lft 2160sec
>     inet 192.168.122.148/24 scope global secondary eth0
>        valid_lft forever preferred_lft forever
>     inet6 fe80::5054:ff:fe15:186a/64 scope link
>        valid_lft forever preferred_lft forever
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
>     link/ether 52:54:00:b3:91:46 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.100.149/24 brd 192.168.100.255 scope global dynamic eth1
>        valid_lft 2162sec preferred_lft 2162sec
>     inet 192.168.100.148/24 scope global secondary eth1
>        valid_lft forever preferred_lft forever
>     inet6 fe80::5054:ff:feb3:9146/64 scope link
>        valid_lft forever preferred_lft forever
> 4: ens9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
>     link/ether 52:54:00:05:47:ee brd ff:ff:ff:ff:ff:ff
>     inet6 fe80::5054:ff:fe05:47ee/64 scope link
>        valid_lft forever preferred_lft forever
> 
> # ip r g 192.168.100.193 from 192.168.122.148
> 192.168.100.193 from 192.168.122.148 dev eth1
>     cache
> 
> Even if you specify an interface:
> 
> # ip r g 192.168.100.193 from 192.168.122.148 oif eth1
> 192.168.100.193 from 192.168.122.148 dev eth1
>     cache
> 
> Although this would be valid, peers using rp_filter will drop such
> packets as their src doesn't match the routes for that interface.
> 
> So we fix this by adding an extra check, we try to do the reverse
> routing and check if the interface used would be the same. If not, we
> skip such address. If yes, we use it.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/protocol.c | 55 +++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 41 insertions(+), 14 deletions(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 59e80356672bdf89777265ae1f8c384792dfb98c..e52fd6f77963426a7cf3e83ca01a9cdae1cb2c01 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -53,6 +53,7 @@
>  #include <net/net_namespace.h>
>  #include <net/protocol.h>
>  #include <net/ip.h>
> +#include <net/ip_fib.h>
>  #include <net/ipv6.h>
>  #include <net/route.h>
>  #include <net/sctp/sctp.h>
> @@ -487,23 +488,49 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  	 */
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> +		struct flowi4 in;
> +		struct fib_result res;
> +
>  		if (!laddr->valid)
>  			continue;
> -		if ((laddr->state == SCTP_ADDR_SRC) &&
> -		    (AF_INET == laddr->a.sa.sa_family)) {
> -			fl4->fl4_sport = laddr->a.v4.sin_port;
> -			flowi4_update_output(fl4,
> -					     asoc->base.sk->sk_bound_dev_if,
> -					     RT_CONN_FLAGS(asoc->base.sk),
> -					     daddr->v4.sin_addr.s_addr,
> -					     laddr->a.v4.sin_addr.s_addr);
> -
> -			rt = ip_route_output_key(sock_net(sk), fl4);
> -			if (!IS_ERR(rt)) {
> -				dst = &rt->dst;
> -				goto out_unlock;
> -			}
> +		if (laddr->state != SCTP_ADDR_SRC ||
> +		    AF_INET != laddr->a.sa.sa_family)
> +			continue;
> +
> +		fl4->fl4_sport = laddr->a.v4.sin_port;
> +		flowi4_update_output(fl4,
> +				     asoc->base.sk->sk_bound_dev_if,
> +				     RT_CONN_FLAGS(asoc->base.sk),
> +				     daddr->v4.sin_addr.s_addr,
> +				     laddr->a.v4.sin_addr.s_addr);
> +
> +		rt = ip_route_output_key(sock_net(sk), fl4);
> +		if (IS_ERR(rt))
> +			continue;
> +
> +		dst = &rt->dst;
> +
> +		/* Double check if this is really expected. We simulate
> +		 * rp_filter by swapping src and dst.  If interfaces are
> +		 * different, means that this src wouldn't be expected
> +		 * by the other host on this interface.
> +		 */
> +		memcpy(&in, fl4, sizeof(in));
> +		in.daddr = fl4->saddr;
> +		in.saddr = fl4->daddr;
> +		in.flowi4_iif = fl4->flowi4_oif;
> +		in.flowi4_oif = 0;
> +
> +		if (fib_lookup(sock_net(sk), &in, &res) ||
> +		    res.type != RTN_LOCAL ||
> +		    fl4->flowi4_oif != FIB_RES_DEV(res)->ifindex) {
> +			/* Failed, so this was a false hit */
> +			dst_release(dst);
> +			dst = NULL;
> +			continue;
>  		}
> +
> +		break;
>  	}
>  
>  out_unlock:
> -- 
> 2.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
