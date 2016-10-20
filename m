From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [Patch net v2] ipv6: fix a potential deadlock in
 do_ipv6_setsockopt()
Date: Thu, 20 Oct 2016 09:12:17 -0200
Message-ID: <20161020111217.GA7224@localhost.localdomain>
References: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, sploving1@gmail.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33616 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755137AbcJTLMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 07:12:25 -0400
Content-Disposition: inline
In-Reply-To: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 11:35:12PM -0700, Cong Wang wrote:
> Baozeng reported this deadlock case:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock([  165.136033] sk_lock-AF_INET6);
>                                lock([  165.136033] rtnl_mutex);
>                                lock([  165.136033] sk_lock-AF_INET6);
>   lock([  165.136033] rtnl_mutex);
> 
> Similar to commit 87e9f0315952
> ("ipv4: fix a potential deadlock in mcast getsockopt() path")
> this is due to we still have a case, ipv6_sock_mc_close(),
> where we acquire sk_lock before rtnl_lock. Close this deadlock
> with the similar solution, that is always acquire rtnl lock first.
> 
> Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Tested-by: Baozeng Ding <sploving1@gmail.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/net/addrconf.h   |  1 +
>  net/ipv6/ipv6_sockglue.c |  3 ++-
>  net/ipv6/mcast.c         | 17 ++++++++++++-----
>  3 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index f2d0727..8f998af 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -174,6 +174,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex,
>  		      const struct in6_addr *addr);
>  int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
>  		      const struct in6_addr *addr);
> +void __ipv6_sock_mc_close(struct sock *sk);
>  void ipv6_sock_mc_close(struct sock *sk);
>  bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
>  		    const struct in6_addr *src_addr);
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 5330262..636ec56 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -120,6 +120,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
>  static bool setsockopt_needs_rtnl(int optname)
>  {
>  	switch (optname) {
> +	case IPV6_ADDRFORM:
>  	case IPV6_ADD_MEMBERSHIP:
>  	case IPV6_DROP_MEMBERSHIP:
>  	case IPV6_JOIN_ANYCAST:
> @@ -198,7 +199,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  			}
>  
>  			fl6_free_socklist(sk);
> -			ipv6_sock_mc_close(sk);
> +			__ipv6_sock_mc_close(sk);

Considering we already took rtnl lock and the way __ipv6_sock_mc_close()
is written, we don't need that check
	if (!rcu_access_pointer(np->ipv6_mc_list))
here too as the while() in there does it already.

LGTM, thanks

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

>  
>  			/*
>  			 * Sock is moving from IPv6 to IPv4 (sk_prot), so
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 75c1fc5..14a3903 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -276,16 +276,14 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
>  	return idev;
>  }
>  
> -void ipv6_sock_mc_close(struct sock *sk)
> +void __ipv6_sock_mc_close(struct sock *sk)
>  {
>  	struct ipv6_pinfo *np = inet6_sk(sk);
>  	struct ipv6_mc_socklist *mc_lst;
>  	struct net *net = sock_net(sk);
>  
> -	if (!rcu_access_pointer(np->ipv6_mc_list))
> -		return;
> +	ASSERT_RTNL();
>  
> -	rtnl_lock();
>  	while ((mc_lst = rtnl_dereference(np->ipv6_mc_list)) != NULL) {
>  		struct net_device *dev;
>  
> @@ -303,8 +301,17 @@ void ipv6_sock_mc_close(struct sock *sk)
>  
>  		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
>  		kfree_rcu(mc_lst, rcu);
> -
>  	}
> +}
> +
> +void ipv6_sock_mc_close(struct sock *sk)
> +{
> +	struct ipv6_pinfo *np = inet6_sk(sk);
> +
> +	if (!rcu_access_pointer(np->ipv6_mc_list))
> +		return;
> +	rtnl_lock();
> +	__ipv6_sock_mc_close(sk);
>  	rtnl_unlock();
>  }
>  
> -- 
> 2.1.0
> 
