From: Shmulik Hen <hshmulik@intel.com>
Subject: [patch] (3/8) Add 802.3ad support to bonding
Date: Thu, 20 Mar 2003 17:16:01 +0200 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303201627280.10351-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: Bonding Developement list <bonding-devel@lists.sourceforge.net>,
   Bonding Announce list <bonding-announce@lists.sourceforge.net>,
   Linux Net Mailing list <linux-net@vger.kernel.org>,
   Linux Kernel Mailing list <linux-kernel@vger.kernel.org>,
   Oss SGI Netdev list <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a hang when enslaving a new slave while incoming traffic 
is running, that looks like a deadlock between the BR_NETPROTO_LOCK,
dev->xmit_lock and the bond lock (happens on quad processor machines,
but KDB back trace wasn't clear enough).

This patch is against bonding 2.4.20-20030317.

diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding.c linux-2.4.20-bonding-20030317-devel/drivers/net/bonding.c
--- linux-2.4.20-bonding-20030317/drivers/net/bonding.c	2003-03-18 17:03:25.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding.c	2003-03-18 17:03:26.000000000 +0200
@@ -295,6 +295,10 @@
  *	- Fixed hang in bond_release() while traffic is running.		
  *	  netdev_set_master() must not be called from within the bond lock.
  *
+ * 2003/03/18 - Tsippy Mendelson <tsippy.mendelson at intel dot com> and
+ *		Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Fixed hang in bond_enslave(): netdev_set_master() must not be
+ *	  called from within the bond lock while traffic is running.
  */
 
 #include <linux/config.h>
@@ -1066,14 +1070,12 @@ static int bond_enslave(struct net_devic
 			"Warning : no link monitoring support for %s\n",
 			slave_dev->name);
 	}
-	write_lock_irqsave(&bond->lock, flags);
 
 	/* not running. */
 	if ((slave_dev->flags & IFF_UP) != IFF_UP) {
 #ifdef BONDING_DEBUG
 		printk(KERN_CRIT "Error, slave_dev is not running\n");
 #endif
-		write_unlock_irqrestore(&bond->lock, flags);
 		return -EINVAL;
 	}
 
@@ -1082,12 +1084,10 @@ static int bond_enslave(struct net_devic
 #ifdef BONDING_DEBUG
 		printk(KERN_CRIT "Error, Device was already enslaved\n");
 #endif
-		write_unlock_irqrestore(&bond->lock, flags);
 		return -EBUSY;
 	}
 		   
 	if ((new_slave = kmalloc(sizeof(slave_t), GFP_ATOMIC)) == NULL) {
-		write_unlock_irqrestore(&bond->lock, flags);
 		return -ENOMEM;
 	}
 	memset(new_slave, 0, sizeof(slave_t));
@@ -1100,9 +1100,7 @@ static int bond_enslave(struct net_devic
 #ifdef BONDING_DEBUG
 		printk(KERN_CRIT "Error %d calling netdev_set_master\n", err);
 #endif
-		kfree(new_slave);
-		write_unlock_irqrestore(&bond->lock, flags);
-		return err;      
+		goto err_free;
 	}
 
 	new_slave->dev = slave_dev;
@@ -1121,6 +1119,8 @@ static int bond_enslave(struct net_devic
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 	}
 
+	write_lock_irqsave(&bond->lock, flags);
+	
 	bond_attach_slave(bond, new_slave);
 	new_slave->delay = 0;
 	new_slave->link_failure_count = 0;
@@ -1259,7 +1259,11 @@ static int bond_enslave(struct net_devic
 		new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
 		new_slave->link == BOND_LINK_UP ? "n up" : " down");
 
+	//enslave is successfull
 	return 0;
+err_free:
+	kfree(new_slave);
+	return err;
 }
 
 /* 
@@ -1607,6 +1611,9 @@ static int bond_release_all(struct net_d
 
 		kfree(our_slave);
 
+		/* Can be safely called from inside the bond lock
+		   since traffic and timers have already stopped
+		*/
 		netdev_set_master(slave_dev, NULL);
 
 		/* only restore its RUNNING flag if monitoring set it down */

-- 
| Shmulik Hen                                    |
| Israel Design Center (Jerusalem)               |
| LAN Access Division                            |
| Intel Communications Group, Intel corp.        |
|                                                |
| Anti-Spam: shmulik dot hen at intel dot com    |
