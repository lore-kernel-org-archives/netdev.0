From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/4] [RTNETLINK]: Use rtnl_multicast()/rtnl_unicast()
Date: Wed, 09 Aug 2006 00:00:02 +0200
Message-ID: <20060809205439.725451037@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19874 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751370AbWHIUzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 16:55:15 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_msg
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces rtnl_multicast() to broadcast events and rtnl_unicast()
to send unicast messages via the rtnl socket.

This obsoletes rtnetlink_send() which wrongly provided the netlink
pid of the requesting applications to netlink_broadcast() which
lead to events not being sent to that application even though it
was subscribed.

This patch ensures consistency in all rtnetlink event notification
mechansims, i.e. the pid of the requesting application is kept
in nlmsg_pid to help applications such as quagga to identify whether
the event was caused by themselves and properly feeds all calls
to netlink_broadcast() with a pid of 0 to not exclude any sockets.

Removes the obsoleted NLM_F_ECHO code.

Some notifications are done in atomic contex, therefore
nlmsg_multicast() had to be extended to take allocation flags.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -583,7 +583,8 @@ struct rtnetlink_link
 };
 
 extern struct rtnetlink_link * rtnetlink_links[NPROTO];
-extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
+extern int rtnl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags);
+extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -153,17 +153,14 @@ size_t rtattr_strlcpy(char *dest, const 
 	return ret;
 }
 
-int rtnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
+int rtnl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags)
 {
-	int err = 0;
+	return nlmsg_multicast(rtnl, skb, 0, group, flags);
+}
 
-	NETLINK_CB(skb).dst_group = group;
-	if (echo)
-		atomic_inc(&skb->users);
-	netlink_broadcast(rtnl, skb, pid, group, GFP_KERNEL);
-	if (echo)
-		err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
-	return err;
+int rtnl_unicast(struct sk_buff *skb, u32 pid)
+{
+	return nlmsg_unicast(rtnl, skb, pid);
 }
 
 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
@@ -560,9 +557,7 @@ static int rtnl_getlink(struct sk_buff *
 		goto errout;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(skb).pid);
 errout:
 	kfree(iw_buf);
 	dev_put(dev);
@@ -609,8 +604,8 @@ void rtmsg_ifinfo(int type, struct net_d
 		kfree_skb(skb);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_KERNEL);
+
+	rtnl_multicast(skb, RTNLGRP_LINK, GFP_KERNEL);
 }
 
 /* Protected by RTNL sempahore.  */
Index: net-2.6.19.git/net/decnet/dn_table.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_table.c
+++ net-2.6.19.git/net/decnet/dn_table.c
@@ -343,12 +343,8 @@ static void dn_rtmsg_fib(int event, stru
                 kfree_skb(skb);
                 return;
         }
-        NETLINK_CB(skb).dst_group = RTNLGRP_DECnet_ROUTE;
-        if (nlh->nlmsg_flags & NLM_F_ECHO)
-                atomic_inc(&skb->users);
-        netlink_broadcast(rtnl, skb, pid, RTNLGRP_DECnet_ROUTE, GFP_KERNEL);
-        if (nlh->nlmsg_flags & NLM_F_ECHO)
-                netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+
+	rtnl_multicast(skb, RTNLGRP_DECnet_ROUTE, GFP_KERNEL);
 }
 
 static __inline__ int dn_hash_dump_bucket(struct sk_buff *skb, 
Index: net-2.6.19.git/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_semantics.c
+++ net-2.6.19.git/net/ipv4/fib_semantics.c
@@ -291,12 +291,8 @@ void rtmsg_fib(int event, u32 key, struc
 		kfree_skb(skb);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV4_ROUTE;
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		atomic_inc(&skb->users);
-	netlink_broadcast(rtnl, skb, pid, RTNLGRP_IPV4_ROUTE, GFP_KERNEL);
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+
+	rtnl_multicast(skb, RTNLGRP_IPV4_ROUTE, GFP_KERNEL);
 }
 
 /* Return the first fib alias matching TOS with
Index: net-2.6.19.git/net/sched/act_api.c
===================================================================
--- net-2.6.19.git.orig/net/sched/act_api.c
+++ net-2.6.19.git/net/sched/act_api.c
@@ -459,7 +459,6 @@ static int
 act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 {
 	struct sk_buff *skb;
-	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
@@ -468,10 +467,8 @@ act_get_notify(u32 pid, struct nlmsghdr 
 		kfree_skb(skb);
 		return -EINVAL;
 	}
-	err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
-	return err;
+
+	return rtnl_unicast(skb, pid);
 }
 
 static struct tc_action *
@@ -592,11 +589,8 @@ static int tca_action_flush(struct rtatt
 	nlh->nlmsg_flags |= NLM_F_ROOT;
 	module_put(a->ops->owner);
 	kfree(a);
-	err = rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
-	if (err > 0)
-		return 0;
 
-	return err;
+	return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 
 rtattr_failure:
 nlmsg_failure:
@@ -655,11 +649,8 @@ tca_action_gd(struct rtattr *rta, struct
 
 		/* now do the delete */
 		tcf_action_destroy(head, 0);
-		ret = rtnetlink_send(skb, pid, RTNLGRP_TC,
-		                     n->nlmsg_flags&NLM_F_ECHO);
-		if (ret > 0)
-			return 0;
-		return ret;
+
+		return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 	}
 err:
 	cleanup_a(head);
@@ -674,7 +665,6 @@ static int tcf_add_notify(struct tc_acti
 	struct sk_buff *skb;
 	struct rtattr *x;
 	unsigned char *b;
-	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
@@ -697,12 +687,8 @@ static int tcf_add_notify(struct tc_acti
 	x->rta_len = skb->tail - (u8*)x;
 	
 	nlh->nlmsg_len = skb->tail - b;
-	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
 	
-	err = rtnetlink_send(skb, pid, RTNLGRP_TC, flags&NLM_F_ECHO);
-	if (err > 0)
-		err = 0;
-	return err;
+	return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 
 rtattr_failure:
 nlmsg_failure:
Index: net-2.6.19.git/net/sched/cls_api.c
===================================================================
--- net-2.6.19.git.orig/net/sched/cls_api.c
+++ net-2.6.19.git/net/sched/cls_api.c
@@ -366,7 +366,7 @@ static int tfilter_notify(struct sk_buff
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 }
 
 struct tcf_dump_args
Index: net-2.6.19.git/net/sched/sch_api.c
===================================================================
--- net-2.6.19.git.orig/net/sched/sch_api.c
+++ net-2.6.19.git/net/sched/sch_api.c
@@ -815,7 +815,7 @@ static int qdisc_notify(struct sk_buff *
 	}
 
 	if (skb->len)
-		return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+		return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 
 err_out:
 	kfree_skb(skb);
@@ -1039,7 +1039,7 @@ static int tclass_notify(struct sk_buff 
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	return rtnl_multicast(skb, RTNLGRP_TC, GFP_KERNEL);
 }
 
 struct qdisc_dump_args
Index: net-2.6.19.git/include/net/genetlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/genetlink.h
+++ net-2.6.19.git/include/net/genetlink.h
@@ -133,11 +133,12 @@ static inline int genlmsg_cancel(struct 
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
  * @group: multicast group id
+ * @flags: allocation flags
  */
 static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
-				    unsigned int group)
+				    unsigned int group, gfp_t flags)
 {
-	return nlmsg_multicast(genl_sock, skb, pid, group);
+	return nlmsg_multicast(genl_sock, skb, pid, group, flags);
 }
 
 /**
Index: net-2.6.19.git/include/net/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/netlink.h
+++ net-2.6.19.git/include/net/netlink.h
@@ -545,15 +545,16 @@ static inline void nlmsg_free(struct sk_
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
  * @group: multicast group id
+ * @flags: allocation flags
  */
 static inline int nlmsg_multicast(struct sock *sk, struct sk_buff *skb,
-				  u32 pid, unsigned int group)
+				  u32 pid, unsigned int group, gfp_t flags)
 {
 	int err;
 
 	NETLINK_CB(skb).dst_group = group;
 
-	err = netlink_broadcast(sk, skb, pid, group, GFP_KERNEL);
+	err = netlink_broadcast(sk, skb, pid, group, flags);
 	if (err > 0)
 		err = 0;
 
Index: net-2.6.19.git/net/netlabel/netlabel_user.c
===================================================================
--- net-2.6.19.git.orig/net/netlabel/netlabel_user.c
+++ net-2.6.19.git/net/netlabel/netlabel_user.c
@@ -154,5 +154,5 @@ int netlbl_netlink_snd(struct sk_buff *s
  */
 int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group)
 {
-	return genlmsg_multicast(skb, pid, group);
+	return genlmsg_multicast(skb, pid, group, GFP_KERNEL);
 }
Index: net-2.6.19.git/net/netlink/genetlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/genetlink.c
+++ net-2.6.19.git/net/netlink/genetlink.c
@@ -510,7 +510,7 @@ static int genl_ctrl_event(int event, vo
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
 
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL);
+		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
 		break;
 	}
 
Index: net-2.6.19.git/net/bridge/br_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/bridge/br_netlink.c
+++ net-2.6.19.git/net/bridge/br_netlink.c
@@ -88,8 +88,7 @@ void br_ifinfo_notify(int event, struct 
 	if (err)
 		goto err_kfree;
 
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+	rtnl_multicast(skb, RTNLGRP_LINK, GFP_ATOMIC);
 	return;
 
 err_kfree:
Index: net-2.6.19.git/net/core/fib_rules.c
===================================================================
--- net-2.6.19.git.orig/net/core/fib_rules.c
+++ net-2.6.19.git/net/core/fib_rules.c
@@ -354,7 +354,7 @@ static void notify_rule_change(int event
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, ops->nlgroup, EINVAL);
 	} else
-		netlink_broadcast(rtnl, skb, 0, ops->nlgroup, GFP_KERNEL);
+		rtnl_multicast(skb, ops->nlgroup, GFP_KERNEL);
 }
 
 static void attach_rules(struct list_head *rules, struct net_device *dev)
Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -2416,10 +2416,8 @@ void neigh_app_ns(struct neighbour *n)
 
 	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, NLM_F_REQUEST) <= 0)
 		kfree_skb(skb);
-	else {
-		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
-	}
+	else
+		rtnl_multicast(skb, RTNLGRP_NEIGH, GFP_ATOMIC);
 }
 
 static void neigh_app_notify(struct neighbour *n)
@@ -2432,10 +2430,8 @@ static void neigh_app_notify(struct neig
 
 	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) <= 0)
 		kfree_skb(skb);
-	else {
-		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
-	}
+	else
+		rtnl_multicast(skb, RTNLGRP_NEIGH, GFP_ATOMIC);
 }
 
 #endif /* CONFIG_ARPD */
Index: net-2.6.19.git/net/core/wireless.c
===================================================================
--- net-2.6.19.git.orig/net/core/wireless.c
+++ net-2.6.19.git/net/core/wireless.c
@@ -1903,8 +1903,8 @@ static inline void rtmsg_iwinfo(struct n
 		kfree_skb(skb);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+
+	rtnl_multicast(skb, RTNLGRP_LINK, GFP_ATOMIC);
 }
 #endif	/* WE_EVENT_RTNETLINK */
 
Index: net-2.6.19.git/net/decnet/dn_dev.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_dev.c
+++ net-2.6.19.git/net/decnet/dn_dev.c
@@ -757,8 +757,8 @@ static void rtmsg_ifa(int event, struct 
 		netlink_set_err(rtnl, 0, RTNLGRP_DECnet_IFADDR, EINVAL);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_DECnet_IFADDR;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_DECnet_IFADDR, GFP_KERNEL);
+
+	rtnl_multicast(skb, RTNLGRP_DECnet_IFADDR, GFP_KERNEL);
 }
 
 static int dn_dev_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
Index: net-2.6.19.git/net/decnet/dn_route.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_route.c
+++ net-2.6.19.git/net/decnet/dn_route.c
@@ -1609,9 +1609,7 @@ int dn_cache_getroute(struct sk_buff *in
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-
-	return err;
+	return rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 
 out_free:
 	kfree_skb(skb);
Index: net-2.6.19.git/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/devinet.c
+++ net-2.6.19.git/net/ipv4/devinet.c
@@ -1200,7 +1200,7 @@ static void rtmsg_ifa(int event, struct 
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, EINVAL);
 	} else
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_IFADDR, GFP_KERNEL);
+		rtnl_multicast(skb, RTNLGRP_IPV4_IFADDR, GFP_KERNEL);
 }
 
 static struct rtnetlink_link inet_rtnetlink_table[RTM_NR_MSGTYPES] = {
Index: net-2.6.19.git/net/ipv4/ipmr.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/ipmr.c
+++ net-2.6.19.git/net/ipv4/ipmr.c
@@ -312,7 +312,7 @@ static void ipmr_destroy_unres(struct mf
 			e = NLMSG_DATA(nlh);
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
-			netlink_unicast(rtnl, skb, NETLINK_CB(skb).dst_pid, MSG_DONTWAIT);
+			rtnl_unicast(skb, NETLINK_CB(skb).dst_pid);
 		} else
 			kfree_skb(skb);
 	}
@@ -525,7 +525,7 @@ static void ipmr_cache_resolve(struct mf
 				e->error = -EMSGSIZE;
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
-			err = netlink_unicast(rtnl, skb, NETLINK_CB(skb).dst_pid, MSG_DONTWAIT);
+			err = rtnl_unicast(skb, NETLINK_CB(skb).dst_pid);
 		} else
 			ip_mr_forward(skb, c, 0);
 	}
Index: net-2.6.19.git/net/ipv4/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/route.c
+++ net-2.6.19.git/net/ipv4/route.c
@@ -2808,9 +2808,7 @@ int inet_rtm_getroute(struct sk_buff *in
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 out:	return err;
 
 out_free:
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -3268,9 +3268,7 @@ static int inet6_rtm_getaddr(struct sk_b
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 out:
 	in6_ifa_put(ifa);
 	return err;
@@ -3294,8 +3292,8 @@ static void inet6_ifa_notify(int event, 
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFADDR, EINVAL);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFADDR;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_IFADDR, GFP_ATOMIC);
+
+	rtnl_multicast(skb, RTNLGRP_IPV6_IFADDR, GFP_ATOMIC);
 }
 
 static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
@@ -3448,8 +3446,8 @@ void inet6_ifinfo_notify(int event, stru
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFINFO, EINVAL);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFINFO;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_IFINFO, GFP_ATOMIC);
+
+	rtnl_multicast(skb, RTNLGRP_IPV6_IFINFO, GFP_ATOMIC);
 }
 
 /* Maximum length of prefix_cacheinfo attributes */
@@ -3513,8 +3511,8 @@ static void inet6_prefix_notify(int even
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_PREFIX, EINVAL);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_PREFIX;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_PREFIX, GFP_ATOMIC);
+
+	rtnl_multicast(skb, RTNLGRP_IPV6_PREFIX, GFP_ATOMIC);
 }
 
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_NR_MSGTYPES] = {
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -2161,9 +2161,7 @@ int inet6_rtm_getroute(struct sk_buff *i
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 out:
 	return err;
 out_free:
@@ -2194,8 +2192,8 @@ void inet6_rt_notify(int event, struct r
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_ROUTE, EINVAL);
 		return;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_ROUTE;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_ROUTE, gfp_any());
+
+	rtnl_multicast(skb, RTNLGRP_IPV6_ROUTE, gfp_any());
 }
 
 /*

