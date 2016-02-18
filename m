From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next 1/4] geneve: implement geneve_get_sk_family
 helper
Date: Thu, 18 Feb 2016 09:44:10 -0500
Message-ID: <20160218144409.GA12622@tuxdriver.com>
References: <cover.1455790645.git.jbenc@redhat.com>
 <4d1533364167a04892cb7ec573b3b19dc01c682b.1455790645.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57903 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426053AbcBROpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 09:45:17 -0500
Content-Disposition: inline
In-Reply-To: <4d1533364167a04892cb7ec573b3b19dc01c682b.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 11:22:49AM +0100, Jiri Benc wrote:
> Similarly to the existing vxlan_get_sk_family.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/geneve.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 6f208132a574..f09de1e30955 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -110,6 +110,11 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
>  #endif
>  }
>  
> +static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
> +{
> +	return gs->sock->sk->sk_family;
> +}
> +

Should this be inline?

>  static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
>  					__be32 addr, u8 vni[])
>  {
> @@ -165,16 +170,13 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  	static u8 zero_vni[3];
>  	u8 *vni;
>  	int err = 0;
> -	sa_family_t sa_family;
>  #if IS_ENABLED(CONFIG_IPV6)
>  	struct ipv6hdr *ip6h = NULL;
>  	struct in6_addr addr6;
>  	static struct in6_addr zero_addr6;
>  #endif
>  
> -	sa_family = gs->sock->sk->sk_family;
> -
> -	if (sa_family == AF_INET) {
> +	if (geneve_get_sk_family(gs) == AF_INET) {
>  		iph = ip_hdr(skb); /* outer IP header... */
>  
>  		if (gs->collect_md) {
> @@ -188,7 +190,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  
>  		geneve = geneve_lookup(gs, addr, vni);
>  #if IS_ENABLED(CONFIG_IPV6)
> -	} else if (sa_family == AF_INET6) {
> +	} else if (geneve_get_sk_family(gs) == AF_INET6) {
>  		ip6h = ipv6_hdr(skb); /* outer IPv6 header... */
>  
>  		if (gs->collect_md) {
> @@ -213,7 +215,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>  			(gnvh->oam ? TUNNEL_OAM : 0) |
>  			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
>  
> -		tun_dst = udp_tun_rx_dst(skb, sa_family, flags,
> +		tun_dst = udp_tun_rx_dst(skb, geneve_get_sk_family(gs), flags,
>  					 vni_to_tunnel_id(gnvh->vni),
>  					 gnvh->opt_len * 4);
>  		if (!tun_dst)

Can we count on GCC to inline geneve_get_sk_family on its own?
Otherwise, we are calling the same function as many as three times
on receive.

> @@ -392,7 +394,7 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
>  	struct net_device *dev;
>  	struct sock *sk = gs->sock->sk;
>  	struct net *net = sock_net(sk);
> -	sa_family_t sa_family = sk->sk_family;
> +	sa_family_t sa_family = geneve_get_sk_family(gs);
>  	__be16 port = inet_sk(sk)->inet_sport;
>  	int err;
>  
> @@ -553,7 +555,7 @@ static void geneve_notify_del_rx_port(struct geneve_sock *gs)
>  	struct net_device *dev;
>  	struct sock *sk = gs->sock->sk;
>  	struct net *net = sock_net(sk);
> -	sa_family_t sa_family = sk->sk_family;
> +	sa_family_t sa_family = geneve_get_sk_family(gs);
>  	__be16 port = inet_sk(sk)->inet_sport;
>  
>  	rcu_read_lock();

Then on these three you are caching the results of the function
call instead...

> @@ -596,7 +598,7 @@ static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
>  
>  	list_for_each_entry(gs, &gn->sock_list, list) {
>  		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
> -		    inet_sk(gs->sock->sk)->sk.sk_family == family) {
> +		    geneve_get_sk_family(gs) == family) {
>  			return gs;
>  		}
>  	}

And back to calling it each time (as necessary inside the
list_for_each_entry).

So, it seems like geneve_get_sk_family needs to be inline -- maybe GCC
is doing that on its own?  FWIW, I probably would cache the results
inside of geneve_rx like you have done in geneve_notify_add_rx_port
and geneve_notify_del_rx_port.

Thanks for the attention to geneve!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
