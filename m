From: Marc Angel <marc@arista.com>
Subject: [PATCH net-next v3] macvtap: add namespace support to the sysfs device class
Date: Thu,  5 May 2016 02:34:08 +0200
Message-ID: <1462408448-14033-1-git-send-email-marc@arista.com>
References: <20160504.160445.640444073175153113.davem@davemloft.net>
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37023 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbcEEAdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 20:33:32 -0400
Received: by mail-wm0-f54.google.com with SMTP id a17so2762677wme.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 17:33:31 -0700 (PDT)
In-Reply-To: <20160504.160445.640444073175153113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating macvtaps that are expected to have the same ifindex
in different network namespaces, only the first one will succeed.
The others will fail with a sysfs_warn_dup warning due to them trying
to create the following sysfs link (with 'NN' the ifindex of macvtapX):

/sys/class/macvtap/tapNN -> /sys/devices/virtual/net/macvtapX/tapNN

This is reproducible by running the following commands:

ip netns add ns1
ip netns add ns2
ip link add veth0 type veth peer name veth1
ip link set veth0 netns ns1
ip link set veth1 netns ns2
ip netns exec ns1 ip l add link veth0 macvtap0 type macvtap
ip netns exec ns2 ip l add link veth1 macvtap1 type macvtap

The last command will fail with "RTNETLINK answers: File exists" (along
with the kernel warning) but retrying it will work because the ifindex
was incremented.

The 'net' device class is isolated between network namespaces so each
one has its own hierarchy of net devices.
This isn't the case for the 'macvtap' device class.
The problem occurs half-way through the netdev registration, when
`macvtap_device_event` is called-back to create the 'tapNN' macvtap
class device under the 'macvtapX' net class device.

This patch adds namespace support to the 'macvtap' device class so
that /sys/class/macvtap is no longer shared between net namespaces.

However, making the macvtap sysfs class namespace-aware has the side
effect of changing /sys/devices/virtual/net/macvtapX/tapNN  into
/sys/devices/virtual/net/macvtapX/macvtap/tapNN.

This is due to Commit 24b1442 ("Driver-core: Always create class
directories for classses that support namespaces") and the fact that
class devices supporting namespaces are really not supposed to be placed
directly under other class devices.

To avoid breaking userland, a tapNN symlink pointing to macvtap/tapNN is
created inside the macvtapX directory.

Signed-off-by: Marc Angel <marc@arista.com>
---
 drivers/net/macvtap.c | 36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394ed..d89820f 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -129,7 +129,18 @@ static DEFINE_MUTEX(minor_lock);
 static DEFINE_IDR(minor_idr);
 
 #define GOODCOPY_LEN 128
-static struct class *macvtap_class;
+static const void *macvtap_net_namespace(struct device *d)
+{
+	struct net_device *dev = to_net_dev(d->parent);
+	return dev_net(dev);
+}
+
+static struct class macvtap_class = {
+	.name = "macvtap",
+	.owner = THIS_MODULE,
+	.ns_type = &net_ns_type_operations,
+	.namespace = macvtap_net_namespace,
+};
 static struct cdev macvtap_cdev;
 
 static const struct proto_ops macvtap_socket_ops;
@@ -1278,10 +1289,12 @@ static int macvtap_device_event(struct notifier_block *unused,
 	struct device *classdev;
 	dev_t devt;
 	int err;
+	char tap_name[IFNAMSIZ];
 
 	if (dev->rtnl_link_ops != &macvtap_link_ops)
 		return NOTIFY_DONE;
 
+	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
 	vlan = netdev_priv(dev);
 
 	switch (event) {
@@ -1295,16 +1308,21 @@ static int macvtap_device_event(struct notifier_block *unused,
 			return notifier_from_errno(err);
 
 		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
-		classdev = device_create(macvtap_class, &dev->dev, devt,
-					 dev, "tap%d", dev->ifindex);
+		classdev = device_create(&macvtap_class, &dev->dev, devt,
+					 dev, tap_name);
 		if (IS_ERR(classdev)) {
 			macvtap_free_minor(vlan);
 			return notifier_from_errno(PTR_ERR(classdev));
 		}
+		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
+					tap_name);
+		if (err)
+			return notifier_from_errno(err);
 		break;
 	case NETDEV_UNREGISTER:
+		sysfs_remove_link(&dev->dev.kobj, tap_name);
 		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
-		device_destroy(macvtap_class, devt);
+		device_destroy(&macvtap_class, devt);
 		macvtap_free_minor(vlan);
 		break;
 	}
@@ -1330,11 +1348,9 @@ static int macvtap_init(void)
 	if (err)
 		goto out2;
 
-	macvtap_class = class_create(THIS_MODULE, "macvtap");
-	if (IS_ERR(macvtap_class)) {
-		err = PTR_ERR(macvtap_class);
+	err = class_register(&macvtap_class);
+	if (err)
 		goto out3;
-	}
 
 	err = register_netdevice_notifier(&macvtap_notifier_block);
 	if (err)
@@ -1349,7 +1365,7 @@ static int macvtap_init(void)
 out5:
 	unregister_netdevice_notifier(&macvtap_notifier_block);
 out4:
-	class_unregister(macvtap_class);
+	class_unregister(&macvtap_class);
 out3:
 	cdev_del(&macvtap_cdev);
 out2:
@@ -1363,7 +1379,7 @@ static void macvtap_exit(void)
 {
 	rtnl_link_unregister(&macvtap_link_ops);
 	unregister_netdevice_notifier(&macvtap_notifier_block);
-	class_unregister(macvtap_class);
+	class_unregister(&macvtap_class);
 	cdev_del(&macvtap_cdev);
 	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
 	idr_destroy(&minor_idr);
-- 
2.8.0
