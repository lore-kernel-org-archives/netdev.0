From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 4/5] l2tp: hold tunnel while handling genl TUNNEL_GET
 commands
Date: Fri, 25 Aug 2017 16:51:43 +0200
Message-ID: <d5389d773e368a52ece886e43e355967c2af8fdf.1503671776.git.g.nault@alphalink.fr>
References: <cover.1503671776.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53428 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755006AbdHYOvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:51:51 -0400
Content-Disposition: inline
In-Reply-To: <cover.1503671776.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use l2tp_tunnel_get() instead of l2tp_tunnel_find() so that we get
a reference on the tunnel, preventing l2tp_tunnel_destruct() from
freeing it from under us.

Also move l2tp_tunnel_get() below nlmsg_new() so that we only take
the reference when needed.

Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_netlink.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index d61e75b4e619..ae5170e26281 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -444,34 +444,37 @@ static int l2tp_nl_cmd_tunnel_get(struct sk_buff *skb, struct genl_info *info)
 
 	if (!info->attrs[L2TP_ATTR_CONN_ID]) {
 		ret = -EINVAL;
-		goto out;
+		goto err;
 	}
 
 	tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
 
-	tunnel = l2tp_tunnel_find(net, tunnel_id);
-	if (tunnel == NULL) {
-		ret = -ENODEV;
-		goto out;
-	}
-
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		ret = -ENOMEM;
-		goto out;
+		goto err;
+	}
+
+	tunnel = l2tp_tunnel_get(net, tunnel_id);
+	if (!tunnel) {
+		ret = -ENODEV;
+		goto err_nlmsg;
 	}
 
 	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
 				  NLM_F_ACK, tunnel, L2TP_CMD_TUNNEL_GET);
 	if (ret < 0)
-		goto err_out;
+		goto err_nlmsg_tunnel;
+
+	l2tp_tunnel_dec_refcount(tunnel);
 
 	return genlmsg_unicast(net, msg, info->snd_portid);
 
-err_out:
+err_nlmsg_tunnel:
+	l2tp_tunnel_dec_refcount(tunnel);
+err_nlmsg:
 	nlmsg_free(msg);
-
-out:
+err:
 	return ret;
 }
 
-- 
2.14.1
