From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v8] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Sat, 5 Dec 2015 15:33:00 -0500
Message-ID: <20151205203300.GA8863@oracle.com>
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

The I40E_FLAG_PF_MAC flag in the platform-private i40e_pf structure
tracks whether a platform-specific mac address was found, in which
case calls to i40e_aq_mac_address_write() and i40e_aq_add_macvlan()
will be triggered.

Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2, v3: Andy Shevchenko comments
v4: Shannon Nelson review: explicitly set up mac filters before register_netdev
v5: Shannon Nelson code style comments
v6: Shannon Nelson code style comments
v7: Ensure that i40e_macaddr_init() is called only for VSI_MAIN, and only
    if the mac address is not the default. Some additional code-refactoring
    based on comments from Shannon Nelson
v8: use pf->flags instead of bit value to track if we found a platform-specific
    macaddr. Other code-style comments from Shannon Nelson

 drivers/net/ethernet/intel/i40e/i40e.h      |    1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c |   89 +++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0b9537b..b85eaee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -337,6 +337,7 @@ struct i40e_pf {
 #define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
 #define I40E_FLAG_NO_PCI_LINK_CHECK		BIT_ULL(42)
+#define I40E_FLAG_PF_MAC			BIT_ULL(50)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9e6268b..ad7c941 100644
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
@@ -9387,6 +9396,44 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
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
+	int ret;
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
+	if (ret) {
+		dev_info(&vsi->back->pdev->dev,
+			 "add filter failed err %s aq_err %s\n",
+			 i40e_stat_str(&vsi->back->hw, ret),
+			 i40e_aq_str(&vsi->back->hw,
+				     vsi->back->hw.aq.asq_last_status));
+	}
+	return ret;
+}
+
+/**
  * i40e_vsi_setup - Set up a VSI by a given type
  * @pf: board private structure
  * @type: VSI type
@@ -9510,6 +9557,17 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	switch (vsi->type) {
 	/* setup the netdev if needed */
 	case I40E_VSI_MAIN:
+		/* Apply relevant filters if a platform-specific mac
+		 * address was selected.
+		 */
+		if (!!(pf->flags & I40E_FLAG_PF_MAC)) {
+			ret = i40e_macaddr_init(vsi, pf->hw.mac.addr);
+			if (ret) {
+				dev_warn(&pf->pdev->dev,
+					 "could not set up macaddr; err %d\n",
+					 ret);
+			}
+		}
 	case I40E_VSI_VMDQ2:
 	case I40E_VSI_FCOE:
 		ret = i40e_config_netdev(vsi);
@@ -10340,6 +10398,35 @@ static void i40e_print_features(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_get_platform_mac_addr - get platform-specific MAC address
+ *
+ * @pdev: PCI device information struct
+ * @pf: board private structure
+ *
+ * Look up the MAC address in Open Firmware  on systems that support it,
+ * and use IDPROM on SPARC if no OF address is found. On return, the
+ * I40E_FLAG_PF_MAC will be wset in pf->flags if a platform-specific value
+ * has been selected.
+ **/
+static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
+{
+	struct device_node *dp = pci_device_to_OF_node(pdev);
+	const unsigned char *addr;
+	u8 *mac_addr = pf->hw.mac.addr;
+
+	pf->flags &= ~I40E_FLAG_PF_MAC;
+	addr = of_get_mac_address(dp);
+	if (addr) {
+		ether_addr_copy(mac_addr, addr);
+		pf->flags |= I40E_FLAG_PF_MAC;
+	}
+#ifdef CONFIG_SPARC
+	ether_addr_copy(mac_addr, idprom->id_ethaddr);
+	pf->flags |= I40E_FLAG_PF_MAC;
+#endif /* CONFIG_SPARC */
+}
+
+/**
  * i40e_probe - Device initialization routine
  * @pdev: PCI device information struct
  * @ent: entry in i40e_pci_tbl
@@ -10543,6 +10630,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	i40e_get_mac_addr(hw, hw->mac.addr);
+	/* allow a platform config to override the HW addr */
+	i40e_get_platform_mac_addr(pdev, pf);
 	if (!is_valid_ether_addr(hw->mac.addr)) {
 		dev_info(&pdev->dev, "invalid MAC address %pM\n", hw->mac.addr);
 		err = -EIO;
-- 
1.7.1
