From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 3/5] l2tp: hold tunnel while handling genl tunnel updates
Date: Fri, 25 Aug 2017 16:51:42 +0200
Message-ID: <a24249adef0fe79cf7405fa84d798e67b642c8a9.1503671776.git.g.nault@alphalink.fr>
References: <cover.1503671776.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53425 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757282AbdHYOvu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:51:50 -0400
Content-Disposition: inline
In-Reply-To: <cover.1503671776.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to make sure the tunnel is not going to be destroyed by
l2tp_tunnel_destruct() concurrently.

Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_netlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 808966550620..d61e75b4e619 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -303,8 +303,8 @@ static int l2tp_nl_cmd_tunnel_modify(struct sk_buff *skb, struct genl_info *info
 	}
 	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
 
-	tunnel = l2tp_tunnel_find(net, tunnel_id);
-	if (tunnel == NULL) {
+	tunnel = l2tp_tunnel_get(net, tunnel_id);
+	if (!tunnel) {
 		ret = -ENODEV;
 		goto out;
 	}
@@ -315,6 +315,8 @@ static int l2tp_nl_cmd_tunnel_modify(struct sk_buff *skb, struct genl_info *info
 	ret = l2tp_tunnel_notify(&l2tp_nl_family, info,
 				 tunnel, L2TP_CMD_TUNNEL_MODIFY);
 
+	l2tp_tunnel_dec_refcount(tunnel);
+
 out:
 	return ret;
 }
-- 
2.14.1
