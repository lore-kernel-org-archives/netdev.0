From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/15] sfc: Associate primary and secondary
 functions of controller
Date: Sat, 14 Dec 2013 23:06:17 +0000
Message-ID: <1387062377.12172.70.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17420 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab3LNXGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:06:22 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The primary function of an EF10 controller will share its clock
device with other functions in the same domain (which we call
secondary functions).  To this end, we need to associate functions
on the same controller.

We do not control probe order, so allow primary and secondary
functions to appear in any order.  Maintain global lists of all
primary functions and of unassociated secondary functions,
and a list of secondary functions on each primary function.

Use the VPD serial number to tell whether functions are part of the
same controller.  VPD will not be readable by virtual functions, so
this may need to be revisited later.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   77 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon.c     |    2 +
 drivers/net/ethernet/sfc/mcdi.c       |    4 ++
 drivers/net/ethernet/sfc/net_driver.h |   10 ++++
 4 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5745a9fd034e..d6a927021523 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1117,6 +1117,77 @@ static void efx_remove_port(struct efx_nic *efx)
  *
  **************************************************************************/
 
+static LIST_HEAD(efx_primary_list);
+static LIST_HEAD(efx_unassociated_list);
+
+static bool efx_same_controller(struct efx_nic *left, struct efx_nic *right)
+{
+	return left->type == right->type &&
+		left->vpd_sn && right->vpd_sn &&
+		!strcmp(left->vpd_sn, right->vpd_sn);
+}
+
+static void efx_associate(struct efx_nic *efx)
+{
+	struct efx_nic *other, *next;
+
+	if (efx->primary == efx) {
+		/* Adding primary function; look for secondaries */
+
+		netif_dbg(efx, probe, efx->net_dev, "adding to primary list\n");
+		list_add_tail(&efx->node, &efx_primary_list);
+
+		list_for_each_entry_safe(other, next, &efx_unassociated_list,
+					 node) {
+			if (efx_same_controller(efx, other)) {
+				list_del(&other->node);
+				netif_dbg(other, probe, other->net_dev,
+					  "moving to secondary list of %s %s\n",
+					  pci_name(efx->pci_dev),
+					  efx->net_dev->name);
+				list_add_tail(&other->node,
+					      &efx->secondary_list);
+				other->primary = efx;
+			}
+		}
+	} else {
+		/* Adding secondary function; look for primary */
+
+		list_for_each_entry(other, &efx_primary_list, node) {
+			if (efx_same_controller(efx, other)) {
+				netif_dbg(efx, probe, efx->net_dev,
+					  "adding to secondary list of %s %s\n",
+					  pci_name(other->pci_dev),
+					  other->net_dev->name);
+				list_add_tail(&efx->node,
+					      &other->secondary_list);
+				efx->primary = other;
+				return;
+			}
+		}
+
+		netif_dbg(efx, probe, efx->net_dev,
+			  "adding to unassociated list\n");
+		list_add_tail(&efx->node, &efx_unassociated_list);
+	}
+}
+
+static void efx_dissociate(struct efx_nic *efx)
+{
+	struct efx_nic *other, *next;
+
+	list_del(&efx->node);
+	efx->primary = NULL;
+
+	list_for_each_entry_safe(other, next, &efx->secondary_list, node) {
+		list_del(&other->node);
+		netif_dbg(other, probe, other->net_dev,
+			  "moving to unassociated list\n");
+		list_add_tail(&other->node, &efx_unassociated_list);
+		other->primary = NULL;
+	}
+}
+
 /* This configures the PCI device to enable I/O and DMA. */
 static int efx_init_io(struct efx_nic *efx)
 {
@@ -2214,6 +2285,8 @@ static int efx_register_netdev(struct efx_nic *efx)
 			efx_init_tx_queue_core_txq(tx_queue);
 	}
 
+	efx_associate(efx);
+
 	rtnl_unlock();
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
@@ -2227,6 +2300,7 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 fail_registered:
 	rtnl_lock();
+	efx_dissociate(efx);
 	unregister_netdevice(net_dev);
 fail_locked:
 	efx->state = STATE_UNINIT;
@@ -2568,6 +2642,8 @@ static int efx_init_struct(struct efx_nic *efx,
 	int i;
 
 	/* Initialise common structures */
+	INIT_LIST_HEAD(&efx->node);
+	INIT_LIST_HEAD(&efx->secondary_list);
 	spin_lock_init(&efx->biu_lock);
 #ifdef CONFIG_SFC_MTD
 	INIT_LIST_HEAD(&efx->mtd_list);
@@ -2674,6 +2750,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
+	efx_dissociate(efx);
 	dev_close(efx->net_dev);
 	efx_disable_interrupts(efx);
 	rtnl_unlock();
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 4a9e05c82e2a..76699f4e6e04 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2247,6 +2247,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	struct falcon_board *board;
 	int rc;
 
+	efx->primary = efx; /* only one usable function per controller */
+
 	/* Allocate storage for hardware specific data */
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
 	if (!nic_data)
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 540f57915d6f..0d5d7b5325e8 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -102,6 +102,10 @@ int efx_mcdi_init(struct efx_nic *efx)
 		netif_err(efx, probe, efx->net_dev,
 			  "Host already registered with MCPU\n");
 
+	if (efx->mcdi->fn_flags &
+	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY))
+		efx->primary = efx;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index be8a616a1649..653b8782c956 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -657,6 +657,13 @@ struct vfdi_status;
  * struct efx_nic - an Efx NIC
  * @name: Device name (net device name or bus id before net device registered)
  * @pci_dev: The PCI device
+ * @node: List node for maintaning primary/secondary function lists
+ * @primary: &struct efx_nic instance for the primary function of this
+ *	controller.  May be the same structure, and may be %NULL if no
+ *	primary function is bound.  Serialised by rtnl_lock.
+ * @secondary_list: List of &struct efx_nic instances for the secondary PCI
+ *	functions of the controller, if this is for the primary function.
+ *	Serialised by rtnl_lock.
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
@@ -786,6 +793,9 @@ struct efx_nic {
 	/* The following fields should be written very rarely */
 
 	char name[IFNAMSIZ];
+	struct list_head node;
+	struct efx_nic *primary;
+	struct list_head secondary_list;
 	struct pci_dev *pci_dev;
 	unsigned int port_num;
 	const struct efx_nic_type *type;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
