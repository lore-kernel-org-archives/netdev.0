From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 1/6] netns: add in ida ID to identify the network namespace
Date: Tue, 28 Oct 2008 18:39:11 +0100
Message-ID: <20081028173911.GA8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.thmulti.com ([141.11.234.72]:33890 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752868AbYJ1R6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:58:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch initially submitted by Benjamin Thery, provided again here for reference.

This patch adds in 'id' member to struct net. This member contains an
IDA ID. The id is allocated at netns creation.

This 'id' will be used to reference network namespaces without the need for a pid.
---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 708009b..8bde629 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -75,6 +75,8 @@ struct net {
 #endif
 #endif
 	struct net_generic	*gen;
+
+	int			id;
 };
 
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f1d07b5..894b35e 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -26,6 +26,16 @@ EXPORT_SYMBOL(init_net);
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
 /*
+ * IDs allocated from this ida are used as a suffix in sysfs to tag
+ * devices belonging to each netns (other than init_net).
+ * Only 4 characters are left to store a separator plus this tag in sysfs
+ * (BUS_ID_SIZE-IFNAMSIZ)
+ * Thus, this limits us to 4095 ("FFF") simultaneous network namespaces.
+ */
+static DEFINE_IDA(net_id_ida);
+#define NET_ID_MAX 0xFFF
+
+/*
  * setup_net runs the initializers for the network namespace object.
  */
 static __net_init int setup_net(struct net *net)
@@ -40,7 +50,20 @@ static __net_init int setup_net(struct net *net)
 	atomic_set(&net->use_count, 0);
 #endif
 
+	/* Get an ID */
+again:
+	error = ida_get_new(&net_id_ida, &net->id);
+	if (error) {
+		if (error == -EAGAIN) {
+			ida_pre_get(&net_id_ida, GFP_KERNEL);
+			goto again;
+		}
+		goto out;
+	}
 	error = -ENOMEM;
+	if (net->id > NET_ID_MAX)
+		goto out;
+
 	ng = kzalloc(sizeof(struct net_generic) +
 			INITIAL_NET_GEN_PTRS * sizeof(void *), GFP_KERNEL);
 	if (ng == NULL)
@@ -97,6 +120,7 @@ static void net_free(struct net *net)
 	}
 #endif
 	kfree(net->gen);
+	ida_remove(&net_id_ida, net->id);
 	kmem_cache_free(net_cachep, net);
 }
 
-- 
1.5.4.4

