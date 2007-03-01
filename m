From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Wed, 28 Feb 2007 17:03:37 -0800
Message-ID: <200703010103.l2113b22030905@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54977 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932875AbXCABDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 20:03:39 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2113dHt025679
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:03:39 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l2113cq7441406
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:03:39 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2113cQr011763
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:03:38 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	In active-backup mode, the current bonding code duplicates IGMP
traffic to all slaves, so that switches are up to date in case of a
failover from an active to a backup interface.  If bonding then fails
back to the original active interface, it is likely that the "active
slave" switch's IGMP forwarding for the port will be out of date until
some event occurs to refresh the switch (e.g., a membership query).

	This patch alters the behavior of bonding to no longer flood
IGMP to all ports, and to issue IGMP JOINs to the newly active port at
the time of a failover.  This insures that switches are kept up to date
for all cases.

	"GOELLESCH Niels" <niels.goellesch@eurocontrol.int> originally
reported this problem, and included a patch.  His original patch was
modified by Jay Vosburgh to additionally remove the existing IGMP flood
behavior, use RCU, streamline code paths, fix trailing white space, and
adjust for style.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7ec6121..338d452 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -60,6 +60,7 @@ #include <asm/uaccess.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/igmp.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -861,6 +862,28 @@ static void bond_mc_delete(struct bondin
 	}
 }
 
+
+/*
+ * Retrieve the list of registered multicast addresses for the bonding
+ * device and retransmit an IGMP JOIN request to the current active
+ * slave.
+ */
+static void bond_resend_igmp_join_requests(struct bonding *bond)
+{
+	struct in_device *in_dev;
+	struct ip_mc_list *im;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(bond->dev);
+	if (in_dev) {
+		for (im = in_dev->mc_list; im; im = im->next) {
+			ip_mc_rejoin_group(im);
+		}
+	}
+
+	rcu_read_unlock();
+}
+
 /*
  * Totally destroys the mc_list in bond
  */
@@ -874,6 +897,7 @@ static void bond_mc_list_destroy(struct 
 		kfree(dmi);
 		dmi = bond->mc_list;
 	}
+        bond->mc_list = NULL;
 }
 
 /*
@@ -967,6 +991,7 @@ static void bond_mc_swap(struct bonding 
 		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add(new_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
+		bond_resend_igmp_join_requests(bond);
 	}
 }
 
@@ -4017,42 +4042,6 @@ out:
 	return 0;
 }
 
-static void bond_activebackup_xmit_copy(struct sk_buff *skb,
-                                        struct bonding *bond,
-                                        struct slave *slave)
-{
-	struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
-	struct ethhdr *eth_data;
-	u8 *hwaddr;
-	int res;
-
-	if (!skb2) {
-		printk(KERN_ERR DRV_NAME ": Error: "
-		       "bond_activebackup_xmit_copy(): skb_copy() failed\n");
-		return;
-	}
-
-	skb2->mac.raw = (unsigned char *)skb2->data;
-	eth_data = eth_hdr(skb2);
-
-	/* Pick an appropriate source MAC address
-	 *	-- use slave's perm MAC addr, unless used by bond
-	 *	-- otherwise, borrow active slave's perm MAC addr
-	 *	   since that will not be used
-	 */
-	hwaddr = slave->perm_hwaddr;
-	if (!memcmp(eth_data->h_source, hwaddr, ETH_ALEN))
-		hwaddr = bond->curr_active_slave->perm_hwaddr;
-
-	/* Set source MAC address appropriately */
-	memcpy(eth_data->h_source, hwaddr, ETH_ALEN);
-
-	res = bond_dev_queue_xmit(bond, skb2, slave->dev);
-	if (res)
-		dev_kfree_skb(skb2);
-
-	return;
-}
 
 /*
  * in active-backup mode, we know that bond->curr_active_slave is always valid if
@@ -4073,21 +4062,6 @@ static int bond_xmit_activebackup(struct
 	if (!bond->curr_active_slave)
 		goto out;
 
-	/* Xmit IGMP frames on all slaves to ensure rapid fail-over
-	   for multicast traffic on snooping switches */
-	if (skb->protocol == __constant_htons(ETH_P_IP) &&
-	    skb->nh.iph->protocol == IPPROTO_IGMP) {
-		struct slave *slave, *active_slave;
-		int i;
-
-		active_slave = bond->curr_active_slave;
-		bond_for_each_slave_from_to(bond, slave, i, active_slave->next,
-		                            active_slave->prev)
-			if (IS_UP(slave->dev) &&
-			    (slave->link == BOND_LINK_UP))
-				bond_activebackup_xmit_copy(skb, bond, slave);
-	}
-
 	res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
 
 out:
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 9dbb525..a113fe6 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -218,5 +218,7 @@ extern void ip_mc_up(struct in_device *)
 extern void ip_mc_down(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
+extern void ip_mc_rejoin_group(struct ip_mc_list *im);
+
 #endif
 #endif
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 0637213..1c6a084 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1251,6 +1251,28 @@ out:
 }
 
 /*
+ *	Resend IGMP JOIN report; used for bonding.
+ */
+void ip_mc_rejoin_group(struct ip_mc_list *im)
+{
+	struct in_device *in_dev = im->interface;
+
+#ifdef CONFIG_IP_MULTICAST
+	if (im->multiaddr == IGMP_ALL_HOSTS)
+		return;
+
+	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
+		igmp_mod_timer(im, IGMP_Initial_Report_Delay);
+		return;
+	}
+	/* else, v3 */
+	im->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
+		IGMP_Unsolicited_Report_Count;
+	igmp_ifc_event(in_dev);
+#endif
+}
+
+/*
  *	A socket has left a multicast group on device dev
  */
 
@@ -2596,3 +2618,4 @@ #endif
 EXPORT_SYMBOL(ip_mc_dec_group);
 EXPORT_SYMBOL(ip_mc_inc_group);
 EXPORT_SYMBOL(ip_mc_join_group);
+EXPORT_SYMBOL(ip_mc_rejoin_group);
