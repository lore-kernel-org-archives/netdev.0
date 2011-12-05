From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 3/5] macvtap: flow director support
Date: Mon, 05 Dec 2011 16:59:06 +0800
Message-ID: <20111205085906.6116.84426.stgit@dhcp-8-146.nay.redhat.com>
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

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvlan.c      |    4 ++++
 drivers/net/macvtap.c      |   36 ++++++++++++++++++++++++++++++++++--
 include/linux/if_macvlan.h |    1 +
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7413497..b0cb7ce 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -706,6 +706,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	vlan->port     = port;
 	vlan->receive  = receive;
 	vlan->forward  = forward;
+	vlan->fd_page[0] = NULL;
 
 	vlan->mode     = MACVLAN_MODE_VEPA;
 	if (data && data[IFLA_MACVLAN_MODE])
@@ -749,6 +750,9 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->fd_page[0])
+		put_page(vlan->fd_page[0]);
+
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 }
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 504c745..a34eb84 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -14,6 +14,7 @@
 #include <linux/wait.h>
 #include <linux/cdev.h>
 #include <linux/fs.h>
+#include <linux/highmem.h>
 
 #include <net/net_namespace.h>
 #include <net/rtnetlink.h>
@@ -62,6 +63,8 @@ static DEFINE_IDR(minor_idr);
 static struct class *macvtap_class;
 static struct cdev macvtap_cdev;
 
+#define TAP_HASH_MASK 0xFF
+
 static const struct proto_ops macvtap_socket_ops;
 
 /*
@@ -189,6 +192,11 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 	/* Check if we can use flow to select a queue */
 	rxq = skb_get_rxhash(skb);
 	if (rxq) {
+		if (vlan->fd_page[0]) {
+			u16 *table = kmap_atomic(vlan->fd_page[0]);
+			rxq = table[rxq & TAP_HASH_MASK];
+			kunmap_atomic(table);
+		}
 		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
 		if (tap)
 			goto out;
@@ -851,6 +859,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 {
 	struct macvtap_queue *q = file->private_data;
 	struct macvlan_dev *vlan;
+	struct tun_fd tfd;
 	void __user *argp = (void __user *)arg;
 	struct ifreq __user *ifr = argp;
 	unsigned int __user *up = argp;
@@ -891,8 +900,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case TUNGETFEATURES:
-		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR | IFF_RXHASH,
-			     up))
+		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR | IFF_RXHASH |
+			     IFF_FD, up))
 			return -EFAULT;
 		return 0;
 
@@ -918,6 +927,29 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		q->vnet_hdr_sz = s;
 		return 0;
 
+	case TUNSETFD:
+		rcu_read_lock_bh();
+		vlan = rcu_dereference(q->vlan);
+		if (!vlan)
+			ret = -ENOLINK;
+		else {
+			if (copy_from_user(&tfd, argp, sizeof(tfd)))
+				ret = -EFAULT;
+			if (vlan->fd_page[0]) {
+				put_page(vlan->fd_page[0]);
+				vlan->fd_page[0] = NULL;
+			}
+
+			/* put_page() in macvlan_dellink() */
+			if (get_user_pages_fast(tfd.addr, 1, 0,
+						&vlan->fd_page[0]) != 1)
+				ret = -EFAULT;
+			else
+				ret = 0;
+		}
+		rcu_read_unlock_bh();
+		return ret;
+
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index d103dca..69a87a1 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -65,6 +65,7 @@ struct macvlan_dev {
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
 	int			numvtaps;
 	int			minor;
+	struct page             *fd_page[1];
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
