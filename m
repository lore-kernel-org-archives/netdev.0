From: Marc Angel <marc@arista.com>
Subject: [PATCH net-next v2] macvtap: add namespace support to the sysfs device class
Date: Tue,  3 May 2016 20:30:54 +0200
Message-ID: <1462300254-22273-1-git-send-email-marc@arista.com>
References: <CAPSAET_u3CYvhYgyxXdomi7n5Z6c1DTCpSMv=K544U=TjmM=cw@mail.gmail.com>
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37521 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756AbcECSaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 14:30:18 -0400
Received: by mail-wm0-f50.google.com with SMTP id a17so54724448wme.0
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 11:30:17 -0700 (PDT)
In-Reply-To: <CAPSAET_u3CYvhYgyxXdomi7n5Z6c1DTCpSMv=K544U=TjmM=cw@mail.gmail.com>
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
 drivers/net/macvtap.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394ed..b7ebfcd 100644
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
@@ -1274,6 +1285,7 @@ static int macvtap_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	const char *tap_name = kasprintf(GFP_KERNEL, "tap%d", dev->ifindex);
 	struct macvlan_dev *vlan;
 	struct device *classdev;
 	dev_t devt;
@@ -1295,16 +1307,21 @@ static int macvtap_device_event(struct notifier_block *unused,
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
+					dev_name(classdev));
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
@@ -1330,11 +1347,9 @@ static int macvtap_init(void)
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
@@ -1349,7 +1364,7 @@ static int macvtap_init(void)
 out5:
 	unregister_netdevice_notifier(&macvtap_notifier_block);
 out4:
-	class_unregister(macvtap_class);
+	class_unregister(&macvtap_class);
 out3:
 	cdev_del(&macvtap_cdev);
 out2:
@@ -1363,7 +1378,7 @@ static void macvtap_exit(void)
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
