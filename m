From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] tun using alloc_netdev
Date: Mon, 9 Jun 2003 11:58:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609115857.38bb31d6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change how TUN allocates private data, to be like ethernet devices.
This allows later changes that make network device structure persist if sysfs hooks are open.

Compiles and loads, but don't know how to test it.

One gratitious change was to add C99 initializer for tun_miscdev.

diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Mon Jun  9 11:43:37 2003
+++ b/drivers/net/tun.c	Mon Jun  9 11:43:37 2003
@@ -122,12 +122,6 @@
    
 	DBG(KERN_INFO "%s: tun_net_init\n", tun->name);
 
-	SET_MODULE_OWNER(dev);
-	dev->open = tun_net_open;
-	dev->hard_start_xmit = tun_net_xmit;
-	dev->stop = tun_net_close;
-	dev->get_stats = tun_net_stats;
-
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
 		/* Point-to-Point TUN Device */
@@ -199,14 +193,14 @@
 	skb_reserve(skb, 2);
 	memcpy_fromiovec(skb_put(skb, len), iv, len);
 
-	skb->dev = &tun->dev;
+	skb->dev = tun->dev;
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
 		skb->mac.raw = skb->data;
 		skb->protocol = pi.proto;
 		break;
 	case TUN_TAP_DEV:
-		skb->protocol = eth_type_trans(skb, &tun->dev);
+		skb->protocol = eth_type_trans(skb, tun->dev);
 		break;
 	};
 
@@ -325,7 +319,7 @@
 			schedule();
 			continue;
 		}
-		netif_start_queue(&tun->dev);
+		netif_start_queue(tun->dev);
 
 		ret = tun_put_user(tun, skb, (struct iovec *) iv, len);
 
@@ -347,6 +341,24 @@
 	return tun_chr_readv(file, &iv, 1, pos);
 }
 
+static void tun_setup(struct net_device *dev)
+{
+	struct tun_struct *tun = dev->priv;
+
+	skb_queue_head_init(&tun->readq);
+	init_waitqueue_head(&tun->read_wait);
+
+	tun->owner = -1;
+	dev->init = tun_net_init;
+	tun->name = dev->name;
+	SET_MODULE_OWNER(dev);
+	dev->open = tun_net_open;
+	dev->hard_start_xmit = tun_net_xmit;
+	dev->stop = tun_net_close;
+	dev->get_stats = tun_net_stats;
+	dev->destructor = (void (*)(struct net_device *))kfree;
+}
+
 static int tun_set_iff(struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
@@ -367,30 +379,18 @@
 				return -EPERM;
 	} else {
 		char *name;
-
-		/* Allocate new device */
-		if (!(tun = kmalloc(sizeof(struct tun_struct), GFP_KERNEL)) )
-			return -ENOMEM;
-		memset(tun, 0, sizeof(struct tun_struct));
-
-		skb_queue_head_init(&tun->readq);
-		init_waitqueue_head(&tun->read_wait);
-
-		tun->owner = -1;
-		tun->dev.init = tun_net_init;
-		tun->dev.priv = tun;
-		SET_MODULE_OWNER(&tun->dev);
+		unsigned long flags = 0;
 
 		err = -EINVAL;
 
 		/* Set dev type */
 		if (ifr->ifr_flags & IFF_TUN) {
 			/* TUN device */
-			tun->flags |= TUN_TUN_DEV;
+			flags |= TUN_TUN_DEV;
 			name = "tun%d";
 		} else if (ifr->ifr_flags & IFF_TAP) {
 			/* TAP device */
-			tun->flags |= TUN_TAP_DEV;
+			flags |= TUN_TAP_DEV;
 			name = "tap%d";
 		} else 
 			goto failed;
@@ -398,12 +398,19 @@
 		if (*ifr->ifr_name)
 			name = ifr->ifr_name;
 
-		if ((err = dev_alloc_name(&tun->dev, name)) < 0)
-			goto failed;
-		if ((err = register_netdevice(&tun->dev)))
+		dev = alloc_netdev(sizeof(struct tun_struct), name,
+				   tun_setup);
+		if (!dev)
+			return -ENOMEM;
+
+		tun = dev->priv;
+		tun->flags = flags;
+
+		if ((err = register_netdevice(tun->dev))) {
+			kfree(dev);
 			goto failed;
+		}
 	
-		tun->name = tun->dev.name;
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->name);
@@ -419,9 +426,7 @@
 
 	strcpy(ifr->ifr_name, tun->name);
 	return 0;
-
-failed:
-	kfree(tun);
+ failed:
 	return err;
 }
 
@@ -548,10 +553,8 @@
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
 
-	if (!(tun->flags & TUN_PERSIST)) {
-		dev_close(&tun->dev);
-		unregister_netdevice(&tun->dev);
-	}
+	if (!(tun->flags & TUN_PERSIST)) 
+		unregister_netdevice(tun->dev);
 
 	rtnl_unlock();
 
@@ -574,11 +577,10 @@
 	.fasync = tun_chr_fasync		
 };
 
-static struct miscdevice tun_miscdev=
-{
-	TUN_MINOR,
-	"net/tun",
-	&tun_fops
+static struct miscdevice tun_miscdev = {
+	.minor = TUN_MINOR,
+	.name = "net/tun",
+	.fops = &tun_fops
 };
 
 int __init tun_init(void)
diff -Nru a/include/linux/if_tun.h b/include/linux/if_tun.h
--- a/include/linux/if_tun.h	Mon Jun  9 11:43:37 2003
+++ b/include/linux/if_tun.h	Mon Jun  9 11:43:37 2003
@@ -40,7 +40,7 @@
 	wait_queue_head_t	read_wait;
 	struct sk_buff_head	readq;
 
-	struct net_device	dev;
+	struct net_device	*dev;
 	struct net_device_stats	stats;
 
 	struct fasync_struct    *fasync;
