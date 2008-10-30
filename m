From: Patrick McHardy <kaber@trash.net>
Subject: netns 01/02: add register_pernet_gen_subsys/unregister_pernet_gen_subsys
Date: Thu, 30 Oct 2008 08:31:46 +0100 (MET)
Message-ID: <20081030073145.14487.48665.sendpatchset@x2.localnet>
References: <20081030073143.14487.24299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53515 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbYJ3Hbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 03:31:48 -0400
In-Reply-To: <20081030073143.14487.24299.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 616b16ca5561a4cb0fc6796ebf551e11636a3156
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Thu Oct 30 08:15:35 2008 +0100

    netns: add register_pernet_gen_subsys/unregister_pernet_gen_subsys
    
    netns ops which are registered with register_pernet_gen_device() are
    shutdown strictly before those which are registered with
    register_pernet_subsys(). Sometimes this leads to opposite (read: buggy)
    shutdown ordering between two modules.
    
    Add register_pernet_gen_subsys()/unregister_pernet_gen_subsys() for modules
    which aren't elite enough for entry in struct net, and which can't use
    register_pernet_gen_device(). PPTP conntracking module is such one.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 708009b..700c53a 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -214,6 +214,8 @@ struct pernet_operations {
 
 extern int register_pernet_subsys(struct pernet_operations *);
 extern void unregister_pernet_subsys(struct pernet_operations *);
+extern int register_pernet_gen_subsys(int *id, struct pernet_operations *);
+extern void unregister_pernet_gen_subsys(int id, struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
 extern int register_pernet_gen_device(int *id, struct pernet_operations *);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f1d07b5..1895a4c 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -325,6 +325,38 @@ void unregister_pernet_subsys(struct pernet_operations *module)
 }
 EXPORT_SYMBOL_GPL(unregister_pernet_subsys);
 
+int register_pernet_gen_subsys(int *id, struct pernet_operations *ops)
+{
+	int rv;
+
+	mutex_lock(&net_mutex);
+again:
+	rv = ida_get_new_above(&net_generic_ids, 1, id);
+	if (rv < 0) {
+		if (rv == -EAGAIN) {
+			ida_pre_get(&net_generic_ids, GFP_KERNEL);
+			goto again;
+		}
+		goto out;
+	}
+	rv = register_pernet_operations(first_device, ops);
+	if (rv < 0)
+		ida_remove(&net_generic_ids, *id);
+	mutex_unlock(&net_mutex);
+out:
+	return rv;
+}
+EXPORT_SYMBOL_GPL(register_pernet_gen_subsys);
+
+void unregister_pernet_gen_subsys(int id, struct pernet_operations *ops)
+{
+	mutex_lock(&net_mutex);
+	unregister_pernet_operations(ops);
+	ida_remove(&net_generic_ids, id);
+	mutex_unlock(&net_mutex);
+}
+EXPORT_SYMBOL_GPL(unregister_pernet_gen_subsys);
+
 /**
  *      register_pernet_device - register a network namespace device
  *	@ops:  pernet operations structure for the subsystem
