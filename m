From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: [PATCH] IrDA: smsc-ircc2, smcinit support for ALi ISA bridges
Date: Fri, 14 Apr 2006 13:16:18 +0300
Message-ID: <20060414101617.GB32724@irie>
Reply-To: Samuel Ortiz <samuel.ortiz@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>,
	IrDA users <irda-users@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext11.nokia.com ([131.228.20.170]:17556 "EHLO
	mgw-ext11.nokia.com") by vger.kernel.org with ESMTP id S965139AbWDNKaR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 06:30:17 -0400
To: "ext David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This patch enables support for ALi ISA bridges when we run the smcinit code.
It is needed to properly configure some Toshiba laptops.

Patch from Linus Walleij <triad@df.lth.se>
Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index bbcfc8e..58f76ce 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -225,6 +225,8 @@ static int __init smsc_superio_lpc(unsig
 #ifdef CONFIG_PCI
 static int __init preconfigure_smsc_chip(struct smsc_ircc_subsystem_configuration *conf);
 static int __init preconfigure_through_82801(struct pci_dev *dev, struct smsc_ircc_subsystem_configuration *conf);
+static void __init preconfigure_ali_port(struct pci_dev *dev,
+					 unsigned short port);
 static int __init preconfigure_through_ali(struct pci_dev *dev, struct smsc_ircc_subsystem_configuration *conf);
 static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
 						    unsigned short ircc_fir,
@@ -2327,9 +2329,14 @@ static int __init smsc_superio_lpc(unsig
  * pre-configuration not properly done by the BIOS (especially laptops)
  * This code is based in part on smcinit.c, tosh1800-smcinit.c
  * and tosh2450-smcinit.c. The table lists the device entries
- * for ISA bridges with an LPC (Local Peripheral Configurator)
- * that are in turn used to configure the SMSC device with default
- * SIR and FIR I/O ports, DMA and IRQ.
+ * for ISA bridges with an LPC (Low Pin Count) controller which
+ * handles the communication with the SMSC device. After the LPC
+ * controller is initialized through PCI, the SMSC device is initialized
+ * through a dedicated port in the ISA port-mapped I/O area, this latter
+ * area is used to configure the SMSC device with default
+ * SIR and FIR I/O ports, DMA and IRQ. Different vendors have
+ * used different sets of parameters and different control port
+ * addresses making a subsystem device table necessary.
  */
 #ifdef CONFIG_PCI
 #define PCIID_VENDOR_INTEL 0x8086
@@ -2340,9 +2347,10 @@ static struct smsc_ircc_subsystem_config
 		.device = 0x24cc,
 		.subvendor = 0x103c,
 		.subdevice = 0x088c,
-		.sir_io = 0x02f8, /* Quite certain these are the same for nc8000 as for nc6000 */
+		/* Quite certain these are the same for nc8000 as for nc6000 */
+		.sir_io = 0x02f8,
 		.fir_io = 0x0130,
-		.fir_irq = 0x09,
+		.fir_irq = 0x05,
 		.fir_dma = 0x03,
 		.cfg_base = 0x004e,
 		.preconfigure = preconfigure_through_82801,
@@ -2355,60 +2363,79 @@ static struct smsc_ircc_subsystem_config
 		.subdevice = 0x0890,
 		.sir_io = 0x02f8,
 		.fir_io = 0x0130,
-		.fir_irq = 0x09,
+		.fir_irq = 0x05,
 		.fir_dma = 0x03,
 		.cfg_base = 0x004e,
 		.preconfigure = preconfigure_through_82801,
 		.name = "HP nc6000",
 	},
 	{
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge */
+		/* Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge */
+		.vendor = PCIID_VENDOR_INTEL,
 		.device = 0x24c0,
 		.subvendor = 0x1179,
-		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.subdevice = 0xffff, /* 0xffff is "any" */
 		.sir_io = 0x03f8,
 		.fir_io = 0x0130,
 		.fir_irq = 0x07,
 		.fir_dma = 0x01,
 		.cfg_base = 0x002e,
 		.preconfigure = preconfigure_through_82801,
-		.name = "Toshiba Satellite 2450",
+		.name = "Toshiba laptop with Intel 82801DB/DBL LPC bridge",
 	},
 	{
 		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801CAM ISA bridge */
-		.device = 0x248c, /* Some use 24cc? */
+		.device = 0x248c,
+		.subvendor = 0x1179,
+		.subdevice = 0xffff, /* 0xffff is "any" */
+		.sir_io = 0x03f8,
+		.fir_io = 0x0130,
+		.fir_irq = 0x03,
+		.fir_dma = 0x03,
+		.cfg_base = 0x002e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "Toshiba laptop with Intel 82801CAM ISA bridge",
+	},
+	{
+		/* 82801DBM (ICH4-M) LPC Interface Bridge */
+		.vendor = PCIID_VENDOR_INTEL,
+		.device = 0x24cc,
 		.subvendor = 0x1179,
-		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.subdevice = 0xffff, /* 0xffff is "any" */
 		.sir_io = 0x03f8,
 		.fir_io = 0x0130,
 		.fir_irq = 0x03,
 		.fir_dma = 0x03,
 		.cfg_base = 0x002e,
 		.preconfigure = preconfigure_through_82801,
-		.name = "Toshiba Satellite 5100/5200, Tecra 9100",
+		.name = "Toshiba laptop with Intel 8281DBM LPC bridge",
 	},
 	{
-		.vendor = PCIID_VENDOR_ALI, /* ALi M1533/M1535 PCI to ISA Bridge [Aladdin IV/V/V+] */
+		/* ALi M1533/M1535 PCI to ISA Bridge [Aladdin IV/V/V+] */
+		.vendor = PCIID_VENDOR_ALI,
 		.device = 0x1533,
 		.subvendor = 0x1179,
-		.subdevice = 0xffff, /* 0xffff is "any", Not sure, 0x0001 or 0x0002 */
+		.subdevice = 0xffff, /* 0xffff is "any" */
 		.sir_io = 0x02e8,
 		.fir_io = 0x02f8,
 		.fir_irq = 0x07,
 		.fir_dma = 0x03,
 		.cfg_base = 0x002e,
 		.preconfigure = preconfigure_through_ali,
-		.name = "Toshiba Satellite 1800",
+		.name = "Toshiba laptop with ALi ISA bridge",
 	},
 	{ } // Terminator
 };
 
 
 /*
- * This sets up the basic SMSC parameters (FIR port, SIR port, FIR DMA, FIR IRQ)
+ * This sets up the basic SMSC parameters
+ * (FIR port, SIR port, FIR DMA, FIR IRQ)
  * through the chip configuration port.
  */
-static int __init preconfigure_smsc_chip(struct smsc_ircc_subsystem_configuration *conf)
+static int __init preconfigure_smsc_chip(struct
+					 smsc_ircc_subsystem_configuration
+					 *conf)
 {
 	unsigned short iobase = conf->cfg_base;
 	unsigned char tmpbyte;
@@ -2416,7 +2443,9 @@ static int __init preconfigure_smsc_chip
 	outb(LPC47N227_CFGACCESSKEY, iobase); // enter configuration state
 	outb(SMSCSIOFLAT_DEVICEID_REG, iobase); // set for device ID
 	tmpbyte = inb(iobase +1); // Read device ID
-	IRDA_DEBUG(0, "Detected Chip id: 0x%02x, setting up registers...\n",tmpbyte);
+	IRDA_DEBUG(0,
+		   "Detected Chip id: 0x%02x, setting up registers...\n",
+		   tmpbyte);
 
 	/* Disable UART1 and set up SIR I/O port */
 	outb(0x24, iobase);  // select CR24 - UART1 base addr
@@ -2426,6 +2455,7 @@ static int __init preconfigure_smsc_chip
 	tmpbyte = inb(iobase + 1);
 	if (tmpbyte != (conf->sir_io >> 2) ) {
 		IRDA_WARNING("ERROR: could not configure SIR ioport.\n");
+		IRDA_WARNING("Try to supply ircc_cfg argument.\n");
 		return -ENXIO;
 	}
 
@@ -2461,7 +2491,8 @@ static int __init preconfigure_smsc_chip
 
 	outb(SMSCSIOFLAT_UARTMODE0C_REG, iobase);  // CR0C - UART mode
 	tmpbyte = inb(iobase + 1);
-	tmpbyte &= ~SMSCSIOFLAT_UART2MODE_MASK | SMSCSIOFLAT_UART2MODE_VAL_IRDA;
+	tmpbyte &= ~SMSCSIOFLAT_UART2MODE_MASK |
+		SMSCSIOFLAT_UART2MODE_VAL_IRDA;
 	outb(tmpbyte, iobase + 1); // enable IrDA (HPSIR) mode, high speed
 
 	outb(LPC47N227_APMBOOTDRIVE_REG, iobase);  // CR07 - Auto Pwr Mgt/boot drive sel
@@ -2486,53 +2517,226 @@ static int __init preconfigure_smsc_chip
 	return 0;
 }
 
-/* 82801CAM registers */
+/* 82801CAM generic registers */
 #define VID 0x00
 #define DID 0x02
-#define PIRQA_ROUT 0x60
+#define PIRQ_A_D_ROUT 0x60
+#define SIRQ_CNTL 0x64
+#define PIRQ_E_H_ROUT 0x68
 #define PCI_DMA_C 0x90
+/* LPC-specific registers */
 #define COM_DEC 0xe0
+#define GEN1_DEC 0xe4
 #define LPC_EN 0xe6
 #define GEN2_DEC 0xec
 /*
- * Sets up the I/O range using the 82801CAM ISA bridge, 82801DBM LPC bridge or
- * Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge. They all work the same way!
+ * Sets up the I/O range using the 82801CAM ISA bridge, 82801DBM LPC bridge
+ * or Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge.
+ * They all work the same way!
  */
 static int __init preconfigure_through_82801(struct pci_dev *dev,
-				  struct smsc_ircc_subsystem_configuration *conf)
+					     struct
+					     smsc_ircc_subsystem_configuration
+					     *conf)
 {
 	unsigned short tmpword;
-	int ret;
+	unsigned char tmpbyte;
 
-	IRDA_MESSAGE("Setting up the SMSC device via the 82801 controller.\n");
-	pci_write_config_byte(dev, COM_DEC, 0x10);
+	IRDA_MESSAGE("Setting up Intel 82801 controller and SMSC device\n");
+	/*
+	 * Select the range for the COMA COM port (SIR)
+	 * Register COM_DEC:
+	 * Bit 7: reserved
+	 * Bit 6-4, COMB decode range
+	 * Bit 3: reserved
+	 * Bit 2-0, COMA decode range
+	 *
+	 * Decode ranges:
+	 *   000 = 0x3f8-0x3ff (COM1)
+	 *   001 = 0x2f8-0x2ff (COM2)
+	 *   010 = 0x220-0x227
+	 *   011 = 0x228-0x22f
+	 *   100 = 0x238-0x23f
+	 *   101 = 0x2e8-0x2ef (COM4)
+	 *   110 = 0x338-0x33f
+	 *   111 = 0x3e8-0x3ef (COM3)
+	 */
+	pci_read_config_byte(dev, COM_DEC, &tmpbyte);
+	tmpbyte &= 0xf8; /* mask COMA bits */
+	switch(conf->sir_io) {
+	case 0x3f8:
+		tmpbyte |= 0x00;
+		break;
+	case 0x2f8:
+		tmpbyte |= 0x01;
+		break;
+	case 0x220:
+		tmpbyte |= 0x02;
+		break;
+	case 0x228:
+		tmpbyte |= 0x03;
+		break;
+	case 0x238:
+		tmpbyte |= 0x04;
+		break;
+	case 0x2e8:
+		tmpbyte |= 0x05;
+		break;
+	case 0x338:
+		tmpbyte |= 0x06;
+		break;
+	case 0x3e8:
+		tmpbyte |= 0x07;
+		break;
+	default:
+		tmpbyte |= 0x01; /* COM2 default */
+	}
+	IRDA_DEBUG(1, "COM_DEC (write): 0x%02x\n", tmpbyte);
+	pci_write_config_byte(dev, COM_DEC, tmpbyte);
 
-	/* Enable LPC */
-	pci_read_config_word(dev, LPC_EN, &tmpword); /* LPC_EN register */
-	tmpword &= 0xfffd; /* mask bit 1 */
-	tmpword |= 0x0001; /* set bit 0 : COMA addr range enable */
+	/* Enable Low Pin Count interface */
+	pci_read_config_word(dev, LPC_EN, &tmpword);
+	/* These seem to be set up at all times,
+	 * just make sure it is properly set.
+	 */
+	switch(conf->cfg_base) {
+	case 0x04e:
+		tmpword |= 0x2000;
+		break;
+	case 0x02e:
+		tmpword |= 0x1000;
+		break;
+	case 0x062:
+		tmpword |= 0x0800;
+		break;
+	case 0x060:
+		tmpword |= 0x0400;
+		break;
+	default:
+		IRDA_WARNING("Uncommon I/O base address: 0x%04x\n",
+			     conf->cfg_base);
+		break;
+	}
+	tmpword &= 0xfffd; /* disable LPC COMB */
+	tmpword |= 0x0001; /* set bit 0 : enable LPC COMA addr range (GEN2) */
+	IRDA_DEBUG(1, "LPC_EN (write): 0x%04x\n", tmpword);
 	pci_write_config_word(dev, LPC_EN, tmpword);
 
-	/* Setup DMA */
-	pci_write_config_word(dev, PCI_DMA_C, 0xc0c0); /* LPC I/F DMA on, channel 3  -- rtm (?? PCI DMA ?) */
-	pci_write_config_word(dev, GEN2_DEC, 0x131); /* LPC I/F 2nd decode range */
+	/*
+	 * Configure LPC DMA channel
+	 * PCI_DMA_C bits:
+	 * Bit 15-14: DMA channel 7 select
+	 * Bit 13-12: DMA channel 6 select
+	 * Bit 11-10: DMA channel 5 select
+	 * Bit 9-8:   Reserved
+	 * Bit 7-6:   DMA channel 3 select
+	 * Bit 5-4:   DMA channel 2 select
+	 * Bit 3-2:   DMA channel 1 select
+	 * Bit 1-0:   DMA channel 0 select
+	 *  00 = Reserved value
+	 *  01 = PC/PCI DMA
+	 *  10 = Reserved value
+	 *  11 = LPC I/F DMA
+	 */
+	pci_read_config_word(dev, PCI_DMA_C, &tmpword);
+	switch(conf->fir_dma) {
+	case 0x07:
+		tmpword |= 0xc000;
+		break;
+	case 0x06:
+		tmpword |= 0x3000;
+		break;
+	case 0x05:
+		tmpword |= 0x0c00;
+		break;
+	case 0x03:
+		tmpword |= 0x00c0;
+		break;
+	case 0x02:
+		tmpword |= 0x0030;
+		break;
+	case 0x01:
+		tmpword |= 0x000c;
+		break;
+	case 0x00:
+		tmpword |= 0x0003;
+		break;
+	default:
+		break; /* do not change settings */
+	}
+	IRDA_DEBUG(1, "PCI_DMA_C (write): 0x%04x\n", tmpword);
+	pci_write_config_word(dev, PCI_DMA_C, tmpword);
+
+	/*
+	 * GEN2_DEC bits:
+	 * Bit 15-4: Generic I/O range
+	 * Bit 3-1: reserved (read as 0)
+	 * Bit 0: enable GEN2 range on LPC I/F
+	 */
+	tmpword = conf->fir_io & 0xfff8;
+	tmpword |= 0x0001;
+	IRDA_DEBUG(1, "GEN2_DEC (write): 0x%04x\n", tmpword);
+	pci_write_config_word(dev, GEN2_DEC, tmpword);
 
 	/* Pre-configure chip */
-	ret = preconfigure_smsc_chip(conf);
+	return preconfigure_smsc_chip(conf);
+}
 
-	/* Disable LPC */
-	pci_read_config_word(dev, LPC_EN, &tmpword); /* LPC_EN register */
-	tmpword &= 0xfffc; /* mask bit 1 and bit 0, COMA addr range disable */
-	pci_write_config_word(dev, LPC_EN, tmpword);
-	return ret;
+/*
+ * Pre-configure a certain port on the ALi 1533 bridge.
+ * This is based on reverse-engineering since ALi does not
+ * provide any data sheet for the 1533 chip.
+ */
+static void __init preconfigure_ali_port(struct pci_dev *dev,
+					 unsigned short port)
+{
+	unsigned char reg;
+	/* These bits obviously control the different ports */
+	unsigned char mask;
+	unsigned char tmpbyte;
+
+	switch(port) {
+	case 0x0130:
+	case 0x0178:
+		reg = 0xb0;
+		mask = 0x80;
+		break;
+	case 0x03f8:
+		reg = 0xb4;
+		mask = 0x80;
+		break;
+	case 0x02f8:
+		reg = 0xb4;
+		mask = 0x30;
+		break;
+	case 0x02e8:
+		reg = 0xb4;
+		mask = 0x08;
+		break;
+	default:
+		IRDA_ERROR("Failed to configure unsupported port on ALi 1533 bridge: 0x%04x\n", port);
+		return;
+	}
+
+	pci_read_config_byte(dev, reg, &tmpbyte);
+	/* Turn on the right bits */
+	tmpbyte |= mask;
+	pci_write_config_byte(dev, reg, tmpbyte);
+	IRDA_MESSAGE("Activated ALi 1533 ISA bridge port 0x%04x.\n", port);
+	return;
 }
 
 static int __init preconfigure_through_ali(struct pci_dev *dev,
-				  struct smsc_ircc_subsystem_configuration *conf)
-{
-	/* TODO: put in ALi 1533 configuration here. */
-	IRDA_MESSAGE("SORRY: %s has an unsupported bridge controller (ALi): not pre-configured.\n", conf->name);
-	return -ENODEV;
+					   struct
+					   smsc_ircc_subsystem_configuration
+					   *conf)
+{
+	/* Configure the two ports on the ALi 1533 */
+	preconfigure_ali_port(dev, conf->sir_io);
+	preconfigure_ali_port(dev, conf->fir_io);
+
+	/* Pre-configure chip */
+	return preconfigure_smsc_chip(conf);
 }
 
 static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
@@ -2552,9 +2756,10 @@ static int __init smsc_ircc_preconfigure
 		struct smsc_ircc_subsystem_configuration *conf;
 
 		/*
-		 * Cache the subsystem vendor/device: some manufacturers fail to set
-		 * this for all components, so we save it in case there is just
-		 * 0x0000 0x0000 on the device we want to check.
+		 * Cache the subsystem vendor/device:
+		 * some manufacturers fail to set this for all components,
+		 * so we save it in case there is just 0x0000 0x0000 on the
+		 * device we want to check.
 		 */
 		if (dev->subsystem_vendor != 0x0000U) {
 			ss_vendor = dev->subsystem_vendor;
@@ -2564,13 +2769,20 @@ static int __init smsc_ircc_preconfigure
 		for( ; conf->subvendor; conf++) {
 			if(conf->vendor == dev->vendor &&
 			   conf->device == dev->device &&
-			   conf->subvendor == ss_vendor && /* Sometimes these are cached values */
-			   (conf->subdevice == ss_device || conf->subdevice == 0xffff)) {
-				struct smsc_ircc_subsystem_configuration tmpconf;
+			   conf->subvendor == ss_vendor &&
+			   /* Sometimes these are cached values */
+			   (conf->subdevice == ss_device ||
+			    conf->subdevice == 0xffff)) {
+				struct smsc_ircc_subsystem_configuration
+					tmpconf;
 
-				memcpy(&tmpconf, conf, sizeof(struct smsc_ircc_subsystem_configuration));
+				memcpy(&tmpconf, conf,
+				       sizeof(struct smsc_ircc_subsystem_configuration));
 
-				/* Override the default values with anything passed in as parameter */
+				/*
+				 * Override the default values with anything
+				 * passed in as parameter
+				 */
 				if (ircc_cfg != 0)
 					tmpconf.cfg_base = ircc_cfg;
 				if (ircc_fir != 0)
