From: akpm@osdl.org
Subject: [patch 04/10] Multicast filtering for tun.c
Date: Tue, 04 Jan 2005 21:59:30 -0800
Message-ID: <200501050559.j055xc614681@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org, sjackman@gmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Shaun Jackman <sjackman@gmail.com>

This patch adds multicast filtering to the TUN network driver, for
packets being sent from the network device to the character device.

* drivers/net/tun.c: Add multicast filtering for packets travelling from
  the network device to the character device.

* include/linux/if_tun.h (tun_struct): Add interface flags, a hardware
  device addres, and a multicast filter.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tun.c      |  151 +++++++++++++++++++++++++++++++++++++----
 25-akpm/include/linux/if_tun.h |    5 +
 2 files changed, 144 insertions(+), 12 deletions(-)

diff -puN drivers/net/tun.c~multicast-filtering-for-tunc drivers/net/tun.c
--- 25/drivers/net/tun.c~multicast-filtering-for-tunc	2005-01-04 21:57:35.804691144 -0800
+++ 25-akpm/drivers/net/tun.c	2005-01-04 21:57:35.810690232 -0800
@@ -41,6 +41,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
+#include <linux/crc32.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -104,11 +105,42 @@ drop:
 	return 0;
 }
 
-static void tun_net_mclist(struct net_device *dev)
+/** Add the specified Ethernet address to this multicast filter. */
+static void
+add_multi(u32* filter, const u8* addr)
 {
-	/* Nothing to do for multicast filters. 
-	 * We always accept all frames. */
-	return;
+	int bit_nr = ether_crc(ETH_ALEN, addr) >> 26;
+	filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+}
+
+/** Remove the specified Ethernet addres from this multicast filter. */
+static void
+del_multi(u32* filter, const u8* addr)
+{
+	int bit_nr = ether_crc(ETH_ALEN, addr) >> 26;
+	filter[bit_nr >> 5] &= ~(1 << (bit_nr & 31));
+}
+
+/** Update the list of multicast groups to which the network device belongs.
+ * This list is used to filter packets being sent from the character device to
+ * the network device. */
+static void
+tun_net_mclist(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	const struct dev_mc_list *mclist;
+	int i;
+	DBG(KERN_DEBUG "%s: tun_net_mclist: mc_count %d\n",
+			dev->name, dev->mc_count);
+	memset(tun->chr_filter, 0, sizeof tun->chr_filter);
+	for (i = 0, mclist = dev->mc_list; i < dev->mc_count && mclist != NULL;
+			i++, mclist = mclist->next) {
+		add_multi(tun->net_filter, mclist->dmi_addr);
+		DBG(KERN_DEBUG "%s: tun_net_mclist: %x:%x:%x:%x:%x:%x\n",
+				dev->name,
+				mclist->dmi_addr[0], mclist->dmi_addr[1], mclist->dmi_addr[2],
+				mclist->dmi_addr[3], mclist->dmi_addr[4], mclist->dmi_addr[5]);
+	}
 }
 
 static struct net_device_stats *tun_net_stats(struct net_device *dev)
@@ -301,6 +333,10 @@ static ssize_t tun_chr_readv(struct file
 
 	add_wait_queue(&tun->read_wait, &wait);
 	while (len) {
+		const u8 ones[ ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+		u8 addr[ ETH_ALEN];
+		int bit_nr;
+
 		current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
@@ -320,10 +356,37 @@ static ssize_t tun_chr_readv(struct file
 		}
 		netif_start_queue(tun->dev);
 
-		ret = tun_put_user(tun, skb, (struct iovec *) iv, len);
-
-		kfree_skb(skb);
-		break;
+		/** Decide whether to accept this packet. This code is designed to
+		 * behave identically to an Ethernet interface. Accept the packet if
+		 * - we are promiscuous.
+		 * - the packet is addressed to us.
+		 * - the packet is broadcast.
+		 * - the packet is multicast and
+		 *   - we are multicast promiscous.
+		 *   - we belong to the multicast group.
+		 */
+		memcpy(addr, skb->data, min(sizeof addr, skb->len));
+		bit_nr = ether_crc(sizeof addr, addr) >> 26;
+		if ((tun->if_flags & IFF_PROMISC) ||
+				memcmp(addr, tun->dev_addr, sizeof addr) == 0 ||
+				memcmp(addr, ones, sizeof addr) == 0 ||
+				(((addr[0] == 1 && addr[1] == 0 && addr[2] == 0x5e) ||
+				  (addr[0] == 0x33 && addr[1] == 0x33)) &&
+				 ((tun->if_flags & IFF_ALLMULTI) ||
+				  (tun->chr_filter[bit_nr >> 5] & (1 << (bit_nr & 31)))))) {
+			DBG(KERN_DEBUG "%s: tun_chr_readv: accepted: %x:%x:%x:%x:%x:%x\n",
+					tun->dev->name, addr[0], addr[1], addr[2],
+					addr[3], addr[4], addr[5]);
+			ret = tun_put_user(tun, skb, (struct iovec *) iv, len);
+			kfree_skb(skb);
+			break;
+		} else {
+			DBG(KERN_DEBUG "%s: tun_chr_readv: rejected: %x:%x:%x:%x:%x:%x\n",
+					tun->dev->name, addr[0], addr[1], addr[2],
+					addr[3], addr[4], addr[5]);
+			kfree_skb(skb);
+			continue;
+		}
 	}
 
 	current->state = TASK_RUNNING;
@@ -417,6 +480,12 @@ static int tun_set_iff(struct file *file
 		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;
+		/* Be promiscuous by default to maintain previous behaviour. */
+		tun->if_flags = IFF_PROMISC;
+		/* Generate random Ethernet address. */
+		*(u16 *)tun->dev_addr = htons(0x00FF);
+		get_random_bytes(tun->dev_addr + sizeof(u16), 4);
+		memset(tun->chr_filter, 0, sizeof tun->chr_filter);
 
 		tun_net_init(dev);
 
@@ -457,13 +526,16 @@ static int tun_chr_ioctl(struct inode *i
 			 unsigned int cmd, unsigned long arg)
 {
 	struct tun_struct *tun = file->private_data;
+	void __user* argp = (void __user*)arg;
+	struct ifreq ifr;
+
+	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
+		if (copy_from_user(&ifr, argp, sizeof ifr))
+			return -EFAULT;
 
 	if (cmd == TUNSETIFF && !tun) {
-		struct ifreq ifr;
 		int err;
 
-		if (copy_from_user(&ifr, (void __user *)arg, sizeof(ifr)))
-			return -EFAULT;
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
 		rtnl_lock();
@@ -473,7 +545,7 @@ static int tun_chr_ioctl(struct inode *i
 		if (err)
 			return err;
 
-		if (copy_to_user((void __user *)arg, &ifr, sizeof(ifr)))
+		if (copy_to_user(argp, &ifr, sizeof(ifr)))
 			return -EFAULT;
 		return 0;
 	}
@@ -519,6 +591,61 @@ static int tun_chr_ioctl(struct inode *i
 		break;
 #endif
 
+	case SIOCGIFFLAGS:
+		ifr.ifr_flags = tun->if_flags;
+		if (copy_to_user( argp, &ifr, sizeof ifr))
+			return -EFAULT;
+		return 0;
+
+	case SIOCSIFFLAGS:
+		/** Set the character device's interface flags. Currently only
+		 * IFF_PROMISC and IFF_ALLMULTI are used. */
+		tun->if_flags = ifr.ifr_flags;
+		DBG(KERN_INFO "%s: interface flags 0x%lx\n",
+				tun->dev->name, tun->if_flags);
+		return 0;
+
+	case SIOCGIFHWADDR:
+		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev_addr,
+				min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
+		if (copy_to_user( argp, &ifr, sizeof ifr))
+			return -EFAULT;
+		return 0;
+
+	case SIOCSIFHWADDR:
+		/** Set the character device's hardware address. This is used when
+		 * filtering packets being sent from the network device to the character
+		 * device. */
+		memcpy(tun->dev_addr, ifr.ifr_hwaddr.sa_data,
+				min(sizeof ifr.ifr_hwaddr.sa_data, sizeof tun->dev_addr));
+		DBG(KERN_DEBUG "%s: set hardware address: %x:%x:%x:%x:%x:%x\n",
+				tun->dev->name,
+				tun->dev_addr[0], tun->dev_addr[1], tun->dev_addr[2],
+				tun->dev_addr[3], tun->dev_addr[4], tun->dev_addr[5]);
+		return 0;
+
+	case SIOCADDMULTI:
+		/** Add the specified group to the character device's multicast filter
+		 * list. */
+		add_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
+		DBG(KERN_DEBUG "%s: add multi: %x:%x:%x:%x:%x:%x\n",
+				tun->dev->name,
+				(u8)ifr.ifr_hwaddr.sa_data[0], (u8)ifr.ifr_hwaddr.sa_data[1],
+				(u8)ifr.ifr_hwaddr.sa_data[2], (u8)ifr.ifr_hwaddr.sa_data[3],
+				(u8)ifr.ifr_hwaddr.sa_data[4], (u8)ifr.ifr_hwaddr.sa_data[5]);
+		return 0;
+
+	case SIOCDELMULTI:
+		/** Remove the specified group from the character device's multicast
+		 * filter list. */
+		del_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
+		DBG(KERN_DEBUG "%s: del multi: %x:%x:%x:%x:%x:%x\n",
+				tun->dev->name,
+				(u8)ifr.ifr_hwaddr.sa_data[0], (u8)ifr.ifr_hwaddr.sa_data[1],
+				(u8)ifr.ifr_hwaddr.sa_data[2], (u8)ifr.ifr_hwaddr.sa_data[3],
+				(u8)ifr.ifr_hwaddr.sa_data[4], (u8)ifr.ifr_hwaddr.sa_data[5]);
+		return 0;
+
 	default:
 		return -EINVAL;
 	};
diff -puN include/linux/if_tun.h~multicast-filtering-for-tunc include/linux/if_tun.h
--- 25/include/linux/if_tun.h~multicast-filtering-for-tunc	2005-01-04 21:57:35.805690992 -0800
+++ 25-akpm/include/linux/if_tun.h	2005-01-04 21:57:35.810690232 -0800
@@ -45,6 +45,11 @@ struct tun_struct {
 
 	struct fasync_struct    *fasync;
 
+	unsigned long if_flags;
+	u8 dev_addr[ETH_ALEN];
+	u32 chr_filter[2];
+	u32 net_filter[2];
+
 #ifdef TUN_DEBUG	
 	int debug;
 #endif  
_
