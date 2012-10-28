From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/16] batman-adv: Check return value of try_module_get
Date: Sun, 28 Oct 2012 12:17:09 +0100
Message-ID: <1351423037-5292-9-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:55895 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab2J1LSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:30 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

New operations should not be started when they need an increased module
reference counter and try_module_get failed.

This patch addresses Coverity #712284: Unchecked return value

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/debugfs.c     |  6 ++++--
 net/batman-adv/icmp_socket.c | 12 ++++++++----
 net/batman-adv/main.c        | 10 ----------
 net/batman-adv/main.h        |  2 --
 4 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 391d4fb..bd032bc 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -99,15 +99,17 @@ int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
 
 static int batadv_log_open(struct inode *inode, struct file *file)
 {
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+
 	nonseekable_open(inode, file);
 	file->private_data = inode->i_private;
-	batadv_inc_module_count();
 	return 0;
 }
 
 static int batadv_log_release(struct inode *inode, struct file *file)
 {
-	batadv_dec_module_count();
+	module_put(THIS_MODULE);
 	return 0;
 }
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index bde3cf747..5874c0e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -42,12 +42,16 @@ static int batadv_socket_open(struct inode *inode, struct file *file)
 	unsigned int i;
 	struct batadv_socket_client *socket_client;
 
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+
 	nonseekable_open(inode, file);
 
 	socket_client = kmalloc(sizeof(*socket_client), GFP_KERNEL);
-
-	if (!socket_client)
+	if (!socket_client) {
+		module_put(THIS_MODULE);
 		return -ENOMEM;
+	}
 
 	for (i = 0; i < ARRAY_SIZE(batadv_socket_client_hash); i++) {
 		if (!batadv_socket_client_hash[i]) {
@@ -59,6 +63,7 @@ static int batadv_socket_open(struct inode *inode, struct file *file)
 	if (i == ARRAY_SIZE(batadv_socket_client_hash)) {
 		pr_err("Error - can't add another packet client: maximum number of clients reached\n");
 		kfree(socket_client);
+		module_put(THIS_MODULE);
 		return -EXFULL;
 	}
 
@@ -71,7 +76,6 @@ static int batadv_socket_open(struct inode *inode, struct file *file)
 
 	file->private_data = socket_client;
 
-	batadv_inc_module_count();
 	return 0;
 }
 
@@ -96,7 +100,7 @@ static int batadv_socket_release(struct inode *inode, struct file *file)
 	spin_unlock_bh(&socket_client->lock);
 
 	kfree(socket_client);
-	batadv_dec_module_count();
+	module_put(THIS_MODULE);
 
 	return 0;
 }
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index a4a337d..f9bcfa1 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -160,16 +160,6 @@ void batadv_mesh_free(struct net_device *soft_iface)
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
 }
 
-void batadv_inc_module_count(void)
-{
-	try_module_get(THIS_MODULE);
-}
-
-void batadv_dec_module_count(void)
-{
-	module_put(THIS_MODULE);
-}
-
 int batadv_is_my_mac(const uint8_t *addr)
 {
 	const struct batadv_hard_iface *hard_iface;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 5c0be5b..9b94f05 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -150,8 +150,6 @@ extern struct workqueue_struct *batadv_event_workqueue;
 
 int batadv_mesh_init(struct net_device *soft_iface);
 void batadv_mesh_free(struct net_device *soft_iface);
-void batadv_inc_module_count(void);
-void batadv_dec_module_count(void);
 int batadv_is_my_mac(const uint8_t *addr);
 struct batadv_hard_iface *
 batadv_seq_print_text_primary_if_get(struct seq_file *seq);
-- 
1.7.12.4
