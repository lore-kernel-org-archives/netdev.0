From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 1/3 v2] net: track link-status of ipv4 nexthops
Date: Wed, 10 Jun 2015 02:47:19 -0400
Message-ID: <1433918841-15576-2-git-send-email-gospo@cumulusnetworks.com>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:32783 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbbFJGsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 02:48:45 -0400
Received: by oiha141 with SMTP id a141so26255547oih.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 23:48:45 -0700 (PDT)
In-Reply-To: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
reachable via an interface where carrier is off.  No action is taken,
but additional flags are passed to userspace to indicate carrier status.

This also includes a cleanup to fib_disable_ip to more clearly indicate
what event made the function call to replace the more cryptic force
option previously used.

v2: Split out kernel functionality into 2 patches, this patch simply sets and
clears new nexthop flag RTNH_F_LINKDOWN.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>

---
 include/net/ip_fib.h           |  4 +--
 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv4/fib_frontend.c        | 26 +++++++++++---------
 net/ipv4/fib_semantics.c       | 56 ++++++++++++++++++++++++++++++++----------
 4 files changed, 60 insertions(+), 27 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..d1de1b7 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -305,9 +305,9 @@ void fib_flush_external(struct net *net);
 
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
-int fib_sync_down_dev(struct net_device *dev, int force);
+int fib_sync_down_dev(struct net_device *dev, int event);
 int fib_sync_down_addr(struct net *net, __be32 local);
-int fib_sync_up(struct net_device *dev);
+int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 void fib_select_multipath(struct fib_result *res);
 
 /* Exported by fib_trie.c */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 17fb02f..8dde432 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -338,6 +338,7 @@ struct rtnexthop {
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
 #define RTNH_F_OFFLOAD		8	/* offloaded route */
+#define RTNH_F_LINKDOWN		16	/* carrier-down on nexthop */
 
 /* Macros to handle hexthops */
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 872494e..1e4c646 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1063,9 +1063,9 @@ static void nl_fib_lookup_exit(struct net *net)
 	net->ipv4.fibnl = NULL;
 }
 
-static void fib_disable_ip(struct net_device *dev, int force)
+static void fib_disable_ip(struct net_device *dev, int event)
 {
-	if (fib_sync_down_dev(dev, force))
+	if (fib_sync_down_dev(dev, event))
 		fib_flush(dev_net(dev));
 	rt_cache_flush(dev_net(dev));
 	arp_ifdown(dev);
@@ -1080,9 +1080,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 	switch (event) {
 	case NETDEV_UP:
 		fib_add_ifaddr(ifa);
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-		fib_sync_up(dev);
-#endif
+		fib_sync_up(dev, RTNH_F_DEAD);
 		atomic_inc(&net->ipv4.dev_addr_genid);
 		rt_cache_flush(dev_net(dev));
 		break;
@@ -1093,7 +1091,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 			/* Last address was deleted from this interface.
 			 * Disable IP.
 			 */
-			fib_disable_ip(dev, 1);
+			fib_disable_ip(dev, event);
 		} else {
 			rt_cache_flush(dev_net(dev));
 		}
@@ -1107,9 +1105,10 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
+	unsigned flags;
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, 2);
+		fib_disable_ip(dev, event);
 		rt_flush_dev(dev);
 		return NOTIFY_DONE;
 	}
@@ -1123,17 +1122,20 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		for_ifa(in_dev) {
 			fib_add_ifaddr(ifa);
 		} endfor_ifa(in_dev);
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-		fib_sync_up(dev);
-#endif
+		fib_sync_up(dev, RTNH_F_DEAD);
 		atomic_inc(&net->ipv4.dev_addr_genid);
 		rt_cache_flush(net);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, 0);
+		fib_disable_ip(dev, event);
 		break;
-	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
+		flags = dev_get_flags(dev);
+		if (flags & (IFF_RUNNING|IFF_LOWER_UP))
+			fib_sync_up(dev, RTNH_F_LINKDOWN);
+		else
+			fib_sync_down_dev(dev, event);
+	case NETDEV_CHANGEMTU:
 		rt_cache_flush(net);
 		break;
 	}
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 28ec3c1..776e029 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -266,7 +266,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		    nh->nh_tclassid != onh->nh_tclassid ||
 #endif
-		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
+		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_DEAD|RTNH_F_LINKDOWN)))
 			return -1;
 		onh++;
 	} endfor_nexthops(fi);
@@ -318,7 +318,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 		    nfi->fib_type == fi->fib_type &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
 			   sizeof(u32) * RTAX_MAX) == 0 &&
-		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
+		    ((nfi->fib_flags ^ fi->fib_flags) & ~(RTNH_F_DEAD|RTNH_F_LINKDOWN)) == 0 &&
 		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
 			return fi;
 	}
@@ -604,6 +604,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 				return -ENODEV;
 			if (!(dev->flags & IFF_UP))
 				return -ENETDOWN;
+			if (!netif_carrier_ok(dev))
+				nh->nh_flags |= RTNH_F_LINKDOWN;
 			nh->nh_dev = dev;
 			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
@@ -636,6 +638,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		if (!dev)
 			goto out;
 		dev_hold(dev);
+		if (!netif_carrier_ok(dev))
+			nh->nh_flags |= RTNH_F_LINKDOWN;
 		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
 	} else {
 		struct in_device *in_dev;
@@ -654,6 +658,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		nh->nh_dev = in_dev->dev;
 		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
+		if (!netif_carrier_ok(nh->nh_dev))
+			nh->nh_flags |= RTNH_F_LINKDOWN;
 		err = 0;
 	}
 out:
@@ -920,11 +926,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		if (!nh->nh_dev)
 			goto failure;
 	} else {
+		int linkdown = 0;
 		change_nexthops(fi) {
 			err = fib_check_nh(cfg, fi, nexthop_nh);
 			if (err != 0)
 				goto failure;
+			if (nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
+				linkdown++;
 		} endfor_nexthops(fi)
+		if (linkdown == fi->fib_nhs) {
+			fi->fib_flags |= RTNH_F_LINKDOWN;
+		}
 	}
 
 	if (fi->fib_prefsrc) {
@@ -1103,7 +1115,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 	return ret;
 }
 
-int fib_sync_down_dev(struct net_device *dev, int force)
+int fib_sync_down_dev(struct net_device *dev, int event)
 {
 	int ret = 0;
 	int scope = RT_SCOPE_NOWHERE;
@@ -1112,7 +1124,7 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 	struct hlist_head *head = &fib_info_devhash[hash];
 	struct fib_nh *nh;
 
-	if (force)
+	if (event == NETDEV_UNREGISTER)
 		scope = -1;
 
 	hlist_for_each_entry(nh, head, nh_hash) {
@@ -1129,7 +1141,15 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 				dead++;
 			else if (nexthop_nh->nh_dev == dev &&
 				 nexthop_nh->nh_scope != scope) {
-				nexthop_nh->nh_flags |= RTNH_F_DEAD;
+				switch (event) {
+				case NETDEV_DOWN:
+				case NETDEV_UNREGISTER:
+					nexthop_nh->nh_flags |= RTNH_F_DEAD;
+					/* fall through */
+				case NETDEV_CHANGE:
+					nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
+					break;
+				}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 				spin_lock_bh(&fib_multipath_lock);
 				fi->fib_power -= nexthop_nh->nh_power;
@@ -1139,14 +1159,22 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 				dead++;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-			if (force > 1 && nexthop_nh->nh_dev == dev) {
+			if (event == NETDEV_UNREGISTER && nexthop_nh->nh_dev == dev) {
 				dead = fi->fib_nhs;
 				break;
 			}
 #endif
 		} endfor_nexthops(fi)
 		if (dead == fi->fib_nhs) {
-			fi->fib_flags |= RTNH_F_DEAD;
+			switch (event) {
+			case NETDEV_DOWN:
+			case NETDEV_UNREGISTER:
+				fi->fib_flags |= RTNH_F_DEAD;
+				/* fall through */
+			case NETDEV_CHANGE:
+				fi->fib_flags |= RTNH_F_LINKDOWN;
+				break;
+			}
 			ret++;
 		}
 	}
@@ -1210,13 +1238,11 @@ out:
 	return;
 }
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-
 /*
  * Dead device goes up. We wake up dead nexthops.
  * It takes sense only on multipath routes.
  */
-int fib_sync_up(struct net_device *dev)
+int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
 {
 	struct fib_info *prev_fi;
 	unsigned int hash;
@@ -1243,7 +1269,7 @@ int fib_sync_up(struct net_device *dev)
 		prev_fi = fi;
 		alive = 0;
 		change_nexthops(fi) {
-			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD)) {
+			if (!(nexthop_nh->nh_flags & nh_flags)) {
 				alive++;
 				continue;
 			}
@@ -1254,14 +1280,16 @@ int fib_sync_up(struct net_device *dev)
 			    !__in_dev_get_rtnl(dev))
 				continue;
 			alive++;
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
 			spin_lock_bh(&fib_multipath_lock);
 			nexthop_nh->nh_power = 0;
-			nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
+			nexthop_nh->nh_flags &= ~nh_flags;
 			spin_unlock_bh(&fib_multipath_lock);
+#endif
 		} endfor_nexthops(fi)
 
 		if (alive > 0) {
-			fi->fib_flags &= ~RTNH_F_DEAD;
+			fi->fib_flags &= ~nh_flags;
 			ret++;
 		}
 	}
@@ -1269,6 +1297,8 @@ int fib_sync_up(struct net_device *dev)
 	return ret;
 }
 
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+
 /*
  * The algorithm is suboptimal, but it provides really
  * fair weighted route distribution.
-- 
1.9.3
