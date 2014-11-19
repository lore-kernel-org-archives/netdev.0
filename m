From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/3] tun: drop most type defines
Date: Wed, 19 Nov 2014 18:18:41 +0200
Message-ID: <1416413891-29562-4-git-send-email-mst@redhat.com>
References: <1416413891-29562-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416413891-29562-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's just as easy to use IFF_ flags directly,
there's no point in adding our own defines.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c | 64 ++++++++++++++++++++++++-------------------------------
 1 file changed, 28 insertions(+), 36 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e4bd542..06683af 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -104,20 +104,12 @@ do {								\
 #endif
 
 /* TUN device flags */
-#define TUN_TUN_DEV 	IFF_TUN
-#define TUN_TAP_DEV	IFF_TAP
 #define TUN_TYPE_MASK   (IFF_TUN | IFF_TAP)
 
 /* IFF_ATTACH_QUEUE is never stored in device flags,
  * overload it to mean fasync when stored there.
  */
 #define TUN_FASYNC	IFF_ATTACH_QUEUE
-#define TUN_NO_PI	IFF_NO_PI
-/* This flag has no real effect */
-#define TUN_ONE_QUEUE	IFF_ONE_QUEUE
-#define TUN_PERSIST 	IFF_PERSIST
-#define TUN_VNET_HDR 	IFF_VNET_HDR
-#define TUN_TAP_MQ      IFF_MULTI_QUEUE
 
 #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
 		      IFF_MULTI_QUEUE)
@@ -490,7 +482,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		if (tun && tun->numqueues == 0 && tun->numdisabled == 0) {
 			netif_carrier_off(tun->dev);
 
-			if (!(tun->flags & TUN_PERSIST) &&
+			if (!(tun->flags & IFF_PERSIST) &&
 			    tun->dev->reg_state == NETREG_REGISTERED)
 				unregister_netdevice(tun->dev);
 		}
@@ -541,7 +533,7 @@ static void tun_detach_all(struct net_device *dev)
 	}
 	BUG_ON(tun->numdisabled != 0);
 
-	if (tun->flags & TUN_PERSIST)
+	if (tun->flags & IFF_PERSIST)
 		module_put(THIS_MODULE);
 }
 
@@ -559,7 +551,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 		goto out;
 
 	err = -EBUSY;
-	if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
+	if (!(tun->flags & IFF_MULTI_QUEUE) && tun->numqueues == 1)
 		goto out;
 
 	err = -E2BIG;
@@ -938,7 +930,7 @@ static void tun_net_init(struct net_device *dev)
 	struct tun_struct *tun = netdev_priv(dev);
 
 	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
+	case IFF_TUN:
 		dev->netdev_ops = &tun_netdev_ops;
 
 		/* Point-to-Point TUN Device */
@@ -952,7 +944,7 @@ static void tun_net_init(struct net_device *dev)
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 
-	case TUN_TAP_DEV:
+	case IFF_TAP:
 		dev->netdev_ops = &tap_netdev_ops;
 		/* Ethernet TAP Device */
 		ether_setup(dev);
@@ -1043,7 +1035,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	int err;
 	u32 rxhash;
 
-	if (!(tun->flags & TUN_NO_PI)) {
+	if (!(tun->flags & IFF_NO_PI)) {
 		if (len < sizeof(pi))
 			return -EINVAL;
 		len -= sizeof(pi);
@@ -1053,7 +1045,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		offset += sizeof(pi);
 	}
 
-	if (tun->flags & TUN_VNET_HDR) {
+	if (tun->flags & IFF_VNET_HDR) {
 		if (len < tun->vnet_hdr_sz)
 			return -EINVAL;
 		len -= tun->vnet_hdr_sz;
@@ -1070,7 +1062,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		offset += tun->vnet_hdr_sz;
 	}
 
-	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
+	if ((tun->flags & TUN_TYPE_MASK) == IFF_TAP) {
 		align += NET_IP_ALIGN;
 		if (unlikely(len < ETH_HLEN ||
 			     (gso.hdr_len && __virtio16_to_cpu(false, gso.hdr_len) < ETH_HLEN)))
@@ -1133,8 +1125,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
-		if (tun->flags & TUN_NO_PI) {
+	case IFF_TUN:
+		if (tun->flags & IFF_NO_PI) {
 			switch (skb->data[0] & 0xf0) {
 			case 0x40:
 				pi.proto = htons(ETH_P_IP);
@@ -1153,7 +1145,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		skb->protocol = pi.proto;
 		skb->dev = tun->dev;
 		break;
-	case TUN_TAP_DEV:
+	case IFF_TAP:
 		skb->protocol = eth_type_trans(skb, tun->dev);
 		break;
 	}
@@ -1254,7 +1246,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	ssize_t total = 0;
 	int vlan_offset = 0, copied;
 
-	if (!(tun->flags & TUN_NO_PI)) {
+	if (!(tun->flags & IFF_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
 			return -EINVAL;
 
@@ -1268,7 +1260,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += sizeof(pi);
 	}
 
-	if (tun->flags & TUN_VNET_HDR) {
+	if (tun->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr gso = { 0 }; /* no info leak */
 		if ((len -= tun->vnet_hdr_sz) < 0)
 			return -EINVAL;
@@ -1589,7 +1581,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			return -EINVAL;
 
 		if (!!(ifr->ifr_flags & IFF_MULTI_QUEUE) !=
-		    !!(tun->flags & TUN_TAP_MQ))
+		    !!(tun->flags & IFF_MULTI_QUEUE))
 			return -EINVAL;
 
 		if (tun_not_capable(tun))
@@ -1602,7 +1594,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (err < 0)
 			return err;
 
-		if (tun->flags & TUN_TAP_MQ &&
+		if (tun->flags & IFF_MULTI_QUEUE &&
 		    (tun->numqueues + tun->numdisabled > 1)) {
 			/* One or more queue has already been attached, no need
 			 * to initialize the device again.
@@ -1625,11 +1617,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		/* Set dev type */
 		if (ifr->ifr_flags & IFF_TUN) {
 			/* TUN device */
-			flags |= TUN_TUN_DEV;
+			flags |= IFF_TUN;
 			name = "tun%d";
 		} else if (ifr->ifr_flags & IFF_TAP) {
 			/* TAP device */
-			flags |= TUN_TAP_DEV;
+			flags |= IFF_TAP;
 			name = "tap%d";
 		} else
 			return -EINVAL;
@@ -1822,7 +1814,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 		ret = tun_attach(tun, file, false);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
 		tun = rtnl_dereference(tfile->tun);
-		if (!tun || !(tun->flags & TUN_TAP_MQ) || tfile->detached)
+		if (!tun || !(tun->flags & IFF_MULTI_QUEUE) || tfile->detached)
 			ret = -EINVAL;
 		else
 			__tun_detach(tfile, false);
@@ -1928,12 +1920,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		/* Disable/Enable persist mode. Keep an extra reference to the
 		 * module to prevent the module being unprobed.
 		 */
-		if (arg && !(tun->flags & TUN_PERSIST)) {
-			tun->flags |= TUN_PERSIST;
+		if (arg && !(tun->flags & IFF_PERSIST)) {
+			tun->flags |= IFF_PERSIST;
 			__module_get(THIS_MODULE);
 		}
-		if (!arg && (tun->flags & TUN_PERSIST)) {
-			tun->flags &= ~TUN_PERSIST;
+		if (!arg && (tun->flags & IFF_PERSIST)) {
+			tun->flags &= ~IFF_PERSIST;
 			module_put(THIS_MODULE);
 		}
 
@@ -1991,7 +1983,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	case TUNSETTXFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
-		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+		if ((tun->flags & TUN_TYPE_MASK) != IFF_TAP)
 			break;
 		ret = update_filter(&tun->txflt, (void __user *)arg);
 		break;
@@ -2050,7 +2042,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	case TUNATTACHFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
-		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+		if ((tun->flags & TUN_TYPE_MASK) != IFF_TAP)
 			break;
 		ret = -EFAULT;
 		if (copy_from_user(&tun->fprog, argp, sizeof(tun->fprog)))
@@ -2062,7 +2054,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	case TUNDETACHFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
-		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+		if ((tun->flags & TUN_TYPE_MASK) != IFF_TAP)
 			break;
 		ret = 0;
 		tun_detach_filter(tun, tun->numqueues);
@@ -2070,7 +2062,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	case TUNGETFILTER:
 		ret = -EINVAL;
-		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+		if ((tun->flags & TUN_TYPE_MASK) != IFF_TAP)
 			break;
 		ret = -EFAULT;
 		if (copy_to_user(argp, &tun->fprog, sizeof(tun->fprog)))
@@ -2263,10 +2255,10 @@ static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 
 	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
+	case IFF_TUN:
 		strlcpy(info->bus_info, "tun", sizeof(info->bus_info));
 		break;
-	case TUN_TAP_DEV:
+	case IFF_TAP:
 		strlcpy(info->bus_info, "tap", sizeof(info->bus_info));
 		break;
 	}
-- 
MST
