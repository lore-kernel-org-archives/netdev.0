From: Amerigo Wang <amwang@redhat.com>
Subject: [V2 Patch net-next-2.6] netpoll: disable netpoll when enslave a device
Date: Thu, 19 May 2011 16:39:53 +0800
Message-ID: <1305794393-20775-1-git-send-email-amwang@redhat.com>
References: <20110518105558.GA3203@hmsreliant.think-freely.org>
Cc: akpm@linux-foundation.org, WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518105558.GA3203@hmsreliant.think-freely.org>
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
 drivers/net/bonding/bond_main.c |    2 ++
 drivers/net/netconsole.c        |   26 +++++++++++++++++---------
 include/linux/notifier.h        |    1 +
 3 files changed, 20 insertions(+), 9 deletions(-)

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
index a83e101..c2a8230 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -621,11 +621,10 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
-	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
+	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_ENSLAVE))
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
-restart:
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
@@ -633,6 +632,8 @@ restart:
 			case NETDEV_CHANGENAME:
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;
+			case NETDEV_BONDING_DESLAVE:
+			case NETDEV_ENSLAVE:
 			case NETDEV_UNREGISTER:
 				/*
 				 * rtnl_lock already held
@@ -647,11 +648,7 @@ restart:
 					dev_put(nt->np.dev);
 					nt->np.dev = NULL;
 					netconsole_target_put(nt);
-					goto restart;
 				}
-				/* Fall through */
-			case NETDEV_GOING_DOWN:
-			case NETDEV_BONDING_DESLAVE:
 				nt->enabled = 0;
 				stopped = true;
 				break;
@@ -660,10 +657,21 @@ restart:
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
