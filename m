From: pablo@netfilter.org
Subject: [PATCH 2/3] netfilter: nf_conntrack: fix BUG_ON while removing nf_conntrack with netns
Date: Tue, 15 Jan 2013 00:24:04 +0100
Message-ID: <1358205845-8522-3-git-send-email-pablo@netfilter.org>
References: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38555 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757944Ab3ANXYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 18:24:18 -0500
In-Reply-To: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

canqun zhang reported that we're hitting BUG_ON in the
nf_conntrack_destroy path when calling kfree_skb while
rmmod'ing the nf_conntrack module.

Currently, the nf_ct_destroy hook is being set to NULL in the
destroy path of conntrack.init_net. However, this is a problem
since init_net may be destroyed before any other existing netns
(we cannot assume any specific ordering while releasing existing
netns according to what I read in recent emails).

Thanks to Gao feng for initial patch to address this issue.

Reported-by: canqun zhang <canqunzhang@gmail.com>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    2 ++
 net/netfilter/nf_conntrack_core.c         |    9 +++++----
 net/netfilter/nf_conntrack_standalone.c   |    1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index d8f5b9f..e98aeb3 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -31,6 +31,8 @@ extern void nf_conntrack_cleanup(struct net *net);
 extern int nf_conntrack_proto_init(struct net *net);
 extern void nf_conntrack_proto_fini(struct net *net);
 
+extern void nf_conntrack_cleanup_end(void);
+
 extern bool
 nf_ct_get_tuple(const struct sk_buff *skb,
 		unsigned int nhoff,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 016d95e..e4a0c4f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1376,11 +1376,12 @@ void nf_conntrack_cleanup(struct net *net)
 	synchronize_net();
 	nf_conntrack_proto_fini(net);
 	nf_conntrack_cleanup_net(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		RCU_INIT_POINTER(nf_ct_destroy, NULL);
-		nf_conntrack_cleanup_init_net();
-	}
+void nf_conntrack_cleanup_end(void)
+{
+	RCU_INIT_POINTER(nf_ct_destroy, NULL);
+	nf_conntrack_cleanup_init_net();
 }
 
 void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 363285d..e7185c6 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -575,6 +575,7 @@ static int __init nf_conntrack_standalone_init(void)
 static void __exit nf_conntrack_standalone_fini(void)
 {
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
+	nf_conntrack_cleanup_end();
 }
 
 module_init(nf_conntrack_standalone_init);
-- 
1.7.10.4
