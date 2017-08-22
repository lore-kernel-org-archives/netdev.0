From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: change manner of detecting whether or not
 NIC firmware is loaded
Date: Tue, 22 Aug 2017 12:46:37 -0700
Message-ID: <20170822194637.GA6875@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0089.outbound.protection.outlook.com ([104.47.37.89]:32713
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751739AbdHVTqO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 15:46:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the NIC firmware, the 1-bit flag indicating "firmware is loaded" moved
from SLI_SCRATCH_1 to SLI_SCRATCH_2 (these are Octeon general-purpose
scratch registers).  Make the PF driver conform to this change.

Remove code that sets the "firmware is loaded" flag because it's now the
firmware's job to do that.

In the code that detects whether or not the firmware is loaded, don't just
rely on checking the "firmware is loaded" flag because that may cause a
rare false negative.  Add code that deduces whether or not the firmware is
loaded; that will never give a false negative.

Also bump up driver version to match newer NIC firmware.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c | 15 +++++++++++++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c         |  6 ------
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h  |  3 ++-
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 4b0ca9f..96171cb 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -1405,8 +1405,19 @@ int cn23xx_fw_loaded(struct octeon_device *oct)
 {
 	u64 val;
 
-	val = octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1);
-	return (val >> 1) & 1ULL;
+	/* If there's more than one active PF on this NIC, then that
+	 * implies that the NIC firmware is loaded and running.  This check
+	 * prevents a rare false negative that might occur if we only relied
+	 * on checking the SCR2_BIT_FW_LOADED flag.  The false negative would
+	 * happen if the PF driver sees SCR2_BIT_FW_LOADED as cleared even
+	 * though the firmware was already loaded but still booting and has yet
+	 * to set SCR2_BIT_FW_LOADED.
+	 */
+	if (atomic_read(oct->adapter_refcount) > 1)
+		return 1;
+
+	val = octeon_read_csr64(oct, CN23XX_SLI_SCRATCH2);
+	return (val >> SCR2_BIT_FW_LOADED) & 1ULL;
 }
 
 void cn23xx_tell_vf_its_macaddr_changed(struct octeon_device *oct, int vfidx,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 0eea6a2..e786ac8 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -4098,12 +4098,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 			dev_err(&octeon_dev->pci_dev->dev, "Could not load firmware to board\n");
 			return 1;
 		}
-		/* set bit 1 of SLI_SCRATCH_1 to indicate that firmware is
-		 * loaded
-		 */
-		if (OCTEON_CN23XX_PF(octeon_dev))
-			octeon_write_csr64(octeon_dev, CN23XX_SLI_SCRATCH1,
-					   2ULL);
 	}
 
 	handshake[octeon_dev->octeon_id].init_ok = 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 18d2955..1e5655c 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -28,7 +28,7 @@
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_BASE_MAJOR_VERSION 1
 #define LIQUIDIO_BASE_MINOR_VERSION 6
-#define LIQUIDIO_BASE_MICRO_VERSION 0
+#define LIQUIDIO_BASE_MICRO_VERSION 1
 #define LIQUIDIO_BASE_VERSION   __stringify(LIQUIDIO_BASE_MAJOR_VERSION) "." \
 				__stringify(LIQUIDIO_BASE_MINOR_VERSION)
 #define LIQUIDIO_MICRO_VERSION  "." __stringify(LIQUIDIO_BASE_MICRO_VERSION)
@@ -106,6 +106,7 @@ enum octeon_tag_type {
 #define MAX_IOQ_INTERRUPTS_PER_PF   (64 * 2)
 #define MAX_IOQ_INTERRUPTS_PER_VF   (8 * 2)
 
+#define SCR2_BIT_FW_LOADED	    63
 
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
