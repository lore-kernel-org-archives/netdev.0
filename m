From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 07/11] net/bonding: Enable IP multicast for bonding IPoIB devices
Date: Fri, 14 Sep 2007 16:40:26 -0700
Message-ID: <11898132441599-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
 <11898132372856-git-send-email-fubar@us.ibm.com>
 <11898132411426-git-send-email-fubar@us.ibm.com>
 <1189813242354-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45714 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758559AbXINXkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENekNx025087
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:46 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENekA6545368
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENejln008825
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:46 -0400
In-Reply-To: <1189813242354-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

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
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |    5 +++--
 drivers/net/bonding/bond_sysfs.c |    6 ++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d937bae..a1fe87a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1285,8 +1285,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		dprintk("Error, master_dev is not up\n");
-		return -EPERM;
+		printk(KERN_WARNING DRV_NAME
+			" %s: master_dev is not up in bond_enslave\n",
+			bond_dev->name);
 	}
 
 	/* already enslaved */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 9afd172..073841f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -265,11 +265,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 
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
-- 
1.5.2-rc2.GIT

