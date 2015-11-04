From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Wed, 4 Nov 2015 18:21:00 -0500
Message-ID: <20151104232100.GJ14575@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	andy.shevchenko@gmail.com
To: sowmini.varadhan@oracle.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
address in Open Firmware or IDPROM").

As with that fix, attempt to look up the MAC address in Open Firmware
on systems that support it, and use IDPROM on SPARC if no OF address
is found.

In the case of the i40e there is an assumption that the default mac
address has already been set up as the primary mac filter on probe,
so if this filter is obtained from the Open Firmware or IDPROM, an
explicit write is needed via i40e_aq_mac_address_write() and
i40e_aq_add_macvlan() invocation.

Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2, v3: Andy Shevchenko comments
v4: Shannon Nelson review: explicitly set up mac filters before register_netdev
v5: Shannon Nelson code style comments
v6: Shannon Nelson code style comments

 drivers/net/ethernet/intel/i40e/i40e_main.c |   83 ++++++++++++++++++++++++++-
 1 files changed, 82 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b825f97..e355873 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -24,6 +24,15 @@
  *
  ******************************************************************************/
 
+#include <linux/etherdevice.h>
+#include <linux/of_net.h>
+#include <linux/pci.h>
+
+#ifdef CONFIG_SPARC
+#include <asm/idprom.h>
+#include <asm/prom.h>
+#endif
+
 /* Local includes */
 #include "i40e.h"
 #include "i40e_diag.h"
@@ -9213,6 +9222,44 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_macaddr_init - explicitly write the mac address filters.
+ *
+ * @vsi: pointer to the vsi.
+ * @macaddr: the MAC address
+ *
+ * This is needed when the macaddr has been obtained by other
+ * means than the default, e.g., from Open Firmware or IDPROM.
+ * Returns 0 on success, negative on failure
+ **/
+static int i40e_macaddr_init(struct i40e_vsi *vsi, u8 *macaddr)
+{
+	int ret, aq_err;
+	struct i40e_aqc_add_macvlan_element_data element;
+
+	ret = i40e_aq_mac_address_write(&vsi->back->hw,
+					I40E_AQC_WRITE_TYPE_LAA_WOL,
+					macaddr, NULL);
+	if (ret) {
+		dev_info(&vsi->back->pdev->dev,
+			 "Addr change for VSI failed: %d\n", ret);
+		return -EADDRNOTAVAIL;
+	}
+
+	memset(&element, 0, sizeof(element));
+	ether_addr_copy(element.mac_addr, macaddr);
+	element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
+	ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
+	aq_err = vsi->back->hw.aq.asq_last_status;
+	if (aq_err != I40E_AQ_RC_OK) {
+		dev_info(&vsi->back->pdev->dev,
+			 "add filter failed err %s aq_err %s\n",
+			 i40e_stat_str(&vsi->back->hw, ret),
+			 i40e_aq_str(&vsi->back->hw, aq_err));
+	}
+	return ret;
+}
+
+/**
  * i40e_vsi_setup - Set up a VSI by a given type
  * @pf: board private structure
  * @type: VSI type
@@ -9341,6 +9388,9 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 		ret = i40e_config_netdev(vsi);
 		if (ret)
 			goto err_netdev;
+		ret = i40e_macaddr_init(vsi, pf->hw.mac.addr);
+		if (ret)
+			goto err_netdev;
 		ret = register_netdev(vsi->netdev);
 		if (ret)
 			goto err_netdev;
@@ -10163,6 +10213,35 @@ static void i40e_print_features(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_get_platform_mac_addr - get platform-specific MAC address
+ *
+ * @pdev: PCI device information struct
+ * @mac_addr: the MAC address to be returned
+ *
+ * Look up the MAC address in Open Firmware  on systems that support it,
+ * and use IDPROM on SPARC if no OF address is found.
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int i40e_get_platform_mac_addr(struct pci_dev *pdev, u8 *mac_addr)
+{
+	struct device_node *dp = pci_device_to_OF_node(pdev);
+	const unsigned char *addr;
+
+	addr = of_get_mac_address(dp);
+	if (addr) {
+		ether_addr_copy(mac_addr, addr);
+		return 0;
+	}
+#ifdef CONFIG_SPARC
+	ether_addr_copy(mac_addr, idprom->id_ethaddr);
+	return 0;
+#else
+	return -EINVAL;
+#endif /* CONFIG_SPARC */
+}
+
+/**
  * i40e_probe - Device initialization routine
  * @pdev: PCI device information struct
  * @ent: entry in i40e_pci_tbl
@@ -10360,7 +10439,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		i40e_aq_stop_lldp(hw, true, NULL);
 	}
 
-	i40e_get_mac_addr(hw, hw->mac.addr);
+	err = i40e_get_platform_mac_addr(pdev, hw->mac.addr);
+	if (err)
+		i40e_get_mac_addr(hw, hw->mac.addr);
 	if (!is_valid_ether_addr(hw->mac.addr)) {
 		dev_info(&pdev->dev, "invalid MAC address %pM\n", hw->mac.addr);
 		err = -EIO;
-- 
1.7.1
