From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/50] netfilter: conntrack: remove unused init_net hook
Date: Wed,  7 Dec 2016 22:52:19 +0100
Message-ID: <1481147576-5690-14-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933070AbcLGVxg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:36 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0D5EBC2B08
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:30 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EE850DA861
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CBCFFDA860
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:27 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

since adf0516845bcd0 ("netfilter: remove ip_conntrack* sysctl compat code")
the only user (ipv4 tracker) sets this to an empty stub function.

After this change nf_ct_l3proto_pernet_register() is also empty,
but this will change in a followup patch to add conditional register
of the hooks.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h   | 3 ---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 6 ------
 net/netfilter/nf_conntrack_proto.c             | 8 --------
 3 files changed, 17 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 8992e4229da9..cf8f3dfd810d 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -63,9 +63,6 @@ struct nf_conntrack_l3proto {
 
 	size_t nla_size;
 
-	/* Init l3proto pernet data */
-	int (*init_net)(struct net *net);
-
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 22fce4fcece4..a006b6534323 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -307,11 +307,6 @@ static struct nf_sockopt_ops so_getorigdst = {
 	.owner		= THIS_MODULE,
 };
 
-static int ipv4_init_net(struct net *net)
-{
-	return 0;
-}
-
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.l3proto	 = PF_INET,
 	.name		 = "ipv4",
@@ -325,7 +320,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
-	.init_net	 = ipv4_init_net,
 	.me		 = THIS_MODULE,
 };
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 9bd34647225a..b218e70b2f74 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -193,14 +193,6 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 int nf_ct_l3proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l3proto *proto)
 {
-	int ret;
-
-	if (proto->init_net) {
-		ret = proto->init_net(net);
-		if (ret < 0)
-			return ret;
-	}
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
-- 
2.1.4
