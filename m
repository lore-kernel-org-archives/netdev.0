From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 3/3] tipc: remove wrong use of NLM_F_MULTI
Date: Tue, 28 Apr 2015 18:33:50 +0200
Message-ID: <1430238831-29966-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyaginuug.ch@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35210 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030297AbbD1QeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 12:34:11 -0400
In-Reply-To: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NLM_F_MULTI must be used only when a NLMSG_DONE message is sent. In fact,
it is sent only at the end of a dump.

Libraries like libnl will wait forever for NLMSG_DONE.

Fixes: 35b9dd7607f0 ("tipc: add bearer get/dump to new netlink api")
Fixes: 7be57fc69184 ("tipc: add link get/dump to new netlink api")
Fixes: 46f15c6794fb ("tipc: add media get/dump to new netlink api")
CC: Richard Alpe <richard.alpe@ericsson.com>
CC: Jon Maloy <jon.maloy@ericsson.com>
CC: Ying Xue <ying.xue@windriver.com>
CC: tipc-discussion@lists.sourceforge.net
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/tipc/bearer.c | 17 +++++++++--------
 net/tipc/link.c   |  8 ++++----
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 3613e72e858e..70e3dacbf84a 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -591,14 +591,14 @@ void tipc_bearer_stop(struct net *net)
 
 /* Caller should hold rtnl_lock to protect the bearer */
 static int __tipc_nl_add_bearer(struct tipc_nl_msg *msg,
-				struct tipc_bearer *bearer)
+				struct tipc_bearer *bearer, int nlflags)
 {
 	void *hdr;
 	struct nlattr *attrs;
 	struct nlattr *prop;
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
-			  NLM_F_MULTI, TIPC_NL_BEARER_GET);
+			  nlflags, TIPC_NL_BEARER_GET);
 	if (!hdr)
 		return -EMSGSIZE;
 
@@ -657,7 +657,7 @@ int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (!bearer)
 			continue;
 
-		err = __tipc_nl_add_bearer(&msg, bearer);
+		err = __tipc_nl_add_bearer(&msg, bearer, NLM_F_MULTI);
 		if (err)
 			break;
 	}
@@ -705,7 +705,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	}
 
-	err = __tipc_nl_add_bearer(&msg, bearer);
+	err = __tipc_nl_add_bearer(&msg, bearer, 0);
 	if (err)
 		goto err_out;
 	rtnl_unlock();
@@ -857,14 +857,14 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 }
 
 static int __tipc_nl_add_media(struct tipc_nl_msg *msg,
-			       struct tipc_media *media)
+			       struct tipc_media *media, int nlflags)
 {
 	void *hdr;
 	struct nlattr *attrs;
 	struct nlattr *prop;
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
-			  NLM_F_MULTI, TIPC_NL_MEDIA_GET);
+			  nlflags, TIPC_NL_MEDIA_GET);
 	if (!hdr)
 		return -EMSGSIZE;
 
@@ -916,7 +916,8 @@ int tipc_nl_media_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rtnl_lock();
 	for (; media_info_array[i] != NULL; i++) {
-		err = __tipc_nl_add_media(&msg, media_info_array[i]);
+		err = __tipc_nl_add_media(&msg, media_info_array[i],
+					  NLM_F_MULTI);
 		if (err)
 			break;
 	}
@@ -963,7 +964,7 @@ int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	}
 
-	err = __tipc_nl_add_media(&msg, media);
+	err = __tipc_nl_add_media(&msg, media, 0);
 	if (err)
 		goto err_out;
 	rtnl_unlock();
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 57be6e6aff99..a11cc5e5e0ae 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2013,7 +2013,7 @@ msg_full:
 
 /* Caller should hold appropriate locks to protect the link */
 static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
-			      struct tipc_link *link)
+			      struct tipc_link *link, int nlflags)
 {
 	int err;
 	void *hdr;
@@ -2022,7 +2022,7 @@ static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
-			  NLM_F_MULTI, TIPC_NL_LINK_GET);
+			  nlflags, TIPC_NL_LINK_GET);
 	if (!hdr)
 		return -EMSGSIZE;
 
@@ -2095,7 +2095,7 @@ static int __tipc_nl_add_node_links(struct net *net, struct tipc_nl_msg *msg,
 		if (!node->links[i])
 			continue;
 
-		err = __tipc_nl_add_link(net, msg, node->links[i]);
+		err = __tipc_nl_add_link(net, msg, node->links[i], NLM_F_MULTI);
 		if (err)
 			return err;
 	}
@@ -2209,7 +2209,7 @@ int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	}
 
-	err = __tipc_nl_add_link(net, &msg, link);
+	err = __tipc_nl_add_link(net, &msg, link, 0);
 	if (err)
 		goto err_out;
 
-- 
2.2.2
