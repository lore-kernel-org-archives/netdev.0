From: David Howells <dhowells@redhat.com>
Subject: [PATCH 36/43] MN10300: ASB2364: Add support for SMSC911X and SMC911X
Date: Tue, 26 Oct 2010 03:56:14 +0100
Message-ID: <20101026025614.23512.28225.stgit@warthog.procyon.org.uk>
References: <20101026025301.23512.24525.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Akira Takeuchi <takeuchi.akr@jp.panasonic.com>,
	Kiyoshi Owada <owada.kiyoshi@jp.panasonic.com>
To: linux-am33-list@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101026025301.23512.24525.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>

Add support for SMSC911X and SMC911X for the ASB2364 unit.

Signed-off-by: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
Signed-off-by: Kiyoshi Owada <owada.kiyoshi@jp.panasonic.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: steve.glendinning@smsc.com
cc: netdev@vger.kernel.org
---

 arch/mn10300/Kconfig                              |    1 
 arch/mn10300/include/asm/smsc911x.h               |    1 
 arch/mn10300/unit-asb2364/Makefile                |    2 
 arch/mn10300/unit-asb2364/include/unit/smsc911x.h |  198 +++++++++++++++++++++
 arch/mn10300/unit-asb2364/smsc911x.c              |   58 ++++++
 drivers/net/Kconfig                               |   12 +
 drivers/net/smsc911x.c                            |    7 +
 drivers/net/smsc911x.h                            |   17 ++
 8 files changed, 292 insertions(+), 4 deletions(-)
 create mode 100644 arch/mn10300/include/asm/smsc911x.h
 create mode 100644 arch/mn10300/unit-asb2364/include/unit/smsc911x.h
 create mode 100644 arch/mn10300/unit-asb2364/smsc911x.c


diff --git a/arch/mn10300/Kconfig b/arch/mn10300/Kconfig
index 81e2781..88901a2 100644
--- a/arch/mn10300/Kconfig
+++ b/arch/mn10300/Kconfig
@@ -96,6 +96,7 @@ config MN10300_UNIT_ASB2305
 
 config MN10300_UNIT_ASB2364
 	bool "ASB2364"
+	select SMSC911X_ARCH_HOOKS if SMSC911X
 
 endchoice
 
diff --git a/arch/mn10300/include/asm/smsc911x.h b/arch/mn10300/include/asm/smsc911x.h
new file mode 100644
index 0000000..2fcd108
--- /dev/null
+++ b/arch/mn10300/include/asm/smsc911x.h
@@ -0,0 +1 @@
+#include <unit/smsc911x.h>
diff --git a/arch/mn10300/unit-asb2364/Makefile b/arch/mn10300/unit-asb2364/Makefile
index 6dd27d6..2fdd99b 100644
--- a/arch/mn10300/unit-asb2364/Makefile
+++ b/arch/mn10300/unit-asb2364/Makefile
@@ -7,4 +7,4 @@
 #
 # Note 2! The CFLAGS definitions are now in the main makefile...
 
-obj-y   := unit-init.o leds.o
+obj-y   := unit-init.o leds.o smsc911x.o
diff --git a/arch/mn10300/unit-asb2364/include/unit/smsc911x.h b/arch/mn10300/unit-asb2364/include/unit/smsc911x.h
new file mode 100644
index 0000000..1d3bcdf
--- /dev/null
+++ b/arch/mn10300/unit-asb2364/include/unit/smsc911x.h
@@ -0,0 +1,198 @@
+/* Support for the SMSC911x NIC
+ *
+ * Copyright (C) 2006 Matsushita Electric Industrial Co., Ltd.
+ * All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#ifndef _ASM_UNIT_SMSC911X_H
+#define _ASM_UNIT_SMSC911X_H
+
+#include <linux/netdevice.h>
+#include <proc/irq.h>
+#include <unit/fpga-regs.h>
+
+#define MN10300_USE_EXT_EEPROM
+
+
+#define SMSC911X_BASE		0xA8000000UL
+#define SMSC911X_BASE_END	0xA8000100UL
+#define SMSC911X_IRQ		XIRQ1
+
+/*
+ * Control the FPGA PIC control regs for the SMSC911x chipset
+ */
+#undef SMSC_INITIALIZE
+#undef SMSC_CHECK_INTERRUPT
+#undef SMSC_CLEAR_INTERRUPT
+#undef SMSC_SET_INTERRUPT_MASK
+#undef SMSC_CLEAR_INTERRUPT_MASK
+
+#define SMSC_INITIALIZE()					\
+do {								\
+	/* release reset */					\
+	ASB2364_FPGA_REG_RESET_LAN = 0x0001;			\
+	SyncExBus();						\
+} while (0)
+
+#define SMSC_CHECK_INTERRUPT()					\
+do {								\
+	if ((ASB2364_FPGA_REG_IRQ_LAN & 0x0001) == 0x0001)	\
+		return IRQ_NONE;				\
+} while (0)
+
+#define SMSC_CLEAR_INTERRUPT()					\
+do {								\
+	ASB2364_FPGA_REG_IRQ_LAN = 0x0001;			\
+	SyncExBus();						\
+} while (0)
+
+#define SMSC_SET_INTERRUPT_MASK()				\
+do {								\
+	ASB2364_FPGA_REG_MASK_LAN = 0x0001;			\
+	SyncExBus();						\
+} while (0)
+
+#define SMSC_CLEAR_INTERRUPT_MASK()				\
+do {								\
+	ASB2364_FPGA_REG_MASK_LAN = 0x0000;			\
+	SyncExBus();						\
+} while (0)
+
+
+#ifdef MN10300_USE_EXT_EEPROM
+#include <linux/delay.h>
+#include <unit/clock.h>
+
+#define EEPROM_ADDRESS	0xA0
+#define MAC_OFFSET	0x0008
+#define USE_IIC_CH	0	/* 0 or 1 */
+#define IIC_OFFSET	(0x80000 * USE_IIC_CH)
+#define IIC_DTRM	__SYSREG(0xd8400000 + IIC_OFFSET, u32)
+#define IIC_DREC	__SYSREG(0xd8400004 + IIC_OFFSET, u32)
+#define IIC_MYADD	__SYSREG(0xd8400008 + IIC_OFFSET, u32)
+#define IIC_CLK		__SYSREG(0xd840000c + IIC_OFFSET, u32)
+#define IIC_BRST	__SYSREG(0xd8400010 + IIC_OFFSET, u32)
+#define IIC_HOLD	__SYSREG(0xd8400014 + IIC_OFFSET, u32)
+#define IIC_BSTS	__SYSREG(0xd8400018 + IIC_OFFSET, u32)
+#define IIC_ICR		__SYSREG(0xd4000080 + 4 * USE_IIC_CH, u16)
+
+#define IIC_CLK_PLS	((unsigned short)(MN10300_IOCLK / 100000 - 1))
+#define IIC_CLK_LOW	((unsigned short)(IIC_CLK_PLS / 2))
+
+#define SYS_IIC_DTRM_Bit_STA	((unsigned short)0x0400)
+#define SYS_IIC_DTRM_Bit_STO	((unsigned short)0x0200)
+#define SYS_IIC_DTRM_Bit_ACK	((unsigned short)0x0100)
+#define SYS_IIC_DTRM_Bit_DATA	((unsigned short)0x00FF)
+
+static inline void POLL_INT_REQ(volatile u16 *icr)
+{
+	unsigned long flags;
+	u16 tmp;
+
+	while (!(*icr & GxICR_REQUEST))
+		;
+	flags = arch_local_cli_save();
+	tmp = *icr;
+	*icr = (tmp & GxICR_LEVEL) | GxICR_DETECT;
+	tmp = *icr;
+	arch_local_irq_restore(flags);
+}
+
+#undef smsc_get_mac
+static inline int smsc_get_mac(struct net_device *dev)
+{
+	unsigned char *mac_buf = dev->dev_addr;
+	int i;
+	unsigned short value;
+	unsigned int data;
+	int mac_length = 6;
+	int check;
+	u16 orig_gicr, tmp;
+	unsigned long flags;
+
+	/* save original GnICR and clear GnICR.IE */
+	flags = arch_local_cli_save();
+	orig_gicr = IIC_ICR;
+	IIC_ICR = orig_gicr & GxICR_LEVEL;
+	tmp = IIC_ICR;
+	arch_local_irq_restore(flags);
+
+	IIC_MYADD = 0x00000008;
+	IIC_CLK = (IIC_CLK_LOW << 16) + (IIC_CLK_PLS);
+	/* bus hung recovery */
+
+	while (1) {
+		check = 0;
+		for (i = 0; i < 3; i++) {
+			if ((IIC_BSTS & 0x00000003) == 0x00000003)
+				check++;
+			udelay(3);
+		}
+
+		if (check == 3) {
+			IIC_BRST = 0x00000003;
+			break;
+		} else {
+			for (i = 0; i < 3; i++) {
+				IIC_BRST = 0x00000002;
+				udelay(8);
+				IIC_BRST = 0x00000003;
+				udelay(8);
+			}
+		}
+	}
+
+	IIC_BRST = 0x00000002;
+	IIC_BRST = 0x00000003;
+
+	value	=  SYS_IIC_DTRM_Bit_STA | SYS_IIC_DTRM_Bit_ACK;
+	value	|= (((unsigned short)EEPROM_ADDRESS & SYS_IIC_DTRM_Bit_DATA) |
+		    (unsigned short)0x0000);
+	IIC_DTRM = value;
+	POLL_INT_REQ(&IIC_ICR);
+
+	/** send offset of MAC address in EEPROM **/
+	IIC_DTRM = (unsigned char)((MAC_OFFSET & 0xFF00) >> 8);
+	POLL_INT_REQ(&IIC_ICR);
+
+	IIC_DTRM = (unsigned char)(MAC_OFFSET & 0x00FF);
+	POLL_INT_REQ(&IIC_ICR);
+
+	udelay(1000);
+
+	value	=  SYS_IIC_DTRM_Bit_STA;
+	value	|= (((unsigned short)EEPROM_ADDRESS & SYS_IIC_DTRM_Bit_DATA) |
+		    (unsigned short)0x0001);
+	IIC_DTRM = value;
+	POLL_INT_REQ(&IIC_ICR);
+
+	IIC_DTRM = 0x00000000;
+	while (mac_length > 0) {
+		POLL_INT_REQ(&IIC_ICR);
+
+		data = IIC_DREC;
+		mac_length--;
+		if (mac_length == 0)
+			value = 0x00000300;	/* stop IIC bus */
+		else if (mac_length == 1)
+			value = 0x00000100;	/* no ack */
+		else
+			value = 0x00000000;	/* ack */
+		IIC_DTRM = value;
+		*mac_buf++ = (unsigned char)(data & 0xff);
+	}
+
+	/* restore GnICR.LV and GnICR.IE */
+	flags = arch_local_cli_save();
+	IIC_ICR = (orig_gicr & (GxICR_LEVEL | GxICR_ENABLE));
+	tmp = IIC_ICR;
+	arch_local_irq_restore(flags);
+
+	return 0;
+}
+#endif /* MN10300_USE_EXT_EEPROM */
+#endif /* _ASM_UNIT_SMSC911X_H */
diff --git a/arch/mn10300/unit-asb2364/smsc911x.c b/arch/mn10300/unit-asb2364/smsc911x.c
new file mode 100644
index 0000000..544a73e
--- /dev/null
+++ b/arch/mn10300/unit-asb2364/smsc911x.c
@@ -0,0 +1,58 @@
+/* Specification for the SMSC911x NIC
+ *
+ * Copyright (C) 2006 Matsushita Electric Industrial Co., Ltd.
+ * All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/smsc911x.h>
+#include <unit/smsc911x.h>
+
+static struct smsc911x_platform_config smsc911x_config = {
+	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags		= SMSC911X_USE_32BIT,
+};
+
+static struct resource smsc911x_resources[] = {
+	[0] = {
+		.start	= SMSC911X_BASE,
+		.end	= SMSC911X_BASE_END,
+		.flags	= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start	= SMSC911X_IRQ,
+		.end	= SMSC911X_IRQ,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device smsc911x_device = {
+	.name		= "smsc911x",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(smsc911x_resources),
+	.resource	= smsc911x_resources,
+	.dev		= {
+		.platform_data = &smsc911x_config,
+	}
+};
+
+/*
+ * add platform devices
+ */
+static int __init unit_device_init(void)
+{
+	platform_device_register(&smsc911x_device);
+	return 0;
+}
+
+device_initcall(unit_device_init);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 86fe67f..9334539 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1041,7 +1041,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARM || SUPERH
+	depends on ARM || SUPERH || MN10300
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
@@ -1055,7 +1055,7 @@ config SMC911X
 
 config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH || BLACKFIN || MIPS
+	depends on ARM || SUPERH || BLACKFIN || MIPS || MN10300
 	select CRC32
 	select MII
 	select PHYLIB
@@ -1067,6 +1067,14 @@ config SMSC911X
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called smsc911x.
 
+config SMSC911X_ARCH_HOOKS
+	def_bool n
+	depends on SMSC911X
+	help
+	  If the arch enables this, it allows the arch to implement various
+	  hooks for more comprehensive interrupt control and also to override
+	  the source of the MAC address.
+
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
 	depends on ISA
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index a8e5856..54b55c1 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1456,6 +1456,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	int serviced = IRQ_NONE;
 	u32 temp;
 
+	SMSC_CHECK_INTERRUPT();
 	if (unlikely(intsts & inten & INT_STS_SW_INT_)) {
 		temp = smsc911x_reg_read(pdata, INT_EN);
 		temp &= (~INT_EN_SW_INT_EN_);
@@ -1506,6 +1507,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 		serviced = IRQ_HANDLED;
 	}
 
+	SMSC_CLEAR_INTERRUPT();
 	return serviced;
 }
 
@@ -1931,6 +1933,7 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(dev);
+	SMSC_SET_INTERRUPT_MASK();
 	free_irq(dev->irq, dev);
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
@@ -2042,6 +2045,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 			"Unable to claim requested irq: %d", dev->irq);
 		goto out_unmap_io_3;
 	}
+	SMSC_CLEAR_INTERRUPT_MASK();
 
 	platform_set_drvdata(pdev, dev);
 
@@ -2075,7 +2079,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
 		 * it will already have been set */
-		smsc911x_read_mac_address(dev);
+		smsc_get_mac(dev);
 
 		if (is_valid_ether_addr(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
@@ -2176,6 +2180,7 @@ static struct platform_driver smsc911x_driver = {
 /* Entry point for loading the module */
 static int __init smsc911x_init_module(void)
 {
+	SMSC_INITIALIZE();
 	return platform_driver_register(&smsc911x_driver);
 }
 
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index 016360c..14a7087 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -394,4 +394,21 @@
 #define LPA_PAUSE_ALL			(LPA_PAUSE_CAP | \
 					 LPA_PAUSE_ASYM)
 
+/*
+ * Provide hooks to let the arch implement more comprehensive interrupt control
+ * and to override the source of the MAC address.
+ */
+#define SMSC_INITIALIZE()		do {} while (0)
+#define SMSC_CHECK_INTERRUPT()		do {} while (0)
+#define SMSC_CLEAR_INTERRUPT()		do {} while (0)
+#define SMSC_SET_INTERRUPT_MASK()	do {} while (0)
+#define SMSC_CLEAR_INTERRUPT_MASK()	do {} while (0)
+#define smsc_get_mac(dev)		smsc911x_read_mac_address((dev))
+
+#ifdef CONFIG_SMSC911X_ARCH_HOOKS
+#include <asm/smsc911x.h>
+#endif
+
+
+
 #endif				/* __SMSC911X_H__ */
