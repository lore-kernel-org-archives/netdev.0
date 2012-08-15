From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 8/9] sctp: Enable sctp in all network namespaces
Date: Tue, 14 Aug 2012 23:20:11 -0400
Message-ID: <502B156B.90807@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <87r4rjoo3h.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r4rjoo3h.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2012 02:46 PM, Eric W. Biederman wrote:
>
> - Fix the sctp_af operations to work in all namespaces
> - Enable sctp socket creation in all network namespaces.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   net/sctp/ipv6.c     |   12 ++++++------
>   net/sctp/protocol.c |    8 +++++---
>   2 files changed, 11 insertions(+), 9 deletions(-)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index bbf1534..a18cda6 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -582,7 +582,7 @@ static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
>   	if (!(type & IPV6_ADDR_UNICAST))
>   		return 0;
>
> -	return ipv6_chk_addr(&init_net, in6, NULL, 0);
> +	return ipv6_chk_addr(sock_net(&sp->inet.sk), in6, NULL, 0);
>   }
>
>   /* This function checks if the address is a valid address to be used for
> @@ -859,14 +859,14 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
>   		struct net_device *dev;
>
>   		if (type & IPV6_ADDR_LINKLOCAL) {
> +			struct net *net;
>   			if (!addr->v6.sin6_scope_id)
>   				return 0;
> +			net = sock_net(&opt->inet.sk);
>   			rcu_read_lock();
> -			dev = dev_get_by_index_rcu(&init_net,
> -						   addr->v6.sin6_scope_id);
> +			dev = dev_get_by_index_rcu(net, addr->v6.sin6_scope_id);
>   			if (!dev ||
> -			    !ipv6_chk_addr(&init_net, &addr->v6.sin6_addr,
> -					   dev, 0)) {
> +			    !ipv6_chk_addr(net, &addr->v6.sin6_addr, dev, 0)) {
>   				rcu_read_unlock();
>   				return 0;
>   			}
> @@ -899,7 +899,7 @@ static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
>   			if (!addr->v6.sin6_scope_id)
>   				return 0;
>   			rcu_read_lock();
> -			dev = dev_get_by_index_rcu(&init_net,
> +			dev = dev_get_by_index_rcu(sock_net(&opt->inet.sk),
>   						   addr->v6.sin6_scope_id);
>   			rcu_read_unlock();
>   			if (!dev)
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 72b3aa7..ab35691 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -367,7 +367,8 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
>   /* Should this be available for binding?   */
>   static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
>   {
> -	int ret = inet_addr_type(&init_net, addr->v4.sin_addr.s_addr);
> +	struct net *net = sock_net(&sp->inet.sk);
> +	int ret = inet_addr_type(net, addr->v4.sin_addr.s_addr);
>
>
>   	if (addr->v4.sin_addr.s_addr != htonl(INADDR_ANY) &&
> @@ -454,7 +455,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>   	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
>   			  __func__, &fl4->daddr, &fl4->saddr);
>
> -	rt = ip_route_output_key(&init_net, fl4);
> +	rt = ip_route_output_key(sock_net(sk), fl4);
>   	if (!IS_ERR(rt))
>   		dst = &rt->dst;
>
> @@ -500,7 +501,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>   		    (AF_INET == laddr->a.sa.sa_family)) {
>   			fl4->saddr = laddr->a.v4.sin_addr.s_addr;
>   			fl4->fl4_sport = laddr->a.v4.sin_port;
> -			rt = ip_route_output_key(&init_net, fl4);
> +			rt = ip_route_output_key(sock_net(sk), fl4);
>   			if (!IS_ERR(rt)) {
>   				dst = &rt->dst;
>   				goto out_unlock;
> @@ -1033,6 +1034,7 @@ static const struct net_protocol sctp_protocol = {
>   	.handler     = sctp_rcv,
>   	.err_handler = sctp_v4_err,
>   	.no_policy   = 1,
> +	.netns_ok    = 1,
>   };
>
>   /* IPv4 address related functions.  */
>
