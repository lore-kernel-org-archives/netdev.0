From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Sat, 27 Oct 2012 22:43:13 -0700
Message-ID: <877gqb883y.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org>
	<87ip9zqqlv.fsf@xmission.com> <20121025143811.GH15034@kvack.org>
	<20121025092105.5119b8bf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benjamin LaHaise <bcrl@kvack.org>, rsa <ravi.mlists@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50337 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215Ab2J1FnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 01:43:21 -0400
In-Reply-To: <20121025092105.5119b8bf@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Thu, 25 Oct 2012 09:21:05 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> I noticed that the L2TP sockets are not being moved to the correct name
> space.
>
> Something like this is probably needed.

This is almost right.

There needs to be a line in l2tp_tunnel_create that verifies
the network namespace of the socket derived from a file descriptor
and the passed in network namespace match.

For the l2tp_tunnel_sock_create case where we have a socket that is not
exported to userspace using sk_change_net seems appropriate to avoid
reference counting problems.  And it may be worth moving that work into
sk_create_kern.  But we need a network namespace hook that will lookup
all l2tp tunnel sockets when a network namespace is being destroyed and
remove them.  I think we can hit this bug with rmmod as well.

Bleh.

Eric


> --- a/net/l2tp/l2tp_core.c	2012-10-25 09:11:15.691271882 -0700
> +++ b/net/l2tp/l2tp_core.c	2012-10-25 09:18:58.746621418 -0700
> @@ -1357,7 +1357,10 @@ static void l2tp_tunnel_free(struct l2tp
>   * userspace. This is used for static tunnels where there is no
>   * managing L2TP daemon.
>   */
> -static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct socket **sockp)
> +static int l2tp_tunnel_sock_create(struct net *net,
> +				   u32 tunnel_id, u32 peer_tunnel_id,
> +				   struct l2tp_tunnel_cfg *cfg,
> +				   struct socket **sockp)
>  {
>  	int err = -EINVAL;
>  	struct sockaddr_in udp_addr;
> @@ -1372,11 +1375,12 @@ static int l2tp_tunnel_sock_create(u32 t
>  	case L2TP_ENCAPTYPE_UDP:
>  #if IS_ENABLED(CONFIG_IPV6)
>  		if (cfg->local_ip6 && cfg->peer_ip6) {
> -			err = sock_create(AF_INET6, SOCK_DGRAM, 0, sockp);
> +			err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, sockp);
>  			if (err < 0)
>  				goto out;
>  
>  			sock = *sockp;
> +			sk_change(sock->sk, net);
>  
>  			memset(&udp6_addr, 0, sizeof(udp6_addr));
>  			udp6_addr.sin6_family = AF_INET6;
> @@ -1400,11 +1404,12 @@ static int l2tp_tunnel_sock_create(u32 t
>  		} else
>  #endif
>  		{
> -			err = sock_create(AF_INET, SOCK_DGRAM, 0, sockp);
> +			err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, sockp);
>  			if (err < 0)
>  				goto out;
>  
>  			sock = *sockp;
> +			sk_change(sock->sk, net);
>  
>  			memset(&udp_addr, 0, sizeof(udp_addr));
>  			udp_addr.sin_family = AF_INET;
> @@ -1433,7 +1438,7 @@ static int l2tp_tunnel_sock_create(u32 t
>  	case L2TP_ENCAPTYPE_IP:
>  #if IS_ENABLED(CONFIG_IPV6)
>  		if (cfg->local_ip6 && cfg->peer_ip6) {
> -			err = sock_create(AF_INET6, SOCK_DGRAM, IPPROTO_L2TP,
> +			err = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_L2TP,
>  					  sockp);
>  			if (err < 0)
>  				goto out;
> @@ -1462,12 +1467,13 @@ static int l2tp_tunnel_sock_create(u32 t
>  		} else
>  #endif
>  		{
> -			err = sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP,
> +			err = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_L2TP,
>  					  sockp);
>  			if (err < 0)
>  				goto out;
>  
>  			sock = *sockp;
> +			sk_change(sock->sk, net);
>  
>  			memset(&ip_addr, 0, sizeof(ip_addr));
>  			ip_addr.l2tp_family = AF_INET;
> @@ -1517,7 +1523,8 @@ int l2tp_tunnel_create(struct net *net,
>  	 * kernel socket.
>  	 */
>  	if (fd < 0) {
> -		err = l2tp_tunnel_sock_create(tunnel_id, peer_tunnel_id, cfg, &sock);
> +		err = l2tp_tunnel_sock_create(net, tunnel_id, peer_tunnel_id,
> +					      cfg, &sock);
>  		if (err < 0)
>  			goto err;
>  	} else {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
