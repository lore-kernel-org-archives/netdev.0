From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] make lapbether work on 2.6.0-test3
Date: Tue, 12 Aug 2003 17:07:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812170741.40608f59.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henner Eisen <eis@baty.hanse.de>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lapbether needed work to get it up on 2.6.0-test3;  the network device semantic
changes caused several locking issues. Since lapb devices are created and removed
in response to changes in underlying devices, the locking assumption changes
caused the breakage.

Changes:
	- unneeded include (no proc here)
	- redundant fields in local device structure
	+ convert to dynamic network device allocation
	- refcounts on local data are redundant, it is really part of network_device
	- excessive __inline__
	+ correctly manage references to underlying network device
	+ cascade unregister
	+ use RCU and RTNL to avoid deadlock
	+ account for bytes as well as packets

Tested by exercising up/down/unregister state transitions on SMP.
No change to underlying protocol was made.

--- linux-2.5/drivers/net/wan/lapbether.c	2003-06-05 10:04:38.000000000 -0700
+++ linux-2.5-net/drivers/net/wan/lapbether.c	2003-08-12 16:56:37.452112904 -0700
@@ -37,7 +37,6 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
-#include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
@@ -52,50 +51,27 @@ static char bcast_addr[6] = { 0xFF, 0xFF
 
 struct lapbethdev {
 	struct list_head	node;
-	char			ethname[14];	/* ether device name */
 	struct net_device	*ethdev;	/* link to ethernet device */
-	struct net_device	axdev;		/* lapbeth device (lapb#) */
+	struct net_device	*axdev;		/* lapbeth device (lapb#) */
 	struct net_device_stats stats;		/* some statistics */
-	atomic_t		refcnt;
 };
 
 static struct list_head lapbeth_devices = LIST_HEAD_INIT(lapbeth_devices);
-static rwlock_t lapbeth_devices_lock = RW_LOCK_UNLOCKED;
 
-static __inline__ void lapbeth_hold(struct lapbethdev *lapbeth)
-{
-	atomic_inc(&lapbeth->refcnt);
-}
-
-static __inline__ void lapbeth_put(struct lapbethdev *lapbeth)
-{
-	if (atomic_dec_and_test(&lapbeth->refcnt))
-		kfree(lapbeth);
-}
 /* ------------------------------------------------------------------------ */
 
 /*
  *	Get the LAPB device for the ethernet device
  */
-static __inline__ struct lapbethdev *lapbeth_get_x25_dev(struct net_device *dev)
+static struct lapbethdev *lapbeth_get_x25_dev(struct net_device *dev)
 {
-	struct list_head *entry;
-	struct lapbethdev *lapbeth, *use = NULL;
-
-	read_lock(&lapbeth_devices_lock);
+	struct lapbethdev *lapbeth;
 
-	list_for_each(entry, &lapbeth_devices) {
-		lapbeth = list_entry(entry, struct lapbethdev, node);
-		if (lapbeth->ethdev == dev) {
-			use = lapbeth;
-			break;
-		}
+	list_for_each_entry_rcu(lapbeth, &lapbeth_devices, node) {
+		if (lapbeth->ethdev == dev) 
+			return lapbeth;
 	}
-	if (use)
-		lapbeth_hold(use);
-
-	read_unlock(&lapbeth_devices_lock);
-	return use;
+	return NULL;
 }
 
 static __inline__ int dev_is_ethdev(struct net_device *dev)
@@ -103,36 +79,6 @@ static __inline__ int dev_is_ethdev(stru
 	return dev->type == ARPHRD_ETHER && strncmp(dev->name, "dummy", 5);
 }
 
-/*
- *	Sanity check: remove all devices that ceased to exists and
- *	return '1' if the given LAPB device was affected.
- */
-static int lapbeth_check_devices(struct net_device *dev)
-{
-	struct lapbethdev *lapbeth;
-	struct list_head *entry, *tmp;
-	int result = 0;
-
-	write_lock(&lapbeth_devices_lock);
-
-	list_for_each_safe(entry, tmp, &lapbeth_devices) {
-		lapbeth = list_entry(entry, struct lapbethdev, node);
-
-		if (!dev_get(lapbeth->ethname)) {
-			if (&lapbeth->axdev == dev)
-				result = 1;
-
-			unregister_netdev(&lapbeth->axdev);
-			dev_put(lapbeth->ethdev);
-			list_del(&lapbeth->node);
-			lapbeth_put(lapbeth);
-		}
-	}
-	write_unlock(&lapbeth_devices_lock);
-
-	return result;
-}
-
 /* ------------------------------------------------------------------------ */
 
 /*
@@ -145,29 +91,28 @@ static int lapbeth_rcv(struct sk_buff *s
 
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 
+	rcu_read_lock();
 	lapbeth = lapbeth_get_x25_dev(dev);
-
 	if (!lapbeth)
 		goto drop;
-	if (!netif_running(&lapbeth->axdev))
-		goto put_drop;
+	if (!netif_running(lapbeth->axdev))
+		goto drop;
 
 	lapbeth->stats.rx_packets++;
 
 	len = skb->data[0] + skb->data[1] * 256;
+	lapbeth->stats.rx_bytes += len;
 
 	skb_pull(skb, 2);	/* Remove the length bytes */
 	skb_trim(skb, len);	/* Set the length of the data */
 
 	if ((err = lapb_data_received(lapbeth, skb)) != LAPB_OK) {
 		printk(KERN_DEBUG "lapbether: lapb_data_received err - %d\n", err);
-		goto put_drop;
+		goto drop;
 	}
-	lapbeth_put(lapbeth);
 out:
+	rcu_read_unlock();
 	return 0;
-put_drop:
-	lapbeth_put(lapbeth);
 drop:
 	kfree_skb(skb);
 	goto out;
@@ -181,7 +126,7 @@ static int lapbeth_data_indication(void 
 	ptr  = skb_push(skb, 1);
 	*ptr = 0x00;
 
-	skb->dev      = &lapbeth->axdev;
+	skb->dev      = lapbeth->axdev;
 	skb->protocol = htons(ETH_P_X25);
 	skb->mac.raw  = skb->data;
 	skb->pkt_type = PACKET_HOST;
@@ -203,7 +148,6 @@ static int lapbeth_xmit(struct sk_buff *
 	 * is down, the ethernet device may have gone.
 	 */
 	if (!netif_running(dev)) {
-		lapbeth_check_devices(dev);
 		goto drop;
 	}
 
@@ -257,6 +201,7 @@ static void lapbeth_data_transmit(void *
 	*ptr++ = size / 256;
 
 	lapbeth->stats.tx_packets++;
+	lapbeth->stats.tx_bytes += size;
 
 	skb->dev = dev = lapbeth->ethdev;
 
@@ -279,7 +224,7 @@ static void lapbeth_connected(void *toke
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x01;
 
-	skb->dev      = &lapbeth->axdev;
+	skb->dev      = lapbeth->axdev;
 	skb->protocol = htons(ETH_P_X25);
 	skb->mac.raw  = skb->data;
 	skb->pkt_type = PACKET_HOST;
@@ -302,7 +247,7 @@ static void lapbeth_disconnected(void *t
 	ptr  = skb_put(skb, 1);
 	*ptr = 0x02;
 
-	skb->dev      = &lapbeth->axdev;
+	skb->dev      = lapbeth->axdev;
 	skb->protocol = htons(ETH_P_X25);
 	skb->mac.raw  = skb->data;
 	skb->pkt_type = PACKET_HOST;
@@ -330,27 +275,26 @@ static int lapbeth_set_mac_address(struc
 	return 0;
 }
 
+
+static struct lapb_register_struct lapbeth_callbacks = {
+	.connect_confirmation    = lapbeth_connected,
+	.connect_indication      = lapbeth_connected,
+	.disconnect_confirmation = lapbeth_disconnected,
+	.disconnect_indication   = lapbeth_disconnected,
+	.data_indication         = lapbeth_data_indication,
+	.data_transmit           = lapbeth_data_transmit,
+
+};
+
 /*
  * open/close a device
  */
 static int lapbeth_open(struct net_device *dev)
 {
-	struct lapb_register_struct lapbeth_callbacks;
 	struct lapbethdev *lapbeth;
 	int err;
 
-	if (lapbeth_check_devices(dev))
-		return -ENODEV;		/* oops, it's gone */
-
 	lapbeth = (struct lapbethdev *)dev->priv;
-
-	lapbeth_callbacks.connect_confirmation    = lapbeth_connected;
-	lapbeth_callbacks.connect_indication      = lapbeth_connected;
-	lapbeth_callbacks.disconnect_confirmation = lapbeth_disconnected;
-	lapbeth_callbacks.disconnect_indication   = lapbeth_disconnected;
-	lapbeth_callbacks.data_indication         = lapbeth_data_indication;
-	lapbeth_callbacks.data_transmit           = lapbeth_data_transmit;
-
 	if ((err = lapb_register(lapbeth, &lapbeth_callbacks)) != LAPB_OK) {
 		printk(KERN_ERR "lapbeth: lapb_register error - %d\n", err);
 		return -ENODEV;
@@ -375,65 +319,52 @@ static int lapbeth_close(struct net_devi
 
 /* ------------------------------------------------------------------------ */
 
+static void lapbeth_setup(struct net_device *dev)
+{
+	dev->hard_start_xmit = lapbeth_xmit;
+	dev->open	     = lapbeth_open;
+	dev->stop	     = lapbeth_close;
+	dev->destructor	     = (void (*)(struct net_device *))kfree;
+	dev->set_mac_address = lapbeth_set_mac_address;
+	dev->get_stats	     = lapbeth_get_stats;
+	dev->type            = ARPHRD_X25;
+	dev->hard_header_len = 3;
+	dev->mtu             = 1000;
+	dev->addr_len        = 0;
+	SET_MODULE_OWNER(dev);
+}
+
 /*
  *	Setup a new device.
  */
 static int lapbeth_new_device(struct net_device *dev)
 {
-	unsigned char buf[14];
+	struct net_device *ndev;
 	struct lapbethdev *lapbeth;
-	int k, rc = -ENOMEM;
+	int rc = -ENOMEM;
 
-	if ((lapbeth = kmalloc(sizeof(struct lapbethdev), GFP_ATOMIC)) == NULL)
+	ASSERT_RTNL();
+
+	ndev = alloc_netdev(sizeof(*lapbeth), "lapb%d", 
+			   lapbeth_setup);
+	if (!ndev)
 		goto out;
 
-	memset(lapbeth, 0, sizeof(struct lapbethdev));
+	lapbeth = ndev->priv;
+	lapbeth->axdev = ndev;
 
 	dev_hold(dev);
 	lapbeth->ethdev = dev;
 
-	strncpy(lapbeth->ethname, dev->name, sizeof(lapbeth->ethname) - 1);
-	lapbeth->ethname[sizeof(lapbeth->ethname) - 1] = '\0';
-	atomic_set(&lapbeth->refcnt, 1);
-
-	dev = &lapbeth->axdev;
-	SET_MODULE_OWNER(dev);
-
-	for (k = 0; k < MAXLAPBDEV; k++) {
-		struct net_device *odev;
-
-		sprintf(buf, "lapb%d", k);
-
-		if ((odev = __dev_get_by_name(buf)) == NULL ||
-		    lapbeth_check_devices(odev))
-			break;
-	}
-
-	rc = -ENODEV;
-	if (k == MAXLAPBDEV)
+	rc = dev_alloc_name(ndev, ndev->name);
+	if (rc < 0) 
 		goto fail;
 
-	dev->priv = (void *)lapbeth;	/* pointer back */
-	strcpy(dev->name, buf);
-
 	rc = -EIO;
-	if (register_netdev(dev))
+	if (register_netdevice(ndev))
 		goto fail;
 
-	dev->hard_start_xmit = lapbeth_xmit;
-	dev->open	     = lapbeth_open;
-	dev->stop	     = lapbeth_close;
-	dev->set_mac_address = lapbeth_set_mac_address;
-	dev->get_stats	     = lapbeth_get_stats;
-	dev->type            = ARPHRD_X25;
-	dev->hard_header_len = 3;
-	dev->mtu             = 1000;
-	dev->addr_len        = 0;
-
-	write_lock(&lapbeth_devices_lock);
-	list_add(&lapbeth->node, &lapbeth_devices);
-	lapbeth_hold(lapbeth);
-	write_unlock(&lapbeth_devices_lock);
+	list_add_rcu(&lapbeth->node, &lapbeth_devices);
 	rc = 0;
 out:
 	return rc;
@@ -444,6 +375,16 @@ fail:
 }
 
 /*
+ *	Free a lapb network device.
+ */
+static void lapbeth_free_device(struct lapbethdev *lapbeth)
+{
+	dev_put(lapbeth->ethdev);
+	list_del_rcu(&lapbeth->node);
+	unregister_netdevice(lapbeth->axdev);
+}
+
+/*
  *	Handle device status changes.
  */
 static int lapbeth_device_event(struct notifier_block *this,
@@ -455,30 +396,27 @@ static int lapbeth_device_event(struct n
 	if (!dev_is_ethdev(dev))
 		return NOTIFY_DONE;
 
-	lapbeth_check_devices(NULL);
-
+	rcu_read_lock();
 	switch (event) {
 	case NETDEV_UP:
-		/*
-		 * New ethernet device -> new LAPB interface
-		 */
-		lapbeth = lapbeth_get_x25_dev(dev);
-
-		if (lapbeth)
-			lapbeth_put(lapbeth);
-		else
+		/* New ethernet device -> new LAPB interface	 */
+		if (lapbeth_get_x25_dev(dev) == NULL)
 			lapbeth_new_device(dev);
 		break;
-	case NETDEV_GOING_DOWN:
-	case NETDEV_DOWN:	/* ethernet device closed -> close LAPB interface */
+	case NETDEV_DOWN:	
+		/* ethernet device closed -> close LAPB interface */
 		lapbeth = lapbeth_get_x25_dev(dev);
-
-		if (lapbeth) {
-			dev_close(lapbeth->ethdev);
-			lapbeth_put(lapbeth);
-		}
+		if (lapbeth) 
+			dev_close(lapbeth->axdev);
+		break;
+	case NETDEV_UNREGISTER:
+		/* ethernet device disappears -> remove LAPB interface */
+		lapbeth = lapbeth_get_x25_dev(dev);
+		if (lapbeth)
+			lapbeth_free_device(lapbeth);
 		break;
 	}
+	rcu_read_unlock();
 
 	return NOTIFY_DONE;
 }
@@ -506,15 +444,13 @@ static int __init lapbeth_init_driver(vo
 
 	printk(banner);
 
-	read_lock_bh(&dev_base_lock);
+	rtnl_lock();
 	for (dev = dev_base; dev; dev = dev->next) {
 		if (dev_is_ethdev(dev)) {
-			read_unlock_bh(&dev_base_lock);
 			lapbeth_new_device(dev);
-			read_lock_bh(&dev_base_lock);
 		}
 	}
-	read_unlock_bh(&dev_base_lock);
+	rtnl_unlock();
 
 	return 0;
 }
@@ -528,16 +464,13 @@ static void __exit lapbeth_cleanup_drive
 	dev_remove_pack(&lapbeth_packet_type);
 	unregister_netdevice_notifier(&lapbeth_dev_notifier);
 
-	write_lock(&lapbeth_devices_lock);
-
+	rtnl_lock();
 	list_for_each_safe(entry, tmp, &lapbeth_devices) {
 		lapbeth = list_entry(entry, struct lapbethdev, node);
-		unregister_netdev(&lapbeth->axdev);
-		list_del(&lapbeth->node);
-		lapbeth_put(lapbeth);
-	}
 
-	write_unlock(&lapbeth_devices_lock);
+		unregister_netdevice(lapbeth->axdev);
+	}
+	rtnl_unlock();
 }
 module_exit(lapbeth_cleanup_driver);
 
