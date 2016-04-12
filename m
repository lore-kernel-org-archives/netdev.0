From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: bridge: add nf_afinfo to enable queuing to userspace
Date: Wed, 13 Apr 2016 01:02:40 +0200
Message-ID: <1460502166-20340-3-git-send-email-pablo@netfilter.org>
References: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36488 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965480AbcDLXDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 19:03:01 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 02582EAA9B
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:02:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E478F1B30B6
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:02:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A674E1B309B
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:02:56 +0200 (CEST)
In-Reply-To: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Bryant <stephane.ml.bryant@gmail.com>

This just adds and registers a nf_afinfo for the ethernet
bridge, which enables queuing to userspace for the AF_BRIDGE
family. No checksum computation is done.

Signed-off-by: Stephane Bryant <stephane.ml.bryant@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c | 47 +++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 7fcdd72..a78c4e2 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -162,15 +162,57 @@ static const struct nf_chain_type filter_bridge = {
 			  (1 << NF_BR_POST_ROUTING),
 };
 
+static void nf_br_saveroute(const struct sk_buff *skb,
+			    struct nf_queue_entry *entry)
+{
+}
+
+static int nf_br_reroute(struct net *net, struct sk_buff *skb,
+			 const struct nf_queue_entry *entry)
+{
+	return 0;
+}
+
+static __sum16 nf_br_checksum(struct sk_buff *skb, unsigned int hook,
+			      unsigned int dataoff, u_int8_t protocol)
+{
+	return 0;
+}
+
+static __sum16 nf_br_checksum_partial(struct sk_buff *skb, unsigned int hook,
+				      unsigned int dataoff, unsigned int len,
+				      u_int8_t protocol)
+{
+	return 0;
+}
+
+static int nf_br_route(struct net *net, struct dst_entry **dst,
+		       struct flowi *fl, bool strict __always_unused)
+{
+	return 0;
+}
+
+static const struct nf_afinfo nf_br_afinfo = {
+	.family                 = AF_BRIDGE,
+	.checksum               = nf_br_checksum,
+	.checksum_partial       = nf_br_checksum_partial,
+	.route                  = nf_br_route,
+	.saveroute              = nf_br_saveroute,
+	.reroute                = nf_br_reroute,
+	.route_key_size         = 0,
+};
+
 static int __init nf_tables_bridge_init(void)
 {
 	int ret;
 
+	nf_register_afinfo(&nf_br_afinfo);
 	nft_register_chain_type(&filter_bridge);
 	ret = register_pernet_subsys(&nf_tables_bridge_net_ops);
-	if (ret < 0)
+	if (ret < 0) {
 		nft_unregister_chain_type(&filter_bridge);
-
+		nf_unregister_afinfo(&nf_br_afinfo);
+	}
 	return ret;
 }
 
@@ -178,6 +220,7 @@ static void __exit nf_tables_bridge_exit(void)
 {
 	unregister_pernet_subsys(&nf_tables_bridge_net_ops);
 	nft_unregister_chain_type(&filter_bridge);
+	nf_unregister_afinfo(&nf_br_afinfo);
 }
 
 module_init(nf_tables_bridge_init);
-- 
2.1.4
