From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 2][PATCH 8/8][bonding] Propagating master's settings to slaves
Date: Fri, 8 Aug 2003 17:45:23 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081745.23436.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

8 - Enhance netdev notification handling. Add comment block
    and bump version.

diff -Nuarp linux-2.4.22-rc1/drivers/net/bonding/bond_main.c linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-rc1/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:27 2003
+++ linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:28 2003
@@ -408,6 +408,18 @@
  *	  and free it separately; use standard list operations instead
  *	  of pre-allocated array of bonds.
  *	  Version to 2.3.0.
+ *
+ * 2003/08/07 - Jay Vosburgh <fubar at us dot ibm dot com>,
+ *	       Amir Noam <amir.noam at intel dot com> and
+ *	       Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Propagating master's settings: Distinguish between modes that
+ *	  use a primary slave from those that don't, and propagate settings
+ *	  accordingly; Consolidate change_active opeartions and add
+ *	  reselect_active and find_best opeartions; Decouple promiscuous
+ *	  handling from the multicast mode setting; Add support for changing
+ *	  HW address and MTU with proper unwind; Consolidate procfs code,
+ *	  add CHANGENAME handler; Enhance netdev notification handling.
+ *	  Version to 2.4.0.
  */
 
 #include <linux/config.h>
@@ -452,8 +464,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.3.0"
-#define DRV_RELDATE	"August 6, 2003"
+#define DRV_VERSION	"2.4.0"
+#define DRV_RELDATE	"August 7, 2003"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -572,7 +584,6 @@ static struct net_device_stats *bond_get
 static void bond_mii_monitor(struct net_device *dev);
 static void loadbalance_arp_monitor(struct net_device *dev);
 static void activebackup_arp_monitor(struct net_device *dev);
-static int bond_event(struct notifier_block *this, unsigned long event, void *ptr);
 static void bond_mc_list_destroy(struct bonding *bond);
 static void bond_mc_add(bonding_t *bond, void *addr, int alen);
 static void bond_mc_delete(bonding_t *bond, void *addr, int alen);
@@ -3468,7 +3479,6 @@ static int bond_read_proc(char *buf, cha
 }
 #endif /* CONFIG_PROC_FS */
 
-
 static int bond_create_proc_info(struct bonding *bond)
 {
 #ifdef CONFIG_PROC_FS
@@ -3633,21 +3643,134 @@ unwind:
 	return error;
 }
 
-static int bond_event(struct notifier_block *this, unsigned long event, 
-			void *ptr)
+/*
+ * Change device name
+ */
+static inline int bond_event_changename(struct bonding *bond)
+{
+	int error;
+
+	bond_destroy_proc_info(bond);
+	error = bond_create_proc_info(bond);
+	if (error) {
+		return NOTIFY_BAD;
+	}
+	return NOTIFY_DONE;
+}
+
+static int bond_master_netdev_event(unsigned long event, struct net_device *event_dev)
+{
+	struct bonding *bond, *event_bond = NULL;
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		if (bond == event_dev->priv) {
+			event_bond = bond;
+			break;
+		}
+	}
+
+	if (event_bond == NULL) {
+		return NOTIFY_DONE;
+	}
+
+	switch (event) {
+	case NETDEV_CHANGENAME:
+		return bond_event_changename(event_bond);
+	case NETDEV_UNREGISTER:
+		/*
+		 * TODO: remove a bond from the list?
+		 */
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int bond_slave_netdev_event(unsigned long event, struct net_device *event_dev)
 {
-	struct net_device *event_dev = (struct net_device *)ptr;
 	struct net_device *master = event_dev->master;
 
-	if ((event == NETDEV_UNREGISTER) && (master != NULL)) {
-		bond_release(master, event_dev);
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		if (master != NULL) {
+			bond_release(master, event_dev);
+		}
+		break;
+	case NETDEV_CHANGE:
+		/*
+		 * TODO: is this what we get if somebody
+		 * sets up a hierarchical bond, then rmmod's
+		 * one of the slave bonding devices?
+		 */
+		break;
+	case NETDEV_DOWN:
+		/*
+		 * ... Or is it this?
+		 */
+		break;
+	case NETDEV_CHANGEMTU:
+		/*
+		 * TODO: Should slaves be allowed to
+		 * independently alter their MTU?  For
+		 * an active-backup bond, slaves need
+		 * not be the same type of device, so
+		 * MTUs may vary.  For other modes,
+		 * slaves arguably should have the
+		 * same MTUs. To do this, we'd need to
+		 * take over the slave's change_mtu
+		 * function for the duration of their
+		 * servitude.
+		 */
+		break;
+	case NETDEV_CHANGENAME:
+		/*
+		 * TODO: handle changing the primary's name
+		 */
+		break;
+	default:
+		break;
 	}
 
 	return NOTIFY_DONE;
 }
 
+/*
+ * bond_netdev_event: handle netdev notifier chain events.
+ *
+ * This function receives events for the netdev chain.  The caller (an
+ * ioctl handler calling notifier_call_chain) holds the necessary
+ * locks for us to safely manipulate the slave devices (RTNL lock,
+ * dev_probe_lock).
+ */
+static int bond_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *event_dev = (struct net_device *)ptr;
+	unsigned short flags;
+	int res = NOTIFY_DONE;
+
+	dprintk(KERN_INFO "bond_netdev_event n_b %p ev %lx ptr %p\n",
+		this, event, ptr);
+
+	flags = event_dev->flags & (IFF_MASTER | IFF_SLAVE);
+	switch (flags) {
+	case IFF_MASTER:
+		res = bond_master_netdev_event(event, event_dev);
+		break;
+	case IFF_SLAVE:
+		res = bond_slave_netdev_event(event, event_dev);
+		break;
+	default:
+		/* A master that is also a slave ? */
+		break;
+	}
+
+	return res;
+}
+
 static struct notifier_block bond_netdev_notifier = {
-	notifier_call: bond_event,
+	notifier_call: bond_netdev_event,
 };
 
 static void bond_deinit(struct net_device *dev)

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
