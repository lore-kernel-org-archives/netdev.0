From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V2 3/4] cxgb4: Add CLIP support to store compressed IPv6 address
Date: Wed, 12 Jun 2013 17:11:41 +0530
Message-ID: <1371037302-3586-4-git-send-email-vipul@chelsio.com>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1371037302-3586-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Compressed LIP region is used to hold a limited number of Local IPv6
addresses. This region is primarily used to reduce the TCAM space consumed for
an IPv6 offloaded connection. A 128-bit LIP will be reduced to 13-bit and stored
in the TCAM if there is a match between the IPv6 tuple's LIP and the one stored
in the CLIP region.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
V2: Used local variables instead of typecasting in patch 1/4.

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 206 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  23 +++
 2 files changed, 229 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d1d6ff7..4ae287c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -60,6 +60,7 @@
 #include <linux/workqueue.h>
 #include <net/neighbour.h>
 #include <net/netevent.h>
+#include <net/addrconf.h>
 #include <asm/uaccess.h>
 
 #include "cxgb4.h"
@@ -68,6 +69,11 @@
 #include "t4fw_api.h"
 #include "l2t.h"
 
+#include <../drivers/net/bonding/bonding.h>
+
+#ifdef DRV_VERSION
+#undef DRV_VERSION
+#endif
 #define DRV_VERSION "2.0.0-ko"
 #define DRV_DESC "Chelsio T4/T5 Network Driver"
 
@@ -3227,6 +3233,38 @@ static int tid_init(struct tid_info *t)
 	return 0;
 }
 
+static int cxgb4_clip_get(const struct net_device *dev,
+			  const struct in6_addr *lip)
+{
+	struct adapter *adap;
+	struct fw_clip_cmd c;
+
+	adap = netdev2adap(dev);
+	memset(&c, 0, sizeof(c));
+	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
+			FW_CMD_REQUEST | FW_CMD_WRITE);
+	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_ALLOC | FW_LEN16(c));
+	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
+	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
+}
+
+static int cxgb4_clip_release(const struct net_device *dev,
+			      const struct in6_addr *lip)
+{
+	struct adapter *adap;
+	struct fw_clip_cmd c;
+
+	adap = netdev2adap(dev);
+	memset(&c, 0, sizeof(c));
+	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
+			FW_CMD_REQUEST | FW_CMD_READ);
+	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_FREE | FW_LEN16(c));
+	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
+	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
+}
+
 /**
  *	cxgb4_create_server - create an IP server
  *	@dev: the device
@@ -3878,6 +3916,169 @@ int cxgb4_unregister_uld(enum cxgb4_uld type)
 }
 EXPORT_SYMBOL(cxgb4_unregister_uld);
 
+/* Check if netdev on which event is occured belongs to us or not. Return
+ * suceess (1) if it belongs otherwise failure (0).
+ */
+static int cxgb4_netdev(struct net_device *netdev)
+{
+	struct adapter *adap;
+	int i;
+
+	mutex_lock(&uld_mutex);
+	list_for_each_entry(adap, &adapter_list, list_node)
+		for (i = 0; i < MAX_NPORTS; i++)
+			if (adap->port[i] == netdev) {
+				mutex_unlock(&uld_mutex);
+				return 1;
+			}
+	mutex_unlock(&uld_mutex);
+	return 0;
+}
+
+static int clip_add(struct net_device *event_dev, struct inet6_ifaddr *ifa,
+		    unsigned long event)
+{
+	int ret = NOTIFY_DONE;
+
+	rcu_read_lock();
+	if (cxgb4_netdev(event_dev)) {
+		switch (event) {
+		case NETDEV_UP:
+			ret = cxgb4_clip_get(event_dev,
+				(const struct in6_addr *)ifa->addr.s6_addr);
+			if (ret < 0) {
+				rcu_read_unlock();
+				return ret;
+			}
+			ret = NOTIFY_OK;
+			break;
+		case NETDEV_DOWN:
+			cxgb4_clip_release(event_dev,
+				(const struct in6_addr *)ifa->addr.s6_addr);
+			ret = NOTIFY_OK;
+			break;
+		default:
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
+static int cxgb4_inet6addr_handler(struct notifier_block *this,
+		unsigned long event, void *data)
+{
+	struct inet6_ifaddr *ifa = data;
+	struct net_device *event_dev;
+	int ret = NOTIFY_DONE;
+	int cnt;
+	struct bonding *bond = netdev_priv(ifa->idev->dev);
+	struct slave *slave;
+	struct pci_dev *first_pdev = NULL;
+
+	if (ifa->idev->dev->priv_flags & IFF_802_1Q_VLAN) {
+		event_dev = vlan_dev_real_dev(ifa->idev->dev);
+		ret = clip_add(event_dev, ifa, event);
+	} else if (ifa->idev->dev->flags & IFF_MASTER) {
+		/* It is possible that two different adapters are bonded in one
+		 * bond. We need to find such different adapters and add clip
+		 * in all of them only once.
+		 */
+		read_lock(&bond->lock);
+		bond_for_each_slave(bond, slave, cnt) {
+			if (!first_pdev) {
+				ret = clip_add(slave->dev, ifa, event);
+				/* If clip_add is success then only initialize
+				 * first_pdev since it means it is our device
+				 */
+				if (ret == NOTIFY_OK)
+					first_pdev = to_pci_dev(
+							slave->dev->dev.parent);
+			} else if (first_pdev !=
+				   to_pci_dev(slave->dev->dev.parent))
+					ret = clip_add(slave->dev, ifa, event);
+		}
+		read_unlock(&bond->lock);
+	} else
+		ret = clip_add(ifa->idev->dev, ifa, event);
+
+	return ret;
+}
+
+static struct notifier_block cxgb4_inet6addr_notifier = {
+	.notifier_call = cxgb4_inet6addr_handler
+};
+
+/* Retrieves IPv6 addresses from a root device (bond, vlan) associated with
+ * a physical device.
+ * The physical device reference is needed to send the actul CLIP command.
+ */
+static int update_dev_clip(struct net_device *root_dev, struct net_device *dev)
+{
+	struct inet6_dev *idev = NULL;
+	struct inet6_ifaddr *ifa;
+	int ret = 0;
+
+	idev = __in6_dev_get(root_dev);
+	if (!idev)
+		return ret;
+
+	read_lock_bh(&idev->lock);
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		ret = cxgb4_clip_get(dev,
+				(const struct in6_addr *)ifa->addr.s6_addr);
+		if (ret < 0)
+			break;
+	}
+	read_unlock_bh(&idev->lock);
+
+	return ret;
+}
+
+static int update_root_dev_clip(struct net_device *dev)
+{
+	struct net_device *root_dev = NULL;
+	int i, ret = 0;
+
+	/* First populate the real net device's IPv6 addresses */
+	ret = update_dev_clip(dev, dev);
+	if (ret)
+		return ret;
+
+	/* Parse all bond and vlan devices layered on top of the physical dev */
+	for (i = 0; i < VLAN_N_VID; i++) {
+		root_dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), i);
+		if (!root_dev)
+			continue;
+
+		ret = update_dev_clip(root_dev, dev);
+		if (ret)
+			break;
+	}
+	return ret;
+}
+
+static void update_clip(const struct adapter *adap)
+{
+	int i;
+	struct net_device *dev;
+	int ret;
+
+	rcu_read_lock();
+
+	for (i = 0; i < MAX_NPORTS; i++) {
+		dev = adap->port[i];
+		ret = 0;
+
+		if (dev)
+			ret = update_root_dev_clip(dev);
+
+		if (ret < 0)
+			break;
+	}
+	rcu_read_unlock();
+}
+
 /**
  *	cxgb_up - enable the adapter
  *	@adap: adapter being enabled
@@ -3923,6 +4124,7 @@ static int cxgb_up(struct adapter *adap)
 	t4_intr_enable(adap);
 	adap->flags |= FULL_INIT_DONE;
 	notify_ulds(adap, CXGB4_STATE_UP);
+	update_clip(adap);
  out:
 	return err;
  irq_err:
@@ -5939,11 +6141,15 @@ static int __init cxgb4_init_module(void)
 	ret = pci_register_driver(&cxgb4_driver);
 	if (ret < 0)
 		debugfs_remove(cxgb4_debugfs_root);
+
+	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+
 	return ret;
 }
 
 static void __exit cxgb4_cleanup_module(void)
 {
+	unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
 	pci_unregister_driver(&cxgb4_driver);
 	debugfs_remove(cxgb4_debugfs_root);  /* NULL ok */
 	flush_workqueue(workq);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index d1c755f..6f77ac4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -616,6 +616,7 @@ enum fw_cmd_opcodes {
 	FW_RSS_IND_TBL_CMD             = 0x20,
 	FW_RSS_GLB_CONFIG_CMD          = 0x22,
 	FW_RSS_VI_CONFIG_CMD           = 0x23,
+	FW_CLIP_CMD                    = 0x28,
 	FW_LASTC2E_CMD                 = 0x40,
 	FW_ERROR_CMD                   = 0x80,
 	FW_DEBUG_CMD                   = 0x81,
@@ -2062,6 +2063,28 @@ struct fw_rss_vi_config_cmd {
 	} u;
 };
 
+struct fw_clip_cmd {
+	__be32 op_to_write;
+	__be32 alloc_to_len16;
+	__be64 ip_hi;
+	__be64 ip_lo;
+	__be32 r4[2];
+};
+
+#define S_FW_CLIP_CMD_ALLOC     31
+#define M_FW_CLIP_CMD_ALLOC     0x1
+#define V_FW_CLIP_CMD_ALLOC(x)  ((x) << S_FW_CLIP_CMD_ALLOC)
+#define G_FW_CLIP_CMD_ALLOC(x)  \
+	(((x) >> S_FW_CLIP_CMD_ALLOC) & M_FW_CLIP_CMD_ALLOC)
+#define F_FW_CLIP_CMD_ALLOC     V_FW_CLIP_CMD_ALLOC(1U)
+
+#define S_FW_CLIP_CMD_FREE      30
+#define M_FW_CLIP_CMD_FREE      0x1
+#define V_FW_CLIP_CMD_FREE(x)   ((x) << S_FW_CLIP_CMD_FREE)
+#define G_FW_CLIP_CMD_FREE(x)   \
+	(((x) >> S_FW_CLIP_CMD_FREE) & M_FW_CLIP_CMD_FREE)
+#define F_FW_CLIP_CMD_FREE      V_FW_CLIP_CMD_FREE(1U)
+
 enum fw_error_type {
 	FW_ERROR_TYPE_EXCEPTION		= 0x0,
 	FW_ERROR_TYPE_HWMODULE		= 0x1,
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
