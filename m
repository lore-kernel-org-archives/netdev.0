From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/4] netns: add in ida ID to identify the network namespace
Date: Wed, 22 Oct 2008 17:21:54 +0200
Message-ID: <20081022152144.562569159@theryb.frec.bull.fr>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Cc: Eric Biederman <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:36914 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbYJVPXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 11:23:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds in 'id' member to struct net. This member contains an
IDA ID. The id is allocated at netns creation. 

This id will be used to 'tag' net devices belonging to network namespace
in sysfs (in order to allow registration of net devices with the same name 
in different network namespace: see last patch for the details).

The advantage of IDA IDs over using the netns pointer is the id values
are small starting at 0, thus they requires less bytes to be displayed
(we are limited to 3 characters: again see last patch for the details). 
And they stay small as they are recycled when IDs are freed (unless you
have thousands of netns running on your host).

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

Index: net-next-2.6/include/net/net_namespace.h
===================================================================
--- net-next-2.6.orig/include/net/net_namespace.h
+++ net-next-2.6/include/net/net_namespace.h
@@ -75,6 +75,8 @@ struct net {
 #endif
 #endif
 	struct net_generic	*gen;
+
+	int			id;
 };
 
 
Index: net-next-2.6/net/core/net_namespace.c
===================================================================
--- net-next-2.6.orig/net/core/net_namespace.c
+++ net-next-2.6/net/core/net_namespace.c
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
@@ -40,7 +50,20 @@ static __net_init int setup_net(struct n
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
 
+	ida_remove(&net_id_ida, net->id);
 	kmem_cache_free(net_cachep, net);
 }
 

-- 
