From: kaber@trash.net
Subject: [PATCH 57/79] netfilter: xt_conntrack: support matching on port ranges
Date: Wed, 19 Jan 2011 20:14:57 +0100
Message-ID: <1295464519-21763-58-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab1ASTPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:39 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add a new revision 3 that contains port ranges for all of origsrc,
origdst, replsrc and repldst. The high ports are appended to the
original v2 data structure to allow sharing most of the code with
v1 and v2. Use of the revision specific port matching function is
made dependant on par->match->revision.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_conntrack.h |   15 ++++++
 net/netfilter/xt_conntrack.c           |   75 +++++++++++++++++++++++++++++++-
 2 files changed, 88 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilter/xt_conntrack.h
index 54f47a2..74b904d 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -58,4 +58,19 @@ struct xt_conntrack_mtinfo2 {
 	__u16 state_mask, status_mask;
 };
 
+struct xt_conntrack_mtinfo3 {
+	union nf_inet_addr origsrc_addr, origsrc_mask;
+	union nf_inet_addr origdst_addr, origdst_mask;
+	union nf_inet_addr replsrc_addr, replsrc_mask;
+	union nf_inet_addr repldst_addr, repldst_mask;
+	__u32 expires_min, expires_max;
+	__u16 l4proto;
+	__u16 origsrc_port, origdst_port;
+	__u16 replsrc_port, repldst_port;
+	__u16 match_flags, invert_flags;
+	__u16 state_mask, status_mask;
+	__u16 origsrc_port_high, origdst_port_high;
+	__u16 replsrc_port_high, repldst_port_high;
+};
+
 #endif /*_XT_CONNTRACK_H*/
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index e536710..4ef1b63 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -112,6 +112,54 @@ ct_proto_port_check(const struct xt_conntrack_mtinfo2 *info,
 	return true;
 }
 
+static inline bool
+port_match(u16 min, u16 max, u16 port, bool invert)
+{
+	return (port >= min && port <= max) ^ invert;
+}
+
+static inline bool
+ct_proto_port_check_v3(const struct xt_conntrack_mtinfo3 *info,
+		       const struct nf_conn *ct)
+{
+	const struct nf_conntrack_tuple *tuple;
+
+	tuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	if ((info->match_flags & XT_CONNTRACK_PROTO) &&
+	    (nf_ct_protonum(ct) == info->l4proto) ^
+	    !(info->invert_flags & XT_CONNTRACK_PROTO))
+		return false;
+
+	/* Shortcut to match all recognized protocols by using ->src.all. */
+	if ((info->match_flags & XT_CONNTRACK_ORIGSRC_PORT) &&
+	    !port_match(info->origsrc_port, info->origsrc_port_high,
+			ntohs(tuple->src.u.all),
+			info->invert_flags & XT_CONNTRACK_ORIGSRC_PORT))
+		return false;
+
+	if ((info->match_flags & XT_CONNTRACK_ORIGDST_PORT) &&
+	    !port_match(info->origdst_port, info->origdst_port_high,
+			ntohs(tuple->dst.u.all),
+			info->invert_flags & XT_CONNTRACK_ORIGDST_PORT))
+		return false;
+
+	tuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+
+	if ((info->match_flags & XT_CONNTRACK_REPLSRC_PORT) &&
+	    !port_match(info->replsrc_port, info->replsrc_port_high,
+			ntohs(tuple->src.u.all),
+			info->invert_flags & XT_CONNTRACK_REPLSRC_PORT))
+		return false;
+
+	if ((info->match_flags & XT_CONNTRACK_REPLDST_PORT) &&
+	    !port_match(info->repldst_port, info->repldst_port_high,
+			ntohs(tuple->dst.u.all),
+			info->invert_flags & XT_CONNTRACK_REPLDST_PORT))
+		return false;
+
+	return true;
+}
+
 static bool
 conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
              u16 state_mask, u16 status_mask)
@@ -170,8 +218,13 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 		    !(info->invert_flags & XT_CONNTRACK_REPLDST))
 			return false;
 
-	if (!ct_proto_port_check(info, ct))
-		return false;
+	if (par->match->revision != 3) {
+		if (!ct_proto_port_check(info, ct))
+			return false;
+	} else {
+		if (!ct_proto_port_check_v3(par->matchinfo, ct))
+			return false;
+	}
 
 	if ((info->match_flags & XT_CONNTRACK_STATUS) &&
 	    (!!(status_mask & ct->status) ^
@@ -207,6 +260,14 @@ conntrack_mt_v2(const struct sk_buff *skb, struct xt_action_param *par)
 	return conntrack_mt(skb, par, info->state_mask, info->status_mask);
 }
 
+static bool
+conntrack_mt_v3(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_conntrack_mtinfo3 *info = par->matchinfo;
+
+	return conntrack_mt(skb, par, info->state_mask, info->status_mask);
+}
+
 static int conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	int ret;
@@ -244,6 +305,16 @@ static struct xt_match conntrack_mt_reg[] __read_mostly = {
 		.destroy    = conntrack_mt_destroy,
 		.me         = THIS_MODULE,
 	},
+	{
+		.name       = "conntrack",
+		.revision   = 3,
+		.family     = NFPROTO_UNSPEC,
+		.matchsize  = sizeof(struct xt_conntrack_mtinfo3),
+		.match      = conntrack_mt_v3,
+		.checkentry = conntrack_mt_check,
+		.destroy    = conntrack_mt_destroy,
+		.me         = THIS_MODULE,
+	},
 };
 
 static int __init conntrack_mt_init(void)
-- 
1.7.2.3

