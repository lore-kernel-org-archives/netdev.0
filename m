From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT][PATCH] cleanup net/atm/br2684.c
Date: Mon, 11 Aug 2003 11:48:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811114823.5b81474c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>,
   "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I fixed up some things in br2684 but don't have ATM hardware to test it well enough.
The patch is against 2.6.0-test3 and module loads/unloads fine.

Fixed:
	- Allocate network device with alloc_netdev and embed private data via
	  dev->priv.  This allows for future fix of rmmod race with sysfs.
	- Get rid of all the MOD_INC stuff. MOD_INC is not a spinlock or semaphore
	  and don't use it like that!  Have driver clean itself up properly on
	  unload.
	- Add required owner field for /proc interface.  Thought about converting
	  to seq_file, but existing output format and ordering makes that hard.


diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Aug 11 11:42:19 2003
+++ b/net/atm/br2684.c	Mon Aug 11 11:42:19 2003
@@ -81,7 +81,7 @@
 };
 
 struct br2684_dev {
-	struct net_device net_dev;
+	struct net_device *net_dev;
 	struct list_head br2684_devs;
 	int number;
 	struct list_head brvccs; /* one device <=> one vcc (before xmas) */
@@ -137,8 +137,8 @@
 	case BR2684_FIND_BYIFNAME:
 		list_for_each(lh, &br2684_devs) {
 			brdev = list_entry_brdev(lh);
-			if (!strncmp(brdev->net_dev.name, s->spec.ifname,
-			    sizeof brdev->net_dev.name))
+			if (!strncmp(brdev->net_dev->name, s->spec.ifname,
+				     IFNAMSIZ))
 				return brdev;
 		}
 		break;
@@ -400,7 +400,6 @@
 	brvcc->atmvcc->user_back = NULL;	/* what about vcc->recvq ??? */
 	brvcc->old_push(brvcc->atmvcc, NULL);	/* pass on the bad news */
 	kfree(brvcc);
-	MOD_DEC_USE_COUNT;
 }
 
 /* when AAL5 PDU comes in: */
@@ -418,8 +417,8 @@
 			read_lock(&devs_lock);
 			list_del(&brdev->br2684_devs);
 			read_unlock(&devs_lock);
-			unregister_netdev(&brdev->net_dev);
-			kfree(brdev);
+			unregister_netdev(brdev->net_dev);
+			kfree(brdev->net_dev);
 		}
 		return;
 	}
@@ -464,7 +463,7 @@
 #endif /* CONFIG_BR2684_FAST_TRANS */
 #else
 	skb_pull(skb, plen - ETH_HLEN);
-	skb->protocol = eth_type_trans(skb, &brdev->net_dev);
+	skb->protocol = eth_type_trans(skb, brdev->net_dev);
 #endif /* FASTER_VERSION */
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	if (packet_fails_filter(skb->protocol, brvcc, skb)) {
@@ -473,11 +472,11 @@
 		return;
 	}
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
-	skb->dev = &brdev->net_dev;
+	skb->dev = brdev->net_dev;
 	ATM_SKB(skb)->vcc = atmvcc;	/* needed ? */
 	DPRINTK("received packet's protocol: %x\n", ntohs(skb->protocol));
 	skb_debug(skb);
-	if (!(brdev->net_dev.flags & IFF_UP)) { /* sigh, interface is down */
+	if (!(brdev->net_dev->flags & IFF_UP)) { /* sigh, interface is down */
 		brdev->stats.rx_dropped++;
 		dev_kfree_skb(skb);
 		return;
@@ -500,9 +499,7 @@
 	struct br2684_dev *brdev;
 	struct atm_backend_br2684 be;
 
-	MOD_INC_USE_COUNT;
 	if (copy_from_user(&be, (void *) arg, sizeof be)) {
-		MOD_DEC_USE_COUNT;
 		return -EFAULT;
 	}
 	write_lock_irq(&devs_lock);
@@ -539,10 +536,10 @@
 	if (list_empty(&brdev->brvccs) && !brdev->mac_was_set) {
 		unsigned char *esi = atmvcc->dev->esi;
 		if (esi[0] | esi[1] | esi[2] | esi[3] | esi[4] | esi[5])
-			memcpy(brdev->net_dev.dev_addr, esi,
-			    brdev->net_dev.addr_len);
+			memcpy(brdev->net_dev->dev_addr, esi,
+			    brdev->net_dev->addr_len);
 		else
-			brdev->net_dev.dev_addr[2] = 1;
+			brdev->net_dev->dev_addr[2] = 1;
 	}
 	list_add(&brvcc->brvccs, &brdev->brvccs);
 	write_unlock_irq(&devs_lock);
@@ -563,77 +560,69 @@
 	return 0;
     error:
 	write_unlock_irq(&devs_lock);
-	MOD_DEC_USE_COUNT;
 	return err;
 }
 
+static void br2684_setup(struct net_device *netdev)
+{
+	struct br2684_dev *brdev = netdev->priv;
+
+	ether_setup(netdev);
+	brdev->net_dev = netdev;
+
+#ifdef FASTER_VERSION
+	my_eth_header = netdev->hard_header;
+	netdev->hard_header = br2684_header;
+	my_eth_header_cache = netdev->hard_header_cache;
+	netdev->hard_header_cache = br2684_header_cache;
+	netdev->hard_header_len = sizeof(llc_oui_pid_pad) + ETH_HLEN;	/* 10 + 14 */
+#endif
+	my_eth_mac_addr = netdev->set_mac_address;
+	netdev->set_mac_address = br2684_mac_addr;
+	netdev->hard_start_xmit = br2684_start_xmit;
+	netdev->get_stats = br2684_get_stats;
+
+	INIT_LIST_HEAD(&brdev->brvccs);
+}
+
 static int br2684_create(unsigned long arg)
 {
 	int err;
+	struct net_device *netdev;
 	struct br2684_dev *brdev;
 	struct atm_newif_br2684 ni;
 
 	DPRINTK("br2684_create\n");
-	/*
-	 * We track module use by vcc's NOT the devices they're on.  We're
-	 * protected here against module death by the kernel_lock, but if
-	 * we need to sleep we should make sure that the module doesn't
-	 * disappear under us.
-	 */
-	MOD_INC_USE_COUNT;
+
 	if (copy_from_user(&ni, (void *) arg, sizeof ni)) {
-		MOD_DEC_USE_COUNT;
 		return -EFAULT;
 	}
 	if (ni.media != BR2684_MEDIA_ETHERNET || ni.mtu != 1500) {
-		MOD_DEC_USE_COUNT;
 		return -EINVAL;
 	}
-	if ((brdev = kmalloc(sizeof(struct br2684_dev), GFP_KERNEL)) == NULL) {
-		MOD_DEC_USE_COUNT;
-		return -ENOMEM;
-	}
-	memset(brdev, 0, sizeof(struct br2684_dev));
-	INIT_LIST_HEAD(&brdev->brvccs);
 
-	write_lock_irq(&devs_lock);
-	brdev->number = list_empty(&br2684_devs) ? 1 :
-	    list_entry_brdev(br2684_devs.prev)->number + 1;
-	list_add_tail(&brdev->br2684_devs, &br2684_devs);
-	write_unlock_irq(&devs_lock);
+	netdev = alloc_netdev(sizeof(struct br2684_dev),
+			      ni.ifname[0] ? ni.ifname : "nas%d",
+			      br2684_setup);
+	if (!netdev)
+		return -ENOMEM;
 
-	if (ni.ifname[0] != '\0') {
-		memcpy(brdev->net_dev.name, ni.ifname,
-		    sizeof(brdev->net_dev.name));
-		brdev->net_dev.name[sizeof(brdev->net_dev.name) - 1] = '\0';
-	} else
-		sprintf(brdev->net_dev.name, "nas%d", brdev->number);
-	DPRINTK("registered netdev %s\n", brdev->net_dev.name);
-	ether_setup(&brdev->net_dev);
-	brdev->mac_was_set = 0;
-#ifdef FASTER_VERSION
-	my_eth_header = brdev->net_dev.hard_header;
-	brdev->net_dev.hard_header = br2684_header;
-	my_eth_header_cache = brdev->net_dev.hard_header_cache;
-	brdev->net_dev.hard_header_cache = br2684_header_cache;
-	brdev->net_dev.hard_header_len = sizeof(llc_oui_pid_pad) + ETH_HLEN;	/* 10 + 14 */
-#endif
-	my_eth_mac_addr = brdev->net_dev.set_mac_address;
-	brdev->net_dev.set_mac_address = br2684_mac_addr;
-	brdev->net_dev.hard_start_xmit = br2684_start_xmit;
-	brdev->net_dev.get_stats = br2684_get_stats;
+	brdev = netdev->priv;
 
+	DPRINTK("registered netdev %s\n", netdev->name);
 	/* open, stop, do_ioctl ? */
-	err = register_netdev(&brdev->net_dev);
-	MOD_DEC_USE_COUNT;
+	err = register_netdev(netdev);
 	if (err < 0) {
 		printk(KERN_ERR "br2684_create: register_netdev failed\n");
-		write_lock_irq(&devs_lock);
-		list_del(&brdev->br2684_devs);
-		write_unlock_irq(&devs_lock);
-		kfree(brdev);
+		kfree(netdev);
 		return err;
 	}
+
+	write_lock_irq(&devs_lock);
+	brdev->number = list_empty(&br2684_devs) ? 1 :
+	    list_entry_brdev(br2684_devs.prev)->number + 1;
+	list_add_tail(&brdev->br2684_devs, &br2684_devs);
+	write_unlock_irq(&devs_lock);
 	return 0;
 }
 
@@ -649,9 +638,7 @@
 	case ATM_SETBACKEND:
 	case ATM_NEWBACKENDIF: {
 		atm_backend_t b;
-		MOD_INC_USE_COUNT;
 		err = get_user(b, (atm_backend_t *) arg);
-		MOD_DEC_USE_COUNT;
 		if (err)
 			return -EFAULT;
 		if (b != ATM_BACKEND_BR2684)
@@ -669,9 +656,7 @@
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		MOD_INC_USE_COUNT;
 		err = br2684_setfilt(atmvcc, arg);
-		MOD_DEC_USE_COUNT;
 		return err;
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
 	}
@@ -688,14 +673,14 @@
 		brdev = list_entry_brdev(lhd);
 		if (pos-- == 0)
 			return sprintf(buf, "dev %.16s: num=%d, mac=%02X:%02X:"
-			    "%02X:%02X:%02X:%02X (%s)\n", brdev->net_dev.name,
+			    "%02X:%02X:%02X:%02X (%s)\n", brdev->net_dev->name,
 			    brdev->number,
-			    brdev->net_dev.dev_addr[0],
-			    brdev->net_dev.dev_addr[1],
-			    brdev->net_dev.dev_addr[2],
-			    brdev->net_dev.dev_addr[3],
-			    brdev->net_dev.dev_addr[4],
-			    brdev->net_dev.dev_addr[5],
+			    brdev->net_dev->dev_addr[0],
+			    brdev->net_dev->dev_addr[1],
+			    brdev->net_dev->dev_addr[2],
+			    brdev->net_dev->dev_addr[3],
+			    brdev->net_dev->dev_addr[4],
+			    brdev->net_dev->dev_addr[5],
 			    brdev->mac_was_set ? "set" : "auto");
 		list_for_each(lhc, &brdev->brvccs) {
 			brvcc = list_entry_brvcc(lhc);
@@ -766,15 +751,13 @@
 }
 
 static struct file_operations br2684_proc_operations = {
-	read: br2684_proc_read,
+	.owner = THIS_MODULE,
+	.read =  br2684_proc_read,
 };
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
 
-/* the following avoids some spurious warnings from the compiler */
-#define UNUSED __attribute__((unused))
-
-static int __init UNUSED br2684_init(void)
+static int __init br2684_init(void)
 {
 	struct proc_dir_entry *p;
 	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
@@ -784,16 +767,25 @@
 	return 0;
 }
 
-static void __exit UNUSED br2684_exit(void)
+static void __exit br2684_exit(void)
 {
 	struct br2684_dev *brdev;
+	struct br2684_vcc *brvcc;
+	
 	br2684_ioctl_set(NULL);
+
 	remove_proc_entry("br2684", atm_proc_root);
+
 	while (!list_empty(&br2684_devs)) {
 		brdev = list_entry_brdev(br2684_devs.next);
-		unregister_netdev(&brdev->net_dev);
+		while (!list_empty(&brdev->brvccs)) {
+			brvcc = list_entry_brvcc(brdev->brvccs.next);
+			br2684_close_vcc(brvcc);
+		}
+
+		unregister_netdev(brdev->net_dev);
 		list_del(&brdev->br2684_devs);
-		kfree(brdev);
+		kfree(brdev->net_dev);
 	}
 }
 
