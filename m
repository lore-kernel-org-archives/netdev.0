From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 08/18]: Clean up debugging and printks
Date: Sun, 20 Jan 2008 18:11:28 +0100 (MET)
Message-ID: <20080120171128.7980.9669.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62353 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbYATRL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:29 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Clean up debugging and printks

- use pr_* functions and common prefix for non-device related messages

- remove VLAN_ printk levels

- kill lots of useless debugging statements

- remove a few unnecessary printks like for double VID registration (already
  returns -EEXIST) and kill of a number of unnecessary checks in
  vlan_proc_{add,rem}_dev() that are already performed by the caller

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7d925b47858e2f18fd474c673a0a75a0cfd00ebf
tree 25c74a419d2f5451b57e810897d4704c4e5fa467
parent ead4b3ca023de4d4f05d185e8111c01784ee08e2
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 net/8021q/vlan.c     |   58 +++++++++-----------------------------------------
 net/8021q/vlan.h     |   25 ----------------------
 net/8021q/vlan_dev.c |   56 ++++++++++++++++--------------------------------
 net/8021q/vlanproc.c |   29 -------------------------
 4 files changed, 30 insertions(+), 138 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8bc6385..6edd191 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -80,16 +80,13 @@ static int __init vlan_proto_init(void)
 {
 	int err;
 
-	printk(VLAN_INF "%s v%s %s\n",
-	       vlan_fullname, vlan_version, vlan_copyright);
-	printk(VLAN_INF "All bugs added by %s\n",
-	       vlan_buggyright);
+	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
+	pr_info("All bugs added by %s\n", vlan_buggyright);
 
 	/* proc file system initialization */
 	err = vlan_proc_init();
 	if (err < 0) {
-		printk(KERN_ERR
-		       "%s: can't create entry in proc filesystem!\n",
+		pr_err("%s: can't create entry in proc filesystem!\n",
 		       __FUNCTION__);
 		return err;
 	}
@@ -233,10 +230,6 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 	struct vlan_group *grp;
 	int i, ret;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: VID: %i\n", __FUNCTION__, vlan_id);
-#endif
-
 	/* sanity check */
 	if (vlan_id >= VLAN_VID_MASK)
 		return -EINVAL;
@@ -329,23 +322,22 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
 {
+	char *name = real_dev->name;
+
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
-		printk(VLAN_DBG "%s: VLANs not supported on %s.\n",
-			__FUNCTION__, real_dev->name);
+		pr_info("8021q: VLANs not supported on %s\n", name);
 		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
 	    !real_dev->vlan_rx_register) {
-		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
-			__FUNCTION__, real_dev->name);
+		pr_info("8021q: device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    (!real_dev->vlan_rx_add_vid || !real_dev->vlan_rx_kill_vid)) {
-		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
-			__FUNCTION__, real_dev->name);
+		pr_info("8021q: Device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
 
@@ -355,11 +347,8 @@ int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
 	if (!(real_dev->flags & IFF_UP))
 		return -ENETDOWN;
 
-	if (__find_vlan_dev(real_dev, vlan_id) != NULL) {
-		/* was already registered. */
-		printk(VLAN_DBG "%s: ALREADY had VLAN registered\n", __FUNCTION__);
+	if (__find_vlan_dev(real_dev, vlan_id) != NULL)
 		return -EEXIST;
-	}
 
 	return 0;
 }
@@ -399,8 +388,8 @@ int register_vlan_dev(struct net_device *dev)
 		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
 
 	if (vlan_proc_add_dev(dev) < 0)
-		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
-		       dev->name);
+		pr_warning("8021q: failed to add proc entry for %s\n",
+			   dev->name);
 	return 0;
 
 out_free_group:
@@ -419,11 +408,6 @@ static int register_vlan_device(struct net_device *real_dev,
 	char name[IFNAMSIZ];
 	int err;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
-		__FUNCTION__, eth_IF_name, VLAN_ID);
-#endif
-
 	if (VLAN_ID >= VLAN_VID_MASK)
 		return -ERANGE;
 
@@ -432,10 +416,6 @@ static int register_vlan_device(struct net_device *real_dev,
 		return err;
 
 	/* Gotta set up the fields for the device. */
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "About to allocate name, vlan_name_type: %i\n",
-	       vlan_name_type);
-#endif
 	switch (vlan_name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
@@ -472,13 +452,6 @@ static int register_vlan_device(struct net_device *real_dev,
 	 */
 	new_dev->mtu = real_dev->mtu;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
-	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
-		     new_dev->priv,
-		     sizeof(struct vlan_dev_info));
-#endif
-
 	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
@@ -489,9 +462,6 @@ static int register_vlan_device(struct net_device *real_dev,
 	if (err < 0)
 		goto out_free_newdev;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
-#endif
 	return 0;
 
 out_free_newdev:
@@ -641,10 +611,6 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 	args.device1[23] = 0;
 	args.u.device2[23] = 0;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: args.cmd: %x\n", __FUNCTION__, args.cmd);
-#endif
-
 	rtnl_lock();
 
 	switch (args.cmd) {
@@ -763,8 +729,6 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	default:
 		/* pass on to underlying device instead?? */
-		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
-			__FUNCTION__, args.cmd);
 		err = -EINVAL;
 		break;
 	}
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 7b615d6..5637865 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -3,31 +3,6 @@
 
 #include <linux/if_vlan.h>
 
-/*  Uncomment this if you want debug traces to be shown. */
-/* #define VLAN_DEBUG */
-
-#define VLAN_ERR KERN_ERR
-#define VLAN_INF KERN_INFO
-#define VLAN_DBG KERN_ALERT /* change these... to debug, having a hard time
-			     * changing the log level at run-time..for some reason.
-			     */
-
-/*
-
-These I use for memory debugging.  I feared a leak at one time, but
-I never found it..and the problem seems to have dissappeared.  Still,
-I'll bet they might prove useful again... --Ben
-
-
-#define VLAN_MEM_DBG(x, y, z) printk(VLAN_DBG "%s:  "  x, __FUNCTION__, y, z);
-#define VLAN_FMEM_DBG(x, y) printk(VLAN_DBG "%s:  " x, __FUNCTION__, y);
-*/
-
-/* This way they don't do anything! */
-#define VLAN_MEM_DBG(x, y, z)
-#define VLAN_FMEM_DBG(x, y)
-
-
 extern unsigned short vlan_name_type;
 
 #define VLAN_GRP_HASH_SHIFT	5
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 50d8edc..756a71c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -60,9 +60,8 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 		return arp_find(veth->h_dest, skb);
 #endif
 	default:
-		printk(VLAN_DBG
-		       "%s: unable to resolve type %X addresses.\n",
-		       dev->name, ntohs(veth->h_vlan_encapsulated_proto));
+		pr_debug("%s: unable to resolve type %X addresses.\n",
+			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
 
 		memcpy(veth->h_source, dev->dev_addr, ETH_ALEN);
 		break;
@@ -142,11 +141,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	vid = (vlan_TCI & VLAN_VID_MASK);
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: skb: %p vlan_id: %hx\n",
-		__FUNCTION__, skb, vid);
-#endif
-
 	/* Ok, we will find the correct VLAN device, strip the header,
 	 * and then go on as usual.
 	 */
@@ -162,11 +156,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = __find_vlan_dev(dev, vid);
 	if (!skb->dev) {
 		rcu_read_unlock();
-
-#ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: ERROR: No net_device for VID: %i on dev: %s [%i]\n",
-			__FUNCTION__, (unsigned int)(vid), dev->name, dev->ifindex);
-#endif
+		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s [%i]\n",
+			 __FUNCTION__, (unsigned int)vid, dev->name, dev->ifindex);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -186,11 +177,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 */
 	skb->priority = vlan_get_ingress_priority(skb->dev, ntohs(vhdr->h_vlan_TCI));
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: priority: %lu  for TCI: %hu (hbo)\n",
-		__FUNCTION__, (unsigned long)(skb->priority),
-		ntohs(vhdr->h_vlan_TCI));
-#endif
+	pr_debug("%s: priority: %u for TCI: %hu\n",
+		 __FUNCTION__, skb->priority, ntohs(vhdr->h_vlan_TCI));
 
 	/* The ethernet driver already did the pkt_type calculations
 	 * for us...
@@ -335,10 +323,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	int build_vlan_header = 0;
 	struct net_device *vdev = dev; /* save this for the bottom of the method */
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: skb: %p type: %hx len: %x vlan_id: %hx, daddr: %p\n",
-		__FUNCTION__, skb, type, len, VLAN_DEV_INFO(dev)->vlan_id, daddr);
-#endif
+	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
+		 __FUNCTION__, skb, type, len, VLAN_DEV_INFO(dev)->vlan_id, daddr);
 
 	/* build vlan header only if re_order_header flag is NOT set.  This
 	 * fixes some programs that get confused when they see a VLAN device
@@ -410,9 +396,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			return -ENOMEM;
 		}
 		VLAN_DEV_INFO(vdev)->cnt_inc_headroom_on_tx++;
-#ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: %s: had to grow skb.\n", __FUNCTION__, vdev->name);
-#endif
+		pr_debug("%s: %s: had to grow skb.\n", __FUNCTION__, vdev->name);
 	}
 
 	if (build_vlan_header) {
@@ -453,10 +437,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* This is not a VLAN frame...but we can fix that! */
 		VLAN_DEV_INFO(dev)->cnt_encap_on_xmit++;
 
-#ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: proto to encap: 0x%hx (hbo)\n",
-			__FUNCTION__, htons(veth->h_vlan_proto));
-#endif
+		pr_debug("%s: proto to encap: 0x%hx\n",
+			 __FUNCTION__, htons(veth->h_vlan_proto));
 		/* Construct the second two bytes. This field looks something
 		 * like:
 		 * usr_priority: 3 bits	 (high bits)
@@ -477,14 +459,15 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: about to send skb: %p to dev: %s\n",
+	pr_debug("%s: about to send skb: %p to dev: %s\n",
 		__FUNCTION__, skb, skb->dev->name);
-	printk(VLAN_DBG "  %2hx.%2hx.%2hx.%2xh.%2hx.%2hx %2hx.%2hx.%2hx.%2hx.%2hx.%2hx %4hx %4hx %4hx\n",
-	       veth->h_dest[0], veth->h_dest[1], veth->h_dest[2], veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
-	       veth->h_source[0], veth->h_source[1], veth->h_source[2], veth->h_source[3], veth->h_source[4], veth->h_source[5],
-	       veth->h_vlan_proto, veth->h_vlan_TCI, veth->h_vlan_encapsulated_proto);
-#endif
+	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
+		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
+		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
+		 veth->h_source[0], veth->h_source[1], veth->h_source[2],
+		 veth->h_source[3], veth->h_source[4], veth->h_source[5],
+		 veth->h_vlan_proto, veth->h_vlan_TCI,
+		 veth->h_vlan_encapsulated_proto);
 
 	stats->tx_packets++; /* for statics only */
 	stats->tx_bytes += skb->len;
@@ -596,7 +579,6 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 		}
 		return 0;
 	}
-	printk(KERN_ERR "%s: flag %i is not valid.\n", __FUNCTION__, flag);
 	return -EINVAL;
 }
 
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 1972d5c..5da02e2 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -179,13 +179,6 @@ int vlan_proc_add_dev (struct net_device *vlandev)
 {
 	struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
 
-	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN)) {
-		printk(KERN_ERR
-		       "ERROR:	vlan_proc_add, device -:%s:- is NOT a VLAN\n",
-		       vlandev->name);
-		return -EINVAL;
-	}
-
 	dev_info->dent = create_proc_entry(vlandev->name,
 					   S_IFREG|S_IRUSR|S_IWUSR,
 					   proc_vlan_dir);
@@ -194,11 +187,6 @@ int vlan_proc_add_dev (struct net_device *vlandev)
 
 	dev_info->dent->proc_fops = &vlandev_fops;
 	dev_info->dent->data = vlandev;
-
-#ifdef VLAN_DEBUG
-	printk(KERN_ERR "vlan_proc_add, device -:%s:- being added.\n",
-	       vlandev->name);
-#endif
 	return 0;
 }
 
@@ -207,28 +195,11 @@ int vlan_proc_add_dev (struct net_device *vlandev)
  */
 int vlan_proc_rem_dev(struct net_device *vlandev)
 {
-	if (!vlandev) {
-		printk(VLAN_ERR "%s: invalid argument: %p\n",
-			__FUNCTION__, vlandev);
-		return -EINVAL;
-	}
-
-	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN)) {
-		printk(VLAN_DBG "%s: invalid argument, device: %s is not a VLAN device, priv_flags: 0x%4hX.\n",
-			__FUNCTION__, vlandev->name, vlandev->priv_flags);
-		return -EINVAL;
-	}
-
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: dev: %p\n", __FUNCTION__, vlandev);
-#endif
-
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
 	if (VLAN_DEV_INFO(vlandev)->dent) {
 		remove_proc_entry(VLAN_DEV_INFO(vlandev)->dent->name, proc_vlan_dir);
 		VLAN_DEV_INFO(vlandev)->dent = NULL;
 	}
-
 	return 0;
 }
 
