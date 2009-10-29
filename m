From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 15:23:16 +0100
Message-ID: <4AE9A554.8030207@trash.net>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com> <4AE99C88.40403@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080404090006000700090104"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51462 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbZJ2OXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:23:18 -0400
In-Reply-To: <4AE99C88.40403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080404090006000700090104
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Patrick McHardy wrote:
> Eric Dumazet wrote:
>> Patrick McHardy a écrit :
>>>> +{
>>>> +	LIST_HEAD(list);
>>>> +	int i;
>>>> +	struct net_device *vlandev;
>>>> +	struct vlan_group save;
>>>> +
>>>> +	memcpy(&save, grp, sizeof(save));
>>>> +	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arrays));
>>> This shouldn't be necessary since the lower device is already in the
>>> process of being unregistered. If it was necessary, it could cause
>>> crashes since the individual pointers are not set to zero atomically.
>>> Or maybe I'm misunderstanding the purpose entirely :)
>> Very good point indeed, even if in practice memset() use long word transferts
>>
>> I'll make a cleanup patch, or do you want to do it ?
> 
> I can take care of this, patch will follow shortly.

How about this? I moved the code back into vlan_device_event() since
its now only a very minimal change to the original code.

vlan-orig.diff contains the diff between the original code and the
code after this patch for reference.


--------------080404090006000700090104
Content-Type: text/x-patch;
 name="vlan.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan.diff"

commit aa8fda37701cb6a452aeb6505c42817ad6e081fc
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Oct 29 15:13:38 2009 +0100

    vlan: cleanup multiple unregistrations
    
    The temporary copy of the VLAN group is not neccessary since the lower device
    is already in the process of being unregistered, if it was neccessary the
    memset of the global group would introduce a race condition.
    
    With this removed, the changes to the original code are only a few lines, so
    remove the new function and move the code back into vlan_device_event().
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 511afe7..39f8d01 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -161,10 +161,10 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	grp->nr_vlans--;
 
-	if (!grp->killall) {
-		vlan_group_set_device(grp, vlan_id, NULL);
+	vlan_group_set_device(grp, vlan_id, NULL);
+	if (!grp->killall)
 		synchronize_net();
-	}
+
 	unregister_netdevice_queue(dev, head);
 
 	/* If the group is now empty, kill off the group. */
@@ -184,34 +184,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
-void unregister_vlan_dev_alls(struct vlan_group *grp)
-{
-	LIST_HEAD(list);
-	int i;
-	struct net_device *vlandev;
-	struct vlan_group save;
-
-	memcpy(&save, grp, sizeof(save));
-	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arrays));
-	grp->killall = 1;
-
-	synchronize_net();
-
-	/* Delete all VLANs for this dev. */
-	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
-		vlandev = vlan_group_get_device(&save, i);
-		if (!vlandev)
-			continue;
-
-		unregister_vlan_dev(vlandev, &list);
-		if (grp->nr_vlans == 0)
-			break;
-	}
-	unregister_netdevice_many(&list);
-	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
-		kfree(save.vlan_devices_arrays[i]);
-}
-
 static void vlan_transfer_operstate(const struct net_device *dev,
 				    struct net_device *vlandev)
 {
@@ -456,6 +428,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct vlan_group *grp;
 	int i, flgs;
 	struct net_device *vlandev;
+	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev))
 		__vlan_device_event(dev, event);
@@ -553,7 +526,22 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_UNREGISTER:
-		unregister_vlan_dev_alls(grp);
+		/* Delete all VLANs for this dev. */
+		grp->killall = 1;
+
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			/* unregistration of last vlan destroys group, abort
+			 * afterwards */
+			if (grp->nr_vlans == 1)
+				i = VLAN_GROUP_ARRAY_LEN;
+
+			unregister_vlan_dev(vlandev, &list);
+		}
+		unregister_netdevice_many(&list);
 		break;
 	}
 

--------------080404090006000700090104
Content-Type: text/x-patch;
 name="vlan-orig.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan-orig.diff"

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6b5c9dd..39f8d01 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -159,10 +159,11 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
-	vlan_group_set_device(grp, vlan_id, NULL);
 	grp->nr_vlans--;
 
-	synchronize_net();
+	vlan_group_set_device(grp, vlan_id, NULL);
+	if (!grp->killall)
+		synchronize_net();
 
 	unregister_netdevice_queue(dev, head);
 
@@ -427,6 +428,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct vlan_group *grp;
 	int i, flgs;
 	struct net_device *vlandev;
+	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev))
 		__vlan_device_event(dev, event);
@@ -525,6 +527,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_UNREGISTER:
 		/* Delete all VLANs for this dev. */
+		grp->killall = 1;
+
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
@@ -535,8 +539,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (grp->nr_vlans == 1)
 				i = VLAN_GROUP_ARRAY_LEN;
 
-			unregister_vlan_dev(vlandev, NULL);
+			unregister_vlan_dev(vlandev, &list);
 		}
+		unregister_netdevice_many(&list);
 		break;
 	}
 

--------------080404090006000700090104--
