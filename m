From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/3] Bluetooth: Convert debug files to actually use debugfs instead of sysfs
Date: Sun, 21 Mar 2010 06:41:36 +0100
Message-ID: <aef7d97cc604309b66f6f45cce02cd734934cd4e.1269149356.git.marcel@holtmann.org>
References: <cover.1269149354.git.marcel@holtmann.org>
 <101545f6fef4a0a3ea8daf0b5b880df2c6a92a69.1269149356.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35328 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab0CUFls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 01:41:48 -0400
In-Reply-To: <101545f6fef4a0a3ea8daf0b5b880df2c6a92a69.1269149356.git.marcel@holtmann.org>
In-Reply-To: <cover.1269149354.git.marcel@holtmann.org>
References: <cover.1269149354.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the debug files ended up wrongly in sysfs, because at that point
of time, debugfs didn't exist. Convert these files to use debugfs and
also seq_file. This patch converts all of these files at once and then
removes the exported symbol for the Bluetooth sysfs class.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/bluetooth.h |    2 +-
 net/bluetooth/hci_sysfs.c         |    3 +-
 net/bluetooth/l2cap.c             |   51 +++++++++++++++++++++---------------
 net/bluetooth/rfcomm/core.c       |   52 ++++++++++++++++++++----------------
 net/bluetooth/rfcomm/sock.c       |   47 +++++++++++++++++++--------------
 net/bluetooth/sco.c               |   47 ++++++++++++++++++---------------
 6 files changed, 114 insertions(+), 88 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 04a6908..ff77e8f 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -176,6 +176,6 @@ extern void hci_sock_cleanup(void);
 extern int bt_sysfs_init(void);
 extern void bt_sysfs_cleanup(void);
 
-extern struct class *bt_class;
+extern struct dentry *bt_debugfs;
 
 #endif /* __BLUETOOTH_H */
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index cafb55b..05fd125 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -8,8 +8,7 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 
-struct class *bt_class = NULL;
-EXPORT_SYMBOL_GPL(bt_class);
+static struct class *bt_class;
 
 struct dentry *bt_debugfs = NULL;
 EXPORT_SYMBOL_GPL(bt_debugfs);
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 2755182..43e17f7 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -40,6 +40,8 @@
 #include <linux/skbuff.h>
 #include <linux/list.h>
 #include <linux/device.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/uaccess.h>
 #include <linux/crc16.h>
 #include <net/sock.h>
@@ -3937,39 +3939,42 @@ drop:
 	return 0;
 }
 
-static ssize_t l2cap_sysfs_show(struct class *dev,
-				struct class_attribute *attr,
-				char *buf)
+static int l2cap_debugfs_show(struct seq_file *f, void *p)
 {
 	struct sock *sk;
 	struct hlist_node *node;
-	char *str = buf;
-	int size = PAGE_SIZE;
 
 	read_lock_bh(&l2cap_sk_list.lock);
 
 	sk_for_each(sk, node, &l2cap_sk_list.head) {
 		struct l2cap_pinfo *pi = l2cap_pi(sk);
-		int len;
-
-		len = snprintf(str, size, "%s %s %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
-				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
-				sk->sk_state, __le16_to_cpu(pi->psm), pi->scid,
-				pi->dcid, pi->imtu, pi->omtu, pi->sec_level);
-
-		size -= len;
-		if (size <= 0)
-			break;
 
-		str += len;
+		seq_printf(f, "%s %s %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
+					batostr(&bt_sk(sk)->src),
+					batostr(&bt_sk(sk)->dst),
+					sk->sk_state, __le16_to_cpu(pi->psm),
+					pi->scid, pi->dcid,
+					pi->imtu, pi->omtu, pi->sec_level);
 	}
 
 	read_unlock_bh(&l2cap_sk_list.lock);
 
-	return str - buf;
+	return 0;
 }
 
-static CLASS_ATTR(l2cap, S_IRUGO, l2cap_sysfs_show, NULL);
+static int l2cap_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, l2cap_debugfs_show, inode->i_private);
+}
+
+static const struct file_operations l2cap_debugfs_fops = {
+	.open		= l2cap_debugfs_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *l2cap_debugfs;
 
 static const struct proto_ops l2cap_sock_ops = {
 	.family		= PF_BLUETOOTH,
@@ -4029,8 +4034,12 @@ static int __init l2cap_init(void)
 		goto error;
 	}
 
-	if (class_create_file(bt_class, &class_attr_l2cap) < 0)
-		BT_ERR("Failed to create L2CAP info file");
+	if (bt_debugfs) {
+		l2cap_debugfs = debugfs_create_file("l2cap", 0444,
+					bt_debugfs, NULL, &l2cap_debugfs_fops);
+		if (!l2cap_debugfs)
+			BT_ERR("Failed to create L2CAP debug file");
+	}
 
 	BT_INFO("L2CAP ver %s", VERSION);
 	BT_INFO("L2CAP socket layer initialized");
@@ -4044,7 +4053,7 @@ error:
 
 static void __exit l2cap_exit(void)
 {
-	class_remove_file(bt_class, &class_attr_l2cap);
+	debugfs_remove(l2cap_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
 		BT_ERR("L2CAP socket unregistration failed");
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index cf16407..13f114e 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -33,6 +33,8 @@
 #include <linux/init.h>
 #include <linux/wait.h>
 #include <linux/device.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/net.h>
 #include <linux/mutex.h>
 #include <linux/kthread.h>
@@ -2098,14 +2100,10 @@ static struct hci_cb rfcomm_cb = {
 	.security_cfm	= rfcomm_security_cfm
 };
 
-static ssize_t rfcomm_dlc_sysfs_show(struct class *dev,
-				     struct class_attribute *attr,
-				     char *buf)
+static int rfcomm_dlc_debugfs_show(struct seq_file *f, void *x)
 {
 	struct rfcomm_session *s;
 	struct list_head *pp, *p;
-	char *str = buf;
-	int size = PAGE_SIZE;
 
 	rfcomm_lock();
 
@@ -2114,29 +2112,33 @@ static ssize_t rfcomm_dlc_sysfs_show(struct class *dev,
 		list_for_each(pp, &s->dlcs) {
 			struct sock *sk = s->sock->sk;
 			struct rfcomm_dlc *d = list_entry(pp, struct rfcomm_dlc, list);
-			int len;
 
-			len = snprintf(str, size, "%s %s %ld %d %d %d %d\n",
-					batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
-					d->state, d->dlci, d->mtu, d->rx_credits, d->tx_credits);
-
-			size -= len;
-			if (size <= 0)
-				break;
-
-			str += len;
+			seq_printf(f, "%s %s %ld %d %d %d %d\n",
+						batostr(&bt_sk(sk)->src),
+						batostr(&bt_sk(sk)->dst),
+						d->state, d->dlci, d->mtu,
+						d->rx_credits, d->tx_credits);
 		}
-
-		if (size <= 0)
-			break;
 	}
 
 	rfcomm_unlock();
 
-	return (str - buf);
+	return 0;
+}
+
+static int rfcomm_dlc_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rfcomm_dlc_debugfs_show, inode->i_private);
 }
 
-static CLASS_ATTR(rfcomm_dlc, S_IRUGO, rfcomm_dlc_sysfs_show, NULL);
+static const struct file_operations rfcomm_dlc_debugfs_fops = {
+	.open		= rfcomm_dlc_debugfs_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *rfcomm_dlc_debugfs;
 
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
@@ -2153,8 +2155,12 @@ static int __init rfcomm_init(void)
 		goto unregister;
 	}
 
-	if (class_create_file(bt_class, &class_attr_rfcomm_dlc) < 0)
-		BT_ERR("Failed to create RFCOMM info file");
+	if (bt_debugfs) {
+		rfcomm_dlc_debugfs = debugfs_create_file("rfcomm_dlc", 0444,
+				bt_debugfs, NULL, &rfcomm_dlc_debugfs_fops);
+		if (!rfcomm_dlc_debugfs)
+			BT_ERR("Failed to create RFCOMM debug file");
+	}
 
 	err = rfcomm_init_ttys();
 	if (err < 0)
@@ -2182,7 +2188,7 @@ unregister:
 
 static void __exit rfcomm_exit(void)
 {
-	class_remove_file(bt_class, &class_attr_rfcomm_dlc);
+	debugfs_remove(rfcomm_dlc_debugfs);
 
 	hci_unregister_cb(&rfcomm_cb);
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8d0ee0b..7f43976 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -40,6 +40,8 @@
 #include <linux/skbuff.h>
 #include <linux/list.h>
 #include <linux/device.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <net/sock.h>
 
 #include <asm/system.h>
@@ -1061,37 +1063,38 @@ done:
 	return result;
 }
 
-static ssize_t rfcomm_sock_sysfs_show(struct class *dev,
-				      struct class_attribute *attr,
-				      char *buf)
+static int rfcomm_sock_debugfs_show(struct seq_file *f, void *p)
 {
 	struct sock *sk;
 	struct hlist_node *node;
-	char *str = buf;
-	int size = PAGE_SIZE;
 
 	read_lock_bh(&rfcomm_sk_list.lock);
 
 	sk_for_each(sk, node, &rfcomm_sk_list.head) {
-		int len;
-
-		len = snprintf(str, size, "%s %s %d %d\n",
-				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
+		seq_printf(f, "%s %s %d %d\n",
+				batostr(&bt_sk(sk)->src),
+				batostr(&bt_sk(sk)->dst),
 				sk->sk_state, rfcomm_pi(sk)->channel);
-
-		size -= len;
-		if (size <= 0)
-			break;
-
-		str += len;
 	}
 
 	read_unlock_bh(&rfcomm_sk_list.lock);
 
-	return (str - buf);
+	return 0;
 }
 
-static CLASS_ATTR(rfcomm, S_IRUGO, rfcomm_sock_sysfs_show, NULL);
+static int rfcomm_sock_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rfcomm_sock_debugfs_show, inode->i_private);
+}
+
+static const struct file_operations rfcomm_sock_debugfs_fops = {
+	.open		= rfcomm_sock_debugfs_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *rfcomm_sock_debugfs;
 
 static const struct proto_ops rfcomm_sock_ops = {
 	.family		= PF_BLUETOOTH,
@@ -1131,8 +1134,12 @@ int __init rfcomm_init_sockets(void)
 	if (err < 0)
 		goto error;
 
-	if (class_create_file(bt_class, &class_attr_rfcomm) < 0)
-		BT_ERR("Failed to create RFCOMM info file");
+	if (bt_debugfs) {
+		rfcomm_sock_debugfs = debugfs_create_file("rfcomm", 0444,
+				bt_debugfs, NULL, &rfcomm_sock_debugfs_fops);
+		if (!rfcomm_sock_debugfs)
+			BT_ERR("Failed to create RFCOMM debug file");
+	}
 
 	BT_INFO("RFCOMM socket layer initialized");
 
@@ -1146,7 +1153,7 @@ error:
 
 void rfcomm_cleanup_sockets(void)
 {
-	class_remove_file(bt_class, &class_attr_rfcomm);
+	debugfs_remove(rfcomm_sock_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_RFCOMM) < 0)
 		BT_ERR("RFCOMM socket layer unregistration failed");
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 967a751..e5b16b7 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -38,6 +38,8 @@
 #include <linux/socket.h>
 #include <linux/skbuff.h>
 #include <linux/device.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/list.h>
 #include <net/sock.h>
 
@@ -953,37 +955,36 @@ drop:
 	return 0;
 }
 
-static ssize_t sco_sysfs_show(struct class *dev,
-				struct class_attribute *attr,
-				char *buf)
+static int sco_debugfs_show(struct seq_file *f, void *p)
 {
 	struct sock *sk;
 	struct hlist_node *node;
-	char *str = buf;
-	int size = PAGE_SIZE;
 
 	read_lock_bh(&sco_sk_list.lock);
 
 	sk_for_each(sk, node, &sco_sk_list.head) {
-		int len;
-
-		len = snprintf(str, size, "%s %s %d\n",
-				batostr(&bt_sk(sk)->src), batostr(&bt_sk(sk)->dst),
-				sk->sk_state);
-
-		size -= len;
-		if (size <= 0)
-			break;
-
-		str += len;
+		seq_printf(f, "%s %s %d\n", batostr(&bt_sk(sk)->src),
+				batostr(&bt_sk(sk)->dst), sk->sk_state);
 	}
 
 	read_unlock_bh(&sco_sk_list.lock);
 
-	return (str - buf);
+	return 0;
 }
 
-static CLASS_ATTR(sco, S_IRUGO, sco_sysfs_show, NULL);
+static int sco_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, sco_debugfs_show, inode->i_private);
+}
+
+static const struct file_operations sco_debugfs_fops = {
+	.open		= sco_debugfs_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *sco_debugfs;
 
 static const struct proto_ops sco_sock_ops = {
 	.family		= PF_BLUETOOTH,
@@ -1041,8 +1042,12 @@ static int __init sco_init(void)
 		goto error;
 	}
 
-	if (class_create_file(bt_class, &class_attr_sco) < 0)
-		BT_ERR("Failed to create SCO info file");
+	if (bt_debugfs) {
+		sco_debugfs = debugfs_create_file("sco", 0444,
+					bt_debugfs, NULL, &sco_debugfs_fops);
+		if (!sco_debugfs)
+			BT_ERR("Failed to create SCO debug file");
+	}
 
 	BT_INFO("SCO (Voice Link) ver %s", VERSION);
 	BT_INFO("SCO socket layer initialized");
@@ -1056,7 +1061,7 @@ error:
 
 static void __exit sco_exit(void)
 {
-	class_remove_file(bt_class, &class_attr_sco);
+	debugfs_remove(sco_debugfs);
 
 	if (bt_sock_unregister(BTPROTO_SCO) < 0)
 		BT_ERR("SCO socket unregistration failed");
-- 
1.6.6.1

