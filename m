From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't
	blow up.
Date: Tue,  3 Dec 2013 16:14:06 -0500
Message-ID: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: stefano.stabellini@eu.citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	leosilva@linux.vnet.ibm.com, ashley@ashleylai.com, peterhuewe@gmx.de,
	mail@srajiv.net, tpmdd@selhorst.net, tpmdd@sirrix.com,
	dmitry.torokhov@gmail.com, bhelgaas@google.com, plagnioj@jcrosoft.com,
	tomi.valkeinen@ti.com, tpmdd-devel@lists.sourceforge.net,
	linux-input@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-fbdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

The user has the option of disabling the platform driver:
00:02.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)

which is used to unplug the emulated drivers (IDE, Realtek 8169, etc)
and allow the PV drivers to take over. If the user wishes
to disable that they can set:

  xen_platform_pci=0
  (in the guest config file)

or
  xen_emul_unplug=never
  (on the Linux command line)

except it does not work properly. The PV drivers still try to
load and since the Xen platform driver is not run - and it
has not initialized the grant tables, most of the PV drivers
stumble upon:

input: Xen Virtual Keyboard as /devices/virtual/input/input5
input: Xen Virtual Pointer as /devices/virtual/input/input6M
------------[ cut here ]------------
kernel BUG at /home/konrad/ssd/konrad/linux/drivers/xen/grant-table.c:1206!
invalid opcode: 0000 [#1] SMP
Modules linked in: xen_kbdfront(+) xenfs xen_privcmd
CPU: 6 PID: 1389 Comm: modprobe Not tainted 3.13.0-rc1upstream-00021-ga6c892b-dirty #1
Hardware name: Xen HVM domU, BIOS 4.4-unstable 11/26/2013
RIP: 0010:[<ffffffff813ddc40>]  [<ffffffff813ddc40>] get_free_entries+0x2e0/0x300
Call Trace:
 [<ffffffff8150d9a3>] ? evdev_connect+0x1e3/0x240
 [<ffffffff813ddd0e>] gnttab_grant_foreign_access+0x2e/0x70
 [<ffffffffa0010081>] xenkbd_connect_backend+0x41/0x290 [xen_kbdfront]
 [<ffffffffa0010a12>] xenkbd_probe+0x2f2/0x324 [xen_kbdfront]
 [<ffffffff813e5757>] xenbus_dev_probe+0x77/0x130
 [<ffffffff813e7217>] xenbus_frontend_dev_probe+0x47/0x50
 [<ffffffff8145e9a9>] driver_probe_device+0x89/0x230
 [<ffffffff8145ebeb>] __driver_attach+0x9b/0xa0
 [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
 [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
 [<ffffffff8145cf1c>] bus_for_each_dev+0x8c/0xb0
 [<ffffffff8145e7d9>] driver_attach+0x19/0x20
 [<ffffffff8145e260>] bus_add_driver+0x1a0/0x220
 [<ffffffff8145f1ff>] driver_register+0x5f/0xf0
 [<ffffffff813e55c5>] xenbus_register_driver_common+0x15/0x20
 [<ffffffff813e76b3>] xenbus_register_frontend+0x23/0x40
 [<ffffffffa0015000>] ? 0xffffffffa0014fff
 [<ffffffffa001502b>] xenkbd_init+0x2b/0x1000 [xen_kbdfront]
 [<ffffffff81002049>] do_one_initcall+0x49/0x170

.. snip..

which is hardly nice. This patch fixes this by having each
PV driver check for:
 - if running in PV, then it is fine to execute (as that is their
   native environment).
 - if running in HVM, check if user wanted 'xen_emul_unplug=never',
   in which case bail out and don't load PV drivers.
 - if running in HVM, and if PCI device 5853:0001 (xen_platform_pci)
   does not exist, then bail out and not load PV drivers.

P.S.
Ian Campbell suggested getting rid of 'xen_platform_pci_unplug'
but unfortunatly the xen-blkfront driver is using it, so we
cannot do it.

Reported-by: Sander Eikelenboom <linux@eikelenboom.it
Reported-by: Anthony PERARD <anthony.perard@citrix.com>
Reported-by: Fabio Fantoni <fabio.fantoni@m2r.biz>
---
 arch/x86/xen/platform-pci-unplug.c         | 18 ++++++++++++++++++
 drivers/block/xen-blkfront.c               |  2 +-
 drivers/char/tpm/xen-tpmfront.c            |  4 ++++
 drivers/input/misc/xen-kbdfront.c          |  4 ++++
 drivers/net/xen-netfront.c                 |  2 +-
 drivers/pci/xen-pcifront.c                 |  4 ++++
 drivers/video/xen-fbfront.c                |  4 ++++
 drivers/xen/xenbus/xenbus_probe_frontend.c |  2 +-
 include/xen/platform_pci.h                 | 13 ++++++++++++-
 9 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/arch/x86/xen/platform-pci-unplug.c b/arch/x86/xen/platform-pci-unplug.c
index 0a78524..087dfeb 100644
--- a/arch/x86/xen/platform-pci-unplug.c
+++ b/arch/x86/xen/platform-pci-unplug.c
@@ -69,6 +69,24 @@ static int check_platform_magic(void)
 	return 0;
 }
 
+bool xen_has_pv_devices(void)
+{
+	if (!xen_domain())
+		return false;
+
+	if (xen_hvm_domain()) {
+		/* User requested no unplug, so no PV drivers. */
+		if (xen_emul_unplug & XEN_UNPLUG_NEVER)
+			return false;
+		/* And user has xen_platform_pci=0 set in guest config as
+		 * driver did not modify the value. */
+		if (!xen_platform_pci_unplug)
+			return false;
+	}
+	return true;
+}
+EXPORT_SYMBOL_GPL(xen_has_pv_devices);
+
 void xen_unplug_emulated_devices(void)
 {
 	int r;
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index 432db1b..9616b81 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -2074,7 +2074,7 @@ static int __init xlblk_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
+	if (!xen_has_pv_devices())
 		return -ENODEV;
 
 	if (register_blkdev(XENVBD_MAJOR, DEV_NAME)) {
diff --git a/drivers/char/tpm/xen-tpmfront.c b/drivers/char/tpm/xen-tpmfront.c
index c8ff4df..62e7d38 100644
--- a/drivers/char/tpm/xen-tpmfront.c
+++ b/drivers/char/tpm/xen-tpmfront.c
@@ -17,6 +17,7 @@
 #include <xen/xenbus.h>
 #include <xen/page.h>
 #include "tpm.h"
+#include <xen/platform_pci.h>
 
 struct tpm_private {
 	struct tpm_chip *chip;
@@ -421,6 +422,9 @@ static int __init xen_tpmfront_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
+	if (!xen_has_pv_devices())
+		return -ENODEV;
+
 	return xenbus_register_frontend(&tpmfront_driver);
 }
 module_init(xen_tpmfront_init);
diff --git a/drivers/input/misc/xen-kbdfront.c b/drivers/input/misc/xen-kbdfront.c
index e21c181..fbfdc10 100644
--- a/drivers/input/misc/xen-kbdfront.c
+++ b/drivers/input/misc/xen-kbdfront.c
@@ -29,6 +29,7 @@
 #include <xen/interface/io/fbif.h>
 #include <xen/interface/io/kbdif.h>
 #include <xen/xenbus.h>
+#include <xen/platform_pci.h>
 
 struct xenkbd_info {
 	struct input_dev *kbd;
@@ -380,6 +381,9 @@ static int __init xenkbd_init(void)
 	if (xen_initial_domain())
 		return -ENODEV;
 
+	if (!xen_has_pv_devices())
+		return -ENODEV;
+
 	return xenbus_register_frontend(&xenkbd_driver);
 }
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e59acb1..d4b52e9 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -2115,7 +2115,7 @@ static int __init netif_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
+	if (!xen_has_pv_devices())
 		return -ENODEV;
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
index f7197a7..eae7cd9 100644
--- a/drivers/pci/xen-pcifront.c
+++ b/drivers/pci/xen-pcifront.c
@@ -20,6 +20,7 @@
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
 #include <linux/time.h>
+#include <xen/platform_pci.h>
 
 #include <asm/xen/swiotlb-xen.h>
 #define INVALID_GRANT_REF (0)
@@ -1138,6 +1139,9 @@ static int __init pcifront_init(void)
 	if (!xen_pv_domain() || xen_initial_domain())
 		return -ENODEV;
 
+	if (!xen_has_pv_devices())
+		return -ENODEV;
+
 	pci_frontend_registrar(1 /* enable */);
 
 	return xenbus_register_frontend(&xenpci_driver);
diff --git a/drivers/video/xen-fbfront.c b/drivers/video/xen-fbfront.c
index cd005c2..4b2d3ab 100644
--- a/drivers/video/xen-fbfront.c
+++ b/drivers/video/xen-fbfront.c
@@ -35,6 +35,7 @@
 #include <xen/interface/io/fbif.h>
 #include <xen/interface/io/protocols.h>
 #include <xen/xenbus.h>
+#include <xen/platform_pci.h>
 
 struct xenfb_info {
 	unsigned char		*fb;
@@ -699,6 +700,9 @@ static int __init xenfb_init(void)
 	if (xen_initial_domain())
 		return -ENODEV;
 
+	if (!xen_has_pv_devices())
+		return -ENODEV;
+
 	return xenbus_register_frontend(&xenfb_driver);
 }
 
diff --git a/drivers/xen/xenbus/xenbus_probe_frontend.c b/drivers/xen/xenbus/xenbus_probe_frontend.c
index 129bf84..cb385c1 100644
--- a/drivers/xen/xenbus/xenbus_probe_frontend.c
+++ b/drivers/xen/xenbus/xenbus_probe_frontend.c
@@ -496,7 +496,7 @@ subsys_initcall(xenbus_probe_frontend_init);
 #ifndef MODULE
 static int __init boot_wait_for_devices(void)
 {
-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
+	if (!xen_has_pv_devices())
 		return -ENODEV;
 
 	ready_to_wait_for_devices = 1;
diff --git a/include/xen/platform_pci.h b/include/xen/platform_pci.h
index 438c256..87bc59c 100644
--- a/include/xen/platform_pci.h
+++ b/include/xen/platform_pci.h
@@ -47,5 +47,16 @@ static inline int xen_must_unplug_disks(void) {
 }
 
 extern int xen_platform_pci_unplug;
-
+#if defined(CONFIG_XEN_PVHVM)
+extern bool xen_has_pv_devices(void);
+#else
+static inline bool xen_has_pv_devices(void)
+{
+#if defined(CONFIG_XEN)
+	return true;
+#else
+	return false;
+#endif
+}
+#endif
 #endif /* _XEN_PLATFORM_PCI_H */
-- 
1.8.3.1
