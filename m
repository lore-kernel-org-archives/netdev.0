From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 16/16] tipc: make netlink support net namespace
Date: Fri, 9 Jan 2015 15:27:13 +0800
Message-ID: <1420788433-17960-17-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64505 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037AbbAIH2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:28:25 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tipc module only allows users sitting on "init_net" namespace
to configure it through netlink interface. But now almost each tipc
component is able to be aware of net namespace, so it's time to open
the permission for users residing in other namespaces, allowing them
to configure their own tipc stack instance through netlink interface.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/netlink.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 282b596..fe0f513 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -54,7 +54,8 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
 	u16 cmd;
 
-	if ((req_userhdr->cmd & 0xC000) && (!netlink_capable(skb, CAP_NET_ADMIN)))
+	if ((req_userhdr->cmd & 0xC000) &&
+	    (!netlink_net_capable(skb, CAP_NET_ADMIN)))
 		cmd = TIPC_CMD_NOT_NET_ADMIN;
 	else
 		cmd = req_userhdr->cmd;
@@ -70,7 +71,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).portid);
+		genlmsg_unicast(net, rep_buf, NETLINK_CB(skb).portid);
 	}
 
 	return 0;
@@ -95,6 +96,7 @@ static struct genl_family tipc_genl_family = {
 	.version	= TIPC_GENL_VERSION,
 	.hdrsize	= TIPC_GENL_HDRLEN,
 	.maxattr	= 0,
+	.netnsok	= true,
 };
 
 /* Legacy ASCII API */
@@ -114,6 +116,7 @@ struct genl_family tipc_genl_v2_family = {
 	.version	= TIPC_GENL_V2_VERSION,
 	.hdrsize	= 0,
 	.maxattr	= TIPC_NLA_MAX,
+	.netnsok	= true,
 };
 
 static const struct genl_ops tipc_genl_v2_ops[] = {
-- 
1.7.9.5
