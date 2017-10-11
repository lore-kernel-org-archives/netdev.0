From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 2/4] net: Add extack to validator_info structs
 used for address notifier
Date: Wed, 11 Oct 2017 16:37:06 +0300
Message-ID: <20171011133706.GA11653@splinter>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42825 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752094AbdJKNhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 09:37:10 -0400
Content-Disposition: inline
In-Reply-To: <1507653665-20540-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 09:41:03AM -0700, David Ahern wrote:
> Add extack to in_validator_info and in6_validator_info. Update the one
> user of each, ipvlan, to return an error message for failures.
> 
> Only manual configuration of an address is plumbed in the IPv6 code path.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

See two nits below. Otherwise:

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

> ---
>  drivers/net/ipvlan/ipvlan_main.c | 10 ++++++++--
>  include/linux/inetdevice.h       |  1 +
>  include/net/addrconf.h           |  1 +
>  net/ipv4/devinet.c               |  8 +++++---
>  net/ipv6/addrconf.c              | 23 +++++++++++++----------
>  5 files changed, 28 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 57c3856bab05..56a868415ba2 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -846,8 +846,11 @@ static int ipvlan_addr6_validator_event(struct notifier_block *unused,
>  
>  	switch (event) {
>  	case NETDEV_UP:
> -		if (ipvlan_addr_busy(ipvlan->port, &i6vi->i6vi_addr, true))
> +		if (ipvlan_addr_busy(ipvlan->port, &i6vi->i6vi_addr, true)) {
> +			NL_SET_ERR_MSG(i6vi->extack,
> +				       "Address already assigned to an ipvlan device");
>  			return notifier_from_errno(-EADDRINUSE);
> +		}
>  		break;
>  	}
>  
> @@ -916,8 +919,11 @@ static int ipvlan_addr4_validator_event(struct notifier_block *unused,
>  
>  	switch (event) {
>  	case NETDEV_UP:
> -		if (ipvlan_addr_busy(ipvlan->port, &ivi->ivi_addr, false))
> +		if (ipvlan_addr_busy(ipvlan->port, &ivi->ivi_addr, false)) {
> +			NL_SET_ERR_MSG(ivi->extack,
> +				       "Address already assigned to an ipvlan device");
>  			return notifier_from_errno(-EADDRINUSE);
> +		}
>  		break;
>  	}
>  
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index 751d051f0bc7..681dff30940b 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -154,6 +154,7 @@ struct in_ifaddr {
>  struct in_validator_info {
>  	__be32			ivi_addr;
>  	struct in_device	*ivi_dev;
> +	struct netlink_ext_ack	*extack;
>  };
>  
>  int register_inetaddr_notifier(struct notifier_block *nb);
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 87981cd63180..b8b16437c6d5 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -55,6 +55,7 @@ struct prefix_info {
>  struct in6_validator_info {
>  	struct in6_addr		i6vi_addr;
>  	struct inet6_dev	*i6vi_dev;
> +	struct netlink_ext_ack	*extack;
>  };
>  
>  #define IN6_ADDR_HSIZE_SHIFT	4
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 7ce22a2c07ce..0118698cd623 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -444,7 +444,7 @@ static void check_lifetime(struct work_struct *work);
>  static DECLARE_DELAYED_WORK(check_lifetime_work, check_lifetime);
>  
>  static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
> -			     u32 portid)
> +			     u32 portid, struct netlink_ext_ack  *extack)

Double space before `*extack`.

>  {
>  	struct in_device *in_dev = ifa->ifa_dev;
>  	struct in_ifaddr *ifa1, **ifap, **last_primary;
> @@ -489,6 +489,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>  	 */
>  	ivi.ivi_addr = ifa->ifa_address;
>  	ivi.ivi_dev = ifa->ifa_dev;
> +	ivi.extack = extack;
>  	ret = blocking_notifier_call_chain(&inetaddr_validator_chain,
>  					   NETDEV_UP, &ivi);
>  	ret = notifier_to_errno(ret);
> @@ -521,7 +522,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>  
>  static int inet_insert_ifa(struct in_ifaddr *ifa)
>  {
> -	return __inet_insert_ifa(ifa, NULL, 0);
> +	return __inet_insert_ifa(ifa, NULL, 0, NULL);
>  }
>  
>  static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
> @@ -902,7 +903,8 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
>  				return ret;
>  			}
>  		}
> -		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
> +		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid,
> +					 extack);
>  	} else {
>  		inet_free_ifa(ifa);
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 632cf4b26277..0bad4a800f73 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -958,7 +958,8 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
>  static struct inet6_ifaddr *
>  ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  	      const struct in6_addr *peer_addr, int pfxlen,
> -	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft)
> +	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft,
> +	      struct netlink_ext_ack  *extack)

Double space before `*extack`.

>  {
>  	struct net *net = dev_net(idev->dev);
>  	struct inet6_ifaddr *ifa = NULL;
> @@ -994,6 +995,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  		struct in6_validator_info i6vi = {
>  			.i6vi_addr = *addr,
>  			.i6vi_dev = idev,
> +			.extack = extack,
>  		};
>  
>  		rcu_read_unlock_bh();
> @@ -1336,7 +1338,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
>  
>  	ift = ipv6_add_addr(idev, &addr, NULL, tmp_plen,
>  			    ipv6_addr_scope(&addr), addr_flags,
> -			    tmp_valid_lft, tmp_prefered_lft);
> +			    tmp_valid_lft, tmp_prefered_lft, NULL);
>  	if (IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);
> @@ -2020,7 +2022,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
>  
>  		ifp2 = ipv6_add_addr(idev, &new_addr, NULL, pfxlen,
>  				     scope, flags, valid_lft,
> -				     preferred_lft);
> +				     preferred_lft, NULL);
>  		if (IS_ERR(ifp2))
>  			goto lock_errdad;
>  
> @@ -2478,7 +2480,7 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
>  					    pinfo->prefix_len,
>  					    addr_type&IPV6_ADDR_SCOPE_MASK,
>  					    addr_flags, valid_lft,
> -					    prefered_lft);
> +					    prefered_lft, NULL);
>  
>  		if (IS_ERR_OR_NULL(ifp))
>  			return -1;
> @@ -2788,7 +2790,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
>  			  const struct in6_addr *pfx,
>  			  const struct in6_addr *peer_pfx,
>  			  unsigned int plen, __u32 ifa_flags,
> -			  __u32 prefered_lft, __u32 valid_lft)
> +			  __u32 prefered_lft, __u32 valid_lft,
> +			  struct netlink_ext_ack *extack)
>  {
>  	struct inet6_ifaddr *ifp;
>  	struct inet6_dev *idev;
> @@ -2847,7 +2850,7 @@ static int inet6_addr_add(struct net *net, int ifindex,
>  	}
>  
>  	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
> -			    valid_lft, prefered_lft);
> +			    valid_lft, prefered_lft, extack);
>  
>  	if (!IS_ERR(ifp)) {
>  		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
> @@ -2932,7 +2935,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
>  	rtnl_lock();
>  	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr, NULL,
>  			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
> -			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
> +			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, NULL);
>  	rtnl_unlock();
>  	return err;
>  }
> @@ -2962,7 +2965,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  
>  	ifp = ipv6_add_addr(idev, addr, NULL, plen,
>  			    scope, IFA_F_PERMANENT,
> -			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
> +			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, NULL);
>  	if (!IS_ERR(ifp)) {
>  		spin_lock_bh(&ifp->lock);
>  		ifp->flags &= ~IFA_F_TENTATIVE;
> @@ -3062,7 +3065,7 @@ void addrconf_add_linklocal(struct inet6_dev *idev,
>  #endif
>  
>  	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
> -			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
> +			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, NULL);
>  	if (!IS_ERR(ifp)) {
>  		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
>  		addrconf_dad_start(ifp);
> @@ -4565,7 +4568,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
>  		 */
>  		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
>  				      ifm->ifa_prefixlen, ifa_flags,
> -				      preferred_lft, valid_lft);
> +				      preferred_lft, valid_lft, extack);
>  	}
>  
>  	if (nlh->nlmsg_flags & NLM_F_EXCL ||
> -- 
> 2.1.4
> 
