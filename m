From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 5/5] net-sysfs: make sure objects belong to contrainer's owner
Date: Tue, 16 Aug 2016 15:33:15 -0700
Message-ID: <1471386795-32918-6-git-send-email-dmitry.torokhov@gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When creating various objects in /sys/class/net/... make sure that they
belong to container's owner instead of global root (if they belong to a
container/namespace).

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 net/core/net-sysfs.c | 44 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7a0b616..ef997bb 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -882,11 +882,35 @@ static const void *rx_queue_namespace(struct kobject *kobj)
 	return ns;
 }
 
+static void net_ns_get_ownership(const struct net *net,
+				 kuid_t *uid, kgid_t *gid)
+{
+	if (net) {
+		kuid_t ns_root_uid = make_kuid(net->user_ns, 0);
+		kgid_t ns_root_gid = make_kgid(net->user_ns, 0);
+
+		if (uid_valid(ns_root_uid))
+			*uid = ns_root_uid;
+
+		if (gid_valid(ns_root_gid))
+			*gid = ns_root_gid;
+	}
+}
+
+static void rx_queue_get_ownership(struct kobject *kobj,
+				   kuid_t *uid, kgid_t *gid)
+{
+	const struct net *net = rx_queue_namespace(kobj);
+
+	net_ns_get_ownership(net, uid, gid);
+}
+
 static struct kobj_type rx_queue_ktype = {
 	.sysfs_ops = &rx_queue_sysfs_ops,
 	.release = rx_queue_release,
 	.default_attrs = rx_queue_default_attrs,
-	.namespace = rx_queue_namespace
+	.namespace = rx_queue_namespace,
+	.get_ownership = rx_queue_get_ownership,
 };
 
 static int rx_queue_add_kobject(struct net_device *dev, int index)
@@ -1274,11 +1298,20 @@ static const void *netdev_queue_namespace(struct kobject *kobj)
 	return ns;
 }
 
+static void netdev_queue_get_ownership(struct kobject *kobj,
+				       kuid_t *uid, kgid_t *gid)
+{
+	const struct net *net = netdev_queue_namespace(kobj);
+
+	net_ns_get_ownership(net, uid, gid);
+}
+
 static struct kobj_type netdev_queue_ktype = {
 	.sysfs_ops = &netdev_queue_sysfs_ops,
 	.release = netdev_queue_release,
 	.default_attrs = netdev_queue_default_attrs,
 	.namespace = netdev_queue_namespace,
+	.get_ownership = netdev_queue_get_ownership,
 };
 
 static int netdev_queue_add_kobject(struct net_device *dev, int index)
@@ -1463,6 +1496,14 @@ static const void *net_namespace(struct device *d)
 	return dev_net(dev);
 }
 
+static void net_get_ownership(struct device *d, kuid_t *uid, kgid_t *gid)
+{
+	struct net_device *dev = to_net_dev(d);
+	const struct net *net = dev_net(dev);
+
+	net_ns_get_ownership(net, uid, gid);
+}
+
 static struct class net_class = {
 	.name = "net",
 	.dev_release = netdev_release,
@@ -1470,6 +1511,7 @@ static struct class net_class = {
 	.dev_uevent = netdev_uevent,
 	.ns_type = &net_ns_type_operations,
 	.namespace = net_namespace,
+	.get_ownership = net_get_ownership,
 };
 
 #ifdef CONFIG_OF_NET
-- 
2.8.0.rc3.226.g39d4020
