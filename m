From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [REGRESSION] [PATCH] ssd: fix NULL ptr deref when pcihost_wrapper
	is used
Date: Tue, 25 May 2010 18:37:33 +0200
Message-ID: <1274805453.3663.12.camel@lovely>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	=?iso-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

 with the attached patch my b44 ethernet works again.


Thanks,
 Christoph

---
Ethernet driver b44 does register ssb by it's pcihost_wrapper
and doesn't set ssb_chipcommon. A check on this value
introduced with commit d53cdbb94a52a920d5420ed64d986c3523a56743
and ea2db495f92ad2cf3301623e60cb95b4062bc484 triggers:

BUG: unable to handle kernel NULL pointer dereference at 00000010
IP: [<c1266c36>] ssb_is_sprom_available+0x16/0x30

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/ssb/pci.c   |    9 ++++++---
 drivers/ssb/sprom.c |    1 +
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index 989e275..6dcda86 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -625,9 +625,12 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus,
 		ssb_printk(KERN_ERR PFX "No SPROM available!\n");
 		return -ENODEV;
 	}
-
-	bus->sprom_offset = (bus->chipco.dev->id.revision < 31) ?
-		SSB_SPROM_BASE1 : SSB_SPROM_BASE31;
+	if (bus->chipco.dev) {	/* can be unavailible! */
+		bus->sprom_offset = (bus->chipco.dev->id.revision < 31) ?
+			SSB_SPROM_BASE1 : SSB_SPROM_BASE31;
+	} else {
+		bus->sprom_offset = SSB_SPROM_BASE1;
+	}
 
 	buf = kcalloc(SSB_SPROMSIZE_WORDS_R123, sizeof(u16), GFP_KERNEL);
 	if (!buf)
diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
index 007bc3a..4f7cc8d 100644
--- a/drivers/ssb/sprom.c
+++ b/drivers/ssb/sprom.c
@@ -185,6 +185,7 @@ bool ssb_is_sprom_available(struct ssb_bus *bus)
 	/* this routine differs from specs as we do not access SPROM directly
 	   on PCMCIA */
 	if (bus->bustype == SSB_BUSTYPE_PCI &&
+	    bus->chipco.dev &&	/* can be unavailible! */
 	    bus->chipco.dev->id.revision >= 31)
 		return bus->chipco.capabilities & SSB_CHIPCO_CAP_SPROM;
 
-- 
1.5.6.5
---
b44 0000:02:0e.0: PCI INT A -> Link[C0D8] -> GSI 11 (level, low) -> IRQ 11
ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x07, vendor 0x4243)
ssb: Core 1 found: V90 (cc 0x807, rev 0x03, vendor 0x4243)
ssb: Core 2 found: PCI (cc 0x804, rev 0x0A, vendor 0x4243)
BUG: unable to handle kernel NULL pointer dereference at 00000010
IP: [<c1266c36>] ssb_is_sprom_available+0x16/0x30
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
last sysfs file: /sys/devices/pnp0/00:04/id
Modules linked in: video backlight b44(+) mii yenta_socket sg sr_mod cdrom

Pid: 2013, comm: modprobe Not tainted 2.6.34d #1 3088/HP Compaq nx6110 (EK201ET#ABD)
EIP: 0060:[<c1266c36>] EFLAGS: 00010246 CPU: 0
EIP is at ssb_is_sprom_available+0x16/0x30
EAX: 00000000 EBX: de4de000 ECX: 00000000 EDX: de4de000
ESI: de5bbdd0 EDI: de5bbdd0 EBP: de4de000 ESP: de5bbda8
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process modprobe (pid: 2013, ti=de5ba000 task=df05e700 task.ti=de5ba000)
Stack:
 c12675e0 00000000 de4de000 c12651cb de4de000 de5bbdd0 00000000 de4de2dc
<0> c1265eb3 c12675d0 00000000 00000000 00000000 00000000 00000000 00000000
<0> 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
Call Trace:
 [<c12675e0>] ? ssb_pci_get_invariants+0x10/0x530
 [<c12651cb>] ? ssb_bus_powerup+0x3b/0x60
 [<c1265eb3>] ? ssb_bus_register+0x163/0x240
 [<c12675d0>] ? ssb_pci_get_invariants+0x0/0x530
 [<c1266004>] ? ssb_bus_pcibus_register+0x24/0x70
 [<c1268220>] ? ssb_pcihost_probe+0x90/0xe0
 [<c1166e0b>] ? local_pci_probe+0xb/0x10
 [<c1167d19>] ? pci_device_probe+0x69/0x90
 [<c11e5dec>] ? driver_probe_device+0x7c/0x1b0
 [<c11e5fa1>] ? __driver_attach+0x81/0x90
 [<c11e5674>] ? bus_for_each_dev+0x54/0x80
 [<c11e5c76>] ? driver_attach+0x16/0x20
 [<c11e5f20>] ? __driver_attach+0x0/0x90
 [<c11e4e67>] ? bus_add_driver+0xb7/0x280
 [<c1166e10>] ? pci_device_shutdown+0x0/0x20
 [<c1167c50>] ? pci_device_remove+0x0/0x40
 [<c11e6227>] ? driver_register+0x67/0x150
 [<c1167f66>] ? __pci_register_driver+0x36/0xa0
 [<e00e1000>] ? b44_init+0x0/0x56 [b44]
 [<e00e102b>] ? b44_init+0x2b/0x56 [b44]
 [<e00e1000>] ? b44_init+0x0/0x56 [b44]
 [<c100111e>] ? do_one_initcall+0x2e/0x190
 [<c104fbc2>] ? sys_init_module+0xb2/0x210
 [<c107f2ac>] ? sys_mmap_pgoff+0xfc/0x110
 [<c1328749>] ? syscall_call+0x7/0xb
Code: 90 90 90 90 90 a1 04 68 4b c1 c3 8d 76 00 8d bc 27 00 00 00 00 83 78 10 01 89 c2 74 08 b0 01 c3 90 8d 74 26 00 8b 80 3c 02 00 00 <80> 78 10 1e 76 ec 8b 82 40 02 00 00 c1 e8 1e 24 01 c3 90 8d b4 
EIP: [<c1266c36>] ssb_is_sprom_available+0x16/0x30 SS:ESP 0068:de5bbda8
CR2: 0000000000000010
---[ end trace c237bc4aec4c0537 ]---
