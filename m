From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: [PATCH v2 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump()
 into functions
Date: Thu, 05 Jan 2012 15:28:34 +0200
Message-ID: <20120105132834.22281.78822.stgit@x201>
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

That way it's possible to not export debug_mask outside the upcoming
ath6kl_core.ko and that makes it easier to ath6kl_core.ko in the
following patch.

Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
---
 drivers/net/wireless/ath/ath6kl/debug.c |   30 ++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/ath6kl/debug.h |   25 ++++---------------------
 2 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index 0d77129..f1fa57b 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -57,6 +57,36 @@ int ath6kl_printk(const char *level, const char *fmt, ...)
 
 #ifdef CONFIG_ATH6KL_DEBUG
 
+void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if (!(debug_mask & mask))
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	ath6kl_printk(KERN_DEBUG, "%pV", &vaf);
+
+	va_end(args);
+}
+
+void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
+		     const char *msg, const char *prefix,
+		     const void *buf, size_t len)
+{
+	if (debug_mask & mask) {
+		if (msg)
+			ath6kl_dbg(mask, "%s\n", msg);
+
+		print_hex_dump_bytes(prefix, DUMP_PREFIX_OFFSET, buf, len);
+	}
+}
+
 #define REG_OUTPUT_LEN_PER_LINE	25
 #define REGTYPE_STR_LEN		100
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index cb21d91..c4be6e5 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -61,28 +61,11 @@ enum ath6kl_war {
 };
 
 #ifdef CONFIG_ATH6KL_DEBUG
-#define ath6kl_dbg(mask, fmt, ...)					\
-	({								\
-	 int rtn;							\
-	 if (debug_mask & mask)						\
-		rtn = ath6kl_printk(KERN_DEBUG, fmt, ##__VA_ARGS__);	\
-	 else								\
-		rtn = 0;						\
-									\
-	 rtn;								\
-	 })
 
-static inline void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
-				   const char *msg, const char *prefix,
-				   const void *buf, size_t len)
-{
-	if (debug_mask & mask) {
-		if (msg)
-			ath6kl_dbg(mask, "%s\n", msg);
-
-		print_hex_dump_bytes(prefix, DUMP_PREFIX_OFFSET, buf, len);
-	}
-}
+void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...);
+void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
+		     const char *msg, const char *prefix,
+		     const void *buf, size_t len);
 
 void ath6kl_dump_registers(struct ath6kl_device *dev,
 			   struct ath6kl_irq_proc_registers *irq_proc_reg,
