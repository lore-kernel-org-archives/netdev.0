From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: do not reset Octeon if NIC firmware was
 preloaded
Date: Thu, 23 Mar 2017 13:26:28 -0700
Message-ID: <20170323202628.GA1090@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0070.outbound.protection.outlook.com ([104.47.42.70]:51296
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932074AbdCWU0c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 16:26:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF driver is incorrectly resetting Octeon when the module parameter
"fw_type=none" is there.  "fw_type=none" means the PF should not load any
firmware to the NIC because Octeon is already running preloaded firmware.

Fix it by putting an if (fw_type != none) around the reset code.

Because the Octeon reset is now conditionally gone, when unloading the
driver, conditionally send the RESET_PF command to the firmware who will
then free up PF-related data structures.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 45 +++++++++++++++-------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  1 +
 2 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 2b89ec2..1b0381f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1360,6 +1360,12 @@ liquidio_probe(struct pci_dev *pdev,
 	return 0;
 }
 
+static bool fw_type_is_none(void)
+{
+	return strncmp(fw_type, LIO_FW_NAME_TYPE_NONE,
+		       sizeof(LIO_FW_NAME_TYPE_NONE)) == 0;
+}
+
 /**
  *\brief Destroy resources associated with octeon device
  * @param pdev PCI device structure
@@ -1499,9 +1505,12 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_PCI_MAP_DONE:
-		/* Soft reset the octeon device before exiting */
-		if ((!OCTEON_CN23XX_PF(oct)) || !oct->octeon_id)
-			oct->fn_list.soft_reset(oct);
+		if (!fw_type_is_none()) {
+			/* Soft reset the octeon device before exiting */
+			if (!OCTEON_CN23XX_PF(oct) ||
+			    (OCTEON_CN23XX_PF(oct) && !oct->octeon_id))
+				oct->fn_list.soft_reset(oct);
+		}
 
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
@@ -1634,6 +1643,15 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		liquidio_stop(netdev);
 
+	if (fw_type_is_none()) {
+		struct octnic_ctrl_pkt nctrl;
+
+		memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+		nctrl.ncmd.s.cmd = OCTNET_CMD_RESET_PF;
+		nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+		octnet_send_nic_ctrl_pkt(oct, &nctrl);
+	}
+
 	if (oct->props[lio->ifidx].napi_enabled == 1) {
 		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
 			napi_disable(napi);
@@ -2123,8 +2141,7 @@ static int load_firmware(struct octeon_device *oct)
 	char fw_name[LIO_MAX_FW_FILENAME_LEN];
 	char *tmp_fw_type;
 
-	if (strncmp(fw_type, LIO_FW_NAME_TYPE_NONE,
-		    sizeof(LIO_FW_NAME_TYPE_NONE)) == 0) {
+	if (fw_type_is_none()) {
 		dev_info(&oct->pci_dev->dev, "Skipping firmware load\n");
 		return ret;
 	}
@@ -4443,14 +4460,16 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
 		if (!cn23xx_fw_loaded(octeon_dev)) {
 			fw_loaded = 0;
-			/* Do a soft reset of the Octeon device. */
-			if (octeon_dev->fn_list.soft_reset(octeon_dev))
-				return 1;
-			/* things might have changed */
-			if (!cn23xx_fw_loaded(octeon_dev))
-				fw_loaded = 0;
-			else
-				fw_loaded = 1;
+			if (!fw_type_is_none()) {
+				/* Do a soft reset of the Octeon device. */
+				if (octeon_dev->fn_list.soft_reset(octeon_dev))
+					return 1;
+				/* things might have changed */
+				if (!cn23xx_fw_loaded(octeon_dev))
+					fw_loaded = 0;
+				else
+					fw_loaded = 1;
+			}
 		} else {
 			fw_loaded = 1;
 		}
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index bc0af8a..1bc0385 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -180,6 +180,7 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_Q                0
 
 /* NIC Command types */
+#define   OCTNET_CMD_RESET_PF         0x0
 #define   OCTNET_CMD_CHANGE_MTU       0x1
 #define   OCTNET_CMD_CHANGE_MACADDR   0x2
 #define   OCTNET_CMD_CHANGE_DEVFLAGS  0x3
