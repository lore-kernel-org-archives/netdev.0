From: dlezcano@fr.ibm.com
Subject: [patch 02/12] net namespace : store L2 parent namespace
Date: Fri, 19 Jan 2007 16:47:16 +0100
Message-ID: <20070119155344.598687044@localhost.localdomain>
References: <20070119154714.439706567@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from AToulouse-252-1-85-33.w86-201.abo.wanadoo.fr ([86.201.99.33]:56627
	"EHLO localhost.localdomain" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932617AbXASQkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 11:40:43 -0500
To: containers@lists.osdl.org
Content-Disposition: inline; filename=net-namespace-l3-add-l2-parent.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

All L3 namespaces are the final nodes of the L2 namespaces
tree. Because their share some ressources coming from the L2
namespace. The L2 parent namespace should be stored into the L3 child
when it is created.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

---
 include/linux/net_namespace.h |    1 +
 net/core/net_namespace.c      |   11 +++++++++++
 2 files changed, 12 insertions(+)

Index: 2.6.20-rc4-mm1/include/linux/net_namespace.h
===================================================================
--- 2.6.20-rc4-mm1.orig/include/linux/net_namespace.h
+++ 2.6.20-rc4-mm1/include/linux/net_namespace.h
@@ -27,6 +27,7 @@
 #define NET_NS_LEVEL2		1
 #define NET_NS_LEVEL3		2
 	unsigned int		level;
+	struct net_namespace    *parent;
 };
 
 extern struct net_namespace init_net_ns;
Index: 2.6.20-rc4-mm1/net/core/net_namespace.c
===================================================================
--- 2.6.20-rc4-mm1.orig/net/core/net_namespace.c
+++ 2.6.20-rc4-mm1/net/core/net_namespace.c
@@ -22,6 +22,7 @@
 	.loopback_dev_p	= NULL,
 	.pcpu_lstats_p	= NULL,
 	.level          = NET_NS_LEVEL2,
+	.parent         = NULL,
 };
 
 #ifdef CONFIG_NET_NS
@@ -62,6 +63,12 @@
 		if (ip_fib_struct_init())
 			goto out_fib4;
 	}
+
+	if (level == NET_NS_LEVEL3) {
+		get_net_ns(old_ns);
+		ns->parent = old_ns;
+	}
+
 	ns->level = level;
 	if (loopback_init())
 		goto out_loopback;
@@ -126,8 +133,12 @@
 				ns, atomic_read(&ns->kref.refcount));
 		return;
 	}
+
 	if (ns->level == NET_NS_LEVEL2)
 		ip_fib_struct_cleanup(ns);
+	if (ns->level == NET_NS_LEVEL3)
+		put_net_ns(ns->parent);
+
 	printk(KERN_DEBUG "NET_NS: net namespace %p destroyed\n", ns);
 	kfree(ns);
 }

-- 
