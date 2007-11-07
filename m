From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/2] cleanup pernet operation without CONFIG_NET_NS
Date: Wed, 7 Nov 2007 15:00:07 +0300
Message-ID: <20071107120007.GA10169@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:57207 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752858AbXKGL4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 06:56:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_NET_NS is not set, the only namespace is possible.

This patch removes list of pernet_operations and cleanups code a bit.
This list is not needed if there are no namespaces. We should just call
->init method.

Additionally, the ->exit will be called on module unloading only. This
case is safe - the code is not discarded. For the in/kernel code, ->exit
should never be called.

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/core/net_namespace.c.netinitdata	2007-10-15 13:55:25.000000000 +0400
+++ ./net/core/net_namespace.c	2007-11-06 14:33:14.000000000 +0300
@@ -179,6 +180,7 @@ static int __init net_ns_init(void)
 
 pure_initcall(net_ns_init);
 
+#ifdef CONFIG_NET_NS
 static int register_pernet_operations(struct list_head *list,
 				      struct pernet_operations *ops)
 {
@@ -220,6 +222,23 @@ static void unregister_pernet_operations
 			ops->exit(net);
 }
 
+#else
+
+static int register_pernet_operations(struct list_head *list,
+				      struct pernet_operations *ops)
+{
+	if (ops->init == NULL)
+		return 0;
+	return ops->init(&init_net);
+}
+
+static void unregister_pernet_operations(struct pernet_operations *ops)
+{
+	if (ops->exit)
+		ops->exit(&init_net);
+}
+#endif
+
 /**
  *      register_pernet_subsys - register a network namespace subsystem
  *	@ops:  pernet operations structure for the subsystem
