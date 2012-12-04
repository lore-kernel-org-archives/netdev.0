From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 6/7] ipmr: advertise new mfc entries via rtnl
Date: Tue,  4 Dec 2012 12:13:40 +0100
Message-ID: <1354619621-16016-7-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56638 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab2LDLNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:51 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to monitor mfc activities via rtnetlink.
To avoid parsing two times the mfc oifs, we use maxvif to allocate the rtnl
msg, thus we may allocate some superfluous space.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 59 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 084dac3..a9454cb 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -134,6 +134,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm);
+static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
+				 int cmd);
 static void mroute_clean_tables(struct mr_table *mrt);
 static void ipmr_expire_process(unsigned long arg);
 
@@ -669,6 +671,7 @@ static void ipmr_expire_process(unsigned long arg)
 		}
 
 		list_del(&c->list);
+		mroute_netlink_event(mrt, c, RTM_DELROUTE);
 		ipmr_destroy_unres(mrt, c);
 	}
 
@@ -1026,6 +1029,7 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 
 		atomic_inc(&mrt->cache_resolve_queue_len);
 		list_add(&c->list, &mrt->mfc_unres_queue);
+		mroute_netlink_event(mrt, c, RTM_NEWROUTE);
 
 		if (atomic_read(&mrt->cache_resolve_queue_len) == 1)
 			mod_timer(&mrt->ipmr_expire_timer, c->mfc_un.unres.expires);
@@ -1060,7 +1064,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			list_del_rcu(&c->list);
-
+			mroute_netlink_event(mrt, c, RTM_DELROUTE);
 			ipmr_cache_free(c);
 			return 0;
 		}
@@ -1095,6 +1099,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
+		mroute_netlink_event(mrt, c, RTM_NEWROUTE);
 		return 0;
 	}
 
@@ -1137,6 +1142,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		ipmr_cache_resolve(net, mrt, uc, c);
 		ipmr_cache_free(uc);
 	}
+	mroute_netlink_event(mrt, c, RTM_NEWROUTE);
 	return 0;
 }
 
@@ -1165,6 +1171,7 @@ static void mroute_clean_tables(struct mr_table *mrt)
 			if (c->mfc_flags & MFC_STATIC)
 				continue;
 			list_del_rcu(&c->list);
+			mroute_netlink_event(mrt, c, RTM_DELROUTE);
 			ipmr_cache_free(c);
 		}
 	}
@@ -1173,6 +1180,7 @@ static void mroute_clean_tables(struct mr_table *mrt)
 		spin_lock_bh(&mfc_unres_lock);
 		list_for_each_entry_safe(c, next, &mrt->mfc_unres_queue, list) {
 			list_del(&c->list);
+			mroute_netlink_event(mrt, c, RTM_DELROUTE);
 			ipmr_destroy_unres(mrt, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
@@ -2150,13 +2158,13 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 }
 
 static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
-			    u32 portid, u32 seq, struct mfc_cache *c)
+			    u32 portid, u32 seq, struct mfc_cache *c, int cmd)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 	int err;
 
-	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2191,6 +2199,52 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static size_t mroute_msgsize(bool unresolved, int maxvif)
+{
+	size_t len =
+		NLMSG_ALIGN(sizeof(struct rtmsg))
+		+ nla_total_size(4)	/* RTA_TABLE */
+		+ nla_total_size(4)	/* RTA_SRC */
+		+ nla_total_size(4)	/* RTA_DST */
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
+static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
+				 int cmd)
+{
+	struct net *net = read_pnet(&mrt->net);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(mroute_msgsize(mfc->mfc_parent >= MAXVIFS, mrt->maxvif),
+			GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = ipmr_fill_mroute(mrt, skb, 0, 0, mfc, cmd);
+	if (err < 0)
+		goto errout;
+
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_MROUTE, NULL, GFP_ATOMIC);
+	return;
+
+errout:
+	kfree_skb(skb);
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE, err);
+}
+
 static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2217,7 +2271,7 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (ipmr_fill_mroute(mrt, skb,
 						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
-						     mfc) < 0)
+						     mfc, RTM_NEWROUTE) < 0)
 					goto done;
 next_entry:
 				e++;
@@ -2231,7 +2285,7 @@ next_entry:
 			if (ipmr_fill_mroute(mrt, skb,
 					     NETLINK_CB(cb->skb).portid,
 					     cb->nlh->nlmsg_seq,
-					     mfc) < 0) {
+					     mfc, RTM_NEWROUTE) < 0) {
 				spin_unlock_bh(&mfc_unres_lock);
 				goto done;
 			}
-- 
1.8.0.1
