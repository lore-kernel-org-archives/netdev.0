From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch net-next-2.6] netpoll: disable netpoll when enslave a device
Date: Wed, 18 May 2011 18:00:35 +0800
Message-ID: <1305712845-11762-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Ferenc Wagner <wferi@niif.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we do nothing when we enslave a net device which is running netconsole.
Neil pointed out that we may get weird results in such case, so let's disable
netpoll on the device being enslaved. I think it is too harsh to prevent
the device being ensalved if it is running netconsole.

By the way, this patch also removes the NETDEV_GOING_DOWN from netconsole
netdev notifier, because netpoll will check if the device is running or not
and we don't handle NETDEV_PRE_UP neither.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 088fd84..b9c70c5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1640,6 +1640,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	netdev_bonding_change(slave_dev, NETDEV_ENSLAVE);
+
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
 	if (is_zero_ether_addr(bond->dev->dev_addr))
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index a83e101..0c3e8de 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -621,7 +621,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
-	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
+	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN ||
+	      event == NETDEV_ENSLAVE))
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
@@ -650,8 +651,8 @@ restart:
 					goto restart;
 				}
 				/* Fall through */
-			case NETDEV_GOING_DOWN:
 			case NETDEV_BONDING_DESLAVE:
+			case NETDEV_ENSLAVE:
 				nt->enabled = 0;
 				stopped = true;
 				break;
@@ -660,10 +661,21 @@ restart:
 		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
-	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
+	if (stopped) {
 		printk(KERN_INFO "netconsole: network logging stopped on "
-			"interface %s as it %s\n",  dev->name,
-			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
+		       "interface %s as it ", dev->name);
+		switch (event) {
+		case NETDEV_UNREGISTER:
+			printk(KERN_CONT "unregistered\n");
+			break;
+		case NETDEV_BONDING_DESLAVE:
+			printk(KERN_CONT "released slaves\n");
+			break;
+		case NETDEV_ENSLAVE:
+			printk(KERN_CONT "is enslaved\n");
+			break;
+		}
+	}
 
 done:
 	return NOTIFY_DONE;
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 621dfa1..3d82867 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -211,6 +211,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_UNREGISTER_BATCH 0x0011
 #define NETDEV_BONDING_DESLAVE  0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
+#define NETDEV_ENSLAVE		0x0014
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
