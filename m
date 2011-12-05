From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 2/5] tuntap: simple flow director support
Date: Mon, 05 Dec 2011 16:58:57 +0800
Message-ID: <20111205085857.6116.99252.stgit@dhcp-8-146.nay.redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch adds a simple flow director to tun/tap device. It is just a
page that contains the hash to queue mapping which could be changed by
user-space. The backend (tap/macvtap) would query this table to get
the desired queue of a packets when it send packets to userspace.

The page address were set through a new kind of ioctl - TUNSETFD and
were pinned until device exit or another new page were specified.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      |   63 ++++++++++++++++++++++++++++++++++++++++--------
 include/linux/if_tun.h |   10 ++++++++
 2 files changed, 62 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7d22b4b..2efaf81 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -64,6 +64,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/highmem.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -109,6 +110,7 @@ struct tap_filter {
 };
 
 #define MAX_TAP_QUEUES (NR_CPUS < 16 ? NR_CPUS : 16)
+#define TAP_HASH_MASK  0xFF
 
 struct tun_file {
 	struct sock sk;
@@ -128,6 +130,7 @@ struct tun_sock;
 
 struct tun_struct {
 	struct tun_file		*tfiles[MAX_TAP_QUEUES];
+	struct page             *fd_page[1];
 	unsigned int            numqueues;
 	unsigned int 		flags;
 	uid_t			owner;
@@ -156,7 +159,7 @@ static struct tun_file *tun_get_queue(struct net_device *dev,
 	struct tun_struct *tun = netdev_priv(dev);
 	struct tun_file *tfile = NULL;
 	int numqueues = tun->numqueues;
-	__u32 rxq;
+	__u32 rxq, rxhash;
 
 	BUG_ON(!rcu_read_lock_held());
 
@@ -168,6 +171,22 @@ static struct tun_file *tun_get_queue(struct net_device *dev,
 		goto out;
 	}
 
+	rxhash = skb_get_rxhash(skb);
+	if (rxhash) {
+		if (tun->fd_page[0]) {
+			u16 *table = kmap_atomic(tun->fd_page[0]);
+			rxq = table[rxhash & TAP_HASH_MASK];
+			kunmap_atomic(table);
+			if (rxq < numqueues) {
+				tfile = rcu_dereference(tun->tfiles[rxq]);
+				goto out;
+			}
+		}
+		rxq = ((u64)rxhash * numqueues) >> 32;
+		tfile = rcu_dereference(tun->tfiles[rxq]);
+		goto out;
+	}
+
 	if (likely(skb_rx_queue_recorded(skb))) {
 		rxq = skb_get_rx_queue(skb);
 
@@ -178,14 +197,6 @@ static struct tun_file *tun_get_queue(struct net_device *dev,
 		goto out;
 	}
 
-	/* Check if we can use flow to select a queue */
-	rxq = skb_get_rxhash(skb);
-	if (rxq) {
-		u32 idx = ((u64)rxq * numqueues) >> 32;
-		tfile = rcu_dereference(tun->tfiles[idx]);
-		goto out;
-	}
-
 	tfile = rcu_dereference(tun->tfiles[0]);
 out:
 	return tfile;
@@ -1020,6 +1031,14 @@ out:
 	return ret;
 }
 
+static void tun_destructor(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	if (tun->fd_page[0])
+		put_page(tun->fd_page[0]);
+	free_netdev(dev);
+}
+
 static void tun_setup(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
@@ -1028,7 +1047,7 @@ static void tun_setup(struct net_device *dev)
 	tun->group = -1;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = tun_destructor;
 }
 
 /* Trivial set of netlink ops to allow deleting tun or tap
@@ -1230,6 +1249,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;
+		tun->fd_page[0] = NULL;
 
 		security_tun_dev_post_create(&tfile->sk);
 
@@ -1353,6 +1373,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	struct net_device *dev = NULL;
 	void __user* argp = (void __user*)arg;
 	struct ifreq ifr;
+	struct tun_fd tfd;
 	int ret;
 
 	if (cmd == TUNSETIFF || cmd == TUNATTACHQUEUE || _IOC_TYPE(cmd) == 0x89)
@@ -1364,7 +1385,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE | IFF_RXHASH,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE | IFF_RXHASH |
+				IFF_FD,
 				(unsigned int __user*)argp);
 	}
 
@@ -1476,6 +1498,25 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		ret = set_offload(tun, arg);
 		break;
 
+	case TUNSETFD:
+		if (copy_from_user(&tfd, argp, sizeof(tfd)))
+			ret = -EFAULT;
+		else {
+			if (tun->fd_page[0]) {
+				put_page(tun->fd_page[0]);
+				tun->fd_page[0] = NULL;
+			}
+
+			/* put_page() in tun_destructor() */
+			if (get_user_pages_fast(tfd.addr, 1, 0,
+						&tun->fd_page[0]) != 1)
+				ret = -EFAULT;
+			else
+				ret = 0;
+		}
+
+		break;
+
 	case SIOCGIFHWADDR:
 		/* Get hw address */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev->dev_addr, ETH_ALEN);
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index a1f6f3f..726731d 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -36,6 +36,8 @@
 #define TUN_VNET_HDR 	0x0200
 #define TUN_TAP_MQ      0x0400
 
+struct tun_fd;
+
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
 #define TUNSETDEBUG   _IOW('T', 201, int) 
@@ -56,6 +58,7 @@
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNATTACHQUEUE  _IOW('T', 217, int)
 #define TUNDETACHQUEUE  _IOW('T', 218, int)
+#define TUNSETFD        _IOW('T', 219, struct tun_fd)
 
 
 /* TUNSETIFF ifr flags */
@@ -67,6 +70,7 @@
 #define IFF_TUN_EXCL	0x8000
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_RXHASH      0x0200
+#define IFF_FD          0x0400
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
@@ -97,6 +101,12 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+/* Programmable flow director */
+struct tun_fd {
+	unsigned long addr;
+	size_t size;
+};
+
 #ifdef __KERNEL__
 #if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
 struct socket *tun_get_socket(struct file *);
