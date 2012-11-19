From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/10] batman-adv: support array of debugfs general attributes
Date: Mon, 19 Nov 2012 09:24:04 +0100
Message-ID: <1353313451-2930-4-git-send-email-ordex@autistici.org>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:64118 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab2KSIZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:25:18 -0500
In-Reply-To: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for an array of debugfs general (not soft_iface
specific) attributes. With this change it will be possible to add more general
attributes by simply appending them to the array without touching the rest of
the code.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Acked-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/debugfs.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 3f679cb..6f58ddd 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -323,7 +323,17 @@ struct batadv_debuginfo batadv_debuginfo_##_name = {	\
 		}					\
 };
 
+/* the following attributes are general and therefore they will be directly
+ * placed in the BATADV_DEBUGFS_SUBDIR subdirectory of debugfs
+ */
 static BATADV_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open);
+
+static struct batadv_debuginfo *batadv_general_debuginfos[] = {
+	&batadv_debuginfo_routing_algos,
+	NULL,
+};
+
+/* The following attributes are per soft interface */
 static BATADV_DEBUGINFO(originators, S_IRUGO, batadv_originators_open);
 static BATADV_DEBUGINFO(gateways, S_IRUGO, batadv_gateways_open);
 static BATADV_DEBUGINFO(transtable_global, S_IRUGO,
@@ -358,7 +368,7 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 
 void batadv_debugfs_init(void)
 {
-	struct batadv_debuginfo *bat_debug;
+	struct batadv_debuginfo **bat_debug;
 	struct dentry *file;
 
 	batadv_debugfs = debugfs_create_dir(BATADV_DEBUGFS_SUBDIR, NULL);
@@ -366,17 +376,23 @@ void batadv_debugfs_init(void)
 		batadv_debugfs = NULL;
 
 	if (!batadv_debugfs)
-		goto out;
+		goto err;
 
-	bat_debug = &batadv_debuginfo_routing_algos;
-	file = debugfs_create_file(bat_debug->attr.name,
-				   S_IFREG | bat_debug->attr.mode,
-				   batadv_debugfs, NULL, &bat_debug->fops);
-	if (!file)
-		pr_err("Can't add debugfs file: %s\n", bat_debug->attr.name);
+	for (bat_debug = batadv_general_debuginfos; *bat_debug; ++bat_debug) {
+		file = debugfs_create_file(((*bat_debug)->attr).name,
+					   S_IFREG | ((*bat_debug)->attr).mode,
+					   batadv_debugfs, NULL,
+					   &(*bat_debug)->fops);
+		if (!file) {
+			pr_err("Can't add general debugfs file: %s\n",
+			       ((*bat_debug)->attr).name);
+			goto err;
+		}
+	}
 
-out:
 	return;
+err:
+	debugfs_remove_recursive(batadv_debugfs);
 }
 
 void batadv_debugfs_destroy(void)
-- 
1.8.0
