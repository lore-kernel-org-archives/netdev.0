From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 6/6] tuntap: add ioctls to attach or detach a file form tuntap device
Date: Mon, 25 Jun 2012 19:59:23 +0800
Message-ID: <1340625563-9300-7-git-send-email-jasowang@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Cc: shemminger@vyatta.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces two new ioctls which is used to attach and detach a socket
from tuntap devices:

1) TUNATTACHQUEUE which is used to attach a socket to tuntap device.
2) TUNDETACHQUEUE which is used to detach a socket from tuntap device. It allows
                  a socket to be detached from the device temporarily and could
                  be re-attached again by TUNATTACHQUEUE.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      |   25 ++++++++++++++++++++++---
 include/linux/if_tun.h |    3 +++
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 37e62d3..25d5e1f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1411,11 +1411,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
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
 
@@ -1424,7 +1425,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE,
 				(unsigned int __user*)argp);
 	}
 
@@ -1440,6 +1441,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 		return ret;
 	}
+	if (cmd == TUNDETACHQUEUE)
+		return tun_detach(tfile, false);
 
 	rtnl_lock();
 
@@ -1447,7 +1450,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	ret = -EBADFD;
 	tun = rcu_dereference(tfile->tun);
-	if (!tun)
+	if (!tun && cmd != TUNATTACHQUEUE)
 		goto unlock;
 	else
 		ret = 0;
@@ -1463,6 +1466,22 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			ret = -EFAULT;
 		goto out;
 
+	case TUNATTACHQUEUE:
+		dev = __dev_get_by_name(tfile->net, ifr.ifr_name);
+		if (!dev || (dev->netdev_ops != &tap_netdev_ops &&
+				dev->netdev_ops != &tun_netdev_ops))
+			ret = -EINVAL;
+		else if (ifr.ifr_flags &
+			~(IFF_TAP | IFF_TUN | IFF_NO_PI | IFF_VNET_HDR)) {
+			/* ignore illegal flag */
+			ret = -EINVAL;
+		} else {
+			tun = netdev_priv(dev);
+			tfile->flags = tun->flags;
+			ret = tun_attach(tun, file);
+		}
+		break;
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
-- 
1.7.1
