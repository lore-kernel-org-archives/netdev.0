From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/2] netns: add
	register_pernet_gen_subsys/unregister_pernet_gen_subsys
Date: Sun, 26 Oct 2008 02:43:24 +0400
Message-ID: <20081025224323.GA18858@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfiter-devel@vger.kernel.org,
	containters@lists.osdl.org
To: davem@davemloft.net, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:46014 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbYJYWkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 18:40:07 -0400
Received: by ey-out-2122.google.com with SMTP id 6so619457eyi.37
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2008 15:40:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netns ops which are registered with register_pernet_gen_device() are
shutdown strictly before those which are registered with
register_pernet_subsys(). Sometimes this leads to opposite (read: buggy)
shutdown ordering between two modules.

Add register_pernet_gen_subsys()/unregister_pernet_gen_subsys() for modules
which aren't elite enough for entry in struct net, and which can't use
register_pernet_gen_device(). PPTP conntracking module is such one.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -215,6 +215,8 @@ struct pernet_operations {
 
 extern int register_pernet_subsys(struct pernet_operations *);
 extern void unregister_pernet_subsys(struct pernet_operations *);
+extern int register_pernet_gen_subsys(int *id, struct pernet_operations *);
+extern void unregister_pernet_gen_subsys(int id, struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
 extern int register_pernet_gen_device(int *id, struct pernet_operations *);
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
