From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/16] batman-adv: only call post function if something changed
Date: Sat,  9 Jan 2016 21:20:11 +0800
Message-ID: <1452345621-15908-7-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:44241 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240AbcAINWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:33 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Currently, the post function is also called on errors or if there were
no changes, which is redundant for the functions currently using these
facilities.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/sysfs.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 48e2aaddda49..fe87777fda8a 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -242,10 +242,13 @@ ssize_t batadv_show_vlan_##_name(struct kobject *kobj,			\
 
 static int batadv_store_bool_attr(char *buff, size_t count,
 				  struct net_device *net_dev,
-				  const char *attr_name, atomic_t *attr)
+				  const char *attr_name, atomic_t *attr,
+				  bool *changed)
 {
 	int enabled = -1;
 
+	*changed = false;
+
 	if (buff[count - 1] == '\n')
 		buff[count - 1] = '\0';
 
@@ -272,6 +275,8 @@ static int batadv_store_bool_attr(char *buff, size_t count,
 		    atomic_read(attr) == 1 ? "enabled" : "disabled",
 		    enabled == 1 ? "enabled" : "disabled");
 
+	*changed = true;
+
 	atomic_set(attr, (unsigned int)enabled);
 	return count;
 }
@@ -282,11 +287,12 @@ __batadv_store_bool_attr(char *buff, size_t count,
 			 struct attribute *attr,
 			 atomic_t *attr_store, struct net_device *net_dev)
 {
+	bool changed;
 	int ret;
 
 	ret = batadv_store_bool_attr(buff, count, net_dev, attr->name,
-				     attr_store);
-	if (post_func && ret)
+				     attr_store, &changed);
+	if (post_func && changed)
 		post_func(net_dev);
 
 	return ret;
-- 
2.7.0
