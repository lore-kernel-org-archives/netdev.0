From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 10:24:03 -0400
Message-ID: <20150603142403.GE588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <1433340228.3163.5.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35624 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbFCOYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 10:24:07 -0400
Received: by qgg60 with SMTP id 60so4323807qgg.2
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 07:24:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433340228.3163.5.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 04:03:48PM +0200, Hannes Frederic Sowa wrote:
> On Di, 2015-06-02 at 23:07 -0400, Andy Gospodarek wrote:
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 6f5f71f..5bd953c 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -2986,6 +2986,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
> >  bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
> >  
> >  extern int		netdev_budget;
> > +extern int		kill_routes_on_linkdown;
> 
> Would it make sense to make it per netns?
> 
I had seen it as a global behavior, but per netns could easily be an
option.

> >  
> >  /* Called by rtnetlink.c:rtnl_unlock() */
> >  void netdev_run_todo(void);
> > diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> > index 6d67383..4fbfda5 100644
> > --- a/include/net/fib_rules.h
> > +++ b/include/net/fib_rules.h
> > @@ -37,6 +37,7 @@ struct fib_lookup_arg {
> >  	struct fib_rule		*rule;
> >  	int			flags;
> >  #define FIB_LOOKUP_NOREF	1
> > +#define FIB_LOOKUP_ALLOWDEAD	2
> >  };
> >  
> >  struct fib_rules_ops {
> > diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> > index 54271ed..efb195b 100644
> > --- a/include/net/ip_fib.h
> > +++ b/include/net/ip_fib.h
> > @@ -250,6 +250,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id);
> >  struct fib_table *fib_get_table(struct net *net, u32 id);
> >  
> >  int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res);
> > +int fib_lookup_flags(struct net *n, struct flowi4 *flp, struct fib_result *res, int flags);
> >  
> >  static inline int fib_lookup(struct net *net, struct flowi4 *flp,
> >  			     struct fib_result *res)
> > diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> > index 17fb02f..bc264d4 100644
> > --- a/include/uapi/linux/rtnetlink.h
> > +++ b/include/uapi/linux/rtnetlink.h
> > @@ -338,6 +338,7 @@ struct rtnexthop {
> >  #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
> >  #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
> >  #define RTNH_F_OFFLOAD		8	/* offloaded route */
> > +#define RTNH_F_DEAD_LINKDOWN	16	/* Route dead due to carrier down */
> >  
> >  /* Macros to handle hexthops */
> >  
> 
> -- >8 --
> 
> > diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
> > index 0956373..b6632dc 100644
> > --- a/include/uapi/linux/sysctl.h
> > +++ b/include/uapi/linux/sysctl.h
> > @@ -276,6 +276,7 @@ enum
> >  	NET_CORE_AEVENT_ETIME=20,
> >  	NET_CORE_AEVENT_RSEQTH=21,
> >  	NET_CORE_WARNINGS=22,
> > +	NET_CORE_KILL_ROUTES_ON_LINKDOWN=23,
> >  };
> >  
> >  /* /proc/sys/net/ethernet */
> > diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> > index 7e7746a..f319116 100644
> > --- a/kernel/sysctl_binary.c
> > +++ b/kernel/sysctl_binary.c
> > @@ -196,6 +196,7 @@ static const struct bin_table bin_net_core_table[] = {
> >  	{ CTL_INT,	NET_CORE_AEVENT_ETIME,	"xfrm_aevent_etime" },
> >  	{ CTL_INT,	NET_CORE_AEVENT_RSEQTH,	"xfrm_aevent_rseqth" },
> >  	{ CTL_INT,	NET_CORE_WARNINGS,	"warnings" },
> > +	{ CTL_INT,	NET_CORE_KILL_ROUTES_ON_LINKDOWN,	"kill_routes_on_linkdown" },
> >  	{},
> >  };
> 
> -- >8 --
> 
> I don't think we need this hunk any more as we don't update binary
> sysctls anymore.
OK

> >  
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0602e91..50dc19c 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3167,6 +3167,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
> >  int netdev_tstamp_prequeue __read_mostly = 1;
> >  int netdev_budget __read_mostly = 300;
> >  int weight_p __read_mostly = 64;            /* old backlog weight */
> > +int kill_routes_on_linkdown = 0;
> > +EXPORT_SYMBOL(kill_routes_on_linkdown);
> >  
> >  /* Called with irq disabled */
> >  static inline void ____napi_schedule(struct softnet_data *sd,
> > diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> > index 95b6139..fef1804 100644
> > --- a/net/core/sysctl_net_core.c
> > +++ b/net/core/sysctl_net_core.c
> > @@ -392,6 +392,13 @@ static struct ctl_table net_core_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= proc_dointvec
> >  	},
> > +	{
> > +		.procname	= "kill_routes_on_linkdown",
> > +		.data		= &kill_routes_on_linkdown,
> > +		.maxlen		= sizeof(int),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec
> > +	},
> >  	{ }
> >  };
> >  
> > diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> > index 872494e..94348c7 100644
> > --- a/net/ipv4/fib_frontend.c
> > +++ b/net/ipv4/fib_frontend.c
> > @@ -1107,6 +1107,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
> >  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> >  	struct in_device *in_dev;
> >  	struct net *net = dev_net(dev);
> > +	unsigned flags;
> >  
> >  	if (event == NETDEV_UNREGISTER) {
> >  		fib_disable_ip(dev, 2);
> > @@ -1130,10 +1131,17 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
> >  		rt_cache_flush(net);
> >  		break;
> >  	case NETDEV_DOWN:
> > -		fib_disable_ip(dev, 0);
> > +		fib_disable_ip(dev, 1);
> 
> Shouldn't this depend on the sysctl?
> 
See the comment 2 down from this for the reasoning.

> >  		break;
> > -	case NETDEV_CHANGEMTU:
> >  	case NETDEV_CHANGE:
> > +		if (kill_routes_on_linkdown) {
> > +			flags = dev_get_flags(dev);
> > +			if (flags & (IFF_RUNNING|IFF_LOWER_UP))
> > +				fib_sync_up(dev);
> > +			else
> > +				fib_sync_down_dev(dev, 0);
> > +		}
> > +	case NETDEV_CHANGEMTU:
> >  		rt_cache_flush(net);
> >  		break;
> >  	}
> > diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> > index 5615198..d135ec9 100644
> > --- a/net/ipv4/fib_rules.c
> > +++ b/net/ipv4/fib_rules.c
> > @@ -49,9 +49,14 @@ struct fib4_rule {
> >  
> >  int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
> >  {
> > +	return fib_lookup_flags(net, flp, res, 0);
> > +}
> >
> > +int fib_lookup_flags(struct net *net, struct flowi4 *flp, struct fib_result *res, int flags)
> > +{
> >  	struct fib_lookup_arg arg = {
> >  		.result = res,
> > -		.flags = FIB_LOOKUP_NOREF,
> > +		.flags = FIB_LOOKUP_NOREF | flags,
> >  	};
> >  	int err;
> 
> Can fib_lookup take the flags argument always without adding a new
> wrapper?
It could, but __fib_lookup() is an exported symbol, so I reluctant to
change it.

>  
> > diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> > index 28ec3c1..c0874ee 100644
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -266,7 +266,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
> >  #ifdef CONFIG_IP_ROUTE_CLASSID
> >  		    nh->nh_tclassid != onh->nh_tclassid ||
> >  #endif
> > -		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> > +		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_DEAD|RTNH_F_DEAD_LINKDOWN)))
> >  			return -1;
> >  		onh++;
> >  	} endfor_nexthops(fi);
> > @@ -318,7 +318,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
> >  		    nfi->fib_type == fi->fib_type &&
> >  		    memcmp(nfi->fib_metrics, fi->fib_metrics,
> >  			   sizeof(u32) * RTAX_MAX) == 0 &&
> > -		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
> > +		    ((nfi->fib_flags ^ fi->fib_flags) & ~(RTNH_F_DEAD|RTNH_F_DEAD_LINKDOWN)) == 0 &&
> >  		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
> >  			return fi;
> >  	}
> > @@ -604,6 +604,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  				return -ENODEV;
> >  			if (!(dev->flags & IFF_UP))
> >  				return -ENETDOWN;
> > +			if (!netif_carrier_ok(dev) && kill_routes_on_linkdown)
> > +				nh->nh_flags |= RTNH_F_DEAD;
> >  			nh->nh_dev = dev;
> >  			dev_hold(dev);
> >  			nh->nh_scope = RT_SCOPE_LINK;
> > @@ -621,7 +623,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  			/* It is not necessary, but requires a bit of thinking */
> >  			if (fl4.flowi4_scope < RT_SCOPE_LINK)
> >  				fl4.flowi4_scope = RT_SCOPE_LINK;
> > -			err = fib_lookup(net, &fl4, &res);
> > +			err = fib_lookup_flags(net, &fl4, &res, FIB_LOOKUP_ALLOWDEAD);
> >  			if (err) {
> >  				rcu_read_unlock();
> >  				return err;
> > @@ -636,6 +638,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		if (!dev)
> >  			goto out;
> >  		dev_hold(dev);
> > +		if (!netif_carrier_ok(dev) && kill_routes_on_linkdown)
> > +			nh->nh_flags |= RTNH_F_DEAD;
> >  		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
> >  	} else {
> >  		struct in_device *in_dev;
> > @@ -654,6 +658,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		nh->nh_dev = in_dev->dev;
> >  		dev_hold(nh->nh_dev);
> >  		nh->nh_scope = RT_SCOPE_HOST;
> > +		if (!netif_carrier_ok(nh->nh_dev) && kill_routes_on_linkdown)
> > +			nh->nh_flags |= RTNH_F_DEAD;
> >  		err = 0;
> >  	}
> >  out:
> > @@ -760,6 +766,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  	struct fib_info *ofi;
> >  	int nhs = 1;
> >  	struct net *net = cfg->fc_nlinfo.nl_net;
> > +	int dead;
> >  
> >  	if (cfg->fc_type > RTN_MAX)
> >  		goto err_inval;
> > @@ -920,11 +927,18 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  		if (!nh->nh_dev)
> >  			goto failure;
> >  	} else {
> > +		dead = 0;
> >  		change_nexthops(fi) {
> >  			err = fib_check_nh(cfg, fi, nexthop_nh);
> >  			if (err != 0)
> >  				goto failure;
> > +			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
> > +				dead++;
> >  		} endfor_nexthops(fi)
> > +		if ((dead == fi->fib_nhs)) {
> > +			fi->fib_flags |= RTNH_F_DEAD;
> > +			fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> > +		}
> >  	}
> >  
> >  	if (fi->fib_prefsrc) {
> > @@ -1097,6 +1111,8 @@ int fib_sync_down_addr(struct net *net, __be32 local)
> >  			continue;
> >  		if (fi->fib_prefsrc == local) {
> >  			fi->fib_flags |= RTNH_F_DEAD;
> > +			/* Addr is gone, more serious than a linkdown */
> > +			fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			ret++;
> >  		}
> >  	}
> > @@ -1112,7 +1128,7 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >  	struct hlist_head *head = &fib_info_devhash[hash];
> >  	struct fib_nh *nh;
> >  
> > -	if (force)
> > +	if (force > 1)
> >  		scope = -1;
> 
> Why was this changed? I think force can be made a boolean.
I changed this and changed the call to fib_disable_ip() in
fib_netdev_event() above.  Since previous users of fib_disable_ip only
called force with '0' or '2' today, I added back a call to use 1 and
this change causes the behavior to be the same without the need to
check for the sysctl.  This may be a bit more confusing than necessary,
I would be willing to make it more explicit.

> >  
> >  	hlist_for_each_entry(nh, head, nh_hash) {
> > @@ -1147,6 +1163,11 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >  		} endfor_nexthops(fi)
> >  		if (dead == fi->fib_nhs) {
> >  			fi->fib_flags |= RTNH_F_DEAD;
> > +			/* force marks route down due to admin down and device removal. */
> > +			if (!force)
> > +				fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> > +			else
> > +				fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			ret++;
> >  		}
> >  	}
> > @@ -1223,10 +1244,12 @@ int fib_sync_up(struct net_device *dev)
> >  	struct hlist_head *head;
> >  	struct fib_nh *nh;
> >  	int ret;
> > +	int link_up;
> >  
> >  	if (!(dev->flags & IFF_UP))
> >  		return 0;
> >  
> > +	link_up = netif_carrier_ok(dev);
> >  	prev_fi = NULL;
> >  	hash = fib_devindex_hashfn(dev->ifindex);
> >  	head = &fib_info_devhash[hash];
> > @@ -1253,16 +1276,27 @@ int fib_sync_up(struct net_device *dev)
> >  			if (nexthop_nh->nh_dev != dev ||
> >  			    !__in_dev_get_rtnl(dev))
> >  				continue;
> > -			alive++;
> > +			if (link_up) {
> > +				/* Link is up, so mark NH as alive */
> > +				nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
> > +				alive++;
> > +			} else
> > +				nexthop_nh->nh_flags |= RTNH_F_DEAD;
> > +
> >  			spin_lock_bh(&fib_multipath_lock);
> >  			nexthop_nh->nh_power = 0;
> > -			nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
> >  			spin_unlock_bh(&fib_multipath_lock);
> >  		} endfor_nexthops(fi)
> >  
> >  		if (alive > 0) {
> > +			/* Some NHs are alive, unmark the route as dead */
> > +			fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			fi->fib_flags &= ~RTNH_F_DEAD;
> >  			ret++;
> > +		} else {
> > +			/* No NHs are alive, mark the route as dead */
> > +			fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> > +			fi->fib_flags |= RTNH_F_DEAD;
> >  		}
> >  	}
> >  
> > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> > index 01bce15..eedf287 100644
> > --- a/net/ipv4/fib_trie.c
> > +++ b/net/ipv4/fib_trie.c
> > @@ -1401,12 +1401,18 @@ found:
> >  #endif
> >  			return err;
> >  		}
> > -		if (fi->fib_flags & RTNH_F_DEAD)
> > -			continue;
> > +		if (!(fib_flags & FIB_LOOKUP_ALLOWDEAD)) {
> > +			/* if route is dead and link is down, keep looking  */
> > +			if ((fi->fib_flags & RTNH_F_DEAD) &&
> > +			    (fi->fib_flags & RTNH_F_DEAD_LINKDOWN))
> > +				continue;
> > +		}
> >  		for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
> >  			const struct fib_nh *nh = &fi->fib_nh[nhsel];
> >  
> > -			if (nh->nh_flags & RTNH_F_DEAD)
> > +			/* allow next-hop to be added if link is down */
> > +			if ((nh->nh_flags & RTNH_F_DEAD) &&
> > +			    !(fi->fib_flags & RTNH_F_DEAD_LINKDOWN))
> >  				continue;
> >  			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
> >  				continue;
> > @@ -1829,7 +1835,12 @@ int fib_table_flush(struct fib_table *tb)
> >  		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
> >  			struct fib_info *fi = fa->fa_info;
> >  
> > -			if (!fi || !(fi->fib_flags & RTNH_F_DEAD)) {
> > +			/* DEAD and DEAD_LINKDOWN will not both be set
> > +			 * with IFF_UP is cleared, so do not flush
> > +			 * entries with only DEAD set
> > +			 */
> > +			if (!fi || !((fi->fib_flags & RTNH_F_DEAD) &&
> > +			    !(fi->fib_flags & RTNH_F_DEAD_LINKDOWN))) {
> >  				slen = fa->fa_slen;
> >  				continue;
> >  			}
> 
> Otherwise looks good, thanks!
Thanks for the review.
