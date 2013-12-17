From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v3 1/2] xen/pvhvm: If xen_platform_pci=0 is
 set don't blow up (v3).
Date: Tue, 17 Dec 2013 09:51:50 -0500
Message-ID: <20131217145150.GC4683@phenom.dumpdata.com>
References: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
 <1387206250-13963-2-git-send-email-konrad.wilk@oracle.com>
 <52B01F67.1030108@m2r.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: axboe@kernel.dk, stefano.stabellini@eu.citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, leosilva@linux.vnet.ibm.com,
	ashley@ashleylai.com, peterhuewe@gmx.de, mail@srajiv.net,
	tpmdd@selhorst.net, dmitry.torokhov@gmail.com, bhelgaas@google.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	tpmdd-devel@lists.sourceforge.net, linux-input@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-fbdev@vger.kernel.org
To: Fabio Fantoni <fabio.fantoni@m2r.biz>
Return-path: <linux-input-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B01F67.1030108@m2r.biz>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 10:54:47AM +0100, Fabio Fantoni wrote:
> Il 16/12/2013 16:04, Konrad Rzeszutek Wilk ha scritto:
> >The user has the option of disabling the platform driver:
> >00:02.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)
> >
> >which is used to unplug the emulated drivers (IDE, Realtek 8169, etc)
> >and allow the PV drivers to take over. If the user wishes
> >to disable that they can set:
> >
> >   xen_platform_pci=0
> >   (in the guest config file)
> >
> >or
> >   xen_emul_unplug=never
> >   (on the Linux command line)
> >
> >except it does not work properly. The PV drivers still try to
> >load and since the Xen platform driver is not run - and it
> >has not initialized the grant tables, most of the PV drivers
> >stumble upon:
> >
> >input: Xen Virtual Keyboard as /devices/virtual/input/input5
> >input: Xen Virtual Pointer as /devices/virtual/input/input6M
> >------------[ cut here ]------------
> >kernel BUG at /home/konrad/ssd/konrad/linux/drivers/xen/grant-table.c:1206!
> >invalid opcode: 0000 [#1] SMP
> >Modules linked in: xen_kbdfront(+) xenfs xen_privcmd
> >CPU: 6 PID: 1389 Comm: modprobe Not tainted 3.13.0-rc1upstream-00021-ga6c892b-dirty #1
> >Hardware name: Xen HVM domU, BIOS 4.4-unstable 11/26/2013
> >RIP: 0010:[<ffffffff813ddc40>]  [<ffffffff813ddc40>] get_free_entries+0x2e0/0x300
> >Call Trace:
> >  [<ffffffff8150d9a3>] ? evdev_connect+0x1e3/0x240
> >  [<ffffffff813ddd0e>] gnttab_grant_foreign_access+0x2e/0x70
> >  [<ffffffffa0010081>] xenkbd_connect_backend+0x41/0x290 [xen_kbdfront]
> >  [<ffffffffa0010a12>] xenkbd_probe+0x2f2/0x324 [xen_kbdfront]
> >  [<ffffffff813e5757>] xenbus_dev_probe+0x77/0x130
> >  [<ffffffff813e7217>] xenbus_frontend_dev_probe+0x47/0x50
> >  [<ffffffff8145e9a9>] driver_probe_device+0x89/0x230
> >  [<ffffffff8145ebeb>] __driver_attach+0x9b/0xa0
> >  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
> >  [<ffffffff8145eb50>] ? driver_probe_device+0x230/0x230
> >  [<ffffffff8145cf1c>] bus_for_each_dev+0x8c/0xb0
> >  [<ffffffff8145e7d9>] driver_attach+0x19/0x20
> >  [<ffffffff8145e260>] bus_add_driver+0x1a0/0x220
> >  [<ffffffff8145f1ff>] driver_register+0x5f/0xf0
> >  [<ffffffff813e55c5>] xenbus_register_driver_common+0x15/0x20
> >  [<ffffffff813e76b3>] xenbus_register_frontend+0x23/0x40
> >  [<ffffffffa0015000>] ? 0xffffffffa0014fff
> >  [<ffffffffa001502b>] xenkbd_init+0x2b/0x1000 [xen_kbdfront]
> >  [<ffffffff81002049>] do_one_initcall+0x49/0x170
> >
> >.. snip..
> >
> >which is hardly nice. This patch fixes this by having each
> >PV driver check for:
> >  - if running in PV, then it is fine to execute (as that is their
> >    native environment).
> >  - if running in HVM, check if user wanted 'xen_emul_unplug=never',
> >    in which case bail out and don't load any PV drivers.
> >  - if running in HVM, and if PCI device 5853:0001 (xen_platform_pci)
> >    does not exist, then bail out and not load PV drivers.
> >  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=disks',
> >    then bail out for all PV devices _except_ the block one.
> >    Ditto for the network one ('nics').
> >  - (v2) if running in HVM, and if the user wanted 'xen_emul_unplug=unnecessary'
> >    then load block PV driver, and also setup the legacy IDE paths.
> >    In (v3) make it actually load PV drivers.
> >
> >Reported-by: Sander Eikelenboom <linux@eikelenboom.it
> >Reported-by: Anthony PERARD <anthony.perard@citrix.com>
> >Reported-by: Fabio Fantoni <fabio.fantoni@m2r.biz>
> >Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> >[v2: Add extra logic to handle the myrid ways 'xen_emul_unplug'
> >can be used per Ian and Stefano suggestion]
> >[v3: Make the unnecessary case work properly]
> >Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
> 
> I tested this patch with all possible cases that I know, no crash or
> calltrace found.
> 
> I don't understand the utility of 'xen_emul_unplug=unnecessary' but
> probably it is working correctly, it shows both pv and not pv for
> blocks and nics.

Great!
> 
> About 'xen_emul_unplug=disks' and 'xen_emul_unplug=nics' probably
> there is something wrong.
> With 'xen_emul_unplug=nics' it shows pv nic (this should be correct)
> and about disks it shows the same disk twice, as pv and not pv (xvda
> and sda) with different device number.

Good.
> With 'xen_emul_unplug=disks' it shows pv block (this should be
> correct) and it seems to show the pv nic too (this should be wrong).

Correct. You should see only the PV disk and all other PV devices
should not function. Let me dig in this and see whether there is
another bug. Thank you!

> 
> Thanks for any reply.
> 
> >---
> >  arch/x86/xen/platform-pci-unplug.c         | 74 ++++++++++++++++++++++++++++++
> >  drivers/block/xen-blkfront.c               |  4 +-
> >  drivers/char/tpm/xen-tpmfront.c            |  4 ++
> >  drivers/input/misc/xen-kbdfront.c          |  4 ++
> >  drivers/net/xen-netfront.c                 |  2 +-
> >  drivers/pci/xen-pcifront.c                 |  4 ++
> >  drivers/video/xen-fbfront.c                |  4 ++
> >  drivers/xen/xenbus/xenbus_probe_frontend.c |  2 +-
> >  include/xen/platform_pci.h                 | 23 ++++++++++
> >  9 files changed, 117 insertions(+), 4 deletions(-)
> >
> >diff --git a/arch/x86/xen/platform-pci-unplug.c b/arch/x86/xen/platform-pci-unplug.c
> >index 0a78524..ab84ac1 100644
> >--- a/arch/x86/xen/platform-pci-unplug.c
> >+++ b/arch/x86/xen/platform-pci-unplug.c
> >@@ -69,6 +69,80 @@ static int check_platform_magic(void)
> >  	return 0;
> >  }
> >+bool xen_has_pv_devices()
> >+{
> >+	if (!xen_domain())
> >+		return false;
> >+
> >+	/* PV domains always have them. */
> >+	if (xen_pv_domain())
> >+		return true;
> >+
> >+	/* And user has xen_platform_pci=0 set in guest config as
> >+	 * driver did not modify the value. */
> >+	if (xen_platform_pci_unplug == 0)
> >+		return false;
> >+
> >+	if (xen_platform_pci_unplug & XEN_UNPLUG_NEVER)
> >+		return false;
> >+
> >+	if (xen_platform_pci_unplug & XEN_UNPLUG_ALL)
> >+		return true;
> >+
> >+	/* This is an odd one - we are going to run legacy
> >+	 * and PV drivers at the same time. */
> >+	if (xen_platform_pci_unplug & XEN_UNPLUG_UNNECESSARY)
> >+		return true;
> >+
> >+	/* And the caller has to follow with xen_pv_{disk,nic}_devices
> >+	 * to be certain which driver can load. */
> >+	return false;
> >+}
> >+EXPORT_SYMBOL_GPL(xen_has_pv_devices);
> >+
> >+static bool __xen_has_pv_device(int state)
> >+{
> >+	/* HVM domains might or might not */
> >+	if (xen_hvm_domain() && (xen_platform_pci_unplug & state))
> >+		return true;
> >+
> >+	return xen_has_pv_devices();
> >+}
> >+
> >+bool xen_has_pv_nic_devices(void)
> >+{
> >+	return __xen_has_pv_device(XEN_UNPLUG_ALL_NICS | XEN_UNPLUG_ALL);
> >+}
> >+EXPORT_SYMBOL_GPL(xen_has_pv_nic_devices);
> >+
> >+bool xen_has_pv_disk_devices(void)
> >+{
> >+	return __xen_has_pv_device(XEN_UNPLUG_ALL_IDE_DISKS |
> >+				   XEN_UNPLUG_AUX_IDE_DISKS | XEN_UNPLUG_ALL);
> >+}
> >+EXPORT_SYMBOL_GPL(xen_has_pv_disk_devices);
> >+
> >+/*
> >+ * This one is odd - it determines whether you want to run PV _and_
> >+ * legacy (IDE) drivers together. This combination is only possible
> >+ * under HVM.
> >+ */
> >+bool xen_has_pv_and_legacy_disk_devices(void)
> >+{
> >+	if (!xen_domain())
> >+		return false;
> >+
> >+	/* N.B. This is only ever used in HVM mode */
> >+	if (xen_pv_domain())
> >+		return false;
> >+
> >+	if (xen_platform_pci_unplug & XEN_UNPLUG_UNNECESSARY)
> >+		return true;
> >+
> >+	return false;
> >+}
> >+EXPORT_SYMBOL_GPL(xen_has_pv_and_legacy_disk_devices);
> >+
> >  void xen_unplug_emulated_devices(void)
> >  {
> >  	int r;
> >diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> >index a4660bb..ed88b3c 100644
> >--- a/drivers/block/xen-blkfront.c
> >+++ b/drivers/block/xen-blkfront.c
> >@@ -1278,7 +1278,7 @@ static int blkfront_probe(struct xenbus_device *dev,
> >  		char *type;
> >  		int len;
> >  		/* no unplug has been done: do not hook devices != xen vbds */
> >-		if (xen_platform_pci_unplug & XEN_UNPLUG_UNNECESSARY) {
> >+		if (xen_has_pv_and_legacy_disk_devices()) {
> >  			int major;
> >  			if (!VDEV_IS_EXTENDED(vdevice))
> >@@ -2022,7 +2022,7 @@ static int __init xlblk_init(void)
> >  	if (!xen_domain())
> >  		return -ENODEV;
> >-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
> >+	if (!xen_has_pv_disk_devices())
> >  		return -ENODEV;
> >  	if (register_blkdev(XENVBD_MAJOR, DEV_NAME)) {
> >diff --git a/drivers/char/tpm/xen-tpmfront.c b/drivers/char/tpm/xen-tpmfront.c
> >index 06189e5..9c2cbd1 100644
> >--- a/drivers/char/tpm/xen-tpmfront.c
> >+++ b/drivers/char/tpm/xen-tpmfront.c
> >@@ -16,6 +16,7 @@
> >  #include <xen/xenbus.h>
> >  #include <xen/page.h>
> >  #include "tpm.h"
> >+#include <xen/platform_pci.h>
> >  struct tpm_private {
> >  	struct tpm_chip *chip;
> >@@ -422,6 +423,9 @@ static int __init xen_tpmfront_init(void)
> >  	if (!xen_domain())
> >  		return -ENODEV;
> >+	if (!xen_has_pv_devices())
> >+		return -ENODEV;
> >+
> >  	return xenbus_register_frontend(&tpmfront_driver);
> >  }
> >  module_init(xen_tpmfront_init);
> >diff --git a/drivers/input/misc/xen-kbdfront.c b/drivers/input/misc/xen-kbdfront.c
> >index e21c181..fbfdc10 100644
> >--- a/drivers/input/misc/xen-kbdfront.c
> >+++ b/drivers/input/misc/xen-kbdfront.c
> >@@ -29,6 +29,7 @@
> >  #include <xen/interface/io/fbif.h>
> >  #include <xen/interface/io/kbdif.h>
> >  #include <xen/xenbus.h>
> >+#include <xen/platform_pci.h>
> >  struct xenkbd_info {
> >  	struct input_dev *kbd;
> >@@ -380,6 +381,9 @@ static int __init xenkbd_init(void)
> >  	if (xen_initial_domain())
> >  		return -ENODEV;
> >+	if (!xen_has_pv_devices())
> >+		return -ENODEV;
> >+
> >  	return xenbus_register_frontend(&xenkbd_driver);
> >  }
> >diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> >index 36808bf..eea2392 100644
> >--- a/drivers/net/xen-netfront.c
> >+++ b/drivers/net/xen-netfront.c
> >@@ -2106,7 +2106,7 @@ static int __init netif_init(void)
> >  	if (!xen_domain())
> >  		return -ENODEV;
> >-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
> >+	if (!xen_has_pv_nic_devices())
> >  		return -ENODEV;
> >  	pr_info("Initialising Xen virtual ethernet driver\n");
> >diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> >index f7197a7..eae7cd9 100644
> >--- a/drivers/pci/xen-pcifront.c
> >+++ b/drivers/pci/xen-pcifront.c
> >@@ -20,6 +20,7 @@
> >  #include <linux/workqueue.h>
> >  #include <linux/bitops.h>
> >  #include <linux/time.h>
> >+#include <xen/platform_pci.h>
> >  #include <asm/xen/swiotlb-xen.h>
> >  #define INVALID_GRANT_REF (0)
> >@@ -1138,6 +1139,9 @@ static int __init pcifront_init(void)
> >  	if (!xen_pv_domain() || xen_initial_domain())
> >  		return -ENODEV;
> >+	if (!xen_has_pv_devices())
> >+		return -ENODEV;
> >+
> >  	pci_frontend_registrar(1 /* enable */);
> >  	return xenbus_register_frontend(&xenpci_driver);
> >diff --git a/drivers/video/xen-fbfront.c b/drivers/video/xen-fbfront.c
> >index cd005c2..4b2d3ab 100644
> >--- a/drivers/video/xen-fbfront.c
> >+++ b/drivers/video/xen-fbfront.c
> >@@ -35,6 +35,7 @@
> >  #include <xen/interface/io/fbif.h>
> >  #include <xen/interface/io/protocols.h>
> >  #include <xen/xenbus.h>
> >+#include <xen/platform_pci.h>
> >  struct xenfb_info {
> >  	unsigned char		*fb;
> >@@ -699,6 +700,9 @@ static int __init xenfb_init(void)
> >  	if (xen_initial_domain())
> >  		return -ENODEV;
> >+	if (!xen_has_pv_devices())
> >+		return -ENODEV;
> >+
> >  	return xenbus_register_frontend(&xenfb_driver);
> >  }
> >diff --git a/drivers/xen/xenbus/xenbus_probe_frontend.c b/drivers/xen/xenbus/xenbus_probe_frontend.c
> >index 34b20bf..6244f9c 100644
> >--- a/drivers/xen/xenbus/xenbus_probe_frontend.c
> >+++ b/drivers/xen/xenbus/xenbus_probe_frontend.c
> >@@ -496,7 +496,7 @@ subsys_initcall(xenbus_probe_frontend_init);
> >  #ifndef MODULE
> >  static int __init boot_wait_for_devices(void)
> >  {
> >-	if (xen_hvm_domain() && !xen_platform_pci_unplug)
> >+	if (!xen_has_pv_devices())
> >  		return -ENODEV;
> >  	ready_to_wait_for_devices = 1;
> >diff --git a/include/xen/platform_pci.h b/include/xen/platform_pci.h
> >index 438c256..b49eeab 100644
> >--- a/include/xen/platform_pci.h
> >+++ b/include/xen/platform_pci.h
> >@@ -48,4 +48,27 @@ static inline int xen_must_unplug_disks(void) {
> >  extern int xen_platform_pci_unplug;
> >+#if defined(CONFIG_XEN_PVHVM)
> >+extern bool xen_has_pv_devices(void);
> >+extern bool xen_has_pv_disk_devices(void);
> >+extern bool xen_has_pv_nic_devices(void);
> >+extern bool xen_has_pv_and_legacy_disk_devices(void);
> >+#else
> >+static inline bool xen_has_pv_devices(void)
> >+{
> >+	return IS_ENABLED(CONFIG_XEN);
> >+}
> >+static inline bool xen_has_pv_disk_devices(void)
> >+{
> >+	return IS_ENABLED(CONFIG_XEN);
> >+}
> >+static inline bool xen_has_pv_nic_devices(void)
> >+{
> >+	return IS_ENABLED(CONFIG_XEN);
> >+}
> >+static inline bool xen_has_pv_and_legacy_disk_devices(void)
> >+{
> >+	return false;
> >+}
> >+#endif
> >  #endif /* _XEN_PLATFORM_PCI_H */
> 
