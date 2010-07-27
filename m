From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/vxge: Use pr_<level>, fix logging
 macros
Date: Tue, 27 Jul 2010 13:43:08 -0700
Message-ID: <1280263388.24054.27.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> where appropriate.
Use direct printing of logging messages to save text.

Reduces object size ~ 4k or 20k.

(x86 defconfig with vxge)
$ size drivers/net/vxge/built-in.o*
   text	   data	    bss	    dec	    hex	filename
  68463	    784	      8	  69255	  10e87	drivers/net/vxge/built-in.o.new
  72417	    784	      8	  73209	  11df9	drivers/net/vxge/built-in.o.old

(x86 allyesconfig)
$ size drivers/net/vxge/built-in.o.*
   text	   data	    bss	    dec	    hex	filename
 125843	   1039	  27528	 154410	  25b2a	drivers/net/vxge/built-in.o.new
 142589	   1039	  31024	 174652	  2aa3c	drivers/net/vxge/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vxge/vxge-config.h |   38 ++++++++++++++++----------------------
 drivers/net/vxge/vxge-main.c   |   27 +++++++++++----------------
 2 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 1a94343..dfe0e2d 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -20,12 +20,8 @@
 #define VXGE_CACHE_LINE_SIZE 128
 #endif
 
-#define vxge_os_vaprintf(level, mask, fmt, ...) { \
-	char buff[255]; \
-		snprintf(buff, 255, fmt, __VA_ARGS__); \
-		printk(buff); \
-		printk("\n"); \
-}
+#define vxge_os_vaprintf(level, mask, fmt, ...) \
+	printk(fmt "\n", ##__VA_ARGS__)
 
 #ifndef VXGE_ALIGN
 #define VXGE_ALIGN(adrs, size) \
@@ -2228,7 +2224,6 @@ vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
  * vxge_debug
  * @level: level of debug verbosity.
  * @mask: mask for the debug
- * @buf: Circular buffer for tracing
  * @fmt: printf like format string
  *
  * Provides logging facilities. Can be customized on per-module
@@ -2238,24 +2233,23 @@ vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
  * See also: enum vxge_debug_level{}.
  */
 
-#define vxge_trace_aux(level, mask, fmt, ...) \
-{\
-		vxge_os_vaprintf(level, mask, fmt, __VA_ARGS__);\
-}
+#define vxge_trace_aux(level, mask, fmt, ...)			\
+	vxge_os_vaprintf(level, mask, fmt, ##__VA_ARGS__)
 
-#define vxge_debug(module, level, mask, fmt, ...) { \
-if ((level >= VXGE_TRACE && ((module & VXGE_DEBUG_TRACE_MASK) == module)) || \
-	(level >= VXGE_ERR && ((module & VXGE_DEBUG_ERR_MASK) == module))) {\
-	if ((mask & VXGE_DEBUG_MASK) == mask)\
-		vxge_trace_aux(level, mask, fmt, __VA_ARGS__); \
-} \
-}
+#define vxge_debug(module, level, mask, fmt, ...)			\
+do {									\
+	if ((level >= VXGE_TRACE &&					\
+	     ((module & VXGE_DEBUG_TRACE_MASK) == module)) ||		\
+	    (level >= VXGE_ERR &&					\
+	     ((module & VXGE_DEBUG_ERR_MASK) == module))) {		\
+		if ((mask & VXGE_DEBUG_MASK) == mask)			\
+			vxge_trace_aux(level, mask, fmt, ##__VA_ARGS__); \
+	}								\
+} while (0)
 
 #if (VXGE_COMPONENT_LL & VXGE_DEBUG_MODULE_MASK)
-#define vxge_debug_ll(level, mask, fmt, ...) \
-{\
-	vxge_debug(VXGE_COMPONENT_LL, level, mask, fmt, __VA_ARGS__);\
-}
+#define vxge_debug_ll(level, mask, fmt, ...)				\
+	vxge_debug(VXGE_COMPONENT_LL, level, mask, fmt, ##__VA_ARGS__)
 
 #else
 #define vxge_debug_ll(level, mask, fmt, ...)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 94d87e8..c7c5605 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -41,6 +41,8 @@
 *
 ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
@@ -144,7 +146,7 @@ vxge_callback_link_up(struct __vxge_hw_device *hldev)
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
 		vdev->ndev->name, __func__, __LINE__);
-	printk(KERN_NOTICE "%s: Link Up\n", vdev->ndev->name);
+	netdev_notice(vdev->ndev, "Link Up\n");
 	vdev->stats.link_up++;
 
 	netif_carrier_on(vdev->ndev);
@@ -168,7 +170,7 @@ vxge_callback_link_down(struct __vxge_hw_device *hldev)
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
-	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
+	netdev_notice(vdev->ndev, "Link Down\n");
 
 	vdev->stats.link_down++;
 	netif_carrier_off(vdev->ndev);
@@ -2679,7 +2681,7 @@ vxge_open(struct net_device *dev)
 
 	if (vxge_hw_device_link_state_get(vdev->devh) == VXGE_HW_LINK_UP) {
 		netif_carrier_on(vdev->ndev);
-		printk(KERN_NOTICE "%s: Link Up\n", vdev->ndev->name);
+		netdev_notice(vdev->ndev, "Link Up\n");
 		vdev->stats.link_up++;
 	}
 
@@ -2817,7 +2819,7 @@ int do_vxge_close(struct net_device *dev, int do_io)
 	}
 
 	netif_carrier_off(vdev->ndev);
-	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
+	netdev_notice(vdev->ndev, "Link Down\n");
 	netif_tx_stop_all_queues(vdev->ndev);
 
 	/* Note that at this point xmit() is stopped by upper layer */
@@ -3844,9 +3846,7 @@ static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
 	struct vxgedev *vdev = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "%s: "
-			"Cannot re-enable device after reset\n",
-			VXGE_DRIVER_NAME);
+		netdev_err(netdev, "Cannot re-enable device after reset\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
@@ -3871,9 +3871,8 @@ static void vxge_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (vxge_open(netdev)) {
-			printk(KERN_ERR "%s: "
-				"Can't bring device back up after reset\n",
-				VXGE_DRIVER_NAME);
+			netdev_err(netdev,
+				   "Can't bring device back up after reset\n");
 			return;
 		}
 	}
@@ -4430,13 +4429,9 @@ static int __init
 vxge_starter(void)
 {
 	int ret = 0;
-	char version[32];
-	snprintf(version, 32, "%s", DRV_VERSION);
 
-	printk(KERN_INFO "%s: Copyright(c) 2002-2010 Exar Corp.\n",
-		VXGE_DRIVER_NAME);
-	printk(KERN_INFO "%s: Driver version: %s\n",
-			VXGE_DRIVER_NAME, version);
+	pr_info("Copyright(c) 2002-2010 Exar Corp.\n");
+	pr_info("Driver version: %s\n", DRV_VERSION);
 
 	verify_bandwidth();
 
