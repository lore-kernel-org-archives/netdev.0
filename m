From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/15] batman-adv: Adding hard_iface specific sysfs wrapper macros for UINT
Date: Fri, 11 May 2012 14:21:28 +0200
Message-ID: <1336738892-7401-12-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Linus Luessing <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58890 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758752Ab2EKMZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:37 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Luessing <linus.luessing@web.de>

This allows us to easily add a sysfs parameter for an unsigned int
later, which is not for a batman mesh interface (e.g. bat0), but for a
common interface instead. It allows reading and writing an atomic_t in
hard_iface (instead of bat_priv compared to the mesh variant).

Developed by Linus during a 6 months trainee study period in Ascom
(Switzerland) AG.

Signed-off-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 913299d..5bc7b66 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -117,6 +117,49 @@ ssize_t show_##_name(struct kobject *kobj,				\
 	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
 
 
+#define BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)		\
+ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
+		      char *buff, size_t count)				\
+{									\
+	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);	\
+	ssize_t length;							\
+									\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = __store_uint_attr(buff, count, _min, _max, _post_func,	\
+				   attr, &hard_iface->_name, net_dev);	\
+									\
+	hardif_free_ref(hard_iface);					\
+	return length;							\
+}
+
+#define BAT_ATTR_HIF_SHOW_UINT(_name)					\
+ssize_t show_##_name(struct kobject *kobj,				\
+		     struct attribute *attr, char *buff)		\
+{									\
+	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);	\
+	ssize_t length;							\
+									\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_name));\
+									\
+	hardif_free_ref(hard_iface);					\
+	return length;							\
+}
+
+/* Use this, if you are going to set [name] in hard_iface to an
+ * unsigned integer value*/
+#define BAT_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)		\
+	static BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
+	static BAT_ATTR_HIF_SHOW_UINT(_name)				\
+	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+
+
 static int store_bool_attr(char *buff, size_t count,
 			   struct net_device *net_dev,
 			   const char *attr_name, atomic_t *attr)
-- 
1.7.9.4
