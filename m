From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/3] liquidio: allow override of firmware present in
 flash
Date: Fri, 22 Sep 2017 17:12:43 -0700
Message-ID: <20170923001243.GA1485@felix-thinkpad.cavium.com>
References: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0043.outbound.protection.outlook.com ([104.47.41.43]:10627
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbdIWAMu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 20:12:50 -0400
Content-Disposition: inline
In-Reply-To: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 68 ++++++++++++++--------
 .../net/ethernet/cavium/liquidio/liquidio_image.h  |  1 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 11 +++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 10 ++++
 4 files changed, 64 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index e7f5494..ce08f71 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -59,9 +59,9 @@
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
 
-static char fw_type[LIO_MAX_FW_TYPE_LEN] = LIO_FW_NAME_TYPE_NIC;
+static char fw_type[LIO_MAX_FW_TYPE_LEN] = LIO_FW_NAME_TYPE_AUTO;
 module_param_string(fw_type, fw_type, sizeof(fw_type), 0444);
-MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\".  Use \"none\" to load firmware from flash.");
+MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded (default is \"auto\"), which uses firmware in flash, if present, else loads \"nic\".");
 
 static u32 console_bitmask;
 module_param(console_bitmask, int, 0644);
@@ -1115,10 +1115,10 @@ static int liquidio_watchdog(void *param)
 	return 0;
 }
 
-static bool fw_type_is_none(void)
+static bool fw_type_is_auto(void)
 {
-	return strncmp(fw_type, LIO_FW_NAME_TYPE_NONE,
-		       sizeof(LIO_FW_NAME_TYPE_NONE)) == 0;
+	return strncmp(fw_type, LIO_FW_NAME_TYPE_AUTO,
+		       sizeof(LIO_FW_NAME_TYPE_AUTO)) == 0;
 }
 
 /**
@@ -1302,7 +1302,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		 * Implementation note: only soft-reset the device
 		 * if it is a CN6XXX OR the LAST CN23XX device.
 		 */
-		if (fw_type_is_none())
+		if (atomic_read(oct->adapter_fw_state) == FW_IS_PRELOADED)
 			octeon_pci_flr(oct);
 		else if (OCTEON_CN6XXX(oct) || !refcount)
 			oct->fn_list.soft_reset(oct);
@@ -1934,7 +1934,7 @@ static int load_firmware(struct octeon_device *oct)
 	char fw_name[LIO_MAX_FW_FILENAME_LEN];
 	char *tmp_fw_type;
 
-	if (fw_type[0] == '\0')
+	if (fw_type_is_auto())
 		tmp_fw_type = LIO_FW_NAME_TYPE_NIC;
 	else
 		tmp_fw_type = fw_type;
@@ -3882,9 +3882,9 @@ static void nic_starter(struct work_struct *work)
 static int octeon_device_init(struct octeon_device *octeon_dev)
 {
 	int j, ret;
-	int fw_loaded = 0;
 	char bootcmd[] = "\n";
 	char *dbg_enb = NULL;
+	enum lio_fw_state fw_state;
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)octeon_dev->priv;
 	atomic_set(&octeon_dev->status, OCT_DEV_BEGIN_STATE);
@@ -3916,24 +3916,40 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	octeon_dev->app_mode = CVM_DRV_INVALID_APP;
 
-	if (OCTEON_CN23XX_PF(octeon_dev)) {
-		if (!cn23xx_fw_loaded(octeon_dev) && !fw_type_is_none()) {
-			fw_loaded = 0;
-			/* Do a soft reset of the Octeon device. */
-			if (octeon_dev->fn_list.soft_reset(octeon_dev))
-				return 1;
-			/* things might have changed */
-			if (!cn23xx_fw_loaded(octeon_dev))
-				fw_loaded = 0;
-			else
-				fw_loaded = 1;
-		} else {
-			fw_loaded = 1;
-		}
-	} else if (octeon_dev->fn_list.soft_reset(octeon_dev)) {
-		return 1;
+	/* CN23XX supports preloaded firmware if the following is true:
+	 *
+	 * The adapter indicates that firmware is currently running AND
+	 * 'fw_type' is 'auto'.
+	 *
+	 * (default state is NEEDS_TO_BE_LOADED, override it if appropriate).
+	 */
+	if (OCTEON_CN23XX_PF(octeon_dev) &&
+	    cn23xx_fw_loaded(octeon_dev) && fw_type_is_auto()) {
+		atomic_cmpxchg(octeon_dev->adapter_fw_state,
+			       FW_NEEDS_TO_BE_LOADED, FW_IS_PRELOADED);
 	}
 
+	/* If loading firmware, only first device of adapter needs to do so. */
+	fw_state = atomic_cmpxchg(octeon_dev->adapter_fw_state,
+				  FW_NEEDS_TO_BE_LOADED,
+				  FW_IS_BEING_LOADED);
+
+	/* Here, [local variable] 'fw_state' is set to one of:
+	 *
+	 *   FW_IS_PRELOADED:       No firmware is to be loaded (see above)
+	 *   FW_NEEDS_TO_BE_LOADED: The driver's first instance will load
+	 *                          firmware to the adapter.
+	 *   FW_IS_BEING_LOADED:    The driver's second instance will not load
+	 *                          firmware to the adapter.
+	 */
+
+	/* Prior to f/w load, perform a soft reset of the Octeon device;
+	 * if error resetting, return w/error.
+	 */
+	if (fw_state == FW_NEEDS_TO_BE_LOADED)
+		if (octeon_dev->fn_list.soft_reset(octeon_dev))
+			return 1;
+
 	/* Initialize the dispatch mechanism used to push packets arriving on
 	 * Octeon Output queues.
 	 */
@@ -4063,7 +4079,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_IO_QUEUES_DONE);
 
-	if ((!OCTEON_CN23XX_PF(octeon_dev)) || !fw_loaded) {
+	if (fw_state == FW_NEEDS_TO_BE_LOADED) {
 		dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
 		if (!ddr_timeout) {
 			dev_info(&octeon_dev->pci_dev->dev,
@@ -4125,6 +4141,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 			dev_err(&octeon_dev->pci_dev->dev, "Could not load firmware to board\n");
 			return 1;
 		}
+
+		atomic_set(octeon_dev->adapter_fw_state, FW_HAS_BEEN_LOADED);
 	}
 
 	handshake[octeon_dev->octeon_id].init_ok = 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
index 78a3685..5bf5e87 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
@@ -24,6 +24,7 @@
 #define LIO_FW_BASE_NAME        "lio_"
 #define LIO_FW_NAME_SUFFIX      ".bin"
 #define LIO_FW_NAME_TYPE_NIC    "nic"
+#define LIO_FW_NAME_TYPE_AUTO   "auto"
 #define LIO_FW_NAME_TYPE_NONE   "none"
 #define LIO_MAX_FIRMWARE_VERSION_LEN 16
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 29d53b1..e4aa339 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -541,6 +541,7 @@
 
 static struct octeon_device *octeon_device[MAX_OCTEON_DEVICES];
 static atomic_t adapter_refcounts[MAX_OCTEON_DEVICES];
+static atomic_t adapter_fw_states[MAX_OCTEON_DEVICES];
 
 static u32 octeon_device_count;
 /* locks device array (i.e. octeon_device[]) */
@@ -770,6 +771,10 @@ int octeon_register_device(struct octeon_device *oct,
 	oct->adapter_refcount = &adapter_refcounts[oct->octeon_id];
 	atomic_set(oct->adapter_refcount, 0);
 
+	/* Like the reference count, the f/w state is shared 'per-adapter' */
+	oct->adapter_fw_state = &adapter_fw_states[oct->octeon_id];
+	atomic_set(oct->adapter_fw_state, FW_NEEDS_TO_BE_LOADED);
+
 	spin_lock(&octeon_devices_lock);
 	for (idx = (int)oct->octeon_id - 1; idx >= 0; idx--) {
 		if (!octeon_device[idx]) {
@@ -780,11 +785,15 @@ int octeon_register_device(struct octeon_device *oct,
 			atomic_inc(oct->adapter_refcount);
 			return 1; /* here, refcount is guaranteed to be 1 */
 		}
-		/* if another device is at same bus/dev, use its refcounter */
+		/* If another device is at same bus/dev, use its refcounter
+		 * (and f/w state variable).
+		 */
 		if ((octeon_device[idx]->loc.bus == bus) &&
 		    (octeon_device[idx]->loc.dev == dev)) {
 			oct->adapter_refcount =
 				octeon_device[idx]->adapter_refcount;
+			oct->adapter_fw_state =
+				octeon_device[idx]->adapter_fw_state;
 			break;
 		}
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 894af19..33d19c4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -50,6 +50,13 @@ enum octeon_pci_swap_mode {
 	OCTEON_PCI_32BIT_LW_SWAP = 3
 };
 
+enum lio_fw_state {
+	FW_IS_PRELOADED = 0,
+	FW_NEEDS_TO_BE_LOADED = 1,
+	FW_IS_BEING_LOADED = 2,
+	FW_HAS_BEEN_LOADED = 3,
+};
+
 enum {
 	OCTEON_CONFIG_TYPE_DEFAULT = 0,
 	NUM_OCTEON_CONFS,
@@ -557,6 +564,9 @@ struct octeon_device {
 	} loc;
 
 	atomic_t *adapter_refcount; /* reference count of adapter */
+
+	atomic_t *adapter_fw_state; /* per-adapter, lio_fw_state */
+
 	bool ptp_enable;
 };
 
-- 
1.8.3.1
