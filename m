From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] iwlwifi: Deinline iwl_{read,write}{8,32}
Date: Tue, 14 Jul 2015 14:22:38 +0200
Message-ID: <1436876558-6674-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_IWLWIFI_DEVICE_TRACING=y, these functions are rather large,
too big for inlining.

With this .config: http://busybox.net/~vda/kernel_config,
after uninlining these functions have sizes and callsite counts
as follows:

iwl_read32  475 bytes, 51 callsites
iwl_write32 477 bytes, 90 callsites
iwl_write8  493 bytes, 3 callsites

Reduction in size is about 74,000 bytes:

    text     data      bss       dec     hex filename
90758147 17226024 36659200 144643371 89f152b vmlinux0
90687995 17221928 36659200 144569123 89df323 vmlinux.after

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Johannes Berg <johannes.berg@intel.com>
CC: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Intel Linux Wireless <ilw@linux.intel.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 drivers/net/wireless/iwlwifi/iwl-io.c |  7 +++++++
 drivers/net/wireless/iwlwifi/iwl-io.h | 39 +++++++++++++++++++++--------------
 2 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-io.c b/drivers/net/wireless/iwlwifi/iwl-io.c
index 27c66e4..aed121e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-io.c
+++ b/drivers/net/wireless/iwlwifi/iwl-io.c
@@ -38,6 +38,13 @@
 
 #define IWL_POLL_INTERVAL 10	/* microseconds */
 
+#if defined(CONFIG_IWLWIFI_DEVICE_TRACING)
+IWL_READ_WRITE( /*not inlined*/ )
+IWL_EXPORT_SYMBOL(iwl_write8);
+IWL_EXPORT_SYMBOL(iwl_write32);
+IWL_EXPORT_SYMBOL(iwl_read32);
+#endif
+
 int iwl_poll_bit(struct iwl_trans *trans, u32 addr,
 		 u32 bits, u32 mask, int timeout)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-io.h b/drivers/net/wireless/iwlwifi/iwl-io.h
index 705d12c..3c9d2a8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-io.h
+++ b/drivers/net/wireless/iwlwifi/iwl-io.h
@@ -32,24 +32,31 @@
 #include "iwl-devtrace.h"
 #include "iwl-trans.h"
 
-static inline void iwl_write8(struct iwl_trans *trans, u32 ofs, u8 val)
-{
-	trace_iwlwifi_dev_iowrite8(trans->dev, ofs, val);
-	iwl_trans_write8(trans, ofs, val);
-}
-
-static inline void iwl_write32(struct iwl_trans *trans, u32 ofs, u32 val)
-{
-	trace_iwlwifi_dev_iowrite32(trans->dev, ofs, val);
-	iwl_trans_write32(trans, ofs, val);
+#define IWL_READ_WRITE(static_inline) \
+static_inline void iwl_write8(struct iwl_trans *trans, u32 ofs, u8 val) \
+{ \
+	trace_iwlwifi_dev_iowrite8(trans->dev, ofs, val); \
+	iwl_trans_write8(trans, ofs, val); \
+} \
+static_inline void iwl_write32(struct iwl_trans *trans, u32 ofs, u32 val) \
+{ \
+	trace_iwlwifi_dev_iowrite32(trans->dev, ofs, val); \
+	iwl_trans_write32(trans, ofs, val); \
+} \
+static_inline u32 iwl_read32(struct iwl_trans *trans, u32 ofs) \
+{ \
+	u32 val = iwl_trans_read32(trans, ofs); \
+	trace_iwlwifi_dev_ioread32(trans->dev, ofs, val); \
+	return val; \
 }
 
-static inline u32 iwl_read32(struct iwl_trans *trans, u32 ofs)
-{
-	u32 val = iwl_trans_read32(trans, ofs);
-	trace_iwlwifi_dev_ioread32(trans->dev, ofs, val);
-	return val;
-}
+#if !defined(CONFIG_IWLWIFI_DEVICE_TRACING)
+IWL_READ_WRITE(static inline)
+#else
+void iwl_write8(struct iwl_trans *trans, u32 ofs, u8 val);
+void iwl_write32(struct iwl_trans *trans, u32 ofs, u32 val);
+u32 iwl_read32(struct iwl_trans *trans, u32 ofs);
+#endif
 
 static inline void iwl_set_bit(struct iwl_trans *trans, u32 reg, u32 mask)
 {
-- 
1.8.1.4
