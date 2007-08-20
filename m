From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V4 7/10] net/bonding: Enable IP multicast for bonding IPoIB
 devices
Date: Mon, 20 Aug 2007 18:51:35 +0300
Message-ID: <46C9B887.7000609@voltaire.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:30480 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759485AbXHTPvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 11:51:37 -0400
In-Reply-To: <46C9B474.5020202@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow to enslave devices when the bonding device is not up. Over the discussion
held at the previous post this seemed to be the most clean way to go, where it
is not expected to cause instabilities.

Normally, the bonding driver is UP before any enslavement takes place.
Once a netdevice is UP, the network stack acts to have it join some multicast groups
(eg the all-hosts 224.0.0.1). Now, since ether_setup() have set the bonding device
type to be ARPHRD_ETHER and address len to be ETHER_ALEN, the net core code
computes a wrong multicast link address. This is b/c ip_eth_mc_map() is called
where for multicast joins taking place after the enslavement another ip_xxx_mc_map()
is called (eg ip_ib_mc_map() when the bond type is ARPHRD_INFINIBAND)

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
---
 drivers/net/bonding/bond_main.c  |    5 +++--
 drivers/net/bonding/bond_sysfs.c |    6 ++----
 2 files changed, 5 insertions(+), 6 deletions(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:54:41.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-15 10:55:48.431862446 +0300
@@ -1285,8 +1285,9 @@ int bond_enslave(struct net_device *bond
 
 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		dprintk("Error, master_dev is not up\n");
-		return -EPERM;
+		printk(KERN_WARNING DRV_NAME
+			" %s: master_dev is not up in bond_enslave\n",
+			bond_dev->name);
 	}
 
 	/* already enslaved */
Index: net-2.6/drivers/net/bonding/bond_sysfs.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_sysfs.c	2007-08-15 10:08:58.000000000 +0300
+++ net-2.6/drivers/net/bonding/bond_sysfs.c	2007-08-15 10:55:48.432862269 +0300
@@ -266,11 +266,9 @@ static ssize_t bonding_store_slaves(stru
 
 	/* Quick sanity check -- is the bond interface up? */
 	if (!(bond->dev->flags & IFF_UP)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Unable to update slaves because interface is down.\n",
+		printk(KERN_WARNING DRV_NAME
+		       ": %s: doing slave updates when interface is down.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
 	}
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */

