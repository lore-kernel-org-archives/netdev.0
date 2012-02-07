From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tun: use ethtool msglevel bit mask convention
Date: Mon, 6 Feb 2012 16:31:59 -0800
Message-ID: <20120206163159.77940478@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37506 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755883Ab2BGAcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 19:32:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace custom debug printk with standard network device message level
interface. The messages about open/close/read/write are debug messages which can
be enabled at compile time or dynamic debug.

It does change the meaning of the debug flag, but the debug code
was disabled (unless source was changed), so I don't consider that
part of any real API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tun.c	2012-01-10 10:56:57.027157981 -0800
+++ b/drivers/net/tun.c	2012-01-30 09:16:15.580796267 -0800
@@ -72,34 +72,11 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-/* Uncomment to enable debugging */
-/* #define TUN_DEBUG 1 */
+static const u32 default_msg = NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR;
 
-#ifdef TUN_DEBUG
-static int debug;
-
-#define tun_debug(level, tun, fmt, args...)			\
-do {								\
-	if (tun->debug)						\
-		netdev_printk(level, tun->dev, fmt, ##args);	\
-} while (0)
-#define DBG1(level, fmt, args...)				\
-do {								\
-	if (debug == 2)						\
-		printk(level fmt, ##args);			\
-} while (0)
-#else
-#define tun_debug(level, tun, fmt, args...)			\
-do {								\
-	if (0)							\
-		netdev_printk(level, tun->dev, fmt, ##args);	\
-} while (0)
-#define DBG1(level, fmt, args...)				\
-do {								\
-	if (0)							\
-		printk(level fmt, ##args);			\
-} while (0)
-#endif
+static int debug = -1;		/* defaults above */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 #define FLT_EXACT_COUNT 8
 struct tap_filter {
@@ -133,10 +110,7 @@ struct tun_struct {
 	struct socket_wq	wq;
 
 	int			vnet_hdr_sz;
-
-#ifdef TUN_DEBUG
-	int debug;
-#endif
+	u32			msg_enable;
 };
 
 struct tun_sock {
@@ -381,7 +355,8 @@ static netdev_tx_t tun_net_xmit(struct s
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
+	netif_info(tun, tx_queued, dev,
+		   "tun_net_xmit %d\n", skb->len);
 
 	/* Drop packet if interface is not attached */
 	if (!tun->tfile)
@@ -553,7 +528,7 @@ static unsigned int tun_chr_poll(struct
 
 	sk = tun->socket.sk;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
+	netif_dbg(tun, drv, tun->dev, "tun_chr_poll\n");
 
 	poll_wait(file, &tun->wq.wait, wait);
 
@@ -693,7 +668,6 @@ static ssize_t tun_get_user(struct tun_s
 	}
 
 	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		pr_debug("GSO!\n");
 		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
@@ -705,6 +679,8 @@ static ssize_t tun_get_user(struct tun_s
 			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 			break;
 		default:
+			netif_err(tun, rx_err, tun->dev,
+				  "received unknown gso type %#x\n", gso.gso_type);
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
 			return -EINVAL;
@@ -715,6 +691,7 @@ static ssize_t tun_get_user(struct tun_s
 
 		skb_shinfo(skb)->gso_size = gso.gso_size;
 		if (skb_shinfo(skb)->gso_size == 0) {
+			netif_err(tun, rx_err, tun->dev, "gso size is zero!\n");
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
 			return -EINVAL;
@@ -743,7 +720,7 @@ static ssize_t tun_chr_aio_write(struct
 	if (!tun)
 		return -EBADFD;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
+	netif_dbg(tun, drv, tun->dev, "tun_chr_write %ld\n", count);
 
 	result = tun_get_user(tun, iv, iov_length(iv, count),
 			      file->f_flags & O_NONBLOCK);
@@ -760,6 +737,8 @@ static ssize_t tun_put_user(struct tun_s
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
 
+	netif_info(tun, tx_done, tun->dev, "tun_put_user len=%d\n", len);
+
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
 			return -EINVAL;
@@ -792,15 +771,17 @@ static ssize_t tun_put_user(struct tun_s
 			else if (sinfo->gso_type & SKB_GSO_UDP)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else {
-				pr_err("unexpected GSO type: "
-				       "0x%x, gso_size %d, hdr_len %d\n",
-				       sinfo->gso_type, gso.gso_size,
-				       gso.hdr_len);
-				print_hex_dump(KERN_ERR, "tun: ",
-					       DUMP_PREFIX_NONE,
-					       16, 1, skb->head,
-					       min((int)gso.hdr_len, 64), true);
-				WARN_ON_ONCE(1);
+				if (netif_msg_tx_err(tun)) {
+					pr_err("unexpected GSO type: "
+					       "0x%x, gso_size %d, hdr_len %d\n",
+					       sinfo->gso_type, gso.gso_size,
+					       gso.hdr_len);
+					print_hex_dump(KERN_ERR, "tun: ",
+						       DUMP_PREFIX_NONE,
+						       16, 1, skb->head,
+						       min((int)gso.hdr_len, 64), true);
+					WARN_ON_ONCE(1);
+				}
 				return -EINVAL;
 			}
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
@@ -841,7 +822,7 @@ static ssize_t tun_do_read(struct tun_st
 	struct sk_buff *skb;
 	ssize_t ret = 0;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
+	netif_dbg(tun, drv, tun->dev, "tun_chr_read\n");
 
 	if (unlikely(!noblock))
 		add_wait_queue(&tun->wq.wait, &wait);
@@ -1106,6 +1087,7 @@ static int tun_set_iff(struct net *net,
 		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;
+		tun->msg_enable = netif_msg_init(debug, default_msg);
 		tun->txflt.count = 0;
 		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
@@ -1147,7 +1129,7 @@ static int tun_set_iff(struct net *net,
 			goto failed;
 	}
 
-	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
+	netif_info(tun, drv, tun->dev, "tun_set_iff flags %#x\n", ifr->ifr_flags);
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
@@ -1184,7 +1166,7 @@ static int tun_set_iff(struct net *net,
 static int tun_get_iff(struct net *net, struct tun_struct *tun,
 		       struct ifreq *ifr)
 {
-	tun_debug(KERN_INFO, tun, "tun_get_iff\n");
+	netif_dbg(tun, drv, tun->dev, "tun_get_iff\n");
 
 	strcpy(ifr->ifr_name, tun->dev->name);
 
@@ -1277,7 +1259,8 @@ static long __tun_chr_ioctl(struct file
 	if (!tun)
 		goto unlock;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
+	netif_info(tun, drv, tun->dev,
+		   "tun_chr_ioctl cmd %#x\n", cmd);
 
 	ret = 0;
 	switch (cmd) {
@@ -1294,7 +1277,8 @@ static long __tun_chr_ioctl(struct file
 		/* Disable/Enable checksum */
 
 		/* [unimplemented] */
-		tun_debug(KERN_INFO, tun, "ignored: set checksum %s\n",
+		netif_info(tun, drv, tun->dev,
+			   "ignored: set checksum %s\n",
 			  arg ? "disabled" : "enabled");
 		break;
 
@@ -1305,43 +1289,42 @@ static long __tun_chr_ioctl(struct file
 		else
 			tun->flags &= ~TUN_PERSIST;
 
-		tun_debug(KERN_INFO, tun, "persist %s\n",
-			  arg ? "enabled" : "disabled");
+		netif_info(tun, drv, tun->dev,
+			   "persist %s\n", arg ? "enabled" : "disabled");
 		break;
 
 	case TUNSETOWNER:
 		/* Set owner of the device */
 		tun->owner = (uid_t) arg;
 
-		tun_debug(KERN_INFO, tun, "owner set to %d\n", tun->owner);
+		netif_info(tun, drv, tun->dev, "owner set to %d\n", tun->owner);
 		break;
 
 	case TUNSETGROUP:
 		/* Set group of the device */
 		tun->group= (gid_t) arg;
 
-		tun_debug(KERN_INFO, tun, "group set to %d\n", tun->group);
+		netif_info(tun, drv, tun->dev, "group set to %d\n", tun->group);
 		break;
 
 	case TUNSETLINK:
 		/* Only allow setting the type when the interface is down */
 		if (tun->dev->flags & IFF_UP) {
-			tun_debug(KERN_INFO, tun,
+			netif_notice(tun, drv, tun->dev,
 				  "Linktype set failed because interface is up\n");
 			ret = -EBUSY;
 		} else {
 			tun->dev->type = (int) arg;
-			tun_debug(KERN_INFO, tun, "linktype set to %d\n",
+			netif_info(tun, drv, tun->dev, "linktype set to %d\n",
 				  tun->dev->type);
 			ret = 0;
 		}
 		break;
 
-#ifdef TUN_DEBUG
 	case TUNSETDEBUG:
-		tun->debug = arg;
+		tun->msg_enable = netif_msg_init(arg, default_msg);
 		break;
-#endif
+
 	case TUNSETOFFLOAD:
 		ret = set_offload(tun, arg);
 		break;
@@ -1364,8 +1347,8 @@ static long __tun_chr_ioctl(struct file
 
 	case SIOCSIFHWADDR:
 		/* Set hw address */
-		tun_debug(KERN_DEBUG, tun, "set hw address: %pM\n",
-			  ifr.ifr_hwaddr.sa_data);
+		netif_dbg(tun, drv, tun->dev,
+			  "set hw address: %pM\n", ifr.ifr_hwaddr.sa_data);
 
 		ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
 		break;
@@ -1479,7 +1462,7 @@ static int tun_chr_fasync(int fd, struct
 	if (!tun)
 		return -EBADFD;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_fasync %d\n", on);
+	netif_dbg(tun, drv, tun->dev, "tun_chr_fasync %d\n", on);
 
 	if ((ret = fasync_helper(fd, file, on, &tun->fasync)) < 0)
 		goto out;
@@ -1501,8 +1484,6 @@ static int tun_chr_open(struct inode *in
 {
 	struct tun_file *tfile;
 
-	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
-
 	tfile = kmalloc(sizeof(*tfile), GFP_KERNEL);
 	if (!tfile)
 		return -ENOMEM;
@@ -1522,7 +1503,7 @@ static int tun_chr_close(struct inode *i
 	if (tun) {
 		struct net_device *dev = tun->dev;
 
-		tun_debug(KERN_INFO, tun, "tun_chr_close\n");
+		netif_dbg(tun, drv, tun->dev, "tun_chr_close\n");
 
 		__tun_detach(tun);
 
@@ -1605,20 +1586,14 @@ static void tun_get_drvinfo(struct net_d
 
 static u32 tun_get_msglevel(struct net_device *dev)
 {
-#ifdef TUN_DEBUG
 	struct tun_struct *tun = netdev_priv(dev);
-	return tun->debug;
-#else
-	return -EOPNOTSUPP;
-#endif
+	return tun->msg_enable;
 }
 
 static void tun_set_msglevel(struct net_device *dev, u32 value)
 {
-#ifdef TUN_DEBUG
 	struct tun_struct *tun = netdev_priv(dev);
-	tun->debug = value;
-#endif
+	tun->msg_enable = value;
 }
 
 static const struct ethtool_ops tun_ethtool_ops = {
