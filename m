From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/5] macvtap: Fix the minor device number allocation
Date: Thu, 20 Oct 2011 07:29:24 -0700
Message-ID: <m17h3zu46z.fsf_-_@fess.ebiederm.org>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
	<m1sjmnu4cm.fsf@fess.ebiederm.org>
	<m1mxcvu4bk.fsf_-_@fess.ebiederm.org>
	<m1hb33u4ab.fsf_-_@fess.ebiederm.org>
	<m1botbu481.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52000 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755734Ab1JTO2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:28:53 -0400
In-Reply-To: <m1botbu481.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 20 Oct 2011 07:28:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On systems that create and delete lots of dynamic devices the
31bit linux ifindex fails to fit in the 16bit macvtap minor,
resulting in unusable macvtap devices.  I have systems running
automated tests that that hit this condition in just a few days.

Use a linux idr allocator to track which mavtap minor numbers
are available and and to track the association between macvtap
minor numbers and macvtap network devices.

Remove the unnecessary unneccessary check to see if the network
device we have found is indeed a macvtap device.  With macvtap
specific data structures it is impossible to find any other
kind of networking device.

Increase the macvtap minor range from 65536 to the full 20 bits
that is supported by linux device numbers.  It doesn't solve the
original problem but there is no penalty for a larger minor
device range.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/macvtap.c      |   87 ++++++++++++++++++++++++++++++++++++--------
 include/linux/if_macvlan.h |    1 +
 2 files changed, 72 insertions(+), 16 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 25689e9..1b7082d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -51,15 +51,13 @@ static struct proto macvtap_proto = {
 };
 
 /*
- * Minor number matches netdev->ifindex, so need a potentially
- * large value. This also makes it possible to split the
- * tap functionality out again in the future by offering it
- * from other drivers besides macvtap. As long as every device
- * only has one tap, the interface numbers assure that the
- * device nodes are unique.
+ * Variables for dealing with macvtaps device numbers.
  */
 static dev_t macvtap_major;
-#define MACVTAP_NUM_DEVS 65536
+#define MACVTAP_NUM_DEVS (1U << MINORBITS)
+static DEFINE_MUTEX(minor_lock);
+static DEFINE_IDR(minor_idr);
+
 #define GOODCOPY_LEN 128
 static struct class *macvtap_class;
 static struct cdev macvtap_cdev;
@@ -275,6 +273,58 @@ static int macvtap_receive(struct sk_buff *skb)
 	return macvtap_forward(skb->dev, skb);
 }
 
+static int macvtap_get_minor(struct macvlan_dev *vlan)
+{
+	int retval = -ENOMEM;
+	int id;
+
+	mutex_lock(&minor_lock);
+	if (idr_pre_get(&minor_idr, GFP_KERNEL) == 0)
+		goto exit;
+
+	retval = idr_get_new_above(&minor_idr, vlan, 1, &id);
+	if (retval < 0) {
+		if (retval == -EAGAIN)
+			retval = -ENOMEM;
+		goto exit;
+	}
+	if (id < MACVTAP_NUM_DEVS) {
+		vlan->minor = id;
+	} else {
+		printk(KERN_ERR "too many macvtap devices\n");
+		retval = -EINVAL;
+		idr_remove(&minor_idr, id);
+	}
+exit:
+	mutex_unlock(&minor_lock);
+	return retval;
+}
+
+static void macvtap_free_minor(struct macvlan_dev *vlan)
+{
+	mutex_lock(&minor_lock);
+	if (vlan->minor) {
+		idr_remove(&minor_idr, vlan->minor);
+		vlan->minor = 0;
+	}
+	mutex_unlock(&minor_lock);
+}
+
+static struct net_device *dev_get_by_macvtap_minor(int minor)
+{
+	struct net_device *dev = NULL;
+	struct macvlan_dev *vlan;
+
+	mutex_lock(&minor_lock);
+	vlan = idr_find(&minor_idr, minor);
+	if (vlan) {
+		dev = vlan->dev;
+		dev_hold(dev);
+	}
+	mutex_unlock(&minor_lock);
+	return dev;
+}
+
 static int macvtap_newlink(struct net *src_net,
 			   struct net_device *dev,
 			   struct nlattr *tb[],
@@ -329,7 +379,7 @@ static void macvtap_sock_destruct(struct sock *sk)
 static int macvtap_open(struct inode *inode, struct file *file)
 {
 	struct net *net = current->nsproxy->net_ns;
-	struct net_device *dev = dev_get_by_index(net, iminor(inode));
+	struct net_device *dev = dev_get_by_macvtap_minor(iminor(inode));
 	struct macvtap_queue *q;
 	int err;
 
@@ -337,11 +387,6 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	if (!dev)
 		goto out;
 
-	/* check if this is a macvtap device */
-	err = -EINVAL;
-	if (dev->rtnl_link_ops != &macvtap_link_ops)
-		goto out;
-
 	err = -ENOMEM;
 	q = (struct macvtap_queue *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
 					     &macvtap_proto);
@@ -961,12 +1006,15 @@ static int macvtap_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
+	struct macvlan_dev *vlan;
 	struct device *classdev;
 	dev_t devt;
+	int err;
 
 	if (dev->rtnl_link_ops != &macvtap_link_ops)
 		return NOTIFY_DONE;
 
+	vlan = netdev_priv(dev);
 
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -974,15 +1022,22 @@ static int macvtap_device_event(struct notifier_block *unused,
 		 * been registered but before register_netdevice has
 		 * finished running.
 		 */
-		devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
+		err = macvtap_get_minor(vlan);
+		if (err)
+			return notifier_from_errno(err);
+
+		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
 		classdev = device_create(macvtap_class, &dev->dev, devt,
 					 dev, "tap%d", dev->ifindex);
-		if (IS_ERR(classdev))
+		if (IS_ERR(classdev)) {
+			macvtap_free_minor(vlan);
 			return notifier_from_errno(PTR_ERR(classdev));
+		}
 		break;
 	case NETDEV_UNREGISTER:
-		devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
+		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
 		device_destroy(macvtap_class, devt);
+		macvtap_free_minor(vlan);
 		break;
 	}
 
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index e28b2e4..d103dca 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -64,6 +64,7 @@ struct macvlan_dev {
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
 	int			numvtaps;
+	int			minor;
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
-- 
1.7.2.5
