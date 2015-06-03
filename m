From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 16:02:33 -0400
Message-ID: <20150603200232.GL588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <556F4685.5010505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36037 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028AbbFCUCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 16:02:37 -0400
Received: by qkx62 with SMTP id 62so12245349qkx.3
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 13:02:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <556F4685.5010505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, Jun 03, 2015 at 11:25:09AM -0700, Alexander Duyck wrote:
> On 06/02/2015 08:07 PM, Andy Gospodarek wrote:
[...]
> >Though there were some that preferred not to have a configuration option
> >and to make this behavior the default when it was discussed in Ottawa
> >earlier this year since "it was time to do this."  I wanted to propose
> >the config option to preserve the current behavior for those that desire
> >it.  I'll happily remove it if Dave and Linus approve.
> >
> >An IPv6 implementation is also needed (DECnet too!), but I wanted to
> >start with the IPv4 implementation to get people comfortable with the
> >idea before moving forward.  If this is accepted the IPv6 implementation
> >can be posted shortly.
> >
> >FWIW, we have been running this patch with the sysctl setting above and
> >our customers have been happily using a backported version for IPv4 a
> >IPv6 for >6 months.
> 
> Really the patch below doesn't completely jive with what you have stated in
> the patch description above.  I would have really much rather seen the
> DEAD_LINKDOWN be the only behavior you changed.  Instead there are a number
> of changes to the DEAD flag that I am not sure are really necessary.
The main reason for the overload (which seems to be the source of most
of your comments), was to allow routes to be reported back as dead to
userspace with no modification to iproute2 and friends since there is
already the ability to print that a route is dead and that implication
is pretty clear.

The other thing I wanted to avoid is to have users update their kernel
(and the sysctl option) while not updating userspace and then have no
real clue why routes are not being selected since their iproute2 output
would not look any different.  It seems preservation of userspace seems
paramount, even in the face of a different config of the kernel.  

> I would have rather seen DEAD_LINKDOWN treated more like something where the
> metric is set to an infinite value than something where it starts to get in
> the way of things like flushing the table.
[...]
> >
> >diff --git a/net/core/dev.c b/net/core/dev.c
> >index 0602e91..50dc19c 100644
> >--- a/net/core/dev.c
> >+++ b/net/core/dev.c
> >@@ -3167,6 +3167,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
> >  int netdev_tstamp_prequeue __read_mostly = 1;
> >  int netdev_budget __read_mostly = 300;
> >  int weight_p __read_mostly = 64;            /* old backlog weight */
> >+int kill_routes_on_linkdown = 0;
> >+EXPORT_SYMBOL(kill_routes_on_linkdown);
> >
> >  /* Called with irq disabled */
> >  static inline void ____napi_schedule(struct softnet_data *sd,
> 
> You might want to move this up or down a few lines.  It doesn't really make
> much sense to drop routing specific stuff in the middle of the NAPI receive
> definitions.
> 
> It would be nice if you could find some place a bit more routing related to
> place them.
No problem.

> >diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> >index 95b6139..fef1804 100644
> >--- a/net/core/sysctl_net_core.c
> >+++ b/net/core/sysctl_net_core.c
> >@@ -392,6 +392,13 @@ static struct ctl_table net_core_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= proc_dointvec
> >  	},
> >+	{
> >+		.procname	= "kill_routes_on_linkdown",
> >+		.data		= &kill_routes_on_linkdown,
> >+		.maxlen		= sizeof(int),
> >+		.mode		= 0644,
> >+		.proc_handler	= proc_dointvec
> >+	},
> >  	{ }
> >  };
> >
> >diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> >index 872494e..94348c7 100644
> >--- a/net/ipv4/fib_frontend.c
> >+++ b/net/ipv4/fib_frontend.c
> >@@ -1107,6 +1107,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
> >  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> >  	struct in_device *in_dev;
> >  	struct net *net = dev_net(dev);
> >+	unsigned flags;
> >
> >  	if (event == NETDEV_UNREGISTER) {
> >  		fib_disable_ip(dev, 2);
> >@@ -1130,10 +1131,17 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
> >  		rt_cache_flush(net);
> >  		break;
> >  	case NETDEV_DOWN:
> >-		fib_disable_ip(dev, 0);
> >+		fib_disable_ip(dev, 1);
> >  		break;
> >-	case NETDEV_CHANGEMTU:
> >  	case NETDEV_CHANGE:
> >+		if (kill_routes_on_linkdown) {
> >+			flags = dev_get_flags(dev);
> >+			if (flags & (IFF_RUNNING|IFF_LOWER_UP))
> >+				fib_sync_up(dev);
> >+			else
> >+				fib_sync_down_dev(dev, 0);
> >+		}
> >+	case NETDEV_CHANGEMTU:
> >  		rt_cache_flush(net);
> >  		break;
> >  	}
> 
> I thought the value of 1 is already being used in fib_inetaddr_event.
You are correct.  I'll need to check the behavior to make sure this does
not break that (or put a check for kill_routes_on_linkdown) here
instead.

> >diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> >index 5615198..d135ec9 100644
> >--- a/net/ipv4/fib_rules.c
> >+++ b/net/ipv4/fib_rules.c
> >@@ -49,9 +49,14 @@ struct fib4_rule {
> >
> >  int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
> >  {
> >+	return fib_lookup_flags(net, flp, res, 0);
> >+}
> >+
> >+int fib_lookup_flags(struct net *net, struct flowi4 *flp, struct fib_result *res, int flags)
> >+{
> >  	struct fib_lookup_arg arg = {
> >  		.result = res,
> >-		.flags = FIB_LOOKUP_NOREF,
> >+		.flags = FIB_LOOKUP_NOREF | flags,
> >  	};
> >  	int err;
> >
> 
> You would probably be better off forking this function so that you have a
> version that can lookup dead routes.  Since this is hot-path we don't wan to
> have to split this up over too many functions.
> 
> >diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> >index 28ec3c1..c0874ee 100644
> >--- a/net/ipv4/fib_semantics.c
> >+++ b/net/ipv4/fib_semantics.c
> >@@ -266,7 +266,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
> >  #ifdef CONFIG_IP_ROUTE_CLASSID
> >  		    nh->nh_tclassid != onh->nh_tclassid ||
> >  #endif
> >-		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> >+		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_DEAD|RTNH_F_DEAD_LINKDOWN)))
> >  			return -1;
> >  		onh++;
> >  	} endfor_nexthops(fi);
> 
> You might just want to come up with a define to cover both dead cases. Maybe
> something like "RTNH_F_DEAD_ANY"
> 
> >@@ -318,7 +318,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
> >  		    nfi->fib_type == fi->fib_type &&
> >  		    memcmp(nfi->fib_metrics, fi->fib_metrics,
> >  			   sizeof(u32) * RTAX_MAX) == 0 &&
> >-		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
> >+		    ((nfi->fib_flags ^ fi->fib_flags) & ~(RTNH_F_DEAD|RTNH_F_DEAD_LINKDOWN)) == 0 &&
> >  		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
> >  			return fi;
> >  	}
> >@@ -604,6 +604,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  				return -ENODEV;
> >  			if (!(dev->flags & IFF_UP))
> >  				return -ENETDOWN;
> >+			if (!netif_carrier_ok(dev) && kill_routes_on_linkdown)
> >+				nh->nh_flags |= RTNH_F_DEAD;
> >  			nh->nh_dev = dev;
> >  			dev_hold(dev);
> >  			nh->nh_scope = RT_SCOPE_LINK;
> 
> It seems like you really should be using the DEAD_LINKDOWN here since this
> is what you are trying to indicate.
> 
> Also it really seems like you should move kill_routes_on_linkdown to
> fib_table_lookup.  You should track the extra flag always, and only skip the
> routes if kill_routes_on_linkdown is set.  Then you can override that with
> the extra flag being passed to fib_table_lookup.
> 
> Actually now that I think about it you could probably use
> kill_routes_on_linkdown in __fib_lookup to set a flag indicating that you
> want to kill the routes, otherwise just use the default behavior.
This is a significantly different design, but I like this.  One of the
issues I had with this was the fact that it felt like there were lots of
checks for kill_routes_on_linkdown and this would eliminate the need to
have this check in many places.

I can play with the following if it seems compelling (and it seems that
this feature is desireable so I'm willing to give it a try):

- set RTNH_F_LINKDOWN (dropping the 'DEAD' from the string) on all
  routes with interfaces that have link-down

- move check for kill_routes_on_linkdown to fib_lookup path and see if
  I can differentiate the cases between when I'm trying to add a route
  on an interface and doing a lookup

- set RTNH_F_DEAD on all nexthops during a fib_dump_info() so older
  userspace tools will still know about the dead routes

> 
> >@@ -621,7 +623,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  			/* It is not necessary, but requires a bit of thinking */
> >  			if (fl4.flowi4_scope < RT_SCOPE_LINK)
> >  				fl4.flowi4_scope = RT_SCOPE_LINK;
> >-			err = fib_lookup(net, &fl4, &res);
> >+			err = fib_lookup_flags(net, &fl4, &res, FIB_LOOKUP_ALLOWDEAD);
> >  			if (err) {
> >  				rcu_read_unlock();
> >  				return err;
> >@@ -636,6 +638,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		if (!dev)
> >  			goto out;
> >  		dev_hold(dev);
> >+		if (!netif_carrier_ok(dev) && kill_routes_on_linkdown)
> >+			nh->nh_flags |= RTNH_F_DEAD;
> >  		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
> >  	} else {
> >  		struct in_device *in_dev;
> 
> Same here.  There is no point in overloading RTNH_F_DEAD if you already are
> adding a new bit that will represent something similar.
The design decision for this mentioned above should probably make the
decision at least clear -- maybe not correct, but it should make more
sense.  :-)

> >@@ -654,6 +658,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		nh->nh_dev = in_dev->dev;
> >  		dev_hold(nh->nh_dev);
> >  		nh->nh_scope = RT_SCOPE_HOST;
> >+		if (!netif_carrier_ok(nh->nh_dev) && kill_routes_on_linkdown)
> >+			nh->nh_flags |= RTNH_F_DEAD;
> >  		err = 0;
> >  	}
> >  out:
> >@@ -760,6 +766,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  	struct fib_info *ofi;
> >  	int nhs = 1;
> >  	struct net *net = cfg->fc_nlinfo.nl_net;
> >+	int dead;
> >
> >  	if (cfg->fc_type > RTN_MAX)
> >  		goto err_inval;
> >@@ -920,11 +927,18 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  		if (!nh->nh_dev)
> >  			goto failure;
> >  	} else {
> >+		dead = 0;
> >  		change_nexthops(fi) {
> >  			err = fib_check_nh(cfg, fi, nexthop_nh);
> >  			if (err != 0)
> >  				goto failure;
> >+			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
> >+				dead++;
> >  		} endfor_nexthops(fi)
> >+		if ((dead == fi->fib_nhs)) {
> >+			fi->fib_flags |= RTNH_F_DEAD;
> >+			fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> >+		}
> >  	}
> >
> >  	if (fi->fib_prefsrc) {
> >@@ -1097,6 +1111,8 @@ int fib_sync_down_addr(struct net *net, __be32 local)
> >  			continue;
> >  		if (fi->fib_prefsrc == local) {
> >  			fi->fib_flags |= RTNH_F_DEAD;
> >+			/* Addr is gone, more serious than a linkdown */
> >+			fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			ret++;
> >  		}
> >  	}
> >@@ -1112,7 +1128,7 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >  	struct hlist_head *head = &fib_info_devhash[hash];
> >  	struct fib_nh *nh;
> >
> >-	if (force)
> >+	if (force > 1)
> >  		scope = -1;
> >
> >  	hlist_for_each_entry(nh, head, nh_hash) {
> >@@ -1147,6 +1163,11 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >  		} endfor_nexthops(fi)
> >  		if (dead == fi->fib_nhs) {
> >  			fi->fib_flags |= RTNH_F_DEAD;
> >+			/* force marks route down due to admin down and device removal. */
> >+			if (!force)
> >+				fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> >+			else
> >+				fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			ret++;
> >  		}
> >  	}
> 
> So what is the idea behind changing the force value like this?  It seems
> like it would make this much more readable if you were to simply use a value
> such as -1 to handle your DEAD_LINKDOWN case rather than altering the
> behavior for the values 1 and 0.
Also a reasonable option.  The key is that I want to be able to
differentiate from a DEAD link that is due to a linkdown and DEAD due to
clearing of IFF_UP.

> 
> >@@ -1223,10 +1244,12 @@ int fib_sync_up(struct net_device *dev)
> >  	struct hlist_head *head;
> >  	struct fib_nh *nh;
> >  	int ret;
> >+	int link_up;
> >
> >  	if (!(dev->flags & IFF_UP))
> >  		return 0;
> >
> >+	link_up = netif_carrier_ok(dev);
> >  	prev_fi = NULL;
> >  	hash = fib_devindex_hashfn(dev->ifindex);
> >  	head = &fib_info_devhash[hash];
> >@@ -1253,16 +1276,27 @@ int fib_sync_up(struct net_device *dev)
> >  			if (nexthop_nh->nh_dev != dev ||
> >  			    !__in_dev_get_rtnl(dev))
> >  				continue;
> >-			alive++;
> >+			if (link_up) {
> >+				/* Link is up, so mark NH as alive */
> >+				nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
> >+				alive++;
> >+			} else
> >+				nexthop_nh->nh_flags |= RTNH_F_DEAD;
> >+
> >  			spin_lock_bh(&fib_multipath_lock);
> >  			nexthop_nh->nh_power = 0;
> >-			nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
> >  			spin_unlock_bh(&fib_multipath_lock);
> >  		} endfor_nexthops(fi)
> >
> >  		if (alive > 0) {
> >+			/* Some NHs are alive, unmark the route as dead */
> >+			fi->fib_flags &= ~RTNH_F_DEAD_LINKDOWN;
> >  			fi->fib_flags &= ~RTNH_F_DEAD;
> >  			ret++;
> >+		} else {
> >+			/* No NHs are alive, mark the route as dead */
> >+			fi->fib_flags |= RTNH_F_DEAD_LINKDOWN;
> >+			fi->fib_flags |= RTNH_F_DEAD;
> >  		}
> >  	}
> >
> >diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> >index 01bce15..eedf287 100644
> >--- a/net/ipv4/fib_trie.c
> >+++ b/net/ipv4/fib_trie.c
> >@@ -1401,12 +1401,18 @@ found:
> >  #endif
> >  			return err;
> >  		}
> >-		if (fi->fib_flags & RTNH_F_DEAD)
> >-			continue;
> >+		if (!(fib_flags & FIB_LOOKUP_ALLOWDEAD)) {
> >+			/* if route is dead and link is down, keep looking  */
> >+			if ((fi->fib_flags & RTNH_F_DEAD) &&
> >+			    (fi->fib_flags & RTNH_F_DEAD_LINKDOWN))
> >+				continue;
> >+		}
> 
> The overloading of things makes this bit confusing.  I would much rather
> have seen this as:
> 		if (fi->fib_flags & RTNH_F_DEAD)
> 			continue;
> 		if ((fi->fib_flags & RTNH_F_DEAD_LINKDOWN) &&
> 		    !(fib_flags & FIB_LOOKUP_ALLOWDEAD))
> 			continue;
> 
> >  		for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
> >  			const struct fib_nh *nh = &fi->fib_nh[nhsel];
> >
> >-			if (nh->nh_flags & RTNH_F_DEAD)
> >+			/* allow next-hop to be added if link is down */
> >+			if ((nh->nh_flags & RTNH_F_DEAD) &&
> >+			    !(fi->fib_flags & RTNH_F_DEAD_LINKDOWN))
> >  				continue;
> >  			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
> >  				continue;
> 
> Same here.  By combining the DEAD and DEAD_LINKDOWN the way they have been
> it is hard to tell exaclty what is going on.  It would be much easier to
> sort all of this out if DEAD was left as DEAD, and DEAD_LINKDOWN was handled
> as something similar with option to override.
I think this will be fine.  Clearly I would want to test it again first,
but I'd have no major issue with a cleanup like this.

> 
> >@@ -1829,7 +1835,12 @@ int fib_table_flush(struct fib_table *tb)
> >  		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
> >  			struct fib_info *fi = fa->fa_info;
> >
> >-			if (!fi || !(fi->fib_flags & RTNH_F_DEAD)) {
> >+			/* DEAD and DEAD_LINKDOWN will not both be set
> >+			 * with IFF_UP is cleared, so do not flush
> >+			 * entries with only DEAD set
> >+			 */
> >+			if (!fi || !((fi->fib_flags & RTNH_F_DEAD) &&
> >+			    !(fi->fib_flags & RTNH_F_DEAD_LINKDOWN))) {
> >  				slen = fa->fa_slen;
> >  				continue;
> >  			}
> >
> 
> First you could do this flags check with just one and:
> 	if (!fi || !(fi->fib_flags & (RTNH_F_DEAD |
> 				      RTNH_F_DEAD_LINKDOWN)) {
> 
> Second I am not a fan of this flag messing with stuff such as the suffix
> length since we are now cut out of the search for just a link down event and
> the fact is link down/link up events can occur quickly and in significant
> quantaties int he case of a link bouncing.
> 
> Really what I would prefer to see is that this route gets ignored in
> fib_table_lookup in the case of a link down, and then we can avoid all of
> the ugly messing with RTNH_F_DEAD that seems to be happening as it makes it
> much more difficult to decode the actual state with the two flags.
That would be fine, but then a new way needs to be devised to report
this back to userspace to anyone who performs a dump of the fib table
knows that routes are dead.  One such option would be to have a check
in fib_dump_info() for link status and add the RTNH_F_DEAD flag (or
another flag if it is deemed that this is necessary and not too
disruptive to userspace on the way up.
