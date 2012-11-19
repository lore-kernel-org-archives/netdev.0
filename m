From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/10] batman-adv: export compatibility version via debugfs
Date: Mon, 19 Nov 2012 09:24:05 +0100
Message-ID: <1353313451-2930-5-git-send-email-ordex@autistici.org>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:64178 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180Ab2KSIZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:25:22 -0500
In-Reply-To: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different versions of the batman-adv module may use the same compatibility
version, but this is not understandable at runtime (the only way is to parse the
kernel log and fetch the batman-adv advertisement message on loading). The user
may want to know whether two nodes using different versions can communicate or
not. For this purpose the module has to export this value through debugfs.

Reported-by: Moritz Warning <moritzwarning@web.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/debugfs.c | 12 ++++++++++++
 net/batman-adv/main.c    | 12 ++++++++++++
 net/batman-adv/main.h    |  1 +
 3 files changed, 25 insertions(+)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 6f58ddd..ae79b19 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -245,6 +245,16 @@ static int batadv_algorithms_open(struct inode *inode, struct file *file)
 	return single_open(file, batadv_algo_seq_print_text, NULL);
 }
 
+/**
+ * batadv_compat_open - Prepare file handler for printing of the compat version
+ * @inode: inode which was opened
+ * @file: file handle to be initialized
+ */
+static int batadv_compat_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, batadv_compat_seq_print_text, NULL);
+}
+
 static int batadv_originators_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -327,9 +337,11 @@ struct batadv_debuginfo batadv_debuginfo_##_name = {	\
  * placed in the BATADV_DEBUGFS_SUBDIR subdirectory of debugfs
  */
 static BATADV_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open);
+static BATADV_DEBUGINFO(compat_version, S_IRUGO, batadv_compat_open);
 
 static struct batadv_debuginfo *batadv_general_debuginfos[] = {
 	&batadv_debuginfo_routing_algos,
+	&batadv_debuginfo_compat_version,
 	NULL,
 };
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index dc33a0c..70797de 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -420,6 +420,18 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 	return 0;
 }
 
+/**
+ * batadv_compat_seq_print_text - print the compatibility version
+ * @seq: debugfs table seq_file struct
+ * @offset: not used
+ */
+int batadv_compat_seq_print_text(struct seq_file *seq, void *offset)
+{
+	seq_printf(seq, "%d\n", BATADV_COMPAT_VERSION);
+
+	return 0;
+}
+
 static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct batadv_algo_ops *bat_algo_ops;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8f149bb..3243189 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -174,6 +174,7 @@ void batadv_recv_handler_unregister(uint8_t packet_type);
 int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_compat_seq_print_text(struct seq_file *seq, void *offset);
 
 /**
  * enum batadv_dbg_level - available log levels
-- 
1.8.0
