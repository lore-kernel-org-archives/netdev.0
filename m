From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 5/7] tuntap: add ioctls to attach
	or detach a	file form tap device
Date: Fri, 12 Aug 2011 09:55:31 +0800
Message-ID: <20110812015531.31613.47224.stgit@intel-e5620-16-2.englab.nay.redhat.com>
References: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This patch adds userspace interface for multi-queue based
tap device. Two new ioctls were added. The first is
TUNATTACHQUEUE which is used to attach an opened file
descriptor to an existed tap device. Another is
TUNDETACHQUEUE which is used to detach an file from an
existed tap device, and this file could be re-attach to the
tap device as a queue again.

After those ioctls were added, userspace can create a
multiqueue tap device by open /dev/net/tap and call
TUNSETIFF, then it could easily control the number of queues
through TUNATTACHQUEUE and TUNDETACHQUEUE.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      |   29 ++++++++++++++++++++++++-----
 include/linux/if_tun.h |    3 +++
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8bc6dff..3bc9dca 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -158,8 +158,8 @@ static int tun_get_slot(struct tun_struct *tun, struct tun_file *tfile)
 			return i;
 	}
 
-       /* Should never happen */
-       BUG_ON(1);
+	/* This is possible when call TUNDETACHQUEUE with wrong ifname */
+	return -1;
 }
 
 /*
@@ -1367,11 +1367,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
+	struct net_device *dev = NULL;
 	void __user* argp = (void __user*)arg;
 	struct ifreq ifr;
 	int ret;
 
-	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
+	if (cmd == TUNSETIFF || cmd == TUNATTACHQUEUE || _IOC_TYPE(cmd) == 0x89)
 		if (copy_from_user(&ifr, argp, ifreq_len))
 			return -EFAULT;
 
@@ -1380,7 +1381,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE,
 				(unsigned int __user*)argp);
 	}
 
@@ -1396,6 +1397,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 		return ret;
 	}
+	if (cmd == TUNDETACHQUEUE) {
+		return tun_detach(tfile, false);
+	}
 
 	rtnl_lock();
 
@@ -1403,7 +1407,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	ret = -EBADFD;
 	tun = rcu_dereference(tfile->tun);
-	if (!tun)
+	if (!tun && cmd != TUNATTACHQUEUE)
 		goto unlock;
 
 
@@ -1418,6 +1422,21 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			ret = -EFAULT;
 		goto out;
 
+       case TUNATTACHQUEUE:
+               dev = __dev_get_by_name(tfile->net, ifr.ifr_name);
+               if (!dev || dev->netdev_ops != &tap_netdev_ops) {
+                       ret = -EINVAL;
+               } else if (ifr.ifr_flags &
+                       ~(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR)) {
+		       /* ignore illegal flag */
+                       ret = -EINVAL;
+               } else {
+                       tfile->flags = TUN_TAP_DEV | TUN_NO_PI | TUN_VNET_HDR;
+                       tun = netdev_priv(dev);
+                       ret = tun_attach(tun, file);
+               }
+               break;
+
 	case TUNSETNOCSUM:
 		/* Disable/Enable checksum */
 
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index c92a291..d3f24d8 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -54,6 +54,9 @@
 #define TUNDETACHFILTER _IOW('T', 214, struct sock_fprog)
 #define TUNGETVNETHDRSZ _IOR('T', 215, int)
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
+#define TUNATTACHQUEUE  _IOW('T', 217, int)
+#define TUNDETACHQUEUE  _IOW('T', 218, int)
+
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
