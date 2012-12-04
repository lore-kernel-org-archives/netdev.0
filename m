From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 7/7] ip6mr: advertise new mfc entries via rtnl
Date: Tue,  4 Dec 2012 12:13:41 +0100
Message-ID: <1354619621-16016-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56637 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab2LDLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:50 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to monitor mf6c activities via rtnetlink.
To avoid parsing two times the mf6c oifs, we use maxvif to allocate the rtnl
msg, thus we may allocate some superfluous space.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6mr.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 59 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 175270f..26dcdec 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -116,6 +116,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 			      mifi_t mifi, int assert);
 static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			       struct mfc6_cache *c, struct rtmsg *rtm);
+static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
+			      int cmd);
 static int ip6mr_rtm_dumproute(struct sk_buff *skb,
 			       struct netlink_callback *cb);
 static void mroute_clean_tables(struct mr6_table *mrt);
@@ -870,6 +872,7 @@ static void ipmr_do_expire_process(struct mr6_table *mrt)
 		}
 
 		list_del(&c->list);
+		mr6_netlink_event(mrt, c, RTM_DELROUTE);
 		ip6mr_destroy_unres(mrt, c);
 	}
 
@@ -1220,6 +1223,7 @@ ip6mr_cache_unresolved(struct mr6_table *mrt, mifi_t mifi, struct sk_buff *skb)
 
 		atomic_inc(&mrt->cache_resolve_queue_len);
 		list_add(&c->list, &mrt->mfc6_unres_queue);
+		mr6_netlink_event(mrt, c, RTM_NEWROUTE);
 
 		ipmr_do_expire_process(mrt);
 	}
@@ -1257,6 +1261,7 @@ static int ip6mr_mfc_delete(struct mr6_table *mrt, struct mf6cctl *mfc)
 			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
+			mr6_netlink_event(mrt, c, RTM_DELROUTE);
 			ip6mr_cache_free(c);
 			return 0;
 		}
@@ -1421,6 +1426,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
+		mr6_netlink_event(mrt, c, RTM_NEWROUTE);
 		return 0;
 	}
 
@@ -1465,6 +1471,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 		ip6mr_cache_resolve(net, mrt, uc, c);
 		ip6mr_cache_free(uc);
 	}
+	mr6_netlink_event(mrt, c, RTM_NEWROUTE);
 	return 0;
 }
 
@@ -1498,6 +1505,7 @@ static void mroute_clean_tables(struct mr6_table *mrt)
 			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
+			mr6_netlink_event(mrt, c, RTM_DELROUTE);
 			ip6mr_cache_free(c);
 		}
 	}
@@ -1506,6 +1514,7 @@ static void mroute_clean_tables(struct mr6_table *mrt)
 		spin_lock_bh(&mfc_unres_lock);
 		list_for_each_entry_safe(c, next, &mrt->mfc6_unres_queue, list) {
 			list_del(&c->list);
+			mr6_netlink_event(mrt, c, RTM_DELROUTE);
 			ip6mr_destroy_unres(mrt, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
@@ -2231,13 +2240,13 @@ int ip6mr_get_route(struct net *net,
 }
 
 static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
-			     u32 portid, u32 seq, struct mfc6_cache *c)
+			     u32 portid, u32 seq, struct mfc6_cache *c, int cmd)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 	int err;
 
-	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2272,6 +2281,52 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int mr6_msgsize(bool unresolved, int maxvif)
+{
+	size_t len =
+		NLMSG_ALIGN(sizeof(struct rtmsg))
+		+ nla_total_size(4)	/* RTA_TABLE */
+		+ nla_total_size(sizeof(struct in6_addr))	/* RTA_SRC */
+		+ nla_total_size(sizeof(struct in6_addr))	/* RTA_DST */
+		;
+
+	if (!unresolved)
+		len = len
+		      + nla_total_size(4)	/* RTA_IIF */
+		      + nla_total_size(0)	/* RTA_MULTIPATH */
+		      + maxvif * NLA_ALIGN(sizeof(struct rtnexthop))
+						/* RTA_MFC_STATS */
+		      + nla_total_size(sizeof(struct rta_mfc_stats))
+		;
+
+	return len;
+}
+
+static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
+			      int cmd)
+{
+	struct net *net = read_pnet(&mrt->net);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(mr6_msgsize(mfc->mf6c_parent >= MAXMIFS, mrt->maxvif),
+			GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = ip6mr_fill_mroute(mrt, skb, 0, 0, mfc, cmd);
+	if (err < 0)
+		goto errout;
+
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_MROUTE, NULL, GFP_ATOMIC);
+	return;
+
+errout:
+	kfree_skb(skb);
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_MROUTE, err);
+}
+
 static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2298,7 +2353,7 @@ static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (ip6mr_fill_mroute(mrt, skb,
 						      NETLINK_CB(cb->skb).portid,
 						      cb->nlh->nlmsg_seq,
-						      mfc) < 0)
+						      mfc, RTM_NEWROUTE) < 0)
 					goto done;
 next_entry:
 				e++;
@@ -2312,7 +2367,7 @@ next_entry:
 			if (ip6mr_fill_mroute(mrt, skb,
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
-					      mfc) < 0) {
+					      mfc, RTM_NEWROUTE) < 0) {
 				spin_unlock_bh(&mfc_unres_lock);
 				goto done;
 			}
-- 
1.8.0.1
