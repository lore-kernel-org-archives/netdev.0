From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [Patch net v2] ipv4: fix a potential deadlock in mcast
 getsockopt() path
Date: Wed, 4 Nov 2015 17:04:32 -0200
Message-ID: <563A56C0.9000100@gmail.com>
References: <1446594076-3304-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35542 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031147AbbKDTEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 14:04:39 -0500
Received: by qgbb65 with SMTP id b65so48299519qgb.2
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 11:04:38 -0800 (PST)
In-Reply-To: <1446594076-3304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 03-11-2015 21:41, Cong Wang escreveu:
> Sasha reported the following lockdep warning:
>
>    Possible unsafe locking scenario:
>
>          CPU0                    CPU1
>          ----                    ----
>     lock(sk_lock-AF_INET);
>                                  lock(rtnl_mutex);
>                                  lock(sk_lock-AF_INET);
>     lock(rtnl_mutex);
>
> This is due to that for IP_MSFILTER and MCAST_MSFILTER, we take
> rtnl lock before the socket lock in setsockopt() path, but take
> the socket lock before rtnl lock in getsockopt() path. All the
> rest optnames are setsockopt()-only.
>
> Fix this by aligning the getsockopt() path with the setsockopt()
> path, so that all mcast socket path would be locked in the same
> order.
>
> Note, IPv6 part is different where rtnl lock is not held.
>
> Fixes: 54ff9ef36bdf ("ipv4, ipv6: kill ip_mc_{join, leave}_group and ipv6_sock_mc_{join, drop}")
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Thanks

> ---
>   net/ipv4/igmp.c        | 12 ++++--------
>   net/ipv4/ip_sockglue.c | 45 ++++++++++++++++++++++++++++++---------------
>   2 files changed, 34 insertions(+), 23 deletions(-)
>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index d38b8b6..a2429b7 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -2392,11 +2392,11 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
>   	struct ip_sf_socklist *psl;
>   	struct net *net = sock_net(sk);
>
> +	ASSERT_RTNL();
> +
>   	if (!ipv4_is_multicast(addr))
>   		return -EINVAL;
>
> -	rtnl_lock();
> -
>   	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
>   	imr.imr_address.s_addr = msf->imsf_interface;
>   	imr.imr_ifindex = 0;
> @@ -2417,7 +2417,6 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
>   		goto done;
>   	msf->imsf_fmode = pmc->sfmode;
>   	psl = rtnl_dereference(pmc->sflist);
> -	rtnl_unlock();
>   	if (!psl) {
>   		len = 0;
>   		count = 0;
> @@ -2436,7 +2435,6 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
>   		return -EFAULT;
>   	return 0;
>   done:
> -	rtnl_unlock();
>   	return err;
>   }
>
> @@ -2450,6 +2448,8 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
>   	struct inet_sock *inet = inet_sk(sk);
>   	struct ip_sf_socklist *psl;
>
> +	ASSERT_RTNL();
> +
>   	psin = (struct sockaddr_in *)&gsf->gf_group;
>   	if (psin->sin_family != AF_INET)
>   		return -EINVAL;
> @@ -2457,8 +2457,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
>   	if (!ipv4_is_multicast(addr))
>   		return -EINVAL;
>
> -	rtnl_lock();
> -
>   	err = -EADDRNOTAVAIL;
>
>   	for_each_pmc_rtnl(inet, pmc) {
> @@ -2470,7 +2468,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
>   		goto done;
>   	gsf->gf_fmode = pmc->sfmode;
>   	psl = rtnl_dereference(pmc->sflist);
> -	rtnl_unlock();
>   	count = psl ? psl->sl_count : 0;
>   	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
>   	gsf->gf_numsrc = count;
> @@ -2490,7 +2487,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
>   	}
>   	return 0;
>   done:
> -	rtnl_unlock();
>   	return err;
>   }
>
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index c3c359a..5f73a7c 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1251,11 +1251,22 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
>    *	the _received_ ones. The set sets the _sent_ ones.
>    */
>
> +static bool getsockopt_needs_rtnl(int optname)
> +{
> +	switch (optname) {
> +	case IP_MSFILTER:
> +	case MCAST_MSFILTER:
> +		return true;
> +	}
> +	return false;
> +}
> +
>   static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>   			    char __user *optval, int __user *optlen, unsigned int flags)
>   {
>   	struct inet_sock *inet = inet_sk(sk);
> -	int val;
> +	bool needs_rtnl = getsockopt_needs_rtnl(optname);
> +	int val, err = 0;
>   	int len;
>
>   	if (level != SOL_IP)
> @@ -1269,6 +1280,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>   	if (len < 0)
>   		return -EINVAL;
>
> +	if (needs_rtnl)
> +		rtnl_lock();
>   	lock_sock(sk);
>
>   	switch (optname) {
> @@ -1386,39 +1399,35 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>   	case IP_MSFILTER:
>   	{
>   		struct ip_msfilter msf;
> -		int err;
>
>   		if (len < IP_MSFILTER_SIZE(0)) {
> -			release_sock(sk);
> -			return -EINVAL;
> +			err = -EINVAL;
> +			goto out;
>   		}
>   		if (copy_from_user(&msf, optval, IP_MSFILTER_SIZE(0))) {
> -			release_sock(sk);
> -			return -EFAULT;
> +			err = -EFAULT;
> +			goto out;
>   		}
>   		err = ip_mc_msfget(sk, &msf,
>   				   (struct ip_msfilter __user *)optval, optlen);
> -		release_sock(sk);
> -		return err;
> +		goto out;
>   	}
>   	case MCAST_MSFILTER:
>   	{
>   		struct group_filter gsf;
> -		int err;
>
>   		if (len < GROUP_FILTER_SIZE(0)) {
> -			release_sock(sk);
> -			return -EINVAL;
> +			err = -EINVAL;
> +			goto out;
>   		}
>   		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0))) {
> -			release_sock(sk);
> -			return -EFAULT;
> +			err = -EFAULT;
> +			goto out;
>   		}
>   		err = ip_mc_gsfget(sk, &gsf,
>   				   (struct group_filter __user *)optval,
>   				   optlen);
> -		release_sock(sk);
> -		return err;
> +		goto out;
>   	}
>   	case IP_MULTICAST_ALL:
>   		val = inet->mc_all;
> @@ -1485,6 +1494,12 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>   			return -EFAULT;
>   	}
>   	return 0;
> +
> +out:
> +	release_sock(sk);
> +	if (needs_rtnl)
> +		rtnl_unlock();
> +	return err;
>   }
>
>   int ip_getsockopt(struct sock *sk, int level,
>
