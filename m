From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 1/6][NETNS]: Introduce sysctl root for read-only
 net sysctls.
Date: Mon, 19 May 2008 19:52:43 +0400
Message-ID: <4831A24B.1080807@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33841 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbYESPzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 11:55:11 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one stores all ctl-heads in one list and restricts the
permissions not give write access to non-init net namespaces.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/net_namespace.h |    3 +++
 net/sysctl_net.c            |   30 ++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index aa540e6..8df751b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -201,8 +201,11 @@ extern void unregister_pernet_gen_device(int id, struct pernet_operations *);
 struct ctl_path;
 struct ctl_table;
 struct ctl_table_header;
+
 extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
+extern struct ctl_table_header *register_net_sysctl_rotable(
+	const struct ctl_path *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
 
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index b4f0525..d8e7916 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -40,6 +40,27 @@ static struct ctl_table_root net_sysctl_root = {
 	.lookup = net_ctl_header_lookup,
 };
 
+static LIST_HEAD(net_sysctl_ro_tables);
+static struct list_head *net_ctl_ro_header_lookup(struct ctl_table_root *root,
+		struct nsproxy *namespaces)
+{
+	return &net_sysctl_ro_tables;
+}
+
+static int net_ctl_ro_header_perms(struct ctl_table_root *root,
+		struct nsproxy *namespaces, struct ctl_table *table)
+{
+	if (namespaces->net_ns == &init_net)
+		return table->mode;
+	else
+		return table->mode & ~0222;
+}
+
+static struct ctl_table_root net_sysctl_ro_root = {
+	.lookup = net_ctl_ro_header_lookup,
+	.permissions = net_ctl_ro_header_perms,
+};
+
 static int sysctl_net_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->sysctl_table_headers);
@@ -64,6 +85,7 @@ static __init int sysctl_init(void)
 	if (ret)
 		goto out;
 	register_sysctl_root(&net_sysctl_root);
+	register_sysctl_root(&net_sysctl_ro_root);
 out:
 	return ret;
 }
@@ -80,6 +102,14 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
+struct ctl_table_header *register_net_sysctl_rotable(const
+		struct ctl_path *path, struct ctl_table *table)
+{
+	return __register_sysctl_paths(&net_sysctl_ro_root,
+			&init_nsproxy, path, table);
+}
+EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
+
 void unregister_net_sysctl_table(struct ctl_table_header *header)
 {
 	unregister_sysctl_table(header);
-- 
1.5.3.4

