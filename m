From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/13] batman-adv: mark debug_log struct as bat_priv only struct
Date: Sat, 19 Jan 2013 21:27:49 +0800
Message-ID: <1358602079-24024-4-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57671 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab3ASN3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:38 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/debugfs.c | 13 +++++++------
 net/batman-adv/types.h   | 25 +++++++++++++------------
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 55a9007..e47555b 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -40,13 +40,14 @@ static struct dentry *batadv_debugfs;
 
 static const int batadv_log_buff_len = BATADV_LOG_BUF_LEN;
 
-static char *batadv_log_char_addr(struct batadv_debug_log *debug_log,
+static char *batadv_log_char_addr(struct batadv_priv_debug_log *debug_log,
 				  size_t idx)
 {
 	return &debug_log->log_buff[idx & BATADV_LOG_BUFF_MASK];
 }
 
-static void batadv_emit_log_char(struct batadv_debug_log *debug_log, char c)
+static void batadv_emit_log_char(struct batadv_priv_debug_log *debug_log,
+				 char c)
 {
 	char *char_addr;
 
@@ -59,7 +60,7 @@ static void batadv_emit_log_char(struct batadv_debug_log *debug_log, char c)
 }
 
 __printf(2, 3)
-static int batadv_fdebug_log(struct batadv_debug_log *debug_log,
+static int batadv_fdebug_log(struct batadv_priv_debug_log *debug_log,
 			     const char *fmt, ...)
 {
 	va_list args;
@@ -114,7 +115,7 @@ static int batadv_log_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int batadv_log_empty(struct batadv_debug_log *debug_log)
+static int batadv_log_empty(struct batadv_priv_debug_log *debug_log)
 {
 	return !(debug_log->log_start - debug_log->log_end);
 }
@@ -123,7 +124,7 @@ static ssize_t batadv_log_read(struct file *file, char __user *buf,
 			       size_t count, loff_t *ppos)
 {
 	struct batadv_priv *bat_priv = file->private_data;
-	struct batadv_debug_log *debug_log = bat_priv->debug_log;
+	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
 	int error, i = 0;
 	char *char_addr;
 	char c;
@@ -177,7 +178,7 @@ static ssize_t batadv_log_read(struct file *file, char __user *buf,
 static unsigned int batadv_log_poll(struct file *file, poll_table *wait)
 {
 	struct batadv_priv *bat_priv = file->private_data;
-	struct batadv_debug_log *debug_log = bat_priv->debug_log;
+	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
 
 	poll_wait(file, &debug_log->queue_wait, wait);
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index dffbdff..db3fb25 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -233,6 +233,16 @@ struct batadv_priv_bla {
 };
 #endif
 
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+struct batadv_priv_debug_log {
+	char log_buff[BATADV_LOG_BUF_LEN];
+	unsigned long log_start;
+	unsigned long log_end;
+	spinlock_t lock; /* protects log_buff, log_start and log_end */
+	wait_queue_head_t queue_wait;
+};
+#endif
+
 struct batadv_priv_gw {
 	struct hlist_head list;
 	spinlock_t list_lock; /* protects gw_list and curr_gw */
@@ -290,9 +300,6 @@ struct batadv_priv {
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
 	char num_ifaces;
-#ifdef CONFIG_BATMAN_ADV_DEBUG
-	struct batadv_debug_log *debug_log;
-#endif
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
@@ -306,6 +313,9 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_BLA
 	struct batadv_priv_bla bla;
 #endif
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+	struct batadv_priv_debug_log *debug_log;
+#endif
 	struct batadv_priv_gw gw;
 	struct batadv_priv_tt tt;
 	struct batadv_priv_vis vis;
@@ -425,15 +435,6 @@ struct batadv_if_list_entry {
 	bool primary;
 	struct hlist_node list;
 };
-
-struct batadv_debug_log {
-	char log_buff[BATADV_LOG_BUF_LEN];
-	unsigned long log_start;
-	unsigned long log_end;
-	spinlock_t lock; /* protects log_buff, log_start and log_end */
-	wait_queue_head_t queue_wait;
-};
-
 struct batadv_frag_packet_list_entry {
 	struct list_head list;
 	uint16_t seqno;
-- 
1.8.0.2
