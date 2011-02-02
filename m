From: kaber@trash.net
Subject: [PATCH 25/26] netfilter: ipset: send error message manually
Date: Thu,  3 Feb 2011 00:12:03 +0100
Message-ID: <1296688324-7830-26-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44728 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426Ab1BBXMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:36 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When a message carries multiple commands and one of them triggers
an error, we have to report to the userspace which one was that.
The line number of the command plays this role and there's an attribute
reserved in the header part of the message to be filled out with the error
line number. In order not to modify the original message received from
the userspace, we construct a new, complete netlink error message and
modifies the attribute there, then send it.
Netlink is notified not to send its ACK/error message.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |   33 ++++++++++++++++++++++++++-------
 1 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index ae0f8b5..8b1a54c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1098,7 +1098,7 @@ static const struct nla_policy ip_set_adt_policy[IPSET_ATTR_CMD_MAX + 1] = {
 };
 
 static int
-call_ad(struct sk_buff *skb, struct ip_set *set,
+call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 	struct nlattr *tb[], enum ipset_adt adt,
 	u32 flags, bool use_lineno)
 {
@@ -1118,12 +1118,25 @@ call_ad(struct sk_buff *skb, struct ip_set *set,
 		return 0;
 	if (lineno && use_lineno) {
 		/* Error in restore/batch mode: send back lineno */
-		struct nlmsghdr *nlh = nlmsg_hdr(skb);
+		struct nlmsghdr *rep, *nlh = nlmsg_hdr(skb);
+		struct sk_buff *skb2;
+		struct nlmsgerr *errmsg;
+		size_t payload = sizeof(*errmsg) + nlmsg_len(nlh);
 		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
 		struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
-		struct nlattr *cmdattr = (void *)nlh + min_len;
+		struct nlattr *cmdattr;
 		u32 *errline;
 
+		skb2 = nlmsg_new(payload, GFP_KERNEL);
+		if (skb2 == NULL)
+			return -ENOMEM;
+		rep = __nlmsg_put(skb2, NETLINK_CB(skb).pid,
+				  nlh->nlmsg_seq, NLMSG_ERROR, payload, 0);
+		errmsg = nlmsg_data(rep);
+		errmsg->error = ret;
+		memcpy(&errmsg->msg, nlh, nlh->nlmsg_len);
+		cmdattr = (void *)&errmsg->msg + min_len;
+
 		nla_parse(cda, IPSET_ATTR_CMD_MAX,
 			  cmdattr, nlh->nlmsg_len - min_len,
 			  ip_set_adt_policy);
@@ -1131,6 +1144,10 @@ call_ad(struct sk_buff *skb, struct ip_set *set,
 		errline = nla_data(cda[IPSET_ATTR_LINENO]);
 
 		*errline = lineno;
+
+		netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+		/* Signal netlink not to send its ACK/errmsg.  */
+		return -EINTR;
 	}
 
 	return ret;
@@ -1169,7 +1186,8 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 				     attr[IPSET_ATTR_DATA],
 				     set->type->adt_policy))
 			return -IPSET_ERR_PROTOCOL;
-		ret = call_ad(skb, set, tb, IPSET_ADD, flags, use_lineno);
+		ret = call_ad(ctnl, skb, set, tb, IPSET_ADD, flags,
+			      use_lineno);
 	} else {
 		int nla_rem;
 
@@ -1180,7 +1198,7 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
 					     set->type->adt_policy))
 				return -IPSET_ERR_PROTOCOL;
-			ret = call_ad(skb, set, tb, IPSET_ADD,
+			ret = call_ad(ctnl, skb, set, tb, IPSET_ADD,
 				      flags, use_lineno);
 			if (ret < 0)
 				return ret;
@@ -1222,7 +1240,8 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 				     attr[IPSET_ATTR_DATA],
 				     set->type->adt_policy))
 			return -IPSET_ERR_PROTOCOL;
-		ret = call_ad(skb, set, tb, IPSET_DEL, flags, use_lineno);
+		ret = call_ad(ctnl, skb, set, tb, IPSET_DEL, flags,
+			      use_lineno);
 	} else {
 		int nla_rem;
 
@@ -1233,7 +1252,7 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
 					     set->type->adt_policy))
 				return -IPSET_ERR_PROTOCOL;
-			ret = call_ad(skb, set, tb, IPSET_DEL,
+			ret = call_ad(ctnl, skb, set, tb, IPSET_DEL,
 				      flags, use_lineno);
 			if (ret < 0)
 				return ret;
-- 
1.7.2.3

