From: Andrew Collins <acollins@cradlepoint.com>
Subject: Re: RESEND: Easily reproducible kernel panic due to netdev
 all_adj_list refcnt handling
Date: Fri, 25 Mar 2016 16:10:14 -0600
Message-ID: <56F5B746.9050401@cradlepoint.com>
References: <56CCDD4D.4080303@cradlepoint.com>
 <56F5A2D9.7090700@universe-factory.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------050106010707020204070907"
Cc: <netdev@vger.kernel.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phaseu-2.complex1.sms.eurus.ops.us.digitar.com ([107.6.68.63]:43143
	"EHLO phaseu-2.complex1.sms.eurus.ops.us.digitar.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595AbcCYWKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 18:10:22 -0400
Received: from apps-2.eurus.ops.us.digitar.com (phaseu-2.complex1.sms.eurus.ops.us.digitar.com [107.6.68.63])
	by phaseu-2.complex1.sms.eurus.ops.us.digitar.com (Postfix) with SMTP id 45D9AC0D9
	for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 22:10:20 +0000 (UTC)
In-Reply-To: <56F5A2D9.7090700@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------050106010707020204070907
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 03/25/2016 02:43 PM, Matthias Schiffer wrote:
> We've tried your patch, and it changes the symptoms a bit, but doesn't fix
> the panic. I've attached kernel logs of the crash both before and after
> applying the patch.
>
> One note: I did not reproduce this issue myself, it was first reported in
> [1], and then forwarded to the batman-adv issue tracker [2] by me.
>
> Regards,
> Matthias
>
>
> [1] https://github.com/freifunk-gluon/gluon/issues/680
> [2] https://www.open-mesh.org/issues/247

On the off chance it helps, the version of the patch I integrated locally takes a somewhat different approach
than the one I sent to the mailing list (propagates adj_list refcnts).  I've attached it in case it's useful.

I haven't submitted this upstream yet as it's still rather ugly.  I'm of the opinion that the whole "every device
knows every upperdev and lowerdev in its tree" model is rather broken, and the patch is just working around
a design that needs some rework.

Thanks,
Andrew Collins

--------------050106010707020204070907
Content-Type: text/x-patch; name="netdev_ref_cnt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="netdev_ref_cnt.patch"

commit df318544e282c6ab5bdc4595658fc1cf8739d091
Author: Andrew Collins <acollins@cradlepoint.com>
Date:   Fri Mar 25 16:04:59 2016 -0600

    This fixes a relatively easily reproducible kernel panic related to the
    all_adj_list handling for netdevs in recent kernels.
    
    The following sequence of commands will reproduce the issue:
    
    ip link add link eth0 name eth0.100 type vlan id 100
    ip link add link eth0 name eth0.200 type vlan id 200
    ip link add name testbr type bridge
    ip link set eth0.100 master testbr
    ip link set eth0.200 master testbr
    ip link add link testbr mac0 type macvlan
    ip link delete dev testbr
    
    This creates an upper/lower tree of (excuse the poor ASCII art):
    
                /---eth0.100-eth0
    mac0-testbr-
                \---eth0.200-eth0
    
    When testbr is deleted, the all_adj_lists are walked, and eth0 is deleted twice from
    the mac0 list. Unfortunately, during setup in __netdev_upper_dev_link, only one
    reference to eth0 is added, so this results in a panic.
    
    This change adds reference count propagation so things are handled properly.

diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..4b4ef6b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5471,6 +5471,7 @@ static inline bool netdev_adjacent_is_neigh_list(struct net_device *dev,
 
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
+					u16 ref_nr,
 					struct list_head *dev_list,
 					void *private, bool master)
 {
@@ -5480,7 +5481,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (adj) {
-		adj->ref_nr++;
+		adj->ref_nr += ref_nr;
 		return 0;
 	}
 
@@ -5490,7 +5491,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	adj->dev = adj_dev;
 	adj->master = master;
-	adj->ref_nr = 1;
+	adj->ref_nr = ref_nr;
 	adj->private = private;
 	dev_hold(adj_dev);
 
@@ -5529,6 +5530,7 @@ free_adj:
 
 static void __netdev_adjacent_dev_remove(struct net_device *dev,
 					 struct net_device *adj_dev,
+					 u16 ref_nr,
 					 struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
@@ -5541,10 +5543,10 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 		BUG();
 	}
 
-	if (adj->ref_nr > 1) {
-		pr_debug("%s to %s ref_nr-- = %d\n", dev->name, adj_dev->name,
-			 adj->ref_nr-1);
-		adj->ref_nr--;
+	if (adj->ref_nr > ref_nr) {
+		pr_debug("%s to %s ref_nr-%d = %d\n", dev->name, adj_dev->name,
+			 ref_nr, adj->ref_nr-ref_nr);
+		adj->ref_nr -= ref_nr;
 		return;
 	}
 
@@ -5563,21 +5565,22 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 
 static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 					    struct net_device *upper_dev,
+					    u16 ref_nr,
 					    struct list_head *up_list,
 					    struct list_head *down_list,
 					    void *private, bool master)
 {
 	int ret;
 
-	ret = __netdev_adjacent_dev_insert(dev, upper_dev, up_list, private,
-					   master);
+	ret = __netdev_adjacent_dev_insert(dev, upper_dev, ref_nr, up_list,
+					   private, master);
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_insert(upper_dev, dev, down_list, private,
-					   false);
+	ret = __netdev_adjacent_dev_insert(upper_dev, dev, ref_nr, down_list,
+					   private, false);
 	if (ret) {
-		__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
+		__netdev_adjacent_dev_remove(dev, upper_dev, ref_nr, up_list);
 		return ret;
 	}
 
@@ -5585,9 +5588,10 @@ static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 }
 
 static int __netdev_adjacent_dev_link(struct net_device *dev,
-				      struct net_device *upper_dev)
+				      struct net_device *upper_dev,
+				      u16 ref_nr)
 {
-	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
+	return __netdev_adjacent_dev_link_lists(dev, upper_dev, ref_nr,
 						&dev->all_adj_list.upper,
 						&upper_dev->all_adj_list.lower,
 						NULL, false);
@@ -5595,17 +5599,19 @@ static int __netdev_adjacent_dev_link(struct net_device *dev,
 
 static void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
 					       struct net_device *upper_dev,
+					       u16 ref_nr,
 					       struct list_head *up_list,
 					       struct list_head *down_list)
 {
-	__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
-	__netdev_adjacent_dev_remove(upper_dev, dev, down_list);
+	__netdev_adjacent_dev_remove(dev, upper_dev, ref_nr, up_list);
+	__netdev_adjacent_dev_remove(upper_dev, dev, ref_nr, down_list);
 }
 
 static void __netdev_adjacent_dev_unlink(struct net_device *dev,
-					 struct net_device *upper_dev)
+					 struct net_device *upper_dev,
+					 u16 ref_nr)
 {
-	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
+	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, ref_nr,
 					   &dev->all_adj_list.upper,
 					   &upper_dev->all_adj_list.lower);
 }
@@ -5614,17 +5620,17 @@ static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 						struct net_device *upper_dev,
 						void *private, bool master)
 {
-	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
+	int ret = __netdev_adjacent_dev_link(dev, upper_dev, 1);
 
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev,
+	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev, 1,
 					       &dev->adj_list.upper,
 					       &upper_dev->adj_list.lower,
 					       private, master);
 	if (ret) {
-		__netdev_adjacent_dev_unlink(dev, upper_dev);
+		__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
 		return ret;
 	}
 
@@ -5634,8 +5640,8 @@ static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 static void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 						   struct net_device *upper_dev)
 {
-	__netdev_adjacent_dev_unlink(dev, upper_dev);
-	__netdev_adjacent_dev_unlink_lists(dev, upper_dev,
+	__netdev_adjacent_dev_unlink(dev, upper_dev, 1);
+	__netdev_adjacent_dev_unlink_lists(dev, upper_dev, 1,
 					   &dev->adj_list.upper,
 					   &upper_dev->adj_list.lower);
 }
@@ -5688,7 +5694,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			pr_debug("Interlinking %s with %s, non-neighbour\n",
 				 i->dev->name, j->dev->name);
-			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
+			ret = __netdev_adjacent_dev_link(i->dev, j->dev, i->ref_nr);
 			if (ret)
 				goto rollback_mesh;
 		}
@@ -5698,7 +5704,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		pr_debug("linking %s's upper device %s with %s\n",
 			 upper_dev->name, i->dev->name, dev->name);
-		ret = __netdev_adjacent_dev_link(dev, i->dev);
+		ret = __netdev_adjacent_dev_link(dev, i->dev, i->ref_nr);
 		if (ret)
 			goto rollback_upper_mesh;
 	}
@@ -5707,7 +5713,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		pr_debug("linking %s's lower device %s with %s\n", dev->name,
 			 i->dev->name, upper_dev->name);
-		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
+		ret = __netdev_adjacent_dev_link(i->dev, upper_dev, i->ref_nr);
 		if (ret)
 			goto rollback_lower_mesh;
 	}
@@ -5725,7 +5731,7 @@ rollback_lower_mesh:
 	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		if (i == to_i)
 			break;
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
+		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
 	}
 
 	i = NULL;
@@ -5735,7 +5741,7 @@ rollback_upper_mesh:
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		if (i == to_i)
 			break;
-		__netdev_adjacent_dev_unlink(dev, i->dev);
+		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
 	}
 
 	i = j = NULL;
@@ -5747,7 +5753,7 @@ rollback_mesh:
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			if (i == to_i && j == to_j)
 				break;
-			__netdev_adjacent_dev_unlink(i->dev, j->dev);
+			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
 		}
 		if (i == to_i)
 			break;
@@ -5827,16 +5833,16 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	 */
 	list_for_each_entry(i, &dev->all_adj_list.lower, list)
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list)
-			__netdev_adjacent_dev_unlink(i->dev, j->dev);
+			__netdev_adjacent_dev_unlink(i->dev, j->dev, i->ref_nr);
 
 	/* remove also the devices itself from lower/upper device
 	 * list
 	 */
 	list_for_each_entry(i, &dev->all_adj_list.lower, list)
-		__netdev_adjacent_dev_unlink(i->dev, upper_dev);
+		__netdev_adjacent_dev_unlink(i->dev, upper_dev, i->ref_nr);
 
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
-		__netdev_adjacent_dev_unlink(dev, i->dev);
+		__netdev_adjacent_dev_unlink(dev, i->dev, i->ref_nr);
 
 	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
 				      &changeupper_info.info);

--------------050106010707020204070907--
