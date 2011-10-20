From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/5] macvtap: Rewrite macvtap_newlink so the error handling works.
Date: Thu, 20 Oct 2011 07:28:46 -0700
Message-ID: <m1botbu481.fsf_-_@fess.ebiederm.org>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
	<m1sjmnu4cm.fsf@fess.ebiederm.org>
	<m1mxcvu4bk.fsf_-_@fess.ebiederm.org>
	<m1hb33u4ab.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58260 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab1JTO2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:28:15 -0400
In-Reply-To: <m1hb33u4ab.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 20 Oct 2011 07:27:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Place macvlan_common_newlink at the end of macvtap_newlink because
failing in newlink after registering your network device is not
supported.

Move device_create into a netdevice creation notifier.   The network device
notifier is the only hook that is called after the network device has been
registered with the device layer and before register_network_device returns
success.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/macvtap.c |   73 +++++++++++++++++++++++++++++++++----------------
 1 files changed, 49 insertions(+), 24 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 515aa87..25689e9 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -280,34 +280,16 @@ static int macvtap_newlink(struct net *src_net,
 			   struct nlattr *tb[],
 			   struct nlattr *data[])
 {
-	struct device *classdev;
-	dev_t devt;
-	int err;
-
-	err = macvlan_common_newlink(src_net, dev, tb, data,
-				     macvtap_receive, macvtap_forward);
-	if (err)
-		goto out;
-
-	devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
-
-	classdev = device_create(macvtap_class, &dev->dev, devt,
-				 dev, "tap%d", dev->ifindex);
-	if (IS_ERR(classdev)) {
-		err = PTR_ERR(classdev);
-		macvtap_del_queues(dev);
-	}
-
-out:
-	return err;
+	/* Don't put anything that may fail after macvlan_common_newlink
+	 * because we can't undo what it does.
+	 */
+	return macvlan_common_newlink(src_net, dev, tb, data,
+				      macvtap_receive, macvtap_forward);
 }
 
 static void macvtap_dellink(struct net_device *dev,
 			    struct list_head *head)
 {
-	device_destroy(macvtap_class,
-		       MKDEV(MAJOR(macvtap_major), dev->ifindex));
-
 	macvtap_del_queues(dev);
 	macvlan_dellink(dev, head);
 }
@@ -975,6 +957,42 @@ struct socket *macvtap_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(macvtap_get_socket);
 
+static int macvtap_device_event(struct notifier_block *unused,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct device *classdev;
+	dev_t devt;
+
+	if (dev->rtnl_link_ops != &macvtap_link_ops)
+		return NOTIFY_DONE;
+
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		/* Create the device node here after the network device has
+		 * been registered but before register_netdevice has
+		 * finished running.
+		 */
+		devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
+		classdev = device_create(macvtap_class, &dev->dev, devt,
+					 dev, "tap%d", dev->ifindex);
+		if (IS_ERR(classdev))
+			return notifier_from_errno(PTR_ERR(classdev));
+		break;
+	case NETDEV_UNREGISTER:
+		devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
+		device_destroy(macvtap_class, devt);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block macvtap_notifier_block __read_mostly = {
+	.notifier_call	= macvtap_device_event,
+};
+
 static int macvtap_init(void)
 {
 	int err;
@@ -995,12 +1013,18 @@ static int macvtap_init(void)
 		goto out3;
 	}
 
-	err = macvlan_link_register(&macvtap_link_ops);
+	err = register_netdevice_notifier(&macvtap_notifier_block);
 	if (err)
 		goto out4;
 
+	err = macvlan_link_register(&macvtap_link_ops);
+	if (err)
+		goto out5;
+
 	return 0;
 
+out5:
+	unregister_netdevice_notifier(&macvtap_notifier_block);
 out4:
 	class_unregister(macvtap_class);
 out3:
@@ -1015,6 +1039,7 @@ module_init(macvtap_init);
 static void macvtap_exit(void)
 {
 	rtnl_link_unregister(&macvtap_link_ops);
+	unregister_netdevice_notifier(&macvtap_notifier_block);
 	class_unregister(macvtap_class);
 	cdev_del(&macvtap_cdev);
 	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
-- 
1.7.2.5
