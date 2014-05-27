From: roopa@cumulusnetworks.com
Subject: [RFC PATCH] Add bridge ifindex to bridge fdb notify msgs
Date: Mon, 26 May 2014 21:39:46 -0700
Message-ID: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35979 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaE0Ejk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 00:39:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds NDA_MASTER attribute to neighbour attributes enum for
bridge/master ifindex. And adds NDA_MASTER to bridge fdb notify msgs.

Today bridge fdb notifications dont contain bridge information.
Userspace can derive it from the port information in the fdb
notification. However this is tricky in some scenarious.

Example, bridge port delete notification comes before bridge fdb
delete notifications. And we have seen problems in userspace
when using libnl where, the bridge fdb delete notification handling code
does not understand which bridge this fdb entry is part of because
the bridge and port association has already been deleted.
And these notifications (port membership and fdb) are generated on
separate rtnl groups.

Fixing the order of notifications could possibly solve the problem
for some cases (I can submit a separate patch for that).

This patch chooses to add NDA_MASTER to bridge fdb notify msgs
because it not only solves the problem described above, but also helps
userspace avoid another lookup into link msgs to derive the master index.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/neighbour.h |    1 +
 net/bridge/br_fdb.c            |    3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index d3ef583..4a1d7e9 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -24,6 +24,7 @@ enum {
 	NDA_PORT,
 	NDA_VNI,
 	NDA_IFINDEX,
+	NDA_MASTER,
 	__NDA_MAX
 };
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..019bb93 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -565,6 +565,8 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
 		goto nla_put_failure;
+	if (nla_put_u32(skb, NDA_MASTER, br->dev->ifindex))
+		goto nla_put_failure;
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
 	ci.ndm_confirmed = 0;
 	ci.ndm_updated	 = jiffies_to_clock_t(now - fdb->updated);
@@ -586,6 +588,7 @@ static inline size_t fdb_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
+		+ nla_total_size(sizeof(u32)) /* NDA_MASTER */
 		+ nla_total_size(sizeof(u16)) /* NDA_VLAN */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
-- 
1.7.10.4
