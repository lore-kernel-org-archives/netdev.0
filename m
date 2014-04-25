From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] sctp: reset flowi4_oif parameter on route lookup
Date: Fri, 25 Apr 2014 10:57:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404251050490.1969@ja.home.ssi.bg>
References: <1398410978-15954-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36317 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752105AbaDYH6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 03:58:17 -0400
In-Reply-To: <1398410978-15954-1-git-send-email-xufeng.zhang@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 25 Apr 2014, Xufeng Zhang wrote:

> commit 813b3b5db83 (ipv4: Use caller's on-stack flowi as-is
> in output route lookups.) introduces another regression which
> is very similar to the problem of commit e6b45241c (ipv4: reset
> flowi parameters on route connect) wants to fix:
> Before we call ip_route_output_key() in sctp_v4_get_dst() to
> get a dst that matches a bind address as the source address,
> we have already called this function previously and the flowi
> parameters have been initialized including flowi4_oif, so when
> we call this function again, the process in ip_route_output_slow()
> will be different because of the setting of flowi4_oif, and we'll
> get a networking device which corresponds to the inputted flowi4_oif
> as the output device, this is wrong because we'll never hit this
> place if the previously returned source address of dst match one
> of the bound addresses.
> 
> To reproduce this problem, a vlan setting is enough:
>   # ifconfig eth0 up
>   # route del default
>   # vconfig add eth0 2
>   # vconfig add eth0 3
>   # ifconfig eth0.2 10.0.1.14 netmask 255.255.255.0
>   # route add default gw 10.0.1.254 dev eth0.2
>   # ifconfig eth0.3 10.0.0.14 netmask 255.255.255.0
>   # ip rule add from 10.0.0.14 table 4
>   # ip route add table 4 default via 10.0.0.254 src 10.0.0.14 dev eth0.3
>   # sctp_darn -H 10.0.0.14 -P 36422 -h 10.1.4.134 -p 36422 -s -I
> You'll detect that all the flow are routed to eth0.2(10.0.1.254).
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
>  net/sctp/protocol.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index c09757f..f8a5968 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -493,6 +493,10 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  		    (AF_INET == laddr->a.sa.sa_family)) {
>  			fl4->saddr = laddr->a.v4.sin_addr.s_addr;
>  			fl4->fl4_sport = laddr->a.v4.sin_port;
> +			/* Reset flowi4_oif so that it won't be incorrectly used
> +			 * as input parameter to routing lookups.
> +			 */
> +			fl4->flowi4_oif = 0;

	May be something like this is more correct:

			flowi4_update_output(fl4,
					     asoc->base.sk->sk_bound_dev_if,
					     RT_CONN_FLAGS(asoc->base.sk),
					     daddr->v4.sin_addr.s_addr,
					     laddr->a.v4.sin_addr.s_addr);

>  			rt = ip_route_output_key(sock_net(sk), fl4);
>  			if (!IS_ERR(rt)) {
>  				dst = &rt->dst;

Regards

--
Julian Anastasov <ja@ssi.bg>
