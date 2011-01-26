From: David Rientjes <rientjes@google.com>
Subject: [patch] kconfig: unify GENERIC_ISA_DMA and ISA_DMA_API
Date: Tue, 25 Jan 2011 17:06:28 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101251706040.9641@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Russell King <linux@arm.linux.org.uk>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kyle McMartin <kyle@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>, x86@kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CONFIG_GENERIC_ISA_DMA and CONFIG_ISA_DMA_API usually have dependencies
on one another depending on the architecture and generic kernel code uses
either to determine whether an ISA-style DMA API is configured.

It doesn't make sense to enable one option without enabling the other and
leads to inconsistencies in generic code, for example, where drivers
depending on CONFIG_ISA_DMA_API actually require CONFIG_GENERIC_ISA_DMA
as well for dma_lock or request_dma().  This could be resolved by
requiring both options whenever one is enabled, but then only one option
is actually required.

This patch unifies both options and consolidates them into a single
option: CONFIG_GENERIC_ISA_DMA.  It is also a prerequisite for a 1% text
savings for a future x86 patch that allows these options to be disabled
on that architecture when CONFIG_ZONE_DMA also becomes configurable.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/DMA-ISA-LPC.txt |   10 +++++-----
 arch/alpha/Kconfig            |    4 ----
 arch/arm/Kconfig              |   10 +++-------
 arch/arm/include/asm/dma.h    |    4 ++--
 arch/arm/kernel/Makefile      |    2 +-
 arch/m68knommu/Kconfig        |    2 +-
 arch/mips/Kconfig             |    4 ----
 arch/parisc/Kconfig           |    2 +-
 arch/powerpc/Kconfig          |    7 +------
 arch/x86/Kconfig              |    4 ----
 drivers/block/Kconfig         |    2 +-
 drivers/char/Kconfig          |    2 +-
 drivers/mmc/host/Kconfig      |    2 +-
 drivers/net/Kconfig           |   10 +++++-----
 drivers/net/appletalk/Kconfig |    2 +-
 drivers/net/cs89x0.c          |    2 +-
 drivers/net/hamradio/Kconfig  |    4 ++--
 drivers/net/irda/Kconfig      |   10 +++++-----
 drivers/net/tokenring/Kconfig |    2 +-
 drivers/net/wan/Kconfig       |    6 +++---
 drivers/net/wireless/Kconfig  |    2 +-
 drivers/parport/parport_pc.c  |    2 +-
 drivers/scsi/Kconfig          |   12 ++++++------
 include/sound/core.h          |    2 +-
 net/irda/irda_device.c        |    2 +-
 sound/core/Makefile           |    8 ++++----
 sound/isa/Kconfig             |    2 +-
 sound/oss/Kconfig             |    2 +-
 sound/pci/Kconfig             |    4 ++--
 29 files changed, 53 insertions(+), 74 deletions(-)

diff --git a/Documentation/DMA-ISA-LPC.txt b/Documentation/DMA-ISA-LPC.txt
--- a/Documentation/DMA-ISA-LPC.txt
+++ b/Documentation/DMA-ISA-LPC.txt
@@ -20,8 +20,8 @@ physical addresses (see Documentation/DMA-API.txt for details).
 
 The second contains the routines specific to ISA DMA transfers. Since
 this is not present on all platforms make sure you construct your
-Kconfig to be dependent on ISA_DMA_API (not ISA) so that nobody tries
-to build your driver on unsupported platforms.
+Kconfig to be dependent on GENERIC_ISA_DMA (not only ISA) so that
+nobody tries to build your driver on unsupported platforms.
 
 Part II - Buffer allocation
 ---------------------------
@@ -53,9 +53,9 @@ Part III - Address translation
 To translate the virtual address to a physical use the normal DMA
 API. Do _not_ use isa_virt_to_phys() even though it does the same
 thing. The reason for this is that the function isa_virt_to_phys()
-will require a Kconfig dependency to ISA, not just ISA_DMA_API which
-is really all you need. Remember that even though the DMA controller
-has its origins in ISA it is used elsewhere.
+will require a Kconfig dependency to ISA, not just GENERIC_ISA_DMA
+which is really all you need. Remember that even though the DMA
+controller has its origins in ISA it is used elsewhere.
 
 Note: x86_64 had a broken DMA API when it came to ISA but has since
 been fixed. If your arch has problems then fix the DMA API instead of
diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -309,10 +309,6 @@ config ISA
 	  (MCA) or VESA.  ISA is an older system, now being displaced by PCI;
 	  newer boards don't support it.  If you have ISA, say Y, otherwise N.
 
-config ISA_DMA_API
-	bool
-	default y
-
 config PCI
 	bool
 	depends on !ALPHA_JENSEN
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -388,7 +388,7 @@ config ARCH_NETX
 config ARCH_H720X
 	bool "Hynix HMS720x-based"
 	select CPU_ARM720T
-	select ISA_DMA_API
+	select GENERIC_ISA_DMA
 	select ARCH_USES_GETTIMEOFFSET
 	help
 	  This enables support for systems based on the Hynix HMS720x
@@ -644,7 +644,7 @@ config ARCH_RPC
 	select TIMER_ACORN
 	select ARCH_MAY_HAVE_PC_FDC
 	select HAVE_PATA_PLATFORM
-	select ISA_DMA_API
+	select GENERIC_ISA_DMA
 	select NO_IOPORT
 	select ARCH_SPARSEMEM_ENABLE
 	select ARCH_USES_GETTIMEOFFSET
@@ -1198,11 +1198,7 @@ config ISA
 # Select ISA DMA controller support
 config ISA_DMA
 	bool
-	select ISA_DMA_API
-
-# Select ISA DMA interface
-config ISA_DMA_API
-	bool
+	select GENERIC_ISA_DMA
 
 config PCI
 	bool "PCI support" if MIGHT_HAVE_PCI
diff --git a/arch/arm/include/asm/dma.h b/arch/arm/include/asm/dma.h
--- a/arch/arm/include/asm/dma.h
+++ b/arch/arm/include/asm/dma.h
@@ -10,7 +10,7 @@
 #define MAX_DMA_ADDRESS	0xffffffff
 #endif
 
-#ifdef CONFIG_ISA_DMA_API
+#ifdef CONFIG_GENERIC_ISA_DMA
 /*
  * This is used to support drivers written for the x86 ISA DMA API.
  * It should not be re-used except for that purpose.
@@ -138,7 +138,7 @@ extern int  get_dma_residue(unsigned int chan);
 #define NO_DMA	255
 #endif
 
-#endif /* CONFIG_ISA_DMA_API */
+#endif /* CONFIG_GENERIC_ISA_DMA */
 
 #ifdef CONFIG_PCI
 extern int isa_dma_bridge_buggy;
diff --git a/arch/arm/kernel/Makefile b/arch/arm/kernel/Makefile
--- a/arch/arm/kernel/Makefile
+++ b/arch/arm/kernel/Makefile
@@ -22,7 +22,7 @@ obj-$(CONFIG_DEPRECATED_PARAM_STRUCT) += compat.o
 obj-$(CONFIG_LEDS)		+= leds.o
 obj-$(CONFIG_OC_ETM)		+= etm.o
 
-obj-$(CONFIG_ISA_DMA_API)	+= dma.o
+obj-$(CONFIG_GENERIC_ISA_DMA)	+= dma.o
 obj-$(CONFIG_ARCH_ACORN)	+= ecard.o 
 obj-$(CONFIG_FIQ)		+= fiq.o
 obj-$(CONFIG_MODULES)		+= armksyms.o module.o
diff --git a/arch/m68knommu/Kconfig b/arch/m68knommu/Kconfig
--- a/arch/m68knommu/Kconfig
+++ b/arch/m68knommu/Kconfig
@@ -771,7 +771,7 @@ source "mm/Kconfig"
 
 endmenu
 
-config ISA_DMA_API
+config GENERIC_ISA_DMA
 	bool
 	depends on !M5272
 	default y
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -907,15 +907,11 @@ config NO_IOPORT
 config GENERIC_ISA_DMA
 	bool
 	select ZONE_DMA if GENERIC_ISA_DMA_SUPPORT_BROKEN=n
-	select ISA_DMA_API
 
 config GENERIC_ISA_DMA_SUPPORT_BROKEN
 	bool
 	select GENERIC_ISA_DMA
 
-config ISA_DMA_API
-	bool
-
 config GENERIC_GPIO
 	bool
 
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -85,7 +85,7 @@ config NEED_DMA_MAP_STATE
 config NEED_SG_DMA_LENGTH
 	def_bool y
 
-config ISA_DMA_API
+config GENERIC_ISA_DMA
 	bool
 
 config ARCH_MAY_HAVE_PC_FDC
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -601,10 +601,6 @@ config SECCOMP
 
 endmenu
 
-config ISA_DMA_API
-	bool
-	default !PPC_ISERIES || PCI
-
 menu "Bus options"
 
 config ISA
@@ -630,8 +626,7 @@ config NEED_SG_DMA_LENGTH
 
 config GENERIC_ISA_DMA
 	bool
-	depends on ISA_DMA_API
-	default y
+	default !PPC_ISERIES || PCI
 
 config PPC_INDIRECT_PCI
 	bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2000,10 +2000,6 @@ source "drivers/pci/pcie/Kconfig"
 
 source "drivers/pci/Kconfig"
 
-# x86_64 have no ISA slots, but do have ISA-style DMA.
-config ISA_DMA_API
-	def_bool y
-
 if X86_32
 
 config ISA
diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -65,7 +65,7 @@ config AMIGA_Z2RAM
 
 config BLK_DEV_XD
 	tristate "XT hard disk support"
-	depends on ISA && ISA_DMA_API
+	depends on ISA && GENERIC_ISA_DMA
 	select CHECK_SIGNATURE
 	help
 	  Very old 8 bit hard disk controllers used in the IBM XT computer
diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -236,7 +236,7 @@ config ISI
 
 config SYNCLINK
 	tristate "Microgate SyncLink card support"
-	depends on SERIAL_NONSTANDARD && PCI && ISA_DMA_API
+	depends on SERIAL_NONSTANDARD && PCI && GENERIC_ISA_DMA
 	help
 	  Provides support for the SyncLink ISA and PCI multiprotocol serial
 	  adapters. These adapters support asynchronous and HDLC bit
diff --git a/drivers/mmc/host/Kconfig b/drivers/mmc/host/Kconfig
--- a/drivers/mmc/host/Kconfig
+++ b/drivers/mmc/host/Kconfig
@@ -235,7 +235,7 @@ config MMC_OMAP_HS
 
 config MMC_WBSD
 	tristate "Winbond W83L51xD SD/MMC Card Interface support"
-	depends on ISA_DMA_API
+	depends on GENERIC_ISA_DMA
 	help
 	  This selects the Winbond(R) W83L51xD Secure digital and
           Multimedia card Interface.
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -655,7 +655,7 @@ config EL2
 
 config ELPLUS
 	tristate "3c505 \"EtherLink Plus\" support"
-	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
+	depends on NET_VENDOR_3COM && ISA && GENERIC_ISA_DMA
 	---help---
 	  Information about this network (Ethernet) card can be found in
 	  <file:Documentation/networking/3c505.txt>.  If you have a card of
@@ -693,7 +693,7 @@ config EL3
 
 config 3C515
 	tristate "3c515 ISA \"Fast EtherLink\""
-	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API
+	depends on NET_VENDOR_3COM && (ISA || EISA) && GENERIC_ISA_DMA
 	help
 	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
 	  network card, say Y and read the Ethernet-HOWTO, available from
@@ -766,7 +766,7 @@ config TYPHOON
 
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on ISA && ISA_DMA_API
+	depends on ISA && GENERIC_ISA_DMA
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -1113,7 +1113,7 @@ config NI52
 
 config NI65
 	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
+	depends on NET_VENDOR_RACAL && ISA && GENERIC_ISA_DMA
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -1306,7 +1306,7 @@ config NE2000
 
 config ZNET
 	tristate "Zenith Z-Note support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
+	depends on NET_ISA && EXPERIMENTAL && GENERIC_ISA_DMA
 	help
 	  The Zenith Z-Note notebook computer has a built-in network
 	  (Ethernet) card, and this is the Linux driver for it. Note that the
diff --git a/drivers/net/appletalk/Kconfig b/drivers/net/appletalk/Kconfig
--- a/drivers/net/appletalk/Kconfig
+++ b/drivers/net/appletalk/Kconfig
@@ -41,7 +41,7 @@ config DEV_APPLETALK
 
 config LTPC
 	tristate "Apple/Farallon LocalTalk PC support"
-	depends on DEV_APPLETALK && (ISA || EISA) && ISA_DMA_API
+	depends on DEV_APPLETALK && (ISA || EISA) && GENERIC_ISA_DMA
 	help
 	  This allows you to use the AppleTalk PC card to connect to LocalTalk
 	  networks. The card is also known as the Farallon PhoneNet PC card.
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -107,7 +107,7 @@
  * Note that even if DMA is turned off we still support the 'dma' and  'use_dma'
  * module options so we don't break any startup scripts.
  */
-#ifndef CONFIG_ISA_DMA_API
+#ifndef CONFIG_GENERIC_ISA_DMA
 #define ALLOW_DMA	0
 #else
 #define ALLOW_DMA	1
diff --git a/drivers/net/hamradio/Kconfig b/drivers/net/hamradio/Kconfig
--- a/drivers/net/hamradio/Kconfig
+++ b/drivers/net/hamradio/Kconfig
@@ -46,7 +46,7 @@ config BPQETHER
 
 config DMASCC
 	tristate "High-speed (DMA) SCC driver for AX.25"
-	depends on ISA && AX25 && BROKEN_ON_SMP && ISA_DMA_API
+	depends on ISA && AX25 && BROKEN_ON_SMP && GENERIC_ISA_DMA
 	---help---
 	  This is a driver for high-speed SCC boards, i.e. those supporting
 	  DMA on one port. You usually use those boards to connect your
@@ -79,7 +79,7 @@ config DMASCC
 
 config SCC
 	tristate "Z8530 SCC driver"
-	depends on ISA && AX25 && ISA_DMA_API
+	depends on ISA && AX25 && GENERIC_ISA_DMA
 	---help---
 	  These cards are used to connect your Linux box to an amateur radio
 	  in order to communicate with other computers. If you want to use
diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -281,7 +281,7 @@ config SIGMATEL_FIR
 
 config NSC_FIR
 	tristate "NSC PC87108/PC87338"
-	depends on IRDA && ISA_DMA_API
+	depends on IRDA && GENERIC_ISA_DMA
 	help
 	  Say Y here if you want to build support for the NSC PC87108 and
 	  PC87338 IrDA chipsets.  This driver supports SIR,
@@ -292,7 +292,7 @@ config NSC_FIR
 
 config WINBOND_FIR
 	tristate "Winbond W83977AF (IR)"
-	depends on IRDA && ISA_DMA_API
+	depends on IRDA && GENERIC_ISA_DMA
 	help
 	  Say Y here if you want to build IrDA support for the Winbond
 	  W83977AF super-io chipset.  This driver should be used for the IrDA
@@ -318,7 +318,7 @@ config AU1000_FIR
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA_DMA_API
+	depends on EXPERIMENTAL && IRDA && GENERIC_ISA_DMA
 	help
 	  Say Y here if you want to build support for the SMC Infrared
 	  Communications Controller.  It is used in a wide variety of
@@ -328,7 +328,7 @@ config SMC_IRCC_FIR
 
 config ALI_FIR
 	tristate "ALi M5123 FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA_DMA_API
+	depends on EXPERIMENTAL && IRDA && GENERIC_ISA_DMA
 	help
 	  Say Y here if you want to build support for the ALi M5123 FIR
 	  Controller.  The ALi M5123 FIR Controller is embedded in ALi M1543C,
@@ -356,7 +356,7 @@ config SA1100_FIR
 
 config VIA_FIR
 	tristate "VIA VT8231/VT1211 SIR/MIR/FIR"
-	depends on IRDA && ISA_DMA_API
+	depends on IRDA && GENERIC_ISA_DMA
 	help
 	  Say Y here if you want to build support for the VIA VT8231
 	  and VIA VT1211 IrDA controllers, found on the motherboards using
diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -84,7 +84,7 @@ config 3C359
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on PCI || ISA && ISA_DMA_API || MCA
+	depends on PCI || ISA && GENERIC_ISA_DMA || MCA
 	select FW_LOADER
 	---help---
 	  This driver provides generic support for token ring adapters
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -25,7 +25,7 @@ if WAN
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on ISA && m && ISA_DMA_API && INET && HDLC
+	depends on ISA && m && GENERIC_ISA_DMA && INET && HDLC
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -37,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on ISA && m && ISA_DMA_API && HDLC
+	depends on ISA && m && GENERIC_ISA_DMA && HDLC
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
@@ -87,7 +87,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on ISA && m && ISA_DMA_API && INET && HDLC
+	depends on ISA && m && GENERIC_ISA_DMA && INET && HDLC
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -53,7 +53,7 @@ config LIBERTAS_THINFIRM_USB
 
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
-	depends on ISA_DMA_API && (PCI || BROKEN)
+	depends on GENERIC_ISA_DMA && (PCI || BROKEN)
 	select WIRELESS_EXT
 	select CRYPTO
 	select WEXT_SPY
diff --git a/drivers/parport/parport_pc.c b/drivers/parport/parport_pc.c
--- a/drivers/parport/parport_pc.c
+++ b/drivers/parport/parport_pc.c
@@ -68,7 +68,7 @@
 
 #define PARPORT_PC_MAX_PORTS PARPORT_MAX
 
-#ifdef CONFIG_ISA_DMA_API
+#ifdef CONFIG_GENERIC_ISA_DMA
 #define HAS_DMA
 #endif
 
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -437,7 +437,7 @@ config SCSI_3W_SAS
 
 config SCSI_7000FASST
 	tristate "7000FASST SCSI support"
-	depends on ISA && SCSI && ISA_DMA_API
+	depends on ISA && SCSI && GENERIC_ISA_DMA
 	select CHECK_SIGNATURE
 	help
 	  This driver supports the Western Digital 7000 SCSI host adapter
@@ -475,7 +475,7 @@ config SCSI_AHA152X
 
 config SCSI_AHA1542
 	tristate "Adaptec AHA1542 support"
-	depends on ISA && SCSI && ISA_DMA_API
+	depends on ISA && SCSI && GENERIC_ISA_DMA
 	---help---
 	  This is support for a SCSI host adapter.  It is explained in section
 	  3.4 of the SCSI-HOWTO, available from
@@ -635,7 +635,7 @@ config SCSI_HPTIOP
 
 config SCSI_BUSLOGIC
 	tristate "BusLogic SCSI support"
-	depends on (PCI || ISA || MCA) && SCSI && ISA_DMA_API && VIRT_TO_BUS
+	depends on (PCI || ISA || MCA) && SCSI && GENERIC_ISA_DMA && VIRT_TO_BUS
 	---help---
 	  This is support for BusLogic MultiMaster and FlashPoint SCSI Host
 	  Adapters. Consult the SCSI-HOWTO, available from
@@ -722,7 +722,7 @@ config SCSI_DTC3280
 
 config SCSI_EATA
 	tristate "EATA ISA/EISA/PCI (DPT and generic EATA/DMA-compliant boards) support"
-	depends on (ISA || EISA || PCI) && SCSI && ISA_DMA_API
+	depends on (ISA || EISA || PCI) && SCSI && GENERIC_ISA_DMA
 	---help---
 	  This driver supports all EATA/DMA-compliant SCSI host adapters.  DPT
 	  ISA and all EISA I/O addresses are probed looking for the "EATA"
@@ -817,7 +817,7 @@ config SCSI_FD_MCS
 
 config SCSI_GDTH
 	tristate "Intel/ICP (former GDT SCSI Disk Array) RAID Controller support"
-	depends on (ISA || EISA || PCI) && SCSI && ISA_DMA_API
+	depends on (ISA || EISA || PCI) && SCSI && GENERIC_ISA_DMA
 	---help---
 	  Formerly called GDT SCSI Disk Array Controller Support.
 
@@ -1526,7 +1526,7 @@ config SCSI_T128
 
 config SCSI_U14_34F
 	tristate "UltraStor 14F/34F support"
-	depends on ISA && SCSI && ISA_DMA_API
+	depends on ISA && SCSI && GENERIC_ISA_DMA
 	---help---
 	  This is support for the UltraStor 14F and 34F SCSI-2 host adapters.
 	  The source at <file:drivers/scsi/u14-34f.c> contains some
diff --git a/include/sound/core.h b/include/sound/core.h
--- a/include/sound/core.h
+++ b/include/sound/core.h
@@ -311,7 +311,7 @@ int snd_device_free_all(struct snd_card *card, snd_device_cmd_t cmd);
 
 /* isadma.c */
 
-#ifdef CONFIG_ISA_DMA_API
+#ifdef CONFIG_GENERIC_ISA_DMA
 #define DMA_MODE_NO_ENABLE	0x0100
 
 void snd_dma_program(unsigned long dma, unsigned long addr, unsigned int size, unsigned short mode);
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -298,7 +298,7 @@ struct net_device *alloc_irdadev(int sizeof_priv)
 }
 EXPORT_SYMBOL(alloc_irdadev);
 
-#ifdef CONFIG_ISA_DMA_API
+#ifdef CONFIG_GENERIC_ISA_DMA
 /*
  * Function setup_dma (idev, buffer, count, mode)
  *
diff --git a/sound/core/Makefile b/sound/core/Makefile
--- a/sound/core/Makefile
+++ b/sound/core/Makefile
@@ -4,10 +4,10 @@
 #
 
 snd-y     := sound.o init.o memory.o info.o control.o misc.o device.o
-snd-$(CONFIG_ISA_DMA_API) += isadma.o
-snd-$(CONFIG_SND_OSSEMUL) += sound_oss.o info_oss.o
-snd-$(CONFIG_SND_VMASTER) += vmaster.o
-snd-$(CONFIG_SND_JACK)	  += jack.o
+snd-$(CONFIG_GENERIC_ISA_DMA)	+= isadma.o
+snd-$(CONFIG_SND_OSSEMUL)	+= sound_oss.o info_oss.o
+snd-$(CONFIG_SND_VMASTER)	+= vmaster.o
+snd-$(CONFIG_SND_JACK)		+= jack.o
 
 snd-pcm-objs := pcm.o pcm_native.o pcm_lib.o pcm_timer.o pcm_misc.o \
 		pcm_memory.o
diff --git a/sound/isa/Kconfig b/sound/isa/Kconfig
--- a/sound/isa/Kconfig
+++ b/sound/isa/Kconfig
@@ -19,7 +19,7 @@ config SND_SB16_DSP
 
 menuconfig SND_ISA
 	bool "ISA sound devices"
-	depends on ISA && ISA_DMA_API
+	depends on ISA && GENERIC_ISA_DMA
 	default y
 	help
 	  Support for sound devices connected via the ISA bus.
diff --git a/sound/oss/Kconfig b/sound/oss/Kconfig
--- a/sound/oss/Kconfig
+++ b/sound/oss/Kconfig
@@ -253,7 +253,7 @@ config MSND_FIFOSIZE
 
 menuconfig SOUND_OSS
 	tristate "OSS sound modules"
-	depends on ISA_DMA_API && VIRT_TO_BUS
+	depends on GENERIC_ISA_DMA && VIRT_TO_BUS
 	help
 	  OSS is the Open Sound System suite of sound card drivers.  They make
 	  sound programming easier since they provide a common API.  Say Y or
diff --git a/sound/pci/Kconfig b/sound/pci/Kconfig
--- a/sound/pci/Kconfig
+++ b/sound/pci/Kconfig
@@ -33,7 +33,7 @@ config SND_ALS300
 
 config SND_ALS4000
 	tristate "Avance Logic ALS4000"
-	depends on ISA_DMA_API
+	depends on GENERIC_ISA_DMA
 	select SND_OPL3_LIB
 	select SND_MPU401_UART
 	select SND_PCM
@@ -266,7 +266,7 @@ config SND_CS46XX_NEW_DSP
 
 config SND_CS5530
 	tristate "CS5530 Audio"
-	depends on ISA_DMA_API
+	depends on GENERIC_ISA_DMA
 	select SND_SB16_DSP
 	help
 	  Say Y here to include support for audio on Cyrix/NatSemi CS5530 chips.
