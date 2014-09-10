From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next 3/5] ipv6: clean up ipv6_dev_ac_inc()
Date: Wed, 10 Sep 2014 14:23:35 +0200
Message-ID: <1410351815.3135.14.camel@localhost>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1410306738-18036-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49692 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbaIJMXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:23:39 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id E9859207B8
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 08:23:37 -0400 (EDT)
In-Reply-To: <1410306738-18036-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-09-09 at 16:52 -0700, Cong Wang wrote:
> Make it accept inet6_dev, and rename it to __ipv6_dev_ac_inc()
> to reflect this change.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/net/addrconf.h |  2 +-
>  net/ipv6/addrconf.c    |  2 +-
>  net/ipv6/anycast.c     | 17 +++++------------
>  3 files changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index f679877..9b1d42e 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -202,7 +202,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex,
>  		      const struct in6_addr *addr);
>  void ipv6_sock_ac_close(struct sock *sk);
>  
> -int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
> +int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr);
>  int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
>  bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
>  			 const struct in6_addr *addr);
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index ad4598f..6b6a373 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1725,7 +1725,7 @@ static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
>  	if (ipv6_addr_any(&addr))
>  		return;
> -	ipv6_dev_ac_inc(ifp->idev->dev, &addr);
> +	__ipv6_dev_ac_inc(ifp->idev, &addr);
>  }
>  
>  /* caller must hold RTNL */
> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index d10f2e2..bec8d14 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
> @@ -122,7 +122,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  			goto error;
>  	}
>  
> -	err = ipv6_dev_ac_inc(dev, addr);
> +	err = __ipv6_dev_ac_inc(idev, addr);
>  	if (!err) {
>  		pac->acl_next = np->ipv6_ac_list;
>  		np->ipv6_ac_list = pac;
> @@ -215,20 +215,15 @@ static void aca_put(struct ifacaddr6 *ac)
>  /*
>   *	device anycast group inc (add if not found)
>   */
> -int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
> +int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
>  {
>  	struct ifacaddr6 *aca;
> -	struct inet6_dev *idev;
>  	struct rt6_info *rt;
>  	int err;
>  
>  	ASSERT_RTNL();
>  
> -	idev = in6_dev_get(dev);
> -
> -	if (idev == NULL)
> -		return -EINVAL;
> -
> +	in6_dev_hold(idev);

Please move this in6_dev_hold down to where it gets attached to the
ifacaddr6 and remove the in6_dev_put from below the out: label.

>  	write_lock_bh(&idev->lock);
>  	if (idev->dead) {
>  		err = -ENODEV;
> @@ -267,7 +262,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>  	aca->aca_users = 1;
>  	/* aca_tstamp should be updated upon changes */
>  	aca->aca_cstamp = aca->aca_tstamp = jiffies;
> -	atomic_set(&aca->aca_refcnt, 2);
> +	atomic_set(&aca->aca_refcnt, 1);
>  	spin_lock_init(&aca->aca_lock);
>  
>  	aca->aca_next = idev->ac_list;
> @@ -276,9 +271,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>  
>  	ip6_ins_rt(rt);
>  
> -	addrconf_join_solict(dev, &aca->aca_addr);
> -
> -	aca_put(aca);

I am not sure why you changed the aca_refcnt code. idev->ac_list is only
protected by idev->lock and you publish one reference and unlock, thus
you need a second reference during addrconf_join_solict. All accesses
should also be protected by rtnl, so it shouldn't be a problem, but if
people review the code they might have problems to figure that out.
Maybe you can also remove the idev->lock?

> +	addrconf_join_solict(idev->dev, &aca->aca_addr);
>  	return 0;
>  out:
>  	write_unlock_bh(&idev->lock);

Thanks,
Hannes
