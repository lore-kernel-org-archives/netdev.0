From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 4/15] wireless/orinoco: Update orinoco changelog
	and module parameters
Date: Tue, 26 Oct 2004 14:45:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098816355.3663.50.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Update orinoco changelog and module parameters

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.4-module-params	2004-10-26 10:40:47.498252680 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 10:41:11.070669128 -0400
@@ -393,12 +393,67 @@
  *	  in the rx_dropped statistics.
  *	o Provided a module parameter to suppress linkstatus messages.
  *
+ * v0.13e -> v0.14alpha1 - 30 Sep 2003 - David Gibson
+ *	o Replaced priv->connected logic with netif_carrier_on/off()
+ *	  calls.
+ *	o Remove has_ibss_any and never set the CREATEIBSS RID when
+ *	  the ESSID is empty.  Too many firmwares break if we do.
+ *	o 2.6 merges: Replace pdev->slot_name with pci_name(), remove
+ *	  __devinitdata from PCI ID tables, use free_netdev().
+ *	o Enabled shared-key authentication for Agere firmware (from
+ *	  Robert J. Moore <Robert.J.Moore AT allanbank.com>
+ *	o Move netif_wake_queue() (back) to the Tx completion from the
+ *	  ALLOC event.  This seems to prevent/mitigate the rolling
+ *	  error -110 problems at least on some Intersil firmwares.
+ *	  Theoretically reduces performance, but I can't measure it.
+ *	  Patch from Andrew Tridgell <tridge AT samba.org>
+ *
+ * v0.14alpha1 -> v0.14alpha2 - 20 Oct 2003 - David Gibson
+ *	o Correctly turn off shared-key authentication when requested
+ *	  (bugfix from Robert J. Moore).
+ *	o Correct airport sleep interfaces for current 2.6 kernels.
+ *	o Add code for key change without disabling/enabling the MAC
+ *	  port.  This is supposed to allow 802.1x to work sanely, but
+ *	  doesn't seem to yet.
+ *
+ * v0.14alpha2 -> v0.15rc1 - 19 Apr 2004 - Pavel Roskin & David Gibson
+ *	o Fix bug which prevented setting 32 character ESSIDs from
+ *	  iwconfig (Thomas Schulz).
+ *	o Fix for incorrect CIS access in orinoco_plx (Pavel Roskin).
+ *	o Fix setting WEP key if __orinoco_fastkeychange() is not
+ *	  supported (Pavel Roskin).
+ *	o New wireless extensions API and scanning support (patch from
+ *	  Moustafa Youssef, updated by Jim Carter and Pavel Roskin).
+ *	o Add minimal ethtool support (Pavel Roskin).
+ *	o Replace CardServices() calls for compatibility with Linux
+ *	  2.6.2 and above (Pavel Roskin).
+ *	o Fix recognition of Intersil x.x.1 firmware (Pavel Roskin).
+ *	o Replace dump_recs with more flexible get_rid ioctl (Pavel
+ *	  Roskin).
+ *	o RF monitor mode support (Pavel Roskin).
+ *	o Lots of bugfixes.
+ *
+ * v0.15rc1 -> v0.15rc2 - 28 Jul 2004 - Pavel Roskin & David Gibson
+ *	o orinoco_pci saves PCI registers on suspend (Simon Huggins).
+ *	o Monitor mode disabled on Agere 8.xx firmware - it's broken.
+ *	o BAP timeout increased - needed for Intersil firmware.
+ *	o Tx power is no longer reported - it's unreliable.
+ *	o Use 802.11 header in rx path.  Hide packets with ToDS flag
+ *	  from programs that don't need promiscous mode (John Denker).
+ *	o Manual roaming implemented for Symbol and Intersil firmware.
+ *	o Use netdev_priv() instead of directly dereferencing dev->priv.
+ *	o Some simplification of pcmcia init code in orinoco_cs and
+ *	  spectrum_cs. 
+ *	o Numerous trivial cleanups, mainly arising from long-overdue
+ *	  merge with mainline.
+ *
+ * v0.15rc2 -> ???? - ???? - David Gibson
+ *	o Use msleep() instead of hardcoded schedule_timeout()s
+ *	  (Nishanth Aravamudan via kernel-janitors list).
+ *
  * TODO
- *	o New wireless extensions API (patch from Moustafa
- *	  Youssef, updated by Jim Carter and Pavel Roskin).
  *	o Handle de-encapsulation within network layer, provide 802.11
  *	  headers (patch from Thomas 'Dent' Mirlacher)
- *	o RF monitor mode support
  *	o Fix possible races in SPY handling.
  *	o Disconnect wireless extensions from fundamental configuration.
  *	o (maybe) Software WEP support (patch from Stano Meduna).
@@ -461,12 +516,17 @@
 /* Level of debugging. Used in the macros in orinoco.h */
 #ifdef ORINOCO_DEBUG
 int orinoco_debug = ORINOCO_DEBUG;
-MODULE_PARM(orinoco_debug, "i");
+module_param(orinoco_debug, int, 0644);
+MODULE_PARM_DESC(orinoco_debug, "Debug level");
 EXPORT_SYMBOL(orinoco_debug);
 #endif
 
 static int suppress_linkstatus; /* = 0 */
-MODULE_PARM(suppress_linkstatus, "i");
+module_param(suppress_linkstatus, int, 0644);
+MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
+static int ignore_disconnect; /* = 0 */
+module_param(ignore_disconnect, int, 0644);
+MODULE_PARM_DESC(ignore_disconnect, "Don't report lost link to the network layer");
 
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */
--- a/drivers/net/wireless/orinoco.h.4-module-params	2004-10-26 10:43:24.213428352 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:43:31.138375600 -0400
@@ -14,6 +14,9 @@
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <linux/version.h>
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 4, 25)
+#include <linux/moduleparam.h>
+#endif
 
 #include "hermes.h"
 
