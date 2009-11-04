From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 07/15] wimax: allow specifying debug levels as command line option
Date: Wed,  4 Nov 2009 13:39:48 -0800
Message-ID: <4c2b1a11646bf74e2926ce8b13a21884adc1e05c.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932713AbZKDVl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:59 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add "debug" module options to all the wimax modules (including
drivers) so that the debug levels can be set upon kernel boot or
module load time.

This is needed as currently there was a limitation where the debug
levels could only be set when a device was succesfully
enumerated. This made it difficult to debug issues that made a device
not probe properly.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   10 +++++
 drivers/net/wimax/i2400m/sdio.c   |   10 +++++
 drivers/net/wimax/i2400m/usb.c    |    9 +++++
 include/linux/wimax/debug.h       |   72 +++++++++++++++++++++++++++++++++++++
 net/wimax/stack.c                 |   11 ++++++
 5 files changed, 112 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 7ba00de..e3b2c24 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -90,6 +90,14 @@ MODULE_PARM_DESC(power_save_disabled,
 		 "False by default (so the device is told to do power "
 		 "saving).");
 
+static char i2400m_debug_params[128];
+module_param_string(debug, i2400m_debug_params, sizeof(i2400m_debug_params),
+		    0644);
+MODULE_PARM_DESC(debug,
+		 "String of space-separated NAME:VALUE pairs, where NAMEs "
+		 "are the different debug submodules and VALUE are the "
+		 "initial debug value to set.");
+
 /**
  * i2400m_queue_work - schedule work on a i2400m's queue
  *
@@ -794,6 +802,8 @@ size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
 static
 int __init i2400m_driver_init(void)
 {
+	d_parse_params(D_LEVEL, D_LEVEL_SIZE, i2400m_debug_params,
+		       "i2400m.debug");
 	return 0;
 }
 module_init(i2400m_driver_init);
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 7c1b843..2d2cc5a 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -71,6 +71,14 @@
 static int ioe_timeout = 2;
 module_param(ioe_timeout, int, 0);
 
+static char i2400ms_debug_params[128];
+module_param_string(debug, i2400ms_debug_params, sizeof(i2400ms_debug_params),
+		    0644);
+MODULE_PARM_DESC(debug,
+		 "String of space-separated NAME:VALUE pairs, where NAMEs "
+		 "are the different debug submodules and VALUE are the "
+		 "initial debug value to set.");
+
 /* Our firmware file name list */
 static const char *i2400ms_bus_fw_names[] = {
 #define I2400MS_FW_FILE_NAME "i2400m-fw-sdio-1.3.sbcf"
@@ -559,6 +567,8 @@ struct sdio_driver i2400m_sdio_driver = {
 static
 int __init i2400ms_driver_init(void)
 {
+	d_parse_params(D_LEVEL, D_LEVEL_SIZE, i2400ms_debug_params,
+		       "i2400m_sdio.debug");
 	return sdio_register_driver(&i2400m_sdio_driver);
 }
 module_init(i2400ms_driver_init);
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index a5879e2..0634222 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -71,6 +71,13 @@
 #define D_SUBMODULE usb
 #include "usb-debug-levels.h"
 
+static char i2400mu_debug_params[128];
+module_param_string(debug, i2400mu_debug_params, sizeof(i2400mu_debug_params),
+		    0644);
+MODULE_PARM_DESC(debug,
+		 "String of space-separated NAME:VALUE pairs, where NAMEs "
+		 "are the different debug submodules and VALUE are the "
+		 "initial debug value to set.");
 
 /* Our firmware file name */
 static const char *i2400mu_bus_fw_names[] = {
@@ -633,6 +640,8 @@ struct usb_driver i2400mu_driver = {
 static
 int __init i2400mu_driver_init(void)
 {
+	d_parse_params(D_LEVEL, D_LEVEL_SIZE, i2400mu_debug_params,
+		       "i2400m_usb.debug");
 	return usb_register(&i2400mu_driver);
 }
 module_init(i2400mu_driver_init);
diff --git a/include/linux/wimax/debug.h b/include/linux/wimax/debug.h
index c703e03..db8096e 100644
--- a/include/linux/wimax/debug.h
+++ b/include/linux/wimax/debug.h
@@ -450,4 +450,76 @@ do {							\
 })
 
 
+static inline
+void d_submodule_set(struct d_level *d_level, size_t d_level_size,
+		     const char *submodule, u8 level, const char *tag)
+{
+	struct d_level *itr, *top;
+	int index = -1;
+
+	for (itr = d_level, top = itr + d_level_size; itr < top; itr++) {
+		index++;
+		if (itr->name == NULL) {
+			printk(KERN_ERR "%s: itr->name NULL?? (%p, #%d)\n",
+			       tag, itr, index);
+			continue;
+		}
+		if (!strcmp(itr->name, submodule)) {
+			itr->level = level;
+			return;
+		}
+	}
+	printk(KERN_ERR "%s: unknown submodule %s\n", tag, submodule);
+}
+
+
+/**
+ * d_parse_params - Parse a string with debug parameters from the
+ * command line
+ *
+ * @d_level: level structure (D_LEVEL)
+ * @d_level_size: number of items in the level structure
+ *     (D_LEVEL_SIZE).
+ * @_params: string with the parameters; this is a space (not tab!)
+ *     separated list of NAME:VALUE, where value is the debug level
+ *     and NAME is the name of the submodule.
+ * @tag: string for error messages (example: MODULE.ARGNAME).
+ */
+static inline
+void d_parse_params(struct d_level *d_level, size_t d_level_size,
+		    const char *_params, const char *tag)
+{
+	char submodule[130], *params, *params_orig, *token, *colon;
+	unsigned level, tokens;
+
+	if (_params == NULL)
+		return;
+	params_orig = kstrdup(_params, GFP_KERNEL);
+	params = params_orig;
+	while (1) {
+		token = strsep(&params, " ");
+		if (token == NULL)
+			break;
+		if (*token == '\0')	/* eat joint spaces */
+			continue;
+		/* kernel's sscanf %s eats until whitespace, so we
+		 * replace : by \n so it doesn't get eaten later by
+		 * strsep */
+		colon = strchr(token, ':');
+		if (colon != NULL)
+			*colon = '\n';
+		tokens = sscanf(token, "%s\n%u", submodule, &level);
+		if (colon != NULL)
+			*colon = ':';	/* set back, for error messages */
+		if (tokens == 2)
+			d_submodule_set(d_level, d_level_size,
+					submodule, level, tag);
+		else
+			printk(KERN_ERR "%s: can't parse '%s' as a "
+			       "SUBMODULE:LEVEL (%d tokens)\n",
+			       tag, token, tokens);
+	}
+	kfree(params_orig);
+}
+
 #endif /* #ifndef __debug__h__ */
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 79fb7d7..c886641 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -60,6 +60,14 @@
 #define D_SUBMODULE stack
 #include "debug-levels.h"
 
+static char wimax_debug_params[128];
+module_param_string(debug, wimax_debug_params, sizeof(wimax_debug_params),
+		    0644);
+MODULE_PARM_DESC(debug,
+		 "String of space-separated NAME:VALUE pairs, where NAMEs "
+		 "are the different debug submodules and VALUE are the "
+		 "initial debug value to set.");
+
 /*
  * Authoritative source for the RE_STATE_CHANGE attribute policy
  *
@@ -562,6 +570,9 @@ int __init wimax_subsys_init(void)
 	int result, cnt;
 
 	d_fnstart(4, NULL, "()\n");
+	d_parse_params(D_LEVEL, D_LEVEL_SIZE, wimax_debug_params,
+		       "wimax.debug");
+
 	snprintf(wimax_gnl_family.name, sizeof(wimax_gnl_family.name),
 		 "WiMAX");
 	result = genl_register_family(&wimax_gnl_family);
-- 
1.6.2.5

