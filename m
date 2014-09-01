From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: fix rtnl locking in setsockopt for anycast and
 multicast
Date: Tue, 02 Sep 2014 00:26:18 +0200
Message-ID: <1409610378.21965.52.camel@localhost>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	 <20140829195339.GA9780@kria> <1409363489.2980.17.camel@localhost>
	 <20140830105821.GB18155@kria> <1409599348.21965.6.camel@localhost>
	 <20140901210520.GB25543@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20140901210520.GB25543@kria>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mo, 2014-09-01 at 23:05 +0200, Sabrina Dubroca wrote:
> Calling setsockopt with IPV6_JOIN_ANYCAST or IPV6_LEAVE_ANYCAST
> triggers the assertion in addrconf_join_solict()/addrconf_leave_solict()
> 
> ipv6_sock_ac_join(), ipv6_sock_ac_drop(), ipv6_sock_ac_close() need to
> take RTNL before calling ipv6_dev_ac_inc/dec. Same thing with
> ipv6_sock_mc_join(), ipv6_sock_mc_drop(), ipv6_sock_mc_close() before
> calling ipv6_dev_mc_inc/dec.
> 
> This patch moves ASSERT_RTNL() up a level in the call stack.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> ---
> I included Cong's Signed-off-by for the first part of the patch,
> I hope that's OK.
> 
> This patch is based on -next, but since the assertion can also be
> triggered on a current kernel (tested on a 3.16), I think it should
> also go in stable.

Ack, thus you should base the patch on the net tree.

> 
>  include/linux/netdevice.h |  4 ++--
>  net/core/dev.c            | 11 ++++++-----
>  net/ipv6/addrconf.c       | 15 +++++----------
>  net/ipv6/anycast.c        | 30 +++++++++++++++++++-----------
>  net/ipv6/mcast.c          | 16 ++++++++++++++++
>  5 files changed, 48 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 429801370d0c..1ae0e745b1b1 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2077,8 +2077,8 @@ void __dev_remove_pack(struct packet_type *pt);
>  void dev_add_offload(struct packet_offload *po);
>  void dev_remove_offload(struct packet_offload *po);
>  
> -struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short flags,
> -					unsigned short mask);
> +struct net_device *dev_get_by_flags(struct net *net, unsigned short flags,
> +				    unsigned short mask);
>  struct net_device *dev_get_by_name(struct net *net, const char *name);
>  struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
>  struct net_device *__dev_get_by_name(struct net *net, const char *name);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 443b814db05b..8fede6ef4a39 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -897,23 +897,24 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
>  EXPORT_SYMBOL(dev_getfirstbyhwtype);
>  
>  /**
> - *	dev_get_by_flags_rcu - find any device with given flags
> + *	dev_get_by_flags - find any device with given flags
>   *	@net: the applicable net namespace
>   *	@if_flags: IFF_* values
>   *	@mask: bitmask of bits in if_flags to check
>   *
>   *	Search for any interface with the given flags. Returns NULL if a device
>   *	is not found or a pointer to the device. Must be called inside
> - *	rcu_read_lock(), and result refcount is unchanged.
> + *	rtnl_lock(), and result refcount is unchanged.
>   */
>  
> -struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags,
> +struct net_device *dev_get_by_flags(struct net *net, unsigned short if_flags,
>  				    unsigned short mask)
>  {
>  	struct net_device *dev, *ret;
>  
> +	ASSERT_RTNL();
>  	ret = NULL;
> -	for_each_netdev_rcu(net, dev) {
> +	for_each_netdev(net, dev) {
>  		if (((dev->flags ^ if_flags) & mask) == 0) {
>  			ret = dev;
>  			break;
> @@ -921,7 +922,7 @@ struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags
>  	}
>  	return ret;
>  }
> -EXPORT_SYMBOL(dev_get_by_flags_rcu);
> +EXPORT_SYMBOL(dev_get_by_flags);

I don't have a very strong opinion on that, but think we shouldn't touch
this function. In general it looks like a useful one and if you force
rtnl lock on it you cannot call it from bh anymore. I think we should
keep rcu locking here and in the anycast code. It shouldn't matter much.

>  /**
>   *	dev_valid_name - check if name is okay for network device
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 267ce3caee24..7ada65937d23 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1690,14 +1690,12 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
>  	addrconf_mod_dad_work(ifp, 0);
>  }
>  
> -/* Join to solicited addr multicast group. */
> -
> +/* Join to solicited addr multicast group.
> + * caller must hold RTNL */
>  void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr)
>  {
>  	struct in6_addr maddr;
>  
> -	ASSERT_RTNL();
> -
>  	if (dev->flags&(IFF_LOOPBACK|IFF_NOARP))
>  		return;
>  
> @@ -1705,12 +1703,11 @@ void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr)
>  	ipv6_dev_mc_inc(dev, &maddr);
>  }
>  
> +/* caller must hold RTNL */
>  void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr)
>  {
>  	struct in6_addr maddr;
>  
> -	ASSERT_RTNL();
> -
>  	if (idev->dev->flags&(IFF_LOOPBACK|IFF_NOARP))
>  		return;
>  
> @@ -1718,12 +1715,11 @@ void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr)
>  	__ipv6_dev_mc_dec(idev, &maddr);
>  }
>  
> +/* caller must hold RTNL */
>  static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
>  {
>  	struct in6_addr addr;
>  
> -	ASSERT_RTNL();
> -
>  	if (ifp->prefix_len >= 127) /* RFC 6164 */
>  		return;
>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
> @@ -1732,12 +1728,11 @@ static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
>  	ipv6_dev_ac_inc(ifp->idev->dev, &addr);
>  }
>  
> +/* caller must hold RTNL */
>  static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>  {
>  	struct in6_addr addr;
>  
> -	ASSERT_RTNL();
> -
>  	if (ifp->prefix_len >= 127) /* RFC 6164 */
>  		return;
>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index 210183244689..572c2faede55 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
> @@ -77,7 +77,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  	pac->acl_next = NULL;
>  	pac->acl_addr = *addr;
>  
> -	rcu_read_lock();
> +	rtnl_lock();

We would need to keep rcu_read_lock inside rtnl_lock if you decide to
keep dev_get_by_flags_rcu around.

>  	if (ifindex == 0) {
>  		struct rt6_info *rt;
>  
> @@ -90,11 +90,11 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  			goto error;
>  		} else {
>  			/* router, no matching interface: just pick one */
> -			dev = dev_get_by_flags_rcu(net, IFF_UP,
> -						   IFF_UP | IFF_LOOPBACK);
> +			dev = dev_get_by_flags(net, IFF_UP,
> +					       IFF_UP | IFF_LOOPBACK);
>  		}
>  	} else
> -		dev = dev_get_by_index_rcu(net, ifindex);
> +		dev = __dev_get_by_index(net, ifindex);
>  
>  	if (dev == NULL) {
>  		err = -ENODEV;
> @@ -136,7 +136,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  	}
>  
>  error:
> -	rcu_read_unlock();
> +	rtnl_unlock();

...here, too.

>  	if (pac)
>  		sock_kfree_s(sk, pac, sizeof(*pac));
>  	return err;
> @@ -171,13 +171,15 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  
>  	spin_unlock_bh(&ipv6_sk_ac_lock);
>  
> -	rcu_read_lock();
> -	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
> +	rtnl_lock();
> +	dev = __dev_get_by_index(net, pac->acl_ifindex);
>  	if (dev)
>  		ipv6_dev_ac_dec(dev, &pac->acl_addr);
> -	rcu_read_unlock();
> +	rtnl_unlock();
>  
>  	sock_kfree_s(sk, pac, sizeof(*pac));
> +	if (!dev)
> +		return -ENODEV;
>  	return 0;
>  }
>  
> @@ -198,12 +200,12 @@ void ipv6_sock_ac_close(struct sock *sk)
>  	spin_unlock_bh(&ipv6_sk_ac_lock);
>  
>  	prev_index = 0;
> -	rcu_read_lock();
> +	rtnl_lock();
>  	while (pac) {
>  		struct ipv6_ac_socklist *next = pac->acl_next;
>  
>  		if (pac->acl_ifindex != prev_index) {
> -			dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
> +			dev = __dev_get_by_index(net, pac->acl_ifindex);
>  			prev_index = pac->acl_ifindex;
>  		}
>  		if (dev)
> @@ -211,7 +213,7 @@ void ipv6_sock_ac_close(struct sock *sk)
>  		sock_kfree_s(sk, pac, sizeof(*pac));
>  		pac = next;
>  	}
> -	rcu_read_unlock();
> +	rtnl_unlock();
>  }
>  
>  static void aca_put(struct ifacaddr6 *ac)
> @@ -233,6 +235,8 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>  	struct rt6_info *rt;
>  	int err;
>  
> +	ASSERT_RTNL();
> +
>  	idev = in6_dev_get(dev);
>  
>  	if (idev == NULL)
> @@ -302,6 +306,8 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
>  {
>  	struct ifacaddr6 *aca, *prev_aca;
>  
> +	ASSERT_RTNL();
> +
>  	write_lock_bh(&idev->lock);
>  	prev_aca = NULL;
>  	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
> @@ -336,6 +342,8 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
>  {
>  	struct inet6_dev *idev = __in6_dev_get(dev);
>  
> +	ASSERT_RTNL();
> +
>  	if (idev == NULL)
>  		return -ENODEV;
>  	return __ipv6_dev_ac_dec(idev, addr);
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 70881795da96..d73ac1ef65f2 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -172,6 +172,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  	mc_lst->next = NULL;
>  	mc_lst->addr = *addr;
>  
> +	rtnl_lock();
>  	rcu_read_lock();
>  	if (ifindex == 0) {
>  		struct rt6_info *rt;
> @@ -185,6 +186,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  
>  	if (dev == NULL) {
>  		rcu_read_unlock();
> +		rtnl_unlock();
>  		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
>  		return -ENODEV;
>  	}
> @@ -202,6 +204,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  
>  	if (err) {
>  		rcu_read_unlock();
> +		rtnl_unlock();
>  		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
>  		return err;
>  	}
> @@ -212,6 +215,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  	spin_unlock(&ipv6_sk_mc_lock);
>  
>  	rcu_read_unlock();
> +	rtnl_unlock();
>  
>  	return 0;
>  }
> @@ -229,6 +233,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  	if (!ipv6_addr_is_multicast(addr))
>  		return -EINVAL;
>  
> +	rtnl_lock();
>  	spin_lock(&ipv6_sk_mc_lock);
>  	for (lnk = &np->ipv6_mc_list;
>  	     (mc_lst = rcu_dereference_protected(*lnk,
> @@ -252,12 +257,15 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
>  			} else
>  				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
>  			rcu_read_unlock();
> +			rtnl_unlock();
> +
>  			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
>  			kfree_rcu(mc_lst, rcu);
>  			return 0;
>  		}
>  	}
>  	spin_unlock(&ipv6_sk_mc_lock);
> +	rtnl_unlock();
>  
>  	return -EADDRNOTAVAIL;
>  }
> @@ -302,6 +310,7 @@ void ipv6_sock_mc_close(struct sock *sk)
>  	if (!rcu_access_pointer(np->ipv6_mc_list))
>  		return;
>  
> +	rtnl_lock();
>  	spin_lock(&ipv6_sk_mc_lock);
>  	while ((mc_lst = rcu_dereference_protected(np->ipv6_mc_list,
>  				lockdep_is_held(&ipv6_sk_mc_lock))) != NULL) {
> @@ -328,6 +337,7 @@ void ipv6_sock_mc_close(struct sock *sk)
>  		spin_lock(&ipv6_sk_mc_lock);
>  	}
>  	spin_unlock(&ipv6_sk_mc_lock);
> +	rtnl_unlock();
>  }
>  
>  int ip6_mc_source(int add, int omode, struct sock *sk,
> @@ -845,6 +855,8 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
>  	struct ifmcaddr6 *mc;
>  	struct inet6_dev *idev;
>  
> +	ASSERT_RTNL();
> +
>  	/* we need to take a reference on idev */
>  	idev = in6_dev_get(dev);
>  
> @@ -916,6 +928,8 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
>  {
>  	struct ifmcaddr6 *ma, **map;
>  
> +	ASSERT_RTNL();
> +
>  	write_lock_bh(&idev->lock);
>  	for (map = &idev->mc_list; (ma = *map) != NULL; map = &ma->next) {
>  		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
> @@ -942,6 +956,8 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
>  	struct inet6_dev *idev;
>  	int err;
>  
> +	ASSERT_RTNL();
> +

Minor nit:
This one is not necessary and will be guarded by the __ipv6_dev_mc_dec
one.

>  	rcu_read_lock();
>  
>  	idev = __in6_dev_get(dev);

Rest looks good to me, thanks,
Hannes
