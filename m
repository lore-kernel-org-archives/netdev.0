From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 4/5] [bonding] backport 2.6 changes to 2.4
Date: Wed, 30 Jul 2003 20:07:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307302007.21369.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Backported from 2.6:
Don't dynamically allocate a net_device_stats structure for each bond,
instead allocate it with the bonding structure.

Since they are always allocated together anyway, we might as well put
the stats struct within the bond.

Amir

diff -Nuarp linux-2.4.22-pre9/drivers/net/bonding/bond_main.c linux-2.4.22-pre9-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-pre9/drivers/net/bonding/bond_main.c	Wed Jul 30 19:14:08 2003
+++ linux-2.4.22-pre9-devel/drivers/net/bonding/bond_main.c	Wed Jul 30 19:14:09 2003
@@ -3319,10 +3319,10 @@ static int bond_xmit_activebackup(struct
 static struct net_device_stats *bond_get_stats(struct net_device *dev)
 {
 	bonding_t *bond = dev->priv;
-	struct net_device_stats *stats = bond->stats, *sstats;
+	struct net_device_stats *stats = &(bond->stats), *sstats;
 	slave_t *slave;
 
-	memset(bond->stats, 0, sizeof(struct net_device_stats));
+	memset(stats, 0, sizeof(struct net_device_stats));
 
 	read_lock_bh(&bond->lock);
 
@@ -3560,13 +3560,6 @@ static int __init bond_init(struct net_d
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->ptrlock);
-	
-	bond->stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
-	if (bond->stats == NULL) {
-		kfree(bond);
-		return -ENOMEM;
-	}
-	memset(bond->stats, 0, sizeof(struct net_device_stats));
 
 	bond->next = bond->prev = (slave_t *)bond;
 	bond->current_slave = NULL;
@@ -3597,7 +3590,6 @@ static int __init bond_init(struct net_d
 		break;
 	default:
 		printk(KERN_ERR "Unknown bonding mode %d\n", bond_mode);
-		kfree(bond->stats);
 		kfree(bond);
 		return -EINVAL;
 	}
@@ -3648,7 +3640,6 @@ static int __init bond_init(struct net_d
 	if (bond->bond_proc_dir == NULL) {
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n", 
 			dev->name, dev->name);
-		kfree(bond->stats);
 		kfree(bond);
 		return -ENOMEM;
 	}
@@ -3661,7 +3652,6 @@ static int __init bond_init(struct net_d
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
 			dev->name, dev->name);
 		remove_proc_entry(dev->name, proc_net);
-		kfree(bond->stats);
 		kfree(bond);
 		return -ENOMEM;
 	}
@@ -4004,9 +3994,8 @@ static void __exit bonding_exit(void)
 		remove_proc_entry(dev_bond->name, proc_net);
 #endif
 		unregister_netdev(dev_bond);
-		kfree(bond->stats);
 		kfree(dev_bond->priv);
-		
+
 		dev_bond->priv = NULL;
 		dev_bond++;
 	}
diff -Nuarp linux-2.4.22-pre9/drivers/net/bonding/bonding.h linux-2.4.22-pre9-devel/drivers/net/bonding/bonding.h
--- linux-2.4.22-pre9/drivers/net/bonding/bonding.h	Wed Jul 30 19:14:08 2003
+++ linux-2.4.22-pre9-devel/drivers/net/bonding/bonding.h	Wed Jul 30 19:14:09 2003
@@ -99,7 +99,7 @@ typedef struct bonding {
 	rwlock_t ptrlock;
 	struct timer_list mii_timer;
 	struct timer_list arp_timer;
-	struct net_device_stats *stats;
+	struct net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *bond_proc_dir;
 	struct proc_dir_entry *bond_proc_info_file;
