From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/5][SYSCTL]: Create the net sysctl root for RO
 tables.
Date: Tue, 19 Feb 2008 15:02:23 +0300
Message-ID: <47BAC54F.2030605@openvz.org>
References: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46234 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbYBSMC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 07:02:29 -0500
In-Reply-To: <47BAC38F.10100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This root keeps ctl tables in one global list, but doesn't allow
for non-init namespaces to write into tables, stored in it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/net_namespace.h |    2 ++
 net/sysctl_net.c            |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 28738b7..2930ae3 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -173,6 +173,8 @@ struct ctl_table;
 struct ctl_table_header;
 extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
+extern struct ctl_table_header *register_init_net_ctl_table(
+		struct ctl_path *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
 
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 665e856..42c99e6 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -40,6 +40,30 @@ static struct ctl_table_root net_sysctl_root = {
 	.lookup = net_ctl_header_lookup,
 };
 
+static LIST_HEAD(net_ro_headers);
+
+static struct list_head *net_ctl_ro_header_lookup(struct ctl_table_root *root,
+		struct nsproxy *namespaces)
+{
+	return &net_ro_headers;
+}
+
+static int net_ctl_ro_permissions(struct ctl_table_root *root,
+		struct nsproxy *ns, struct ctl_table *table)
+{
+	int mode;
+
+	mode = table->mode;
+	if (ns->net_ns != &init_net)
+		mode &= ~0222;
+	return mode;
+}
+
+static struct ctl_table_root net_sysctl_ro_root = {
+	.lookup = net_ctl_ro_header_lookup,
+	.permissions = net_ctl_ro_permissions,
+};
+
 static int sysctl_net_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->sysctl_table_headers);
@@ -64,6 +88,7 @@ static __init int sysctl_init(void)
 	if (ret)
 		goto out;
 	register_sysctl_root(&net_sysctl_root);
+	register_sysctl_root(&net_sysctl_ro_root);
 out:
 	return ret;
 }
@@ -80,6 +105,14 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
+struct ctl_table_header *register_init_net_ctl_table(struct ctl_path *path,
+		struct ctl_table *table)
+{
+	return __register_sysctl_paths(&net_sysctl_ro_root,
+			&init_nsproxy, path, table);
+}
+EXPORT_SYMBOL_GPL(register_net_ro_ctl_table);
+
 void unregister_net_sysctl_table(struct ctl_table_header *header)
 {
 	return unregister_sysctl_table(header);
-- 
1.5.3.4

