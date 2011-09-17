From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V2 PATCH 5/5] tuntap: add ioctls to attach or detach a
	file form tap device
Date: Sat, 17 Sep 2011 14:03:00 +0800
Message-ID: <20110917060300.32666.5700.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	mirq-linux@rere.qmqm.pl, joe@perches.com, shemminger@vyatta.com
To: krkumar2@in.ibm.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New ioctls were added to let multiple files/sockets to be attached to
a tap device.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      |   25 ++++++++++++++++++++++---
 include/linux/if_tun.h |    3 +++
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ec29f85..6a1b591 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1343,11 +1343,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
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
 
@@ -1356,7 +1357,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE,
 				(unsigned int __user*)argp);
 	}
 
@@ -1372,6 +1373,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 		return ret;
 	}
+	if (cmd == TUNDETACHQUEUE) {
+		return tun_detach(tfile, false);
+	}
 
 	rtnl_lock();
 
@@ -1379,7 +1383,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	ret = -EBADFD;
 	tun = rcu_dereference(tfile->tun);
-	if (!tun)
+	if (!tun && cmd != TUNATTACHQUEUE)
 		goto unlock;
 
 
@@ -1394,6 +1398,21 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
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
