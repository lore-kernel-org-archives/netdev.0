From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC] macvlan: add tap device backend
Date: Thu,  3 Dec 2009 18:52:00 +0100
Message-ID: <1259862720-28432-3-git-send-email-arnd@arndb.de>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller\"" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754066AbZLCRwp@vger.kernel.org>
In-Reply-To: <1259862720-28432-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a second prototype of a new interface into the network
stack, to eventually replace tun/tap and the bridge driver
in certain virtual machine setups. The code has changed
significantly, but the goals still remain.

Background
----------
The 'Edge Virtual Bridging' working group is discussing ways to overcome
the limitation of virtual bridges in hypervisors.  One important part
of this is the Virtual Ethernet Port Aggregator (VEPA), as described in
http://www.ieee802.org/1/files/public/docs2009/new-evb-congdon-vepa-modular-0709-v01.pdf

In short, the idea of VEPA is that virtual machines do not communicate
with each other through direct bridging in the hypervisor but only via
an external managed switch that is already well integrated into the data
center, including network filtering, accounting and monitoring. While
we can do most of that efficiently in the Linux bridge code, doing it
externally simplifies the overall setup.

The macvlan code itself now has a bridge-like mode that allows its
slaves to communicate directly, without any of the overhead or the
features of the bridge code.

Related work
------------
The Linux bridge code can now be configured to hairpin mode as the
remote end for macvlan in VEPA mode, thanks to patches from Anna
Fischer. The respective patches to implement VEPA itself in the
bridge code did not get merged because macvlan can do this better.

Or Gerlitz posted a "raw" packet socket backend for qemu to deal with this,
at http://marc.info/?l=qemu-devel&m=124653801212767 and at least three
other people have done a similar functionality independently.
For use with qemu, that raw socket on macvlan should have similar
performance characteristics as macvtap, but would not allow managing
priviledges or doing some of the planned features.

This driver
-----------
While the other approaches should work as well, doing it using a tap
interface should give additional benefits:

* We can keep using the optimizations for jumbo frames that we have put
into the tun/tap driver.

* No need for root permissions that packet sockets need, just use 'ip
link add link type macvtap' to create a new device and give it the right
permissions using udev (using one tap per macvlan netdev).

* support for multiqueue network adapters by opening the tap device
multiple times, using one file descriptor per guest CPU/network
queue/interrupt (if the adapter supports multiple queues on a single
MAC address).

* support for zero-copy receive/transmit using async I/O on the tap device
(if the adapter supports per MAC rx queues).

* The same framework in macvlan can be used to add a third backend
into a future kernel based virtio-net implementation.

This version of the driver does not support any of those features,
but they all appear possible to add ;).
The driver is currently called 'macvtap', which seems to have
stuck, although I would prefer if someone came up with a clearer
name for this thing.

The code is pretty much complete for integration into the
staging tree, but it has seen zero testing since the last
major rework that changed the code to be based around struct
sock as Michael suggested. I'm pretty sure that it does not
work as is, but I don't expect large changes to be necessary.

I'm posting this mainly to solicit feedback. Not sure how
chances for integration into 2.6.33 are, given that the merge
window is opening already.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: David S. Miller" <davem@davemloft.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Or Gerlitz <ogerlitz@voltaire.com>
Cc: "Fischer, Anna" <anna.fischer@hp.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: bridge@lists.linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: Edge Virtual Bridging <evb@yahoogroups.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/Kconfig   |   12 +
 drivers/net/Makefile  |    1 +
 drivers/net/macvtap.c |  561 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 574 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/macvtap.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0bbd5ae..c072027 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -90,6 +90,18 @@ config MACVLAN
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvlan.
 
+config MACVTAP
+	tristate "MAC-VLAN based tap driver (EXPERIMENTAL)"
+	depends on MACVLAN
+	help
+	  This adds a specialized tap character device driver that is based
+	  on the MAC-VLAN network interface, called macvtap. A macvtap device
+	  can be added in the same way as a macvlan device, using 'type
+	  macvlan', and then be accessed through the tap user space interface.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called macvtap.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 246323d..ae553fb 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -167,6 +167,7 @@ obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
 obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
+obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
 obj-$(CONFIG_LANCE) += lance.o
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
new file mode 100644
index 0000000..c61b504
--- /dev/null
+++ b/drivers/net/macvtap.c
@@ -0,0 +1,561 @@
+#include <linux/etherdevice.h>
+#include <linux/if_macvlan.h>
+#include <linux/nsproxy.h>
+#include <linux/compat.h>
+#include <linux/if_tun.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/cache.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/wait.h>
+#include <linux/cdev.h>
+#include <linux/fs.h>
+
+#include <net/net_namespace.h>
+#include <net/rtnetlink.h>
+#include <net/sock.h>
+
+/*
+ * A macvtap queue is the central object of this driver, it connects
+ * an open character device to a macvlan interface. There can be
+ * multiple queues on one interface, which map back to queues
+ * implemented in hardware on the underlying device.
+ *
+ * macvtap_proto is used to allocate queues through the sock allocation
+ * mechanism.
+ *
+ * TODO: multiqueue support is currently not implemented, even though
+ * macvtap is basically prepared for that. We will need to add this
+ * here as well as in virtio-net and qemu to get line rate on 10gbit
+ * adapters from a guest.
+ */
+struct macvtap_queue {
+	struct sock sk;
+	wait_queue_head_t wait;
+	struct macvlan_dev *vlan;
+	struct file *file;
+};
+
+static struct proto macvtap_proto = {
+	.name = "macvtap",
+	.owner = THIS_MODULE,
+	.obj_size = sizeof (struct macvtap_queue),
+};
+
+/*
+ * Minor number matches netdev->ifindex, so need a potentially
+ * large value. This also makes it possible to split the
+ * tap functionality out again in the future by offering it
+ * from other drivers besides macvtap. As long as every device
+ * only has one tap, the interface numbers assure that the
+ * device nodes are unique.
+ */
+static unsigned int macvtap_major;
+#define MACVTAP_NUM_DEVS 65536
+static struct class *macvtap_class;
+static struct cdev macvtap_cdev;
+
+/*
+ * RCU usage:
+ * The macvtap_queue is referenced both from the chardev struct file
+ * and from the struct macvlan_dev using rcu_read_lock.
+ *
+ * We never actually update the contents of a macvtap_queue atomically
+ * with RCU but it is used for race-free destruction of a queue when
+ * either the file or the macvlan_dev goes away. Pointers back to
+ * the dev and the file are implicitly valid as long as the queue
+ * exists.
+ *
+ * The callbacks from macvlan are always done with rcu_read_lock held
+ * already, while in the file_operations, we get it ourselves.
+ *
+ * When destroying a queue, we remove the pointers from the file and
+ * from the dev and then synchronize_rcu to make sure no thread is
+ * still using the queue. There may still be references to the struct
+ * sock inside of the queue from outbound SKBs, but these never
+ * reference back to the file or the dev. The data structure is freed
+ * through __sk_free when both our references and any pending SKBs
+ * are gone.
+ *
+ * macvtap_lock is only used to prevent multiple concurrent open()
+ * calls to assign a new vlan->tap pointer. It could be moved into
+ * the macvlan_dev itself but is extremely rarely used.
+ */
+static DEFINE_SPINLOCK(macvtap_lock);
+
+/*
+ * Choose the next free queue, for now there is only one
+ */
+static int macvtap_set_queue(struct net_device *dev, struct file *file,
+				struct macvtap_queue *q)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err = -EBUSY;
+
+	spin_lock(&macvtap_lock);
+	if (rcu_dereference(vlan->tap))
+		goto out;
+
+	err = 0;
+	q->vlan = vlan;
+	rcu_assign_pointer(vlan->tap, q);
+
+	q->file = file;
+	rcu_assign_pointer(file->private_data, q);
+
+out:
+	spin_unlock(&macvtap_lock);
+	return err;
+}
+
+/*
+ * We must destroy each queue exactly once, when either
+ * the netdev or the file go away.
+ *
+ * Using the spinlock makes sure that we don't get
+ * to the queue again after destroying it.
+ *
+ * synchronize_rcu serializes with the packet flow
+ * that uses rcu_read_lock.
+ */
+static void macvtap_del_queue(struct macvtap_queue **qp)
+{
+	struct macvtap_queue *q;
+
+	spin_lock(&macvtap_lock);
+	q = rcu_dereference(*qp);
+	if (!q) {
+		spin_unlock(&macvtap_lock);
+		return;
+	}
+
+	rcu_assign_pointer(q->vlan->tap, NULL);
+	rcu_assign_pointer(q->file->private_data, NULL);
+	spin_unlock(&macvtap_lock);
+
+	synchronize_rcu();
+	sock_put(&q->sk);
+}
+
+/*
+ * Since we only support one queue, just dereference the pointer.
+ */
+static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
+					       struct sk_buff *skb)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	return rcu_dereference(vlan->tap);
+}
+
+static void macvtap_del_queues(struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	macvtap_del_queue(&vlan->tap);
+}
+
+static inline struct macvtap_queue *macvtap_file_get_queue(struct file *file)
+{
+	rcu_read_lock();
+	return rcu_dereference(file->private_data);
+}
+
+static inline void macvtap_file_put_queue(void)
+{
+	rcu_read_unlock();
+}
+
+/*
+ * Forward happens for data that gets sent from one macvlan
+ * endpoint to another one in bridge mode. We just take
+ * the skb and put it into the receive queue.
+ */
+static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
+{
+	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
+	if (!q)
+		return -ENOLINK;
+
+	skb_queue_tail(&q->sk.sk_receive_queue, skb);
+	wake_up(q->sk.sk_sleep);
+	return 0;
+}
+
+/*
+ * Receive is for data from the external interface (lowerdev),
+ * in case of macvtap, we can treat that the same way as
+ * forward, which macvlan cannot.
+ */
+static int macvtap_receive(struct sk_buff *skb)
+{
+	return macvtap_forward(skb->dev, skb);
+}
+
+static int macvtap_newlink(struct net *src_net,
+			   struct net_device *dev,
+			   struct nlattr *tb[],
+			   struct nlattr *data[])
+{
+	struct device *classdev;
+	dev_t devt;
+	int err;
+
+	err = macvlan_common_newlink(src_net, dev, tb, data,
+				     macvtap_receive, macvtap_forward);
+	if (err)
+		goto out;
+
+	devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
+
+	classdev = device_create(macvtap_class, &dev->dev, devt,
+				 dev, "tap%d", dev->ifindex);
+	if (IS_ERR(classdev)) {
+		err = PTR_ERR(classdev);
+		macvtap_del_queues(dev);
+		macvlan_dellink(dev, NULL);
+	}
+
+out:
+	return err;
+}
+
+static void macvtap_dellink(struct net_device *dev,
+			    struct list_head *head)
+{
+	device_destroy(macvtap_class,
+		       MKDEV(MAJOR(macvtap_major), dev->ifindex));
+
+	macvtap_del_queues(dev);
+	macvlan_dellink(dev, head);
+}
+
+static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
+	.kind		= "macvtap",
+	.newlink	= macvtap_newlink,
+	.dellink	= macvtap_dellink,
+};
+
+
+static int macvtap_open(struct inode *inode, struct file *file)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct net_device *dev = dev_get_by_index(net, iminor(inode));
+	struct macvtap_queue *q;
+	int err;
+
+	err = -ENODEV;
+	if (!dev)
+		goto out;
+
+	/* check if this is a macvtap device */
+	err = -EINVAL;
+	if (dev->rtnl_link_ops != &macvtap_link_ops)
+		goto out;
+
+	err = -ENOMEM;
+	q = (struct macvtap_queue *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
+					     &macvtap_proto);
+	if (!q)
+		goto out;
+
+	sock_init_data(NULL, &q->sk);
+	init_waitqueue_head(&q->wait);
+	q->sk.sk_sleep = &q->wait;
+
+	err = macvtap_set_queue(dev, file, q);
+	if (err)
+		sock_put(&q->sk);
+
+out:
+	return err;
+}
+
+static int macvtap_release(struct inode *inode, struct file *file)
+{
+	macvtap_del_queue((struct macvtap_queue **)&file->private_data);
+	return 0;
+}
+
+static unsigned int macvtap_poll(struct file *file, poll_table * wait)
+{
+	struct macvtap_queue *q = macvtap_file_get_queue(file);
+	unsigned int mask = POLLERR;
+
+	if (!q)
+		goto out;
+
+	mask = 0;
+	poll_wait(file, &q->wait, wait);
+
+	if (!skb_queue_empty(&q->sk.sk_receive_queue))
+		mask |= POLLIN | POLLRDNORM;
+
+	if (sock_writeable(&q->sk))
+		mask |= POLLOUT | POLLWRNORM;
+
+out:
+	macvtap_file_put_queue();
+	return mask;
+}
+
+/* Get packet from user space buffer */
+static ssize_t macvtap_get_user(struct macvtap_queue *q,
+				const struct iovec *iv, size_t count,
+				int noblock)
+{
+	struct sk_buff *skb;
+	size_t len = count;
+	int err;
+
+	if (unlikely(len < ETH_HLEN))
+		return -EINVAL;
+
+	skb = sock_alloc_send_skb(&q->sk, NET_IP_ALIGN + len, noblock, &err);
+
+	if (!skb) {
+		macvlan_count_rx(q->vlan, 0, false, false);
+		return err;
+	}
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb_put(skb, count);
+
+	if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
+		macvlan_count_rx(q->vlan, 0, false, false);
+		kfree_skb(skb);
+		return -EFAULT;
+	}
+
+	skb_set_network_header(skb, ETH_HLEN);
+
+	macvlan_start_xmit(skb, q->vlan->dev);
+
+	return count;
+}
+
+static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
+				 unsigned long count, loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	ssize_t result = -ENOLINK;
+	struct macvtap_queue *q = macvtap_file_get_queue(file);
+
+	if (!q)
+		goto out;
+
+	result = macvtap_get_user(q, iv, iov_length(iv, count),
+			      file->f_flags & O_NONBLOCK);
+out:
+	macvtap_file_put_queue();
+	return result;
+}
+
+/* Put packet to the user space buffer */
+static ssize_t macvtap_put_user(struct macvtap_queue *q,
+				const struct sk_buff *skb,
+				const struct iovec *iv, int len)
+{
+	struct macvlan_dev *vlan = q->vlan;
+	int ret;
+
+	len = min_t(int, skb->len, len);
+
+	ret = skb_copy_datagram_const_iovec(skb, 0, iv, 0, len);
+
+	macvlan_count_rx(vlan, len, ret == 0, 0);
+
+	return ret ? ret : len;
+}
+
+static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
+				unsigned long count, loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	struct macvtap_queue *q = macvtap_file_get_queue(file);
+
+	DECLARE_WAITQUEUE(wait, current);
+	struct sk_buff *skb;
+	ssize_t len, ret = 0;
+
+	if (!q) {
+		ret = -ENOLINK;
+		goto out;
+	}
+
+	len = iov_length(iv, count);
+	if (len < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	add_wait_queue(q->sk.sk_sleep, &wait);
+	while (len) {
+		current->state = TASK_INTERRUPTIBLE;
+
+		/* Read frames from the queue */
+		skb = skb_dequeue(&q->sk.sk_receive_queue);
+		if (!skb) {
+			if (file->f_flags & O_NONBLOCK) {
+				ret = -EAGAIN;
+				break;
+			}
+			if (signal_pending(current)) {
+				ret = -ERESTARTSYS;
+				break;
+			}
+			/* Nothing to read, let's sleep */
+			schedule();
+			continue;
+		}
+		skb_push(skb, ETH_HLEN);
+		ret = macvtap_put_user(q, skb, iv, len);
+		kfree_skb(skb);
+		break;
+	}
+
+	current->state = TASK_RUNNING;
+	remove_wait_queue(q->sk.sk_sleep, &wait);
+
+out:
+	macvtap_file_put_queue();
+	return ret;
+}
+
+/*
+ * provide compatibility with generic tun/tap interface
+ */
+static long macvtap_ioctl(struct file *file, unsigned int cmd,
+			  unsigned long arg)
+{
+	struct macvtap_queue *q;
+	void __user *argp = (void __user *)arg;
+	struct ifreq __user *ifr = argp;
+	unsigned int __user *up = argp;
+	unsigned int u;
+	int err;
+
+	switch (cmd) {
+	case TUNSETIFF:
+		/* ignore the name, just look at flags */
+		if (get_user(u, &ifr->ifr_flags))
+			return -EFAULT;
+		if (u != (TUN_TAP_DEV | TUN_NO_PI))
+			return -EINVAL;
+		return 0;
+
+	case TUNGETIFF:
+		q = macvtap_file_get_queue(file);
+		if (!q)
+			return -ENOLINK;
+		err = 0;
+		if (copy_to_user(&ifr->ifr_name, q->vlan->dev->name, IFNAMSIZ) ||
+		    put_user((TUN_TAP_DEV | TUN_NO_PI), &ifr->ifr_flags))
+			err = -EFAULT;
+		macvtap_file_put_queue();
+		return err;
+
+	case TUNGETFEATURES:
+		u = TUN_TAP_DEV | TUN_NO_PI;
+		if (put_user((TUN_TAP_DEV | TUN_NO_PI), up))
+			return -EFAULT;
+		return 0;
+
+	case TUNSETSNDBUF:
+		/* ignore */
+		return 0;
+
+	case TUNSETOFFLOAD:
+		if (get_user(u, up))
+			return -EFAULT;
+
+		/* let the user check for future flags */
+		if (u & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
+			  TUN_F_TSO_ECN | TUN_F_UFO))
+			return -EINVAL;
+
+		/* TODO: add support for these, so far we don't
+			 support any offload */
+		if (u & (TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
+			 TUN_F_TSO_ECN | TUN_F_UFO))
+			return -EINVAL;
+
+		return 0;
+
+	default:
+		return -EINVAL;
+	}
+}
+
+#ifdef CONFIG_COMPAT
+static long macvtap_compat_ioctl(struct file *file, unsigned int cmd,
+				 unsigned long arg)
+{
+	return macvtap_ioctl(file, cmd, (unsigned long)compat_ptr(arg));
+}
+#endif
+
+static const struct file_operations macvtap_fops = {
+	.owner		= THIS_MODULE,
+	.open		= macvtap_open,
+	.release	= macvtap_release,
+	.aio_read	= macvtap_aio_read,
+	.aio_write	= macvtap_aio_write,
+	.poll		= macvtap_poll,
+	.llseek		= no_llseek,
+	.unlocked_ioctl	= macvtap_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= macvtap_compat_ioctl,
+#endif
+};
+
+static int macvtap_init(void)
+{
+	int err;
+
+	err = alloc_chrdev_region(&macvtap_major, 0,
+				MACVTAP_NUM_DEVS, "macvtap");
+	if (err)
+		goto out1;
+
+	cdev_init(&macvtap_cdev, &macvtap_fops);
+	err = cdev_add(&macvtap_cdev, macvtap_major, MACVTAP_NUM_DEVS);
+	if (err)
+		goto out2;
+
+	macvtap_class = class_create(THIS_MODULE, "macvtap");
+	if (IS_ERR(macvtap_class)) {
+		err = PTR_ERR(macvtap_class);
+		goto out3;
+	}
+
+	err = macvlan_link_register(&macvtap_link_ops);
+	if (err)
+		goto out4;
+
+	return 0;
+
+out4:
+	class_unregister(macvtap_class);
+out3:
+	cdev_del(&macvtap_cdev);
+out2:
+	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
+out1:
+	return err;
+}
+module_init(macvtap_init);
+
+static void macvtap_exit(void)
+{
+	rtnl_link_unregister(&macvtap_link_ops);
+	class_unregister(macvtap_class);
+	cdev_del(&macvtap_cdev);
+	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
+}
+module_exit(macvtap_exit);
+
+MODULE_ALIAS_RTNL_LINK("macvtap");
+MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
+MODULE_LICENSE("GPL");
-- 
1.6.3.3
