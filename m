From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 08/16] ipvs: fix ip_vs_set_timeout debug messages
Date: Fri, 5 Oct 2012 23:39:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210052305190.1639@ja.ssi.bg>
References: <1349448930-23976-1-git-send-email-arnd@arndb.de> <1349448930-23976-9-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1349448930-23976-9-git-send-email-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 5 Oct 2012, Arnd Bergmann wrote:

> The ip_vs_set_timeout function sets timeouts for TCP and UDP, which
> can be enabled independently at compile time. The debug message
> always prints both timeouts that are passed into the function,
> but if one is disabled, the message will show uninitialized data.
> 
> This splits the debug message into two separte IP_VS_DBG statements
> that are in the same #ifdef section to ensure we only print the
> text about what is actually going on.
> 
> Without this patch, building ARM ixp4xx_defconfig results in:

	Are there any CONFIG_IP_VS_PROTO_xxx options in this
default config? It is a waste of memory if IPVS is compiled
without any protocols.

> net/netfilter/ipvs/ip_vs_ctl.c: In function 'ip_vs_genl_set_cmd':
> net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.udp_timeout' may be used uninitialized in this function [-Wuninitialized]
> net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.udp_timeout' was declared here
> net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_fin_timeout' may be used uninitialized in this function [-Wuninitialized]
> net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_fin_timeout' was declared here
> net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_timeout' may be used uninitialized in this function [-Wuninitialized]
> net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_timeout' was declared here

	There are many __ip_vs_get_timeouts callers but
just one calls memset(&t, 0, sizeof(t)) before that,
problem only for ip_vs_genl_set_config and ip_vs_set_timeout.

	To be safe, can we move this memset into
__ip_vs_get_timeouts instead of playing games with defines?:

	memset(t, 0, sizeof(*t));

	This debug message will be more precise in showing the
changed values if we replace the __ip_vs_get_timeouts 
call in ip_vs_genl_set_config with memset(&t, 0, sizeof(t)).
Then we will see 0 for values that are not changed/supported.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: netfilter-devel@vger.kernel.org
> Cc: netfilter@vger.kernel.org
> Cc: coreteam@netfilter.org
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index f51013c..f3a66c3 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2237,12 +2237,11 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
>  	struct ip_vs_proto_data *pd;
>  #endif
>  
> -	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
> +#ifdef CONFIG_IP_VS_PROTO_TCP
> +	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d\n",
>  		  u->tcp_timeout,
> -		  u->tcp_fin_timeout,
> -		  u->udp_timeout);
> +		  u->tcp_fin_timeout);
>  
> -#ifdef CONFIG_IP_VS_PROTO_TCP
>  	if (u->tcp_timeout) {
>  		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
>  		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
> @@ -2257,6 +2256,9 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
>  #endif
>  
>  #ifdef CONFIG_IP_VS_PROTO_UDP
> +	IP_VS_DBG(2, "Setting timeout udp:%d\n",
> +		  u->udp_timeout);
> +
>  	if (u->udp_timeout) {
>  		pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
>  		pd->timeout_table[IP_VS_UDP_S_NORMAL]
> -- 
> 1.7.10

Regards

--
Julian Anastasov <ja@ssi.bg>
