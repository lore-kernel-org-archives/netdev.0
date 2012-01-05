From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: [PATCH v2 6/6] ath6kl: create ath6kl_core.ko
Date: Thu, 05 Jan 2012 15:28:55 +0200
Message-ID: <20120105132855.22281.87053.stgit@x201>
References: <20120105132523.22281.95999.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, ath6kl-devel@qualcomm.com,
	davem@davemloft.net
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105132523.22281.95999.stgit@x201>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now ath6kl is ready for splitting core code to ath6kl_core.ko module.
This also makes it possible to link both sdio and usb code to kernel
at the same time, which earlier failed miserably.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
---
 drivers/net/wireless/ath/ath6kl/Makefile   |   37 +++++++++++-----------------
 drivers/net/wireless/ath/ath6kl/cfg80211.c |    3 ++
 drivers/net/wireless/ath/ath6kl/core.c     |    9 +++++++
 drivers/net/wireless/ath/ath6kl/debug.c    |    3 ++
 drivers/net/wireless/ath/ath6kl/hif.c      |    5 ++++
 drivers/net/wireless/ath/ath6kl/init.c     |    3 ++
 6 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/Makefile b/drivers/net/wireless/ath/ath6kl/Makefile
index 9bb69a8..863b9f6 100644
--- a/drivers/net/wireless/ath/ath6kl/Makefile
+++ b/drivers/net/wireless/ath/ath6kl/Makefile
@@ -21,32 +21,23 @@
 # Author(s): ="Atheros"
 #------------------------------------------------------------------------------
 
-obj-$(CONFIG_ATH6KL_SDIO) := ath6kl_sdio.o
-ath6kl_sdio-y += debug.o
-ath6kl_sdio-y += hif.o
-ath6kl_sdio-y += htc.o
-ath6kl_sdio-y += bmi.o
-ath6kl_sdio-y += cfg80211.o
-ath6kl_sdio-y += init.o
-ath6kl_sdio-y += main.o
-ath6kl_sdio-y += txrx.o
-ath6kl_sdio-y += wmi.o
-ath6kl_sdio-y += core.o
+obj-$(CONFIG_ATH6KL) += ath6kl_core.o
+ath6kl_core-y += debug.o
+ath6kl_core-y += hif.o
+ath6kl_core-y += htc.o
+ath6kl_core-y += bmi.o
+ath6kl_core-y += cfg80211.o
+ath6kl_core-y += init.o
+ath6kl_core-y += main.o
+ath6kl_core-y += txrx.o
+ath6kl_core-y += wmi.o
+ath6kl_core-y += core.o
+ath6kl_core-$(CONFIG_NL80211_TESTMODE) += testmode.o
+
+obj-$(CONFIG_ATH6KL_SDIO) += ath6kl_sdio.o
 ath6kl_sdio-y += sdio.o
-ath6kl_sdio-$(CONFIG_NL80211_TESTMODE) += testmode.o
 
 obj-$(CONFIG_ATH6KL_USB) += ath6kl_usb.o
-ath6kl_usb-y += debug.o
-ath6kl_usb-y += hif.o
-ath6kl_usb-y += htc.o
-ath6kl_usb-y += bmi.o
-ath6kl_usb-y += cfg80211.o
-ath6kl_usb-y += init.o
-ath6kl_usb-y += main.o
-ath6kl_usb-y += txrx.o
-ath6kl_usb-y += wmi.o
-ath6kl_usb-y += core.o
 ath6kl_usb-y += usb.o
-ath6kl_usb-$(CONFIG_NL80211_TESTMODE) += testmode.o
 
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 64043f8..d4ed6d1 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -15,6 +15,7 @@
  */
 
 #include <linux/moduleparam.h>
+#include <linux/export.h>
 
 #include "core.h"
 #include "cfg80211.h"
@@ -1907,6 +1908,7 @@ int ath6kl_cfg80211_suspend(struct ath6kl *ar,
 
 	return 0;
 }
+EXPORT_SYMBOL(ath6kl_cfg80211_suspend);
 
 int ath6kl_cfg80211_resume(struct ath6kl *ar)
 {
@@ -1958,6 +1960,7 @@ int ath6kl_cfg80211_resume(struct ath6kl *ar)
 
 	return 0;
 }
+EXPORT_SYMBOL(ath6kl_cfg80211_resume);
 
 #ifdef CONFIG_PM
 
diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
index 7e3574e..0d00475 100644
--- a/drivers/net/wireless/ath/ath6kl/core.c
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -16,7 +16,9 @@
 
 #include "core.h"
 
+#include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/export.h>
 
 #include "debug.h"
 #include "hif-ops.h"
@@ -198,6 +200,7 @@ err_wq:
 
 	return ret;
 }
+EXPORT_SYMBOL(ath6kl_core_init);
 
 struct ath6kl *ath6kl_core_create(struct device *dev)
 {
@@ -254,6 +257,7 @@ struct ath6kl *ath6kl_core_create(struct device *dev)
 
 	return ar;
 }
+EXPORT_SYMBOL(ath6kl_core_create);
 
 void ath6kl_core_cleanup(struct ath6kl *ar)
 {
@@ -280,9 +284,14 @@ void ath6kl_core_cleanup(struct ath6kl *ar)
 	ath6kl_cfg80211_cleanup(ar);
 	ath6kl_cfg80211_destroy(ar);
 }
+EXPORT_SYMBOL(ath6kl_core_cleanup);
 
 void ath6kl_core_destroy(struct ath6kl *ar)
 {
 	ath6kl_cfg80211_destroy(ar);
 }
+EXPORT_SYMBOL(ath6kl_core_destroy);
 
+MODULE_AUTHOR("Qualcomm Atheros");
+MODULE_DESCRIPTION("Core module for AR600x SDIO and USB devices.");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index f1fa57b..5430166 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -54,6 +54,7 @@ int ath6kl_printk(const char *level, const char *fmt, ...)
 
 	return rtn;
 }
+EXPORT_SYMBOL(ath6kl_printk);
 
 #ifdef CONFIG_ATH6KL_DEBUG
 
@@ -74,6 +75,7 @@ void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
 
 	va_end(args);
 }
+EXPORT_SYMBOL(ath6kl_dbg);
 
 void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
 		     const char *msg, const char *prefix,
@@ -86,6 +88,7 @@ void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
 		print_hex_dump_bytes(prefix, DUMP_PREFIX_OFFSET, buf, len);
 	}
 }
+EXPORT_SYMBOL(ath6kl_dbg_dump);
 
 #define REG_OUTPUT_LEN_PER_LINE	25
 #define REGTYPE_STR_LEN		100
diff --git a/drivers/net/wireless/ath/ath6kl/hif.c b/drivers/net/wireless/ath/ath6kl/hif.c
index 3d26c14..e911737 100644
--- a/drivers/net/wireless/ath/ath6kl/hif.c
+++ b/drivers/net/wireless/ath/ath6kl/hif.c
@@ -15,6 +15,8 @@
  */
 #include "hif.h"
 
+#include <linux/export.h>
+
 #include "core.h"
 #include "target.h"
 #include "hif-ops.h"
@@ -59,6 +61,8 @@ int ath6kl_hif_rw_comp_handler(void *context, int status)
 
 	return 0;
 }
+EXPORT_SYMBOL(ath6kl_hif_rw_comp_handler);
+
 #define REG_DUMP_COUNT_AR6003   60
 #define REGISTER_DUMP_LEN_MAX   60
 
@@ -560,6 +564,7 @@ int ath6kl_hif_intr_bh_handler(struct ath6kl *ar)
 
 	return status;
 }
+EXPORT_SYMBOL(ath6kl_hif_intr_bh_handler);
 
 static int ath6kl_hif_enable_intrs(struct ath6kl_device *dev)
 {
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 5a92307..6183c42 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -17,8 +17,10 @@
 
 #include <linux/moduleparam.h>
 #include <linux/errno.h>
+#include <linux/export.h>
 #include <linux/of.h>
 #include <linux/mmc/sdio_func.h>
+
 #include "core.h"
 #include "cfg80211.h"
 #include "target.h"
@@ -1596,3 +1598,4 @@ void ath6kl_stop_txrx(struct ath6kl *ar)
 
 	clear_bit(WLAN_ENABLED, &ar->flag);
 }
+EXPORT_SYMBOL(ath6kl_stop_txrx);
