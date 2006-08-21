From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 01/14] ipw2200: always enable frequently used debugging code
Date: Mon, 21 Aug 2006 11:36:53 +0800
Message-ID: <20060821033653.GA5326@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60606 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932576AbWHUDis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:38:48 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moving part of the debugging code from IPW_DEBUG to IPW_LL_DEBUG (low level
debugging) and make IPW_DEBUG be always enabled. IPW_LL_DEBUG still needs
to be enabled by selecting CONFIG_IPW2200_DEBUG. But it is highly
deprecated for normal users since it adds higher debug verbosity in driver
hot paths.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/Kconfig   |   23 ++++++-----------------
 drivers/net/wireless/ipw2200.c |   18 ------------------
 drivers/net/wireless/ipw2200.h |   40 ++++++++++++++++++++++------------------
 3 files changed, 28 insertions(+), 53 deletions(-)

d65bf064588ecf4ed4ae29668eae2fd50bd19eee
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 96bb820..a8ffd78 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -271,25 +271,14 @@ config IPW2200_DEBUG
 	bool "Enable full debugging output in IPW2200 module."
 	depends on IPW2200
 	---help---
-	  This option will enable debug tracing output for the IPW2200.  
+	  This option will enable low level debug tracing output for IPW2200.  
 
-	  This will result in the kernel module being ~100k larger.  You can 
-	  control which debug output is sent to the kernel log by setting the 
-	  value in 
+	  Note, normal debug code is already compiled in. This low level
+	  debug option enables debug on hot paths (e.g Tx, Rx, ISR) and
+	  will result in the kernel module being ~70 larger.  Most users
+	  will typically not need this high verbosity debug information. 
 
-	  /sys/bus/pci/drivers/ipw2200/debug_level
-
-	  This entry will only exist if this option is enabled.
-
-	  To set a value, simply echo an 8-byte hex value to the same file:
-
-	  % echo 0x00000FFO > /sys/bus/pci/drivers/ipw2200/debug_level
-
-	  You can find the list of debug mask values in 
-	  drivers/net/wireless/ipw2200.h
-
-	  If you are not trying to debug or develop the IPW2200 driver, you 
-	  most likely want to say N here.
+	  If you are not sure, say N here.
 
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 758459e..89e076f 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -567,7 +567,6 @@ static inline void ipw_disable_interrupt
 	spin_unlock_irqrestore(&priv->irq_lock, flags);
 }
 
-#ifdef CONFIG_IPW2200_DEBUG
 static char *ipw_error_desc(u32 val)
 {
 	switch (val) {
@@ -634,7 +633,6 @@ static void ipw_dump_error_log(struct ip
 			  error->log[i].time,
 			  error->log[i].data, error->log[i].event);
 }
-#endif
 
 static inline int ipw_is_init(struct ipw_priv *priv)
 {
@@ -1435,9 +1433,7 @@ static ssize_t store_scan_age(struct dev
 			      const char *buf, size_t count)
 {
 	struct ipw_priv *priv = dev_get_drvdata(d);
-#ifdef CONFIG_IPW2200_DEBUG
 	struct net_device *dev = priv->net_dev;
-#endif
 	char buffer[] = "00000000";
 	unsigned long len =
 	    (sizeof(buffer) - 1) > count ? count : sizeof(buffer) - 1;
@@ -1958,14 +1954,12 @@ static void ipw_irq_tasklet(struct ipw_p
 		IPW_WARNING("Firmware error detected.  Restarting.\n");
 		if (priv->error) {
 			IPW_DEBUG_FW("Sysfs 'error' log already exists.\n");
-#ifdef CONFIG_IPW2200_DEBUG
 			if (ipw_debug_level & IPW_DL_FW_ERRORS) {
 				struct ipw_fw_error *error =
 				    ipw_alloc_error_log(priv);
 				ipw_dump_error_log(priv, error);
 				kfree(error);
 			}
-#endif
 		} else {
 			priv->error = ipw_alloc_error_log(priv);
 			if (priv->error)
@@ -1973,10 +1967,8 @@ static void ipw_irq_tasklet(struct ipw_p
 			else
 				IPW_DEBUG_FW("Error allocating sysfs 'error' "
 					     "log.\n");
-#ifdef CONFIG_IPW2200_DEBUG
 			if (ipw_debug_level & IPW_DL_FW_ERRORS)
 				ipw_dump_error_log(priv, priv->error);
-#endif
 		}
 
 		/* XXX: If hardware encryption is for WPA/WPA2,
@@ -3915,7 +3907,6 @@ static const struct ipw_status_code ipw_
 	{0x2E, "Cipher suite is rejected per security policy"},
 };
 
-#ifdef CONFIG_IPW2200_DEBUG
 static const char *ipw_get_status_code(u16 status)
 {
 	int i;
@@ -3924,7 +3915,6 @@ static const char *ipw_get_status_code(u
 			return ipw_status_codes[i].reason;
 	return "Unknown status value.";
 }
-#endif
 
 static void inline average_init(struct average *avg)
 {
@@ -4394,7 +4384,6 @@ static void ipw_rx_notification(struct i
 					if (priv->
 					    status & (STATUS_ASSOCIATED |
 						      STATUS_AUTH)) {
-#ifdef CONFIG_IPW2200_DEBUG
 						struct notif_authenticate *auth
 						    = &notif->u.auth;
 						IPW_DEBUG(IPW_DL_NOTIF |
@@ -4412,7 +4401,6 @@ static void ipw_rx_notification(struct i
 							  ipw_get_status_code
 							  (ntohs
 							   (auth->status)));
-#endif
 
 						priv->status &=
 						    ~(STATUS_ASSOCIATING |
@@ -5969,7 +5957,6 @@ static void ipw_bg_adhoc_check(void *dat
 	mutex_unlock(&priv->mutex);
 }
 
-#ifdef CONFIG_IPW2200_DEBUG
 static void ipw_debug_config(struct ipw_priv *priv)
 {
 	IPW_DEBUG_INFO("Scan completed, no valid APs matched "
@@ -5994,9 +5981,6 @@ static void ipw_debug_config(struct ipw_
 		IPW_DEBUG_INFO("PRIVACY off\n");
 	IPW_DEBUG_INFO("RATE MASK: 0x%08X\n", priv->rates_mask);
 }
-#else
-#define ipw_debug_config(x) do {} while (0)
-#endif
 
 static void ipw_set_fixed_rate(struct ipw_priv *priv, int mode)
 {
@@ -11467,9 +11451,7 @@ static int ipw_pci_probe(struct pci_dev 
 
 	priv->net_dev = net_dev;
 	priv->pci_dev = pdev;
-#ifdef CONFIG_IPW2200_DEBUG
 	ipw_debug_level = debug;
-#endif
 	spin_lock_init(&priv->irq_lock);
 	spin_lock_init(&priv->lock);
 	for (i = 0; i < IPW_IBSS_MAC_HASH_SIZE; i++)
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 8b1cd7c..b49f766 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1381,13 +1381,18 @@ BITC(x,19),BITC(x,18),BITC(x,17),BITC(x,
 BIT_ARG16(x)
 
 
-#ifdef CONFIG_IPW2200_DEBUG
 #define IPW_DEBUG(level, fmt, args...) \
 do { if (ipw_debug_level & (level)) \
   printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
          in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+
+#ifdef CONFIG_IPW2200_DEBUG
+#define IPW_LL_DEBUG(level, fmt, args...) \
+do { if (ipw_debug_level & (level)) \
+  printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
+         in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
 #else
-#define IPW_DEBUG(level, fmt, args...) do {} while (0)
+#define IPW_LL_DEBUG(level, fmt, args...) do {} while (0)
 #endif				/* CONFIG_IPW2200_DEBUG */
 
 /*
@@ -1457,28 +1462,27 @@ do { if (ipw_debug_level & (level)) \
 
 #define IPW_DEBUG_WX(f, a...)     IPW_DEBUG(IPW_DL_WX, f, ## a)
 #define IPW_DEBUG_SCAN(f, a...)   IPW_DEBUG(IPW_DL_SCAN, f, ## a)
-#define IPW_DEBUG_STATUS(f, a...) IPW_DEBUG(IPW_DL_STATUS, f, ## a)
-#define IPW_DEBUG_TRACE(f, a...)  IPW_DEBUG(IPW_DL_TRACE, f, ## a)
-#define IPW_DEBUG_RX(f, a...)     IPW_DEBUG(IPW_DL_RX, f, ## a)
-#define IPW_DEBUG_TX(f, a...)     IPW_DEBUG(IPW_DL_TX, f, ## a)
-#define IPW_DEBUG_ISR(f, a...)    IPW_DEBUG(IPW_DL_ISR, f, ## a)
+#define IPW_DEBUG_TRACE(f, a...)  IPW_LL_DEBUG(IPW_DL_TRACE, f, ## a)
+#define IPW_DEBUG_RX(f, a...)     IPW_LL_DEBUG(IPW_DL_RX, f, ## a)
+#define IPW_DEBUG_TX(f, a...)     IPW_LL_DEBUG(IPW_DL_TX, f, ## a)
+#define IPW_DEBUG_ISR(f, a...)    IPW_LL_DEBUG(IPW_DL_ISR, f, ## a)
 #define IPW_DEBUG_MANAGEMENT(f, a...) IPW_DEBUG(IPW_DL_MANAGE, f, ## a)
-#define IPW_DEBUG_LED(f, a...) IPW_DEBUG(IPW_DL_LED, f, ## a)
-#define IPW_DEBUG_WEP(f, a...)    IPW_DEBUG(IPW_DL_WEP, f, ## a)
-#define IPW_DEBUG_HC(f, a...) IPW_DEBUG(IPW_DL_HOST_COMMAND, f, ## a)
-#define IPW_DEBUG_FRAG(f, a...) IPW_DEBUG(IPW_DL_FRAG, f, ## a)
-#define IPW_DEBUG_FW(f, a...) IPW_DEBUG(IPW_DL_FW, f, ## a)
+#define IPW_DEBUG_LED(f, a...) IPW_LL_DEBUG(IPW_DL_LED, f, ## a)
+#define IPW_DEBUG_WEP(f, a...)    IPW_LL_DEBUG(IPW_DL_WEP, f, ## a)
+#define IPW_DEBUG_HC(f, a...) IPW_LL_DEBUG(IPW_DL_HOST_COMMAND, f, ## a)
+#define IPW_DEBUG_FRAG(f, a...) IPW_LL_DEBUG(IPW_DL_FRAG, f, ## a)
+#define IPW_DEBUG_FW(f, a...) IPW_LL_DEBUG(IPW_DL_FW, f, ## a)
 #define IPW_DEBUG_RF_KILL(f, a...) IPW_DEBUG(IPW_DL_RF_KILL, f, ## a)
 #define IPW_DEBUG_DROP(f, a...) IPW_DEBUG(IPW_DL_DROP, f, ## a)
-#define IPW_DEBUG_IO(f, a...) IPW_DEBUG(IPW_DL_IO, f, ## a)
-#define IPW_DEBUG_ORD(f, a...) IPW_DEBUG(IPW_DL_ORD, f, ## a)
-#define IPW_DEBUG_FW_INFO(f, a...) IPW_DEBUG(IPW_DL_FW_INFO, f, ## a)
+#define IPW_DEBUG_IO(f, a...) IPW_LL_DEBUG(IPW_DL_IO, f, ## a)
+#define IPW_DEBUG_ORD(f, a...) IPW_LL_DEBUG(IPW_DL_ORD, f, ## a)
+#define IPW_DEBUG_FW_INFO(f, a...) IPW_LL_DEBUG(IPW_DL_FW_INFO, f, ## a)
 #define IPW_DEBUG_NOTIF(f, a...) IPW_DEBUG(IPW_DL_NOTIF, f, ## a)
 #define IPW_DEBUG_STATE(f, a...) IPW_DEBUG(IPW_DL_STATE | IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
 #define IPW_DEBUG_ASSOC(f, a...) IPW_DEBUG(IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
-#define IPW_DEBUG_STATS(f, a...) IPW_DEBUG(IPW_DL_STATS, f, ## a)
-#define IPW_DEBUG_MERGE(f, a...) IPW_DEBUG(IPW_DL_MERGE, f, ## a)
-#define IPW_DEBUG_QOS(f, a...)   IPW_DEBUG(IPW_DL_QOS, f, ## a)
+#define IPW_DEBUG_STATS(f, a...) IPW_LL_DEBUG(IPW_DL_STATS, f, ## a)
+#define IPW_DEBUG_MERGE(f, a...) IPW_LL_DEBUG(IPW_DL_MERGE, f, ## a)
+#define IPW_DEBUG_QOS(f, a...)   IPW_LL_DEBUG(IPW_DL_QOS, f, ## a)
 
 #include <linux/ctype.h>
 
-- 
1.2.6
