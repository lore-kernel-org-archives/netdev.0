From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/9] net/bonding: Enable IP multicast for bonding IPoIB devices
Date: Tue,  9 Oct 2007 19:43:40 -0700
Message-ID: <11919842273755-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
 <1191984226411-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48698 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbXJJCnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:50 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hmHf018527
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:48 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hmWp480758
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hl9L002051
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
In-Reply-To: <1191984226411-git-send-email-fubar@us.ibm.com>
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

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |    5 +++--
 drivers/net/bonding/bond_sysfs.c |    6 ++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6508e0b..3eebfe2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1280,8 +1280,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
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
index 6f49ca7..ca4e429 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -266,11 +266,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 
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
1.5.3.1

