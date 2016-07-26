From: Joe Perches <joe@perches.com>
Subject: [PATCH] qed: Add and use specific logging functions to reduce object size
Date: Tue, 26 Jul 2016 14:25:41 -0700
Message-ID: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current DP_<LEVEL> macros generate a lot of code.
Using functions with vsprintf extension %pV helps reduce that size.

$ size drivers/net/ethernet/qlogic/built-in.o* (x86-64)
   text	   data	    bss	    dec	    hex	filename
 165161	  28470	  32812	 226443	  3748b	drivers/net/ethernet/qlogic/built-in.o.defconfig.new
 190473	  28470	  32812	 251755	  3d76b	drivers/net/ethernet/qlogic/built-in.o.defconfig.old
1215984	 257822	  39712	1513518	 17182e	drivers/net/ethernet/qlogic/built-in.o.allyesconfig.new
1262402	 284334	  39712	1586448	 183510	drivers/net/ethernet/qlogic/built-in.o.allyesconfig.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qed/Makefile   |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_util.c | 82 ++++++++++++++++++++++++++++++
 include/linux/qed/qed_if.h                 | 60 +++++++++-------------
 3 files changed, 106 insertions(+), 38 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_util.c

diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index d1f157e..9d7e55f 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -2,5 +2,5 @@ obj-$(CONFIG_QED) := qed.o
 
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
-	 qed_selftest.o qed_dcbx.o
+	 qed_selftest.o qed_dcbx.o qed_util.o
 qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed_util.c b/drivers/net/ethernet/qlogic/qed/qed_util.c
new file mode 100644
index 0000000..2795e63
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_util.c
@@ -0,0 +1,82 @@
+#include <linux/kernel.h>
+#include <linux/qed/qed_if.h>
+
+#include "qed.h"
+
+void qed_err(const char *name, int line, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	pr_err("[%ps:%d(%s)] %pV",
+	       __builtin_return_address(0), line, name ? name : "",
+               &vaf);
+
+	va_end(args);
+}
+
+void qed_notice(u32 level, const char *name, int line, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if (likely(level > QED_LEVEL_NOTICE))
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	pr_notice("[%ps:%d(%s)] %pV",
+		  __builtin_return_address(0), line, name ? name : "",
+		  &vaf);
+
+	va_end(args);
+}
+
+void qed_info(u32 level, const char *name, int line, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if (likely(level > QED_LEVEL_INFO))
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	pr_notice("[%ps:%d(%s)] %pV",
+		  __builtin_return_address(0), line, name ? name : "",
+		  &vaf);
+
+	va_end(args);
+}
+
+void qed_verbose(u32 level, const char *name, int line,
+		 const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if (likely(level > QED_LEVEL_VERBOSE))
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	pr_notice("[%ps:%d(%s)] %pV",
+		  __builtin_return_address(0), line, name ? name : "",
+		  &vaf);
+
+	va_end(args);
+}
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index b1e3c57..fa3d8c0 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -539,44 +539,30 @@ struct qed_common_ops {
 #define GET_FIELD(value, name) \
 	(((value) >> (name ## _SHIFT)) & name ## _MASK)
 
-/* Debug print definitions */
-#define DP_ERR(cdev, fmt, ...)						     \
-		pr_err("[%s:%d(%s)]" fmt,				     \
-		       __func__, __LINE__,				     \
-		       DP_NAME(cdev) ? DP_NAME(cdev) : "",		     \
-		       ## __VA_ARGS__)					     \
-
-#define DP_NOTICE(cdev, fmt, ...)				      \
-	do {							      \
-		if (unlikely((cdev)->dp_level <= QED_LEVEL_NOTICE)) { \
-			pr_notice("[%s:%d(%s)]" fmt,		      \
-				  __func__, __LINE__,		      \
-				  DP_NAME(cdev) ? DP_NAME(cdev) : "", \
-				  ## __VA_ARGS__);		      \
-								      \
-		}						      \
-	} while (0)
-
-#define DP_INFO(cdev, fmt, ...)					      \
-	do {							      \
-		if (unlikely((cdev)->dp_level <= QED_LEVEL_INFO)) {   \
-			pr_notice("[%s:%d(%s)]" fmt,		      \
-				  __func__, __LINE__,		      \
-				  DP_NAME(cdev) ? DP_NAME(cdev) : "", \
-				  ## __VA_ARGS__);		      \
-		}						      \
-	} while (0)
+__printf(3, 4)
+void qed_err(const char *name, int line, const char *fmt, ...);
+__printf(4, 5)
+void qed_notice(u32 level, const char *name, int line, const char *fmt, ...);
+__printf(4, 5)
+void qed_info(u32 level, const char *name, int line, const char *fmt, ...);
+__printf(4, 5)
+void qed_verbose(u32 level, const char *name, int line, const char *fmt, ...);
 
-#define DP_VERBOSE(cdev, module, fmt, ...)				\
-	do {								\
-		if (unlikely(((cdev)->dp_level <= QED_LEVEL_VERBOSE) &&	\
-			     ((cdev)->dp_module & module))) {		\
-			pr_notice("[%s:%d(%s)]" fmt,			\
-				  __func__, __LINE__,			\
-				  DP_NAME(cdev) ? DP_NAME(cdev) : "",	\
-				  ## __VA_ARGS__);			\
-		}							\
-	} while (0)
+/* Debug print definitions */
+#define DP_ERR(type, fmt, ...)						\
+	qed_err(DP_NAME(type), __LINE__, fmt, ##__VA_ARGS__)
+#define DP_NOTICE(type, fmt, ...)					\
+	qed_notice((type)->dp_level, DP_NAME(type), __LINE__,		\
+		   fmt, ##__VA_ARGS__)
+#define DP_INFO(type, fmt, ...)						\
+	qed_info((type)->dp_level, DP_NAME(type), __LINE__,		\
+		 fmt, ##__VA_ARGS__)
+#define DP_VERBOSE(type, module, fmt, ...)				\
+do {									\
+	if ((type)->dp_module & module)					\
+		qed_verbose((type)->dp_level, DP_NAME(type), __LINE__,	\
+			    fmt, ##__VA_ARGS__);			\
+} while (0)
 
 enum DP_LEVEL {
 	QED_LEVEL_VERBOSE	= 0x0,
-- 
2.8.0.rc4.16.g56331f8
