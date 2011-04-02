From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 17/24] sysctl: add register_net_sysctl_table_with_parent
Date: Sat,  2 Apr 2011 04:53:31 +0200
Message-ID: <6d86285bd925dba2917507d22ea6c4ad87ea9c12.1301711868.git.lucian.grijincu__7602.73521668768$1301713063$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab1DBCyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:50 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/net_namespace.h |    3 +++
 net/sysctl_net.c            |   20 +++++++++++++++++---
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 86c6e57..dd4d3cf 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -272,6 +272,9 @@ struct ctl_path;
 struct ctl_table;
 struct ctl_table_header;
 
+extern struct ctl_table_header *register_net_sysctl_table_with_parent(
+	struct net *net, const struct ctl_path *path,
+	struct ctl_table *table, struct ctl_table_header *parent);
 extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
 extern struct ctl_table_header *register_net_sysctl_rotable(
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index aa6c6f4..a4f853a 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -103,14 +103,28 @@ out:
 }
 subsys_initcall(sysctl_init);
 
-struct ctl_table_header *register_net_sysctl_table(struct net *net,
-	const struct ctl_path *path, struct ctl_table *table)
+/* The newly created ctl_table_header will be a member of the parent's
+ * private_children list. The following restrictions apply:
+ * - the children must be freed before the parent
+ * - the children are assumed to be unique (no duplicate checks)
+ * - the children are not listed under attached_to/attached_by
+ * - you cannot attach another node under a private child. */
+struct ctl_table_header *register_net_sysctl_table_with_parent(struct net *net,
+	const struct ctl_path *path, struct ctl_table *table,
+	struct ctl_table_header *parent)
 {
 	struct nsproxy namespaces;
 	namespaces = *current->nsproxy;
 	namespaces.net_ns = net;
 	return __register_sysctl_paths(&net_sysctl_root, &namespaces, path,
-				       table, net, NULL);
+				       table, net, parent);
+}
+EXPORT_SYMBOL_GPL(register_net_sysctl_table_with_parent);
+
+struct ctl_table_header *register_net_sysctl_table(struct net *net,
+	const struct ctl_path *path, struct ctl_table *table)
+{
+	return register_net_sysctl_table_with_parent(net, path, table, NULL);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
-- 
1.7.5.rc0

