From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/15] batman-adv: Add hard_iface specific sysfs wrapper macros for UINT
Date: Mon, 29 Feb 2016 19:05:54 +0800
Message-ID: <1456743968-17562-2-git-send-email-a__37623.4647971161$1456744134$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Linus Luessing <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@open-mesh.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:2071 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753155AbcB2LIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:40 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Luessing <linus.luessing@web.de>

This allows us to easily add a sysfs parameter for an
unsigned int later, which is not for a batman mesh interface
(e.g. bat0), but for a common interface instead. It allows
reading and writing an atomic_t in hard_iface (instead of
bat_priv compared to the mesh variant).

Developed by Linus during a 6 months trainee study period in
Ascom (Switzerland) AG.

Signed-off-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
[antonio@open-mesh.com: rename functions and move macros]
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
---
 net/batman-adv/sysfs.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 4d70d4413e40..d3f69d5e79d9 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -242,6 +242,55 @@ ssize_t batadv_show_vlan_##_name(struct kobject *kobj,			\
 	static BATADV_ATTR_VLAN(_name, _mode, batadv_show_vlan_##_name,	\
 				batadv_store_vlan_##_name)
 
+#define BATADV_ATTR_HIF_STORE_UINT(_name, _var, _min, _max, _post_func)	\
+ssize_t batadv_store_##_name(struct kobject *kobj,			\
+			     struct attribute *attr, char *buff,	\
+			     size_t count)				\
+{									\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
+	struct batadv_hard_iface *hard_iface;				\
+	ssize_t length;							\
+									\
+	hard_iface = batadv_hardif_get_by_netdev(net_dev);		\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = __batadv_store_uint_attr(buff, count, _min, _max,	\
+					  _post_func, attr,		\
+					  &hard_iface->_var, net_dev);	\
+									\
+	batadv_hardif_put(hard_iface);				\
+	return length;							\
+}
+
+#define BATADV_ATTR_HIF_SHOW_UINT(_name, _var)				\
+ssize_t batadv_show_##_name(struct kobject *kobj,			\
+			    struct attribute *attr, char *buff)		\
+{									\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
+	struct batadv_hard_iface *hard_iface;				\
+	ssize_t length;							\
+									\
+	hard_iface = batadv_hardif_get_by_netdev(net_dev);		\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_var));	\
+									\
+	batadv_hardif_put(hard_iface);				\
+	return length;							\
+}
+
+/* Use this, if you are going to set [name] in hard_iface to an
+ * unsigned integer value
+ */
+#define BATADV_ATTR_HIF_UINT(_name, _var, _mode, _min, _max, _post_func)\
+	static BATADV_ATTR_HIF_STORE_UINT(_name, _var, _min,		\
+					  _max, _post_func)		\
+	static BATADV_ATTR_HIF_SHOW_UINT(_name, _var)			\
+	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
+			   batadv_store_##_name)
+
 static int batadv_store_bool_attr(char *buff, size_t count,
 				  struct net_device *net_dev,
 				  const char *attr_name, atomic_t *attr,
-- 
2.7.2
