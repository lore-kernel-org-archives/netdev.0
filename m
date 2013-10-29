From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 20:08:10 -0400 (EDT)
Message-ID: <20131028.200810.66180312939474324.davem@davemloft.net>
References: <20131027164835.GB4714@order.stressinduktion.org>
	<20131028.171725.1076499130782328273.davem@davemloft.net>
	<1383002179.28991.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab3J2AIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 20:08:13 -0400
In-Reply-To: <1383002179.28991.14.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 28 Oct 2013 18:16:19 -0500

> On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> First off, what's the reasoning behind having IPv6 privacy as a config
> option?  It's off-by-default and must be explicitly turned on, so is
> there any harm in removing the config?  Or is it just for
> smallest-kernel-ever folks?

I think it's for "smallest kernel ever" stuff.  Even every arch
defconfig that mentions it has it enabled :-)

Maybe it was optional initially because the code was new and
experimental'ish.  I don't know.

Regardless of the reason I think it only obfuscates the code with
ifdefs right now and I would be happy to see it disappear.

Any objections to this patch?

====================
[PATCH] ipv6: Remove privacy config option.

The code for privacy extentions is very mature, and making it
configurable only gives marginal memory/code savings in exchange
for obfuscation and hard to read code via CPP ifdef'ery.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/ipv6.h   |  2 --
 include/net/if_inet6.h |  5 +----
 net/ipv6/Kconfig       | 18 ------------------
 net/ipv6/addrconf.c    | 41 +++--------------------------------------
 4 files changed, 4 insertions(+), 62 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index a80a63c..5d89d1b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -21,13 +21,11 @@ struct ipv6_devconf {
 	__s32		force_mld_version;
 	__s32		mldv1_unsolicited_report_interval;
 	__s32		mldv2_unsolicited_report_interval;
-#ifdef CONFIG_IPV6_PRIVACY
 	__s32		use_tempaddr;
 	__s32		temp_valid_lft;
 	__s32		temp_prefered_lft;
 	__s32		regen_max_retry;
 	__s32		max_desync_factor;
-#endif
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
 	__s32		accept_ra_pinfo;
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 02ef772..76d5427 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -66,11 +66,10 @@ struct inet6_ifaddr {
 	struct hlist_node	addr_lst;
 	struct list_head	if_list;
 
-#ifdef CONFIG_IPV6_PRIVACY
 	struct list_head	tmp_list;
 	struct inet6_ifaddr	*ifpub;
 	int			regen_count;
-#endif
+
 	bool			tokenized;
 
 	struct rcu_head		rcu;
@@ -192,11 +191,9 @@ struct inet6_dev {
 	__u32			if_flags;
 	int			dead;
 
-#ifdef CONFIG_IPV6_PRIVACY
 	u8			rndid[8];
 	struct timer_list	regen_timer;
 	struct list_head	tempaddr_list;
-#endif
 
 	struct in6_addr		token;
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index e1a8d90..d92e558 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -21,24 +21,6 @@ menuconfig IPV6
 
 if IPV6
 
-config IPV6_PRIVACY
-	bool "IPv6: Privacy Extensions (RFC 3041) support"
-	---help---
-	  Privacy Extensions for Stateless Address Autoconfiguration in IPv6
-	  support.  With this option, additional periodically-altered
-	  pseudo-random global-scope unicast address(es) will be assigned to
-	  your interface(s).
-	
-	  We use our standard pseudo-random algorithm to generate the
-          randomized interface identifier, instead of one described in RFC 3041.
-
-	  By default the kernel does not generate temporary addresses.
-	  To use temporary addresses, do
-	
-	        echo 2 >/proc/sys/net/ipv6/conf/all/use_tempaddr 
-
-	  See <file:Documentation/networking/ip-sysctl.txt> for details.
-
 config IPV6_ROUTER_PREF
 	bool "IPv6: Router Preference (RFC 4191) support"
 	---help---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd3fb30..542d095 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -83,11 +83,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
 #include <linux/netconf.h>
-
-#ifdef CONFIG_IPV6_PRIVACY
 #include <linux/random.h>
-#endif
-
 #include <linux/uaccess.h>
 #include <asm/unaligned.h>
 
@@ -124,11 +120,9 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 }
 #endif
 
-#ifdef CONFIG_IPV6_PRIVACY
 static void __ipv6_regen_rndid(struct inet6_dev *idev);
 static void __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 static void ipv6_regen_rndid(unsigned long data);
-#endif
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
@@ -183,13 +177,11 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-#ifdef CONFIG_IPV6_PRIVACY
 	.use_tempaddr 		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
-#endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_pinfo	= 1,
@@ -221,13 +213,11 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-#ifdef CONFIG_IPV6_PRIVACY
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
-#endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
 	.accept_ra_pinfo	= 1,
@@ -371,7 +361,6 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	}
 #endif
 
-#ifdef CONFIG_IPV6_PRIVACY
 	INIT_LIST_HEAD(&ndev->tempaddr_list);
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
@@ -384,7 +373,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		in6_dev_hold(ndev);
 		ipv6_regen_rndid((unsigned long) ndev);
 	}
-#endif
+
 	ndev->token = in6addr_any;
 
 	if (netif_running(dev) && addrconf_qdisc_ok(dev))
@@ -865,12 +854,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	/* Add to inet6_dev unicast addr list. */
 	ipv6_link_dev_addr(idev, ifa);
 
-#ifdef CONFIG_IPV6_PRIVACY
 	if (ifa->flags&IFA_F_TEMPORARY) {
 		list_add(&ifa->tmp_list, &idev->tempaddr_list);
 		in6_ifa_hold(ifa);
 	}
-#endif
 
 	in6_ifa_hold(ifa);
 	write_unlock(&idev->lock);
@@ -913,7 +900,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	spin_unlock_bh(&addrconf_hash_lock);
 
 	write_lock_bh(&idev->lock);
-#ifdef CONFIG_IPV6_PRIVACY
+
 	if (ifp->flags&IFA_F_TEMPORARY) {
 		list_del(&ifp->tmp_list);
 		if (ifp->ifpub) {
@@ -922,7 +909,6 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		}
 		__in6_ifa_put(ifp);
 	}
-#endif
 
 	list_for_each_entry_safe(ifa, ifn, &idev->addr_list, if_list) {
 		if (ifa == ifp) {
@@ -1013,7 +999,6 @@ out:
 	in6_ifa_put(ifp);
 }
 
-#ifdef CONFIG_IPV6_PRIVACY
 static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *ift)
 {
 	struct inet6_dev *idev = ifp->idev;
@@ -1116,7 +1101,6 @@ retry:
 out:
 	return ret;
 }
-#endif
 
 /*
  *	Choose an appropriate source address (RFC3484)
@@ -1131,9 +1115,7 @@ enum {
 #endif
 	IPV6_SADDR_RULE_OIF,
 	IPV6_SADDR_RULE_LABEL,
-#ifdef CONFIG_IPV6_PRIVACY
 	IPV6_SADDR_RULE_PRIVACY,
-#endif
 	IPV6_SADDR_RULE_ORCHID,
 	IPV6_SADDR_RULE_PREFIX,
 	IPV6_SADDR_RULE_MAX
@@ -1247,7 +1229,6 @@ static int ipv6_get_saddr_eval(struct net *net,
 				      &score->ifa->addr, score->addr_type,
 				      score->ifa->idev->dev->ifindex) == dst->label;
 		break;
-#ifdef CONFIG_IPV6_PRIVACY
 	case IPV6_SADDR_RULE_PRIVACY:
 	    {
 		/* Rule 7: Prefer public address
@@ -1259,7 +1240,6 @@ static int ipv6_get_saddr_eval(struct net *net,
 		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ preftmp;
 		break;
 	    }
-#endif
 	case IPV6_SADDR_RULE_ORCHID:
 		/* Rule 8-: Prefer ORCHID vs ORCHID or
 		 *	    non-ORCHID vs non-ORCHID
@@ -1588,7 +1568,6 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 		if (dad_failed)
 			ipv6_ifa_notify(0, ifp);
 		in6_ifa_put(ifp);
-#ifdef CONFIG_IPV6_PRIVACY
 	} else if (ifp->flags&IFA_F_TEMPORARY) {
 		struct inet6_ifaddr *ifpub;
 		spin_lock_bh(&ifp->lock);
@@ -1602,7 +1581,6 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 			spin_unlock_bh(&ifp->lock);
 		}
 		ipv6_del_addr(ifp);
-#endif
 	} else
 		ipv6_del_addr(ifp);
 }
@@ -1851,7 +1829,6 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 	return err;
 }
 
-#ifdef CONFIG_IPV6_PRIVACY
 /* (re)generation of randomized interface identifier (RFC 3041 3.2, 3.5) */
 static void __ipv6_regen_rndid(struct inet6_dev *idev)
 {
@@ -1919,7 +1896,6 @@ static void  __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmp
 	if (tmpaddr && memcmp(idev->rndid, &tmpaddr->s6_addr[8], 8) == 0)
 		__ipv6_regen_rndid(idev);
 }
-#endif
 
 /*
  *	Add prefix route.
@@ -2207,9 +2183,7 @@ ok:
 		if (ifp) {
 			int flags;
 			unsigned long now;
-#ifdef CONFIG_IPV6_PRIVACY
 			struct inet6_ifaddr *ift;
-#endif
 			u32 stored_lft;
 
 			/* update lifetime (RFC2462 5.5.3 e) */
@@ -2250,7 +2224,6 @@ ok:
 			} else
 				spin_unlock(&ifp->lock);
 
-#ifdef CONFIG_IPV6_PRIVACY
 			read_lock_bh(&in6_dev->lock);
 			/* update all temporary addresses in the list */
 			list_for_each_entry(ift, &in6_dev->tempaddr_list,
@@ -2315,7 +2288,7 @@ ok:
 			} else {
 				read_unlock_bh(&in6_dev->lock);
 			}
-#endif
+
 			in6_ifa_put(ifp);
 			addrconf_verify(0);
 		}
@@ -2995,7 +2968,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	if (!how)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
 
-#ifdef CONFIG_IPV6_PRIVACY
 	if (how && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
 
@@ -3015,7 +2987,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		in6_ifa_put(ifa);
 		write_lock_bh(&idev->lock);
 	}
-#endif
 
 	while (!list_empty(&idev->addr_list)) {
 		ifa = list_first_entry(&idev->addr_list,
@@ -3528,7 +3499,6 @@ restart:
 					in6_ifa_put(ifp);
 					goto restart;
 				}
-#ifdef CONFIG_IPV6_PRIVACY
 			} else if ((ifp->flags&IFA_F_TEMPORARY) &&
 				   !(ifp->flags&IFA_F_TENTATIVE)) {
 				unsigned long regen_advance = ifp->idev->cnf.regen_max_retry *
@@ -3556,7 +3526,6 @@ restart:
 				} else if (time_before(ifp->tstamp + ifp->prefered_lft * HZ - regen_advance * HZ, next))
 					next = ifp->tstamp + ifp->prefered_lft * HZ - regen_advance * HZ;
 				spin_unlock(&ifp->lock);
-#endif
 			} else {
 				/* ifp->prefered_lft <= ifp->valid_lft */
 				if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))
@@ -4128,13 +4097,11 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 		jiffies_to_msecs(cnf->mldv1_unsolicited_report_interval);
 	array[DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] =
 		jiffies_to_msecs(cnf->mldv2_unsolicited_report_interval);
-#ifdef CONFIG_IPV6_PRIVACY
 	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
 	array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
 	array[DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
 	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
-#endif
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
@@ -4828,7 +4795,6 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_ms_jiffies,
 		},
-#ifdef CONFIG_IPV6_PRIVACY
 		{
 			.procname	= "use_tempaddr",
 			.data		= &ipv6_devconf.use_tempaddr,
@@ -4864,7 +4830,6 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-#endif
 		{
 			.procname	= "max_addresses",
 			.data		= &ipv6_devconf.max_addresses,
-- 
1.7.11.7
