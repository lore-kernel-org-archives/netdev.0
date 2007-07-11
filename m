From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN 02/04]: Fix MAC address handling
Date: Wed, 11 Jul 2007 19:54:18 +0200
Message-ID: <4695194A.3040908@trash.net>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain> <20070711173815.18369.24201.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030304050602050403070100"
Cc: netdev@vger.kernel.org, greearb@candelatech.com, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58649 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764658AbXGKRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:54:21 -0400
In-Reply-To: <20070711173815.18369.24201.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030304050602050403070100
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [VLAN]: Fix MAC address handling
> 
> +static void vlan_sync_address(struct net_device *dev,
> +			      struct net_device *vlandev)
> +{
> +	struct vlan_dev_info *vlan = VLAN_DEV_INFO(vlandev);
> +
> +	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
> +		return;
> +
> +	if (compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
> +		dev_unicast_add(dev, vlandev->dev_addr, ETH_ALEN);
> +	else
> +		dev_unicast_delete(dev, vlandev->dev_addr, ETH_ALEN);
> +
> +	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
> +}


Unfortunately the one case I didn't test is still wrong :|

The above synchronization incorrectly removes the address in case
if was different before and is still different afterwards. This
patch is fixed and contains a few comments as an added bonus :)


--------------030304050602050403070100
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[VLAN]: Fix MAC address handling

The VLAN MAC address handling is broken in multiple ways. When the address
differs when setting it, the real device is put in promiscous mode twice,
but never taken out again. Additionally it doesn't resync when the real
device's address is changed and needlessly puts it in promiscous mode when
the vlan device is still down.

Fix by moving address handling to vlan_dev_open/vlan_dev_stop and properly
deal with address changes in the device notifier. Also switch to
dev_unicast_add (which needs the exact same handling).

Since the set_mac_address handler is identical to the generic ethernet one
with these changes, kill it and use ether_setup().

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7d0a5d2f8d28ebe95cda8d2e16bf6d8030efc8b3
tree d91afa76b1aaaaa069a435967b8627f6aa820e13
parent 690fb4dbafa9f60f8cb520d5def544580107b3a4
author Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:52:08 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:52:08 +0200

 include/linux/if_vlan.h |    1 +
 net/8021q/vlan.c        |   43 +++++++++++++++++++++++++++++++----
 net/8021q/vlan.h        |    1 -
 net/8021q/vlan_dev.c    |   57 +++++++++++++++--------------------------------
 4 files changed, 57 insertions(+), 45 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index c791287..61a57dc 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -135,6 +135,7 @@ struct vlan_dev_info {
 	int old_allmulti;               /* similar to above. */
 	int old_promiscuity;            /* similar to above. */
 	struct net_device *real_dev;    /* the underlying device/interface */
+	unsigned char real_dev_addr[ETH_ALEN];
 	struct proc_dir_entry *dent;    /* Holds the proc data */
 	unsigned long cnt_inc_headroom_on_tx; /* How many times did we have to grow the skb on TX. */
 	unsigned long cnt_encap_on_xmit;      /* How many times did we have to encapsulate the skb on TX. */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index e7583ee..b463ba4 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -345,12 +345,8 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
-	/* TODO: maybe just assign it to be ETHERNET? */
-	dev->type = real_dev->type;
-
 	memcpy(dev->broadcast, real_dev->broadcast, real_dev->addr_len);
 	memcpy(dev->dev_addr, real_dev->dev_addr, real_dev->addr_len);
-	dev->addr_len = real_dev->addr_len;
 
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->hard_header     = real_dev->hard_header;
@@ -364,6 +360,7 @@ static int vlan_dev_init(struct net_device *dev)
 		dev->rebuild_header  = vlan_dev_rebuild_header;
 	}
 	dev->hard_header_parse = real_dev->hard_header_parse;
+	dev->hard_header_cache = NULL;
 
 	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
 	return 0;
@@ -373,6 +370,8 @@ void vlan_setup(struct net_device *new_dev)
 {
 	SET_MODULE_OWNER(new_dev);
 
+	ether_setup(new_dev);
+
 	/* new_dev->ifindex = 0;  it will be set when added to
 	 * the global list.
 	 * iflink is set as well.
@@ -392,7 +391,6 @@ void vlan_setup(struct net_device *new_dev)
 	new_dev->init = vlan_dev_init;
 	new_dev->open = vlan_dev_open;
 	new_dev->stop = vlan_dev_stop;
-	new_dev->set_mac_address = vlan_dev_set_mac_address;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->destructor = free_netdev;
 	new_dev->do_ioctl = vlan_dev_ioctl;
@@ -592,6 +590,30 @@ out_free_newdev:
 	return err;
 }
 
+static void vlan_sync_address(struct net_device *dev,
+			      struct net_device *vlandev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(vlandev);
+
+	/* May be called without an actual change */
+	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
+		return;
+
+	/* vlan address was different from the old address and is equal to
+	 * the new address */
+	if (compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    !compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
+		dev_unicast_delete(dev, vlandev->dev_addr, ETH_ALEN);
+
+	/* vlan address was equal to the old address and is different from
+	 * the new address */
+	if (!compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
+		dev_unicast_add(dev, vlandev->dev_addr, ETH_ALEN);
+
+	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
+}
+
 static int vlan_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -618,6 +640,17 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		break;
 
+	case NETDEV_CHANGEADDR:
+		/* Adjust unicast filters on underlying device */
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			vlan_sync_address(dev, vlandev);
+		}
+		break;
+
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index fe6bb0f..62ce1c5 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -58,7 +58,6 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int vlan_dev_change_mtu(struct net_device *dev, int new_mtu);
-int vlan_dev_set_mac_address(struct net_device *dev, void* addr);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
 int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 95afe38..d4a62d1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -612,44 +612,6 @@ void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
 	*result = VLAN_DEV_INFO(dev)->vlan_id;
 }
 
-int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
-{
-	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
-	int i;
-
-	if (netif_running(dev))
-		return -EBUSY;
-
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-
-	printk("%s: Setting MAC address to ", dev->name);
-	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i]);
-	printk(".\n");
-
-	if (memcmp(VLAN_DEV_INFO(dev)->real_dev->dev_addr,
-		   dev->dev_addr,
-		   dev->addr_len) != 0) {
-		if (!(VLAN_DEV_INFO(dev)->real_dev->flags & IFF_PROMISC)) {
-			int flgs = VLAN_DEV_INFO(dev)->real_dev->flags;
-
-			/* Increment our in-use promiscuity counter */
-			dev_set_promiscuity(VLAN_DEV_INFO(dev)->real_dev, 1);
-
-			/* Make PROMISC visible to the user. */
-			flgs |= IFF_PROMISC;
-			printk("VLAN (%s):  Setting underlying device (%s) to promiscious mode.\n",
-			       dev->name, VLAN_DEV_INFO(dev)->real_dev->name);
-			dev_change_flags(VLAN_DEV_INFO(dev)->real_dev, flgs);
-		}
-	} else {
-		printk("VLAN (%s):  Underlying device (%s) has same MAC, not checking promiscious mode.\n",
-		       dev->name, VLAN_DEV_INFO(dev)->real_dev->name);
-	}
-
-	return 0;
-}
-
 static inline int vlan_dmi_equals(struct dev_mc_list *dmi1,
 				  struct dev_mc_list *dmi2)
 {
@@ -736,15 +698,32 @@ static void vlan_flush_mc_list(struct net_device *dev)
 
 int vlan_dev_open(struct net_device *dev)
 {
-	if (!(VLAN_DEV_INFO(dev)->real_dev->flags & IFF_UP))
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct net_device *real_dev = vlan->real_dev;
+	int err;
+
+	if (!(real_dev->flags & IFF_UP))
 		return -ENETDOWN;
 
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
+		err = dev_unicast_add(real_dev, dev->dev_addr, ETH_ALEN);
+		if (err < 0)
+			return err;
+	}
+	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
+
 	return 0;
 }
 
 int vlan_dev_stop(struct net_device *dev)
 {
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+
 	vlan_flush_mc_list(dev);
+
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
+
 	return 0;
 }
 

--------------030304050602050403070100--
