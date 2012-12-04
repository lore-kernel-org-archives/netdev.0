From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/7] ipmr/ip6mr: advertise mfc stats via rtnetlink
Date: Tue,  4 Dec 2012 12:13:37 +0100
Message-ID: <1354619621-16016-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56627 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab2LDLNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:49 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These statistics can be checked only via /proc/net/ip_mr_cache or
SIOCGETSGCNT[_IN6] and thus only for the table RT_TABLE_DEFAULT.
Advertising them via rtnetlink allows to get statistics for all cache entries,
whatever the table is.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h | 7 +++++++
 net/ipv4/ipmr.c                | 7 +++++++
 net/ipv6/ip6mr.c               | 7 +++++++
 3 files changed, 21 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 3dee071..80abe27 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -288,6 +288,7 @@ enum rtattr_type_t {
 	RTA_MP_ALGO, /* no longer used */
 	RTA_TABLE,
 	RTA_MARK,
+	RTA_MFC_STATS,
 	__RTA_MAX
 };
 
@@ -408,6 +409,12 @@ struct rta_session {
 	} u;
 };
 
+struct rta_mfc_stats {
+	__u64	mfcs_packets;
+	__u64	mfcs_bytes;
+	__u64	mfcs_wrong_if;
+};
+
 /****
  *		General form of address family dependent message.
  ****/
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0c452e3..c5617d6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2046,6 +2046,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	int ct;
 	struct rtnexthop *nhp;
 	struct nlattr *mp_attr;
+	struct rta_mfc_stats mfcs;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mfc_parent >= MAXVIFS)
@@ -2074,6 +2075,12 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 
 	nla_nest_end(skb, mp_attr);
 
+	mfcs.mfcs_packets = c->mfc_un.res.pkt;
+	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
+	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
+	if (nla_put(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs) < 0)
+		return -EMSGSIZE;
+
 	rtm->rtm_type = RTN_MULTICAST;
 	return 1;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 653df91..b744b98 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2120,6 +2120,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	int ct;
 	struct rtnexthop *nhp;
 	struct nlattr *mp_attr;
+	struct rta_mfc_stats mfcs;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mf6c_parent >= MAXMIFS)
@@ -2149,6 +2150,12 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 
 	nla_nest_end(skb, mp_attr);
 
+	mfcs.mfcs_packets = c->mfc_un.res.pkt;
+	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
+	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
+	if (nla_put(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs) < 0)
+		return -EMSGSIZE;
+
 	rtm->rtm_type = RTN_MULTICAST;
 	return 1;
 }
-- 
1.8.0.1
