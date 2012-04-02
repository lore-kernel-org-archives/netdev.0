From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 08/51] genetlink: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:58 -0400
Message-ID: <1333335521-1348-9-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2DBC7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:16 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netlink/genetlink.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 9f40441..8340ace 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -635,11 +635,12 @@ static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 	if (hdr == NULL)
 		return -1;
 
-	NLA_PUT_STRING(skb, CTRL_ATTR_FAMILY_NAME, family->name);
-	NLA_PUT_U16(skb, CTRL_ATTR_FAMILY_ID, family->id);
-	NLA_PUT_U32(skb, CTRL_ATTR_VERSION, family->version);
-	NLA_PUT_U32(skb, CTRL_ATTR_HDRSIZE, family->hdrsize);
-	NLA_PUT_U32(skb, CTRL_ATTR_MAXATTR, family->maxattr);
+	if (nla_put_string(skb, CTRL_ATTR_FAMILY_NAME, family->name) ||
+	    nla_put_u16(skb, CTRL_ATTR_FAMILY_ID, family->id) ||
+	    nla_put_u32(skb, CTRL_ATTR_VERSION, family->version) ||
+	    nla_put_u32(skb, CTRL_ATTR_HDRSIZE, family->hdrsize) ||
+	    nla_put_u32(skb, CTRL_ATTR_MAXATTR, family->maxattr))
+		goto nla_put_failure;
 
 	if (!list_empty(&family->ops_list)) {
 		struct nlattr *nla_ops;
@@ -657,8 +658,9 @@ static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			if (nest == NULL)
 				goto nla_put_failure;
 
-			NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
-			NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
+			if (nla_put_u32(skb, CTRL_ATTR_OP_ID, ops->cmd) ||
+			    nla_put_u32(skb, CTRL_ATTR_OP_FLAGS, ops->flags))
+				goto nla_put_failure;
 
 			nla_nest_end(skb, nest);
 		}
@@ -682,9 +684,10 @@ static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			if (nest == NULL)
 				goto nla_put_failure;
 
-			NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
-			NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
-				       grp->name);
+			if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id) ||
+			    nla_put_string(skb, CTRL_ATTR_MCAST_GRP_NAME,
+					   grp->name))
+				goto nla_put_failure;
 
 			nla_nest_end(skb, nest);
 		}
@@ -710,8 +713,9 @@ static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
 	if (hdr == NULL)
 		return -1;
 
-	NLA_PUT_STRING(skb, CTRL_ATTR_FAMILY_NAME, grp->family->name);
-	NLA_PUT_U16(skb, CTRL_ATTR_FAMILY_ID, grp->family->id);
+	if (nla_put_string(skb, CTRL_ATTR_FAMILY_NAME, grp->family->name) ||
+	    nla_put_u16(skb, CTRL_ATTR_FAMILY_ID, grp->family->id))
+		goto nla_put_failure;
 
 	nla_grps = nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
 	if (nla_grps == NULL)
@@ -721,9 +725,10 @@ static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id);
-	NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME,
-		       grp->name);
+	if (nla_put_u32(skb, CTRL_ATTR_MCAST_GRP_ID, grp->id) ||
+	    nla_put_string(skb, CTRL_ATTR_MCAST_GRP_NAME,
+			   grp->name))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	nla_nest_end(skb, nla_grps);
-- 
1.7.7.6
