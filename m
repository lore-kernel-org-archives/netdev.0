From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 28/84] ipvs: Pass ipvs not net to __ip_vs_get_timeouts
Date: Mon, 21 Sep 2015 13:02:05 -0500
Message-ID: <1442858581-15869-28-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47025 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756853AbbIUSOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:14:11 -0400
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6c06e9a8414d..e509c27f7292 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2584,10 +2584,9 @@ __ip_vs_get_dest_entries(struct netns_ipvs *ipvs, const struct ip_vs_get_dests *
 }
 
 static inline void
-__ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
+__ip_vs_get_timeouts(struct netns_ipvs *ipvs, struct ip_vs_timeout_user *u)
 {
 #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 #endif
 
@@ -2768,7 +2767,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(net, &t);
+		__ip_vs_get_timeouts(ipvs, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
 	}
@@ -3461,7 +3460,7 @@ static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_timeout_user t;
 
-	__ip_vs_get_timeouts(net, &t);
+	__ip_vs_get_timeouts(ipvs, &t);
 
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_TCP])
 		t.tcp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_TCP]);
@@ -3637,8 +3636,10 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	void *reply;
 	int ret, cmd, reply_cmd;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
+	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_GET_SERVICE)
@@ -3688,7 +3689,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(net, &t);
+		__ip_vs_get_timeouts(ipvs, &t);
 #ifdef CONFIG_IP_VS_PROTO_TCP
 		if (nla_put_u32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP,
 				t.tcp_timeout) ||
-- 
2.2.1
