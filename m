From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] IrDA: smcinit merged into smsc-ircc driver
Date: Thu, 6 Apr 2006 02:21:25 +0300
Message-ID: <20060405232125.GA377@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

Hi David,

This patch integrates the smcinit code into the smsc-ircc driver.
Some laptops have their smsc-ircc chip not properly configured by the BIOS and needs some preconfiguration. Currently, this can be done from userspace with smcinit, a utility that comes with the irda-utils package. It messes with ioports and PCI settings, from userspace.
Now with this patch, if we happen to be on one of the known to be faulty laptops, we preconfigure the chip from the driver.

Patch from Linus Walleij <triad-HEm3bjczhZmzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index ec94ecd..f6d98b4 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -11,6 +11,7 @@
  *     Copyright (c) 2002      Daniele Peri
  *     All Rights Reserved.
  *     Copyright (c) 2002      Jean Tourrilhes
+ *     Copyright (c) 2006      Linus Walleij
  *
  *
  * Based on smc-ircc.c:
@@ -61,6 +62,9 @@
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
+#ifdef CONFIG_PCI
+#include <linux/pci.h>
+#endif
 
 #include <net/irda/wrapper.h>
 #include <net/irda/irda.h>
@@ -100,6 +104,22 @@ MODULE_PARM_DESC(ircc_transceiver, "Tran
 
 /* Types */
 
+#ifdef CONFIG_PCI
+struct smsc_ircc_subsystem_configuration {
+	unsigned short vendor; /* PCI vendor ID */
+	unsigned short device; /* PCI vendor ID */
+	unsigned short subvendor; /* PCI subsystem vendor ID */
+	unsigned short subdevice; /* PCI sybsystem device ID */
+	unsigned short sir_io; /* I/O port for SIR */
+	unsigned short fir_io; /* I/O port for FIR */
+	unsigned char  fir_irq; /* FIR IRQ */
+	unsigned char  fir_dma; /* FIR DMA */
+	unsigned short cfg_base; /* I/O port for chip configuration */
+	int (*preconfigure)(struct pci_dev *dev, struct smsc_ircc_subsystem_configuration *conf); /* Preconfig function */
+	const char *name;	/* name shown as info */
+};
+#endif
+
 struct smsc_transceiver {
 	char *name;
 	void (*set_for_speed)(int fir_base, u32 speed);
@@ -202,6 +222,16 @@ static int __init smsc_superio_flat(cons
 static int __init smsc_superio_paged(const struct smsc_chip *chips, unsigned short cfg_base, char *type);
 static int __init smsc_superio_fdc(unsigned short cfg_base);
 static int __init smsc_superio_lpc(unsigned short cfg_base);
+#ifdef CONFIG_PCI
+static int __init preconfigure_smsc_chip(struct smsc_ircc_subsystem_configuration *conf);
+static int __init preconfigure_through_82801(struct pci_dev *dev, struct smsc_ircc_subsystem_configuration *conf);
+static int __init preconfigure_through_ali(struct pci_dev *dev, struct smsc_ircc_subsystem_configuration *conf);
+static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg, 
+						    unsigned short ircc_fir, 
+						    unsigned short ircc_sir, 
+						    unsigned char ircc_dma, 
+						    unsigned char ircc_irq);
+#endif
 
 /* Transceivers specific functions */
 
@@ -353,6 +383,13 @@ static int __init smsc_ircc_init(void)
 		return ret;
 	}
 
+#ifdef CONFIG_PCI
+	if (smsc_ircc_preconfigure_subsystems(ircc_cfg, ircc_fir, ircc_sir, ircc_dma, ircc_irq) < 0) {
+		/* Ignore errors from preconfiguration */
+		IRDA_ERROR("%s, Preconfiguration failed !\n", driver_name);
+	}
+#endif
+
 	dev_count = 0;
 
 	if (ircc_fir > 0 && ircc_sir > 0) {
@@ -2285,6 +2322,280 @@ static int __init smsc_superio_lpc(unsig
 	return ret;
 }
 
+/*
+ * Look for some specific subsystem setups that need 
+ * pre-configuration not properly done by the BIOS (especially laptops)
+ * This code is based in part on smcinit.c, tosh1800-smcinit.c
+ * and tosh2450-smcinit.c. The table lists the device entries
+ * for ISA bridges with an LPC (Local Peripheral Configurator)
+ * that are in turn used to configure the SMSC device with default 
+ * SIR and FIR I/O ports, DMA and IRQ.
+ */
+#ifdef CONFIG_PCI
+#define PCIID_VENDOR_INTEL 0x8086
+#define PCIID_VENDOR_ALI 0x10b9
+static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __devinitdata = {
+	{
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.device = 0x24cc,
+		.subvendor = 0x103c,
+		.subdevice = 0x088c,
+		.sir_io = 0x02f8, /* Quite certain these are the same for nc8000 as for nc6000 */
+		.fir_io = 0x0130,
+		.fir_irq = 0x09,
+		.fir_dma = 0x03,
+		.cfg_base = 0x004e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "HP nc8000",
+	},
+	{
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.device = 0x24cc,
+		.subvendor = 0x103c,
+		.subdevice = 0x0890,
+		.sir_io = 0x02f8,
+		.fir_io = 0x0130,
+		.fir_irq = 0x09,
+		.fir_dma = 0x03,
+		.cfg_base = 0x004e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "HP nc6000",
+	},
+	{
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge */
+		.device = 0x24c0,
+		.subvendor = 0x1179,
+		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.sir_io = 0x03f8,
+		.fir_io = 0x0130,
+		.fir_irq = 0x07,
+		.fir_dma = 0x01,
+		.cfg_base = 0x002e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "Toshiba Satellite 2450",
+	},
+	{
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801CAM ISA bridge */
+		.device = 0x248c, /* Some use 24cc? */
+		.subvendor = 0x1179,
+		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.sir_io = 0x03f8,
+		.fir_io = 0x0130,
+		.fir_irq = 0x03,
+		.fir_dma = 0x03,
+		.cfg_base = 0x002e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "Toshiba Satellite 5100/5200, Tecra 9100",
+	},
+	{
+		.vendor = PCIID_VENDOR_ALI, /* ALi M1533/M1535 PCI to ISA Bridge [Aladdin IV/V/V+] */
+		.device = 0x1533,
+		.subvendor = 0x1179,
+		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.sir_io = 0x02e8,
+		.fir_io = 0x02f8,
+		.fir_irq = 0x07,
+		.fir_dma = 0x03,
+		.cfg_base = 0x002e,
+		.preconfigure = preconfigure_through_ali,
+		.name = "Toshiba Satellite 1800",
+	},
+	{ } // Terminator
+};
+
+
+/*
+ * This sets up the basic SMSC parameters (FIR port, SIR port, FIR DMA, FIR IRQ)
+ * through the chip configuration port.
+ */
+static int __init preconfigure_smsc_chip(struct smsc_ircc_subsystem_configuration *conf)
+{
+	unsigned short iobase = conf->cfg_base;
+	unsigned char tmpbyte;
+
+	outb(LPC47N227_CFGACCESSKEY, iobase); // enter configuration state
+	outb(SMSCSIOFLAT_DEVICEID_REG, iobase); // set for device ID
+	tmpbyte = inb(iobase +1); // Read device ID
+	IRDA_DEBUG(0, "Detected Chip id: 0x%02x, setting up registers...\n",tmpbyte);
+	
+	/* Disable UART1 and set up SIR I/O port */
+	outb(0x24, iobase);  // select CR24 - UART1 base addr
+	outb(0x00, iobase + 1); // disable UART1
+	outb(SMSCSIOFLAT_UART2BASEADDR_REG, iobase);  // select CR25 - UART2 base addr
+	outb( (conf->sir_io >> 2), iobase + 1); // bits 2-9 of 0x3f8
+	tmpbyte = inb(iobase + 1);
+	if (tmpbyte != (conf->sir_io >> 2) ) {
+		IRDA_WARNING("ERROR: could not configure SIR ioport.\n");
+		return -ENXIO;
+	}
+	
+	/* Set up FIR IRQ channel for UART2 */
+	outb(SMSCSIOFLAT_UARTIRQSELECT_REG, iobase); // select CR28 - UART1,2 IRQ select
+	tmpbyte = inb(iobase + 1);
+	tmpbyte &= SMSCSIOFLAT_UART1IRQSELECT_MASK; // Do not touch the UART1 portion
+	tmpbyte |= (conf->fir_irq & SMSCSIOFLAT_UART2IRQSELECT_MASK);
+	outb(tmpbyte, iobase + 1);
+	tmpbyte = inb(iobase + 1) & SMSCSIOFLAT_UART2IRQSELECT_MASK;
+	if (tmpbyte != conf->fir_irq) {
+		IRDA_WARNING("ERROR: could not configure FIR IRQ channel.\n");
+		return -ENXIO;
+	}
+	
+	/* Set up FIR I/O port */
+	outb(SMSCSIOFLAT_FIRBASEADDR_REG, iobase);  // CR2B - SCE (FIR) base addr
+	outb((conf->fir_io >> 3), iobase + 1);
+	tmpbyte = inb(iobase + 1);
+	if (tmpbyte != (conf->fir_io >> 3) ) {
+		IRDA_WARNING("ERROR: could not configure FIR I/O port.\n");
+		return -ENXIO;
+	}
+
+	/* Set up FIR DMA channel */
+	outb(SMSCSIOFLAT_FIRDMASELECT_REG, iobase);  // CR2C - SCE (FIR) DMA select
+	outb((conf->fir_dma & LPC47N227_FIRDMASELECT_MASK), iobase + 1); // DMA
+	tmpbyte = inb(iobase + 1) & LPC47N227_FIRDMASELECT_MASK;
+	if (tmpbyte != (conf->fir_dma & LPC47N227_FIRDMASELECT_MASK)) {
+		IRDA_WARNING("ERROR: could not configure FIR DMA channel.\n");
+		return -ENXIO;
+	}
+	
+	outb(SMSCSIOFLAT_UARTMODE0C_REG, iobase);  // CR0C - UART mode
+	tmpbyte = inb(iobase + 1);
+	tmpbyte &= ~SMSCSIOFLAT_UART2MODE_MASK | SMSCSIOFLAT_UART2MODE_VAL_IRDA;
+	outb(tmpbyte, iobase + 1); // enable IrDA (HPSIR) mode, high speed
+
+	outb(LPC47N227_APMBOOTDRIVE_REG, iobase);  // CR07 - Auto Pwr Mgt/boot drive sel
+	tmpbyte = inb(iobase + 1);
+	outb(tmpbyte | LPC47N227_UART2AUTOPWRDOWN_MASK, iobase + 1); // enable UART2 autopower down
+
+	/* This one was not part of tosh1800 */
+	outb(0x0a, iobase);  // CR0a - ecp fifo / ir mux
+	tmpbyte = inb(iobase + 1);
+	outb(tmpbyte | 0x40, iobase + 1); // send active device to ir port
+
+	outb(LPC47N227_UART12POWER_REG, iobase);  // CR02 - UART 1,2 power
+	tmpbyte = inb(iobase + 1);
+	outb(tmpbyte | LPC47N227_UART2POWERDOWN_MASK, iobase + 1); // UART2 power up mode, UART1 power down
+
+	outb(LPC47N227_FDCPOWERVALIDCONF_REG, iobase);  // CR00 - FDC Power/valid config cycle
+	tmpbyte = inb(iobase + 1);
+	outb(tmpbyte | LPC47N227_VALID_MASK, iobase + 1); // valid config cycle done
+
+	outb(LPC47N227_CFGEXITKEY, iobase);  // Exit configuration
+
+	return 0;
+}
+
+/* 82801CAM registers */
+#define VID 0x00
+#define DID 0x02
+#define PIRQA_ROUT 0x60
+#define PCI_DMA_C 0x90
+#define COM_DEC 0xe0
+#define LPC_EN 0xe6
+#define GEN2_DEC 0xec
+/*
+ * Sets up the I/O range using the 82801CAM ISA bridge, 82801DBM LPC bridge or
+ * Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge. They all work the same way!
+ */
+static int __init preconfigure_through_82801(struct pci_dev *dev, 
+				  struct smsc_ircc_subsystem_configuration *conf)
+{
+	unsigned short tmpword;
+	int ret;
+
+	IRDA_MESSAGE("Setting up the SMSC device via the 82801 controller.\n");
+	pci_write_config_byte(dev, COM_DEC, 0x10);
+
+	/* Enable LPC */
+	pci_read_config_word(dev, LPC_EN, &tmpword); /* LPC_EN register */
+	tmpword &= 0xfffd; /* mask bit 1 */
+	tmpword |= 0x0001; /* set bit 0 : COMA addr range enable */
+	pci_write_config_word(dev, LPC_EN, tmpword);
+
+	/* Setup DMA */
+	pci_write_config_word(dev, PCI_DMA_C, 0xc0c0); /* LPC I/F DMA on, channel 3  -- rtm (?? PCI DMA ?) */
+	pci_write_config_word(dev, GEN2_DEC, 0x131); /* LPC I/F 2nd decode range */
+
+	/* Pre-configure chip */
+	ret = preconfigure_smsc_chip(conf);
+
+	/* Disable LPC */
+	pci_read_config_word(dev, LPC_EN, &tmpword); /* LPC_EN register */
+	tmpword &= 0xfffc; /* mask bit 1 and bit 0, COMA addr range disable */
+	pci_write_config_word(dev, LPC_EN, tmpword);
+	return ret;
+}
+
+static int __init preconfigure_through_ali(struct pci_dev *dev, 
+				  struct smsc_ircc_subsystem_configuration *conf)
+{
+	/* TODO: put in ALi 1533 configuration here. */
+	IRDA_MESSAGE("SORRY: %s has an unsupported bridge controller (ALi): not pre-configured.\n", conf->name);
+	return -ENODEV;
+}
+
+static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg, 
+						    unsigned short ircc_fir, 
+						    unsigned short ircc_sir, 
+						    unsigned char ircc_dma, 
+						    unsigned char ircc_irq)
+{
+	struct pci_dev *dev = NULL;
+	unsigned short ss_vendor = 0x0000;
+	unsigned short ss_device = 0x0000;
+	int ret = 0;
+
+	dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev);
+
+	while (dev != NULL) {
+		struct smsc_ircc_subsystem_configuration *conf;
+
+		/* 
+		 * Cache the subsystem vendor/device: some manufacturers fail to set 
+		 * this for all components, so we save it in case there is just
+		 * 0x0000 0x0000 on the device we want to check.
+		 */
+		if (dev->subsystem_vendor != 0x0000U) {
+			ss_vendor = dev->subsystem_vendor;
+			ss_device = dev->subsystem_device;
+		}
+		conf = subsystem_configurations;
+		for( ; conf->subvendor; conf++) {
+			if(conf->vendor == dev->vendor &&
+			   conf->device == dev->device &&
+			   conf->subvendor == ss_vendor && /* Sometimes these are cached values */
+			   (conf->subdevice == ss_device || conf->subdevice == 0xffff)) {
+				struct smsc_ircc_subsystem_configuration tmpconf;
+
+				memcpy(&tmpconf, conf, sizeof(struct smsc_ircc_subsystem_configuration));
+
+				/* Override the default values with anything passed in as parameter */
+				if (ircc_cfg != 0)
+					tmpconf.cfg_base = ircc_cfg;
+				if (ircc_fir != 0)
+					tmpconf.fir_io = ircc_fir;
+				if (ircc_sir != 0)
+					tmpconf.sir_io = ircc_sir;
+				if (ircc_dma != 0xff)
+					tmpconf.fir_dma = ircc_dma;
+				if (ircc_irq != 0xff)
+					tmpconf.fir_irq = ircc_irq;
+
+				IRDA_MESSAGE("Detected unconfigured %s SMSC IrDA chip, pre-configuring device.\n", conf->name);
+				if (conf->preconfigure)
+					ret = conf->preconfigure(dev, &tmpconf);
+				else
+					ret = -ENODEV;
+			}
+		}
+		dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev);
+	}
+
+	return ret;
+}
+#endif // CONFIG_PCI
+
 /************************************************
  *
  * Transceivers specific functions



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
