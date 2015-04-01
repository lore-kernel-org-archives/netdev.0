From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/4] netns: allow to dump netns ids
Date: Wed,  1 Apr 2015 14:49:49 +0200
Message-ID: <1427892589-4266-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55543 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbbDAMuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:50:08 -0400
In-Reply-To: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Which this patch, it's possible to dump the list of ids allocated for peer
netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 48 insertions(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index bfe44c328ec2..19630538c16d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -620,6 +620,52 @@ out:
 	return err;
 }
 
+struct rtnl_net_dump_cb {
+	struct net *net;
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	int idx;
+	int s_idx;
+};
+
+static int rtnl_net_dumpid_one(int id, void *peer, void *data)
+{
+	struct rtnl_net_dump_cb *net_cb = (struct rtnl_net_dump_cb *)data;
+	int ret;
+
+	if (net_cb->idx < net_cb->s_idx)
+		goto cont;
+
+	ret = rtnl_net_fill(net_cb->skb, NETLINK_CB(net_cb->cb->skb).portid,
+			    net_cb->cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			    RTM_NEWNSID, net_cb->net, peer, id);
+	if (ret < 0)
+		return ret;
+
+cont:
+	net_cb->idx++;
+	return 0;
+}
+
+static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct rtnl_net_dump_cb net_cb = {
+		.net = net,
+		.skb = skb,
+		.cb = cb,
+		.idx = 0,
+		.s_idx = cb->args[0],
+	};
+
+	ASSERT_RTNL();
+
+	idr_for_each(&net->netns_ids, rtnl_net_dumpid_one, &net_cb);
+
+	cb->args[0] = net_cb.idx;
+	return skb->len;
+}
+
 static void rtnl_net_notifyid(struct net *net, struct net *peer, int cmd,
 			      int id)
 {
@@ -677,7 +723,8 @@ static int __init net_ns_init(void)
 	register_pernet_subsys(&net_ns_ops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
+		      NULL);
 
 	return 0;
 }
-- 
2.2.2
