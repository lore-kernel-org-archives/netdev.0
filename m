From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V6 5/9] net/bonding: Enable IP multicast for
 bonding IPoIB devices
Date: Mon, 24 Sep 2007 17:37:00 +0200
Message-ID: <46F7D99C.3030602@voltaire.com>
References: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F7D770.4090500@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
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

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
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
