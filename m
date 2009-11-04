From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 09/12] wimax/i2400m: Make boot retries a BUS-specific
	parameter
Date: Wed,  4 Nov 2009 13:39:45 -0800
Message-ID: <c30836580b35ae5cab3de97a3df16878fe097868.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

In i2400m-based devices, the driver's bootloader will retry to load
the firmware when things go wrong. The driver currently has a constant
(I2400M_BOOT_RETRIES) which governs the max number of tries.

However, different SKUs of the same hardware may admit or require
different numbers of retries due to it's particulars, so it is made a
BUS specific parameter and different values are assigned for 5x50
devices versus the 3200 ones.

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c          |    2 +-
 drivers/net/wimax/i2400m/i2400m-sdio.h |    1 +
 drivers/net/wimax/i2400m/i2400m-usb.h  |    1 +
 drivers/net/wimax/i2400m/i2400m.h      |    3 ---
 drivers/net/wimax/i2400m/sdio.c        |    2 +-
 drivers/net/wimax/i2400m/usb.c         |    2 +-
 6 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index e81750e..55bd69e 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -602,7 +602,7 @@ int i2400m_bootrom_init(struct i2400m *i2400m, enum i2400m_bri flags)
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_bootrom_header *cmd;
 	struct i2400m_bootrom_header ack;
-	int count = I2400M_BOOT_RETRIES;
+	int count = i2400m->bus_bm_retries;
 	int ack_timeout_cnt = 1;
 
 	BUILD_BUG_ON(sizeof(*cmd) != sizeof(i2400m_NBOOT_BARKER));
diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index 9c4e318..66884eb 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -67,6 +67,7 @@
 
 /* Host-Device interface for SDIO */
 enum {
+	I2400M_SDIO_BOOT_RETRIES = 3,
 	I2400MS_BLK_SIZE = 256,
 	I2400MS_PL_SIZE_MAX = 0x3E00,
 
diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 6f76558..79c3753 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -137,6 +137,7 @@ static inline int edc_inc(struct edc *edc, u16 max_err, u16 timeframe)
 
 /* Host-Device interface for USB */
 enum {
+	I2400M_USB_BOOT_RETRIES = 3,
 	I2400MU_MAX_NOTIFICATION_LEN = 256,
 	I2400MU_BLK_SIZE = 16,
 	I2400MU_PL_SIZE_MAX = 0x3EFF,
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index a6e59f1..73b4e6a 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -148,9 +148,6 @@
 
 /* Misc constants */
 enum {
-	/* Firmware uploading */
-	I2400M_BOOT_RETRIES = 3,
-	I3200_BOOT_RETRIES = 3,
 	/* Size of the Boot Mode Command buffer */
 	I2400M_BM_CMD_BUF_SIZE = 16 * 1024,
 	I2400M_BM_ACK_BUF_SIZE = 256,
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index a68232a..1429608 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -430,7 +430,7 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_reset = i2400ms_bus_reset;
 	/* The iwmc3200-wimax sometimes requires the driver to try
 	 * hard when we paint it into a corner. */
-	i2400m->bus_bm_retries = I3200_BOOT_RETRIES;
+	i2400m->bus_bm_retries = I2400M_SDIO_BOOT_RETRIES;
 	i2400m->bus_bm_cmd_send = i2400ms_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400ms_bus_bm_wait_for_ack;
 	i2400m->bus_fw_names = i2400ms_bus_fw_names;
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 49d7554..8f7b16a 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -406,7 +406,7 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_dev_stop = i2400mu_bus_dev_stop;
 	i2400m->bus_tx_kick = i2400mu_bus_tx_kick;
 	i2400m->bus_reset = i2400mu_bus_reset;
-	i2400m->bus_bm_retries = I2400M_BOOT_RETRIES;
+	i2400m->bus_bm_retries = I2400M_USB_BOOT_RETRIES;
 	i2400m->bus_bm_cmd_send = i2400mu_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400mu_bus_bm_wait_for_ack;
 	i2400m->bus_fw_names = i2400mu_bus_fw_names;
-- 
1.6.2.5
