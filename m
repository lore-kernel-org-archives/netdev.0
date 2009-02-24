From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: ixp4xx_hss modifications for 2x4 HDLC
Date: Tue, 24 Feb 2009 13:47:27 +0100
Message-ID: <b0438a630902240447y7afe5510u7465804f94c0e22b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:45194 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbZBXMrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 07:47:39 -0500
Received: by fg-out-1718.google.com with SMTP id 16so88997fgg.17
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 04:47:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I have finished my modifications to Krzysztof Halasa's driver for
ixp4xx_hss that allow to use four HDLC for each HSS.

The modifications are functional, but some effort must be done to
allow the configuration in 2x1HDLC (Krzysztof's) or 2x4HDLC (mine)
modes.

I would appreciate your comments very much, because I think this
functionallity is quite usefull and I would like to add it to the main
kernel stream.

diff -urN linux-2.6.26.7/arch/arm/mach-ixp4xx/ixdp425-setup.c
linux-2.6.26.7_hss/arch/arm/mach-ixp4xx/ixdp425-setup.c
--- linux-2.6.26.7/arch/arm/mach-ixp4xx/ixdp425-setup.c	2009-02-03
17:37:55.000000000 +0100
+++ linux-2.6.26.7_hss/arch/arm/mach-ixp4xx/ixdp425-setup.c	2009-02-03
15:50:44.000000000 +0100
@@ -48,74 +48,19 @@

 static int hss_set_clock(int port, unsigned int clock_type)
 {
-	/*int ctrl_int =3D port ? CONTROL_HSS1_CLK_INT : CONTROL_HSS0_CLK_INT=
;
-
-	switch (clock_type) {
-	case CLOCK_DEFAULT:
-	case CLOCK_EXT:
-		set_control(ctrl_int, 0);
-		output_control();
-		return CLOCK_EXT;
-
-	case CLOCK_INT:
-		set_control(ctrl_int, 1);
-		output_control();
-		return CLOCK_INT;
-
-	default:
-		return -EINVAL;
-	}*/
-}
-
-static irqreturn_t hss_dcd_irq(int irq, void *pdev)
-{
-	/*int i, port =3D (irq =3D=3D gpio_irq(GPIO_HSS1_DCD_N));
-	gpio_line_get(port ? GPIO_HSS1_DCD_N : GPIO_HSS0_DCD_N, &i);
-	set_carrier_cb_tab[port](pdev, !i);*/
-	return IRQ_HANDLED;
+	return clock_type;
 }

-
 static int hss_open(int port, void *pdev,
 		    void (*set_carrier_cb)(void *pdev, int carrier))
 {
-	/*
-	int i, irq;
-
-	if (!port)
-		irq =3D gpio_irq(GPIO_HSS0_DCD_N);
-	else
-		irq =3D gpio_irq(GPIO_HSS1_DCD_N);
-
-	gpio_line_get(port ? GPIO_HSS1_DCD_N : GPIO_HSS0_DCD_N, &i);
-	set_carrier_cb(pdev, !i);
-
-	set_carrier_cb_tab[!!port] =3D set_carrier_cb;
-
-	if ((i =3D request_irq(irq, hss_dcd_irq, 0, "IXP4xx HSS", pdev)) !=3D=
 0) {
-		printk(KERN_ERR "ixp4xx_hss: failed to request IRQ%i\n", irq);
-		return -EIO;
-	}
-
-	set_control(port ? CONTROL_HSS1_DTR_N : CONTROL_HSS0_DTR_N, 0);
-	output_control();
-	gpio_line_set(port ? GPIO_HSS1_RTS_N : GPIO_HSS0_RTS_N, 0);
-	*/
 	return 0;
 }

 static void hss_close(int port, void *pdev)
 {
-	//free_irq(port ? gpio_irq(GPIO_HSS1_DCD_N) : gpio_irq(GPIO_HSS0_DCD_=
N),
-	//	 pdev);
-	//set_carrier_cb_tab[!!port] =3D NULL; /* catch bugs */
-
-	//set_control(port ? CONTROL_HSS1_DTR_N : CONTROL_HSS0_DTR_N, 1);
-	//output_control();
-	//gpio_line_set(port ? GPIO_HSS1_RTS_N : GPIO_HSS0_RTS_N, 1);
 }

-
 static struct flash_platform_data ixdp425_flash_data =3D {
 	.map_name	=3D "cfi_probe",
 	.width		=3D 2,
@@ -321,12 +266,12 @@
 static struct eth_plat_info ixdp425_plat_eth[] =3D {
 	{
 		.phy		=3D 0,
-		.rxq		=3D 3,
-		.txreadyq	=3D 20,
+		.rxq		=3D 10,
+		.txreadyq	=3D 40,
 	}, {
 		.phy		=3D 1,
-		.rxq		=3D 4,
-		.txreadyq	=3D 21,
+		.rxq		=3D 11,
+		.txreadyq	=3D 41,
 	}
 };

@@ -349,12 +294,58 @@
 		.set_clock	=3D hss_set_clock,
 		.open		=3D hss_open,
 		.close		=3D hss_close,
-		.txreadyq	=3D 2,
+		.txreadyq	=3D 32,
+		.hss        =3D 0,
+		.hdlc       =3D 0,
 	}, {
 		.set_clock	=3D hss_set_clock,
 		.open		=3D hss_open,
 		.close		=3D hss_close,
-		.txreadyq	=3D 19,
+		.txreadyq	=3D 36,
+		.hss        =3D 1,
+		.hdlc       =3D 0,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 33,
+		.hss        =3D 0,
+		.hdlc       =3D 1,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 37,
+		.hss        =3D 1,
+		.hdlc       =3D 1,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 34,
+		.hss        =3D 0,
+		.hdlc       =3D 2,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 38,
+		.hss        =3D 1,
+		.hdlc       =3D 2,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 35,
+		.hss        =3D 0,
+		.hdlc       =3D 3,
+	}, {
+		.set_clock	=3D hss_set_clock,
+		.open		=3D hss_open,
+		.close		=3D hss_close,
+		.txreadyq	=3D 39,
+		.hss        =3D 1,
+		.hdlc       =3D 3,
 	}
 };

@@ -367,6 +358,30 @@
 		.name			=3D "ixp4xx_hss",
 		.id			=3D 1,
 		.dev.platform_data	=3D hss_plat + 1,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 2,
+		.dev.platform_data	=3D hss_plat + 2,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 3,
+		.dev.platform_data	=3D hss_plat + 3,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 4,
+		.dev.platform_data	=3D hss_plat + 4,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 5,
+		.dev.platform_data	=3D hss_plat + 5,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 6,
+		.dev.platform_data	=3D hss_plat + 6,
+	}, {
+		.name			=3D "ixp4xx_hss",
+		.id			=3D 7,
+		.dev.platform_data	=3D hss_plat + 7,
 	}
 };

@@ -384,6 +399,12 @@
 	&ixdp425_spi,
 	&device_hss_tab[0],
 	&device_hss_tab[1],
+	&device_hss_tab[2],
+	&device_hss_tab[3],
+	&device_hss_tab[4],
+	&device_hss_tab[5],
+	&device_hss_tab[6],
+	&device_hss_tab[7],
 };

 /*static struct spi_board_info spi_board_info[] __initdata =3D { {
diff -urN linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c
linux-2.6.26.7_hss/drivers/net/wan/ixp4xx_hss.c
--- linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c	2009-02-03
17:37:54.000000000 +0100
+++ linux-2.6.26.7_hss/drivers/net/wan/ixp4xx_hss.c	2009-02-03
17:30:18.000000000 +0100
@@ -2,6 +2,7 @@
  * Intel IXP4xx HSS (synchronous serial port) driver for Linux
  *
  * Copyright (C) 2007-2008 Krzysztof Ha=C3=85=C2=82asa <khc@pm.waw.pl>
+ * Portions Copyright (C) 2008 Miguel Angel Alvarez <gotzoncabanes@gma=
il.com>
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of version 2 of the GNU General Public License
@@ -32,11 +33,15 @@

 #define DRV_NAME		"ixp4xx_hss"

-#define PKT_EXTRA_FLAGS		0 /* orig 1 */
+#define FRAME_SYNC_EXT      0
+#define FRAME_SYNC_INT_RISE 1
+#define FRAME_SYNC_INT_FALL 2
+
 #define TX_FRAME_SYNC_OFFSET	0 /* channelized */
-#define PKT_NUM_PIPES		1 /* 1, 2 or 4 */
-#define PKT_PIPE_FIFO_SIZEW	4 /* total 4 dwords per HSS */
+#define PKT_NUM_PIPES		4 /* 1, 2 or 4 */
+#define PKT_PIPE_FIFO_SIZEW	1 /* total 4 dwords per HSS */

+#define HDLC_COUNT		4
 #define RX_DESCS		16 /* also length of all RX queues */
 #define TX_DESCS		16 /* also length of all TX queues */

@@ -45,7 +50,7 @@
 #define MAX_CLOSE_WAIT		1000 /* microseconds */
 #define HSS_COUNT		2
 #define MIN_FRAME_SIZE		16   /* bits */
-#define MAX_FRAME_SIZE		257  /* 256 bits + framing bit */
+#define MAX_FRAME_SIZE		1024  /* 256 bits + framing bit */
 #define MAX_CHANNELS		(MAX_FRAME_SIZE / 8)
 #define MAX_CHAN_DEVICES	32
 #define CHANNEL_HDLC		0xFE
@@ -62,7 +67,7 @@


 /* Queue IDs */
-#define HSS0_CHL_RXTRIG_QUEUE	12	/* orig size =3D 32 dwords */
+#define HSS0_CHL_RXTRIG_QUEUE	12	/* orig size =3D 32 dwords */ //
:TOSEE 20 for PHY4
 #define HSS0_PKT_RX_QUEUE	13	/* orig size =3D 32 dwords */
 #define HSS0_PKT_TX0_QUEUE	14	/* orig size =3D 16 dwords */
 #define HSS0_PKT_TX1_QUEUE	15
@@ -95,75 +100,96 @@
 #define PKT_HDLC_IDLE_ONES		0x1 /* default =3D flags */
 #define PKT_HDLC_CRC_32			0x2 /* default =3D CRC-16 */
 #define PKT_HDLC_MSB_ENDIAN		0x4 /* default =3D LE */
+#define PKT_EXTRA_FLAGS		    0 /* orig 1 frmFlagStart */

-
+/* HSSTXPCR / HSSRXPCR */
 /* hss_config, PCRs */
-/* Frame sync sampling, default =3D active low */
+/* Frame sync sampling, default =3D active low (FTYPE bits 30,31)*/
 #define PCR_FRM_SYNC_ACTIVE_HIGH	0x40000000
 #define PCR_FRM_SYNC_FALLINGEDGE	0x80000000
 #define PCR_FRM_SYNC_RISINGEDGE		0xC0000000

 /* Frame sync pin: input (default) or output generated off a given clk=
 edge */
+/* (FENABLE bits 28, 29) */
 #define PCR_FRM_SYNC_OUTPUT_FALLING	0x20000000
 #define PCR_FRM_SYNC_OUTPUT_RISING	0x30000000

 /* Frame and data clock sampling on edge, default =3D falling */
+/* (FEDGE bit 27) */
 #define PCR_FCLK_EDGE_RISING		0x08000000
+/* (DEDGE bit 26) */
 #define PCR_DCLK_EDGE_RISING		0x04000000

 /* Clock direction, default =3D input */
+/* (CLKDIR bit 25) */
 #define PCR_SYNC_CLK_DIR_OUTPUT		0x02000000

 /* Generate/Receive frame pulses, default =3D enabled */
+/* (FRAME bit 24) */
 #define PCR_FRM_PULSE_DISABLED		0x01000000

  /* Data rate is full (default) or half the configured clk speed */
+/* (HALF bit 21) */
 #define PCR_HALF_CLK_RATE		0x00200000

 /* Invert data between NPE and HSS FIFOs? (default =3D no) */
+/* (DPOL bit 20) */
 #define PCR_DATA_POLARITY_INVERT	0x00100000

 /* TX/RX endianness, default =3D LSB */
+/* (BITEND bit 19) */
 #define PCR_MSB_ENDIAN			0x00080000

 /* Normal (default) / open drain mode (TX only) */
+/* (ODRAIN bin 18 TX) */
 #define PCR_TX_PINS_OPEN_DRAIN		0x00040000

 /* No framing bit transmitted and expected on RX? (default =3D framing=
 bit) */
+/* (FBIT bit 17) */
 #define PCR_SOF_NO_FBIT			0x00020000

 /* Drive data pins? */
+/* (ENABLE bit 16 TX) */
 #define PCR_TX_DATA_ENABLE		0x00010000

 /* Voice 56k type: drive the data pins low (default), high, high Z */
+/* (56KTYPE bits 13, 14 (and 15?) TX) */
 #define PCR_TX_V56K_HIGH		0x00002000
 #define PCR_TX_V56K_HIGH_IMP		0x00004000

 /* Unassigned type: drive the data pins low (default), high, high Z */
+/* (UTYPE bits 11, 12 TX) */
 #define PCR_TX_UNASS_HIGH		0x00000800
 #define PCR_TX_UNASS_HIGH_IMP		0x00001000

 /* T1 @ 1.544MHz only: Fbit dictated in FIFO (default) or high Z */
+/* (FBTYPE bit 10 TX) */
 #define PCR_TX_FB_HIGH_IMP		0x00000400

 /* 56k data endiannes - which bit unused: high (default) or low */
+/* (56KEND bit 9 TX) */
 #define PCR_TX_56KE_BIT_0_UNUSED	0x00000200

 /* 56k data transmission type: 32/8 bit data (default) or 56K data */
+/* (56KSEL bit 8 TX) */
 #define PCR_TX_56KS_56K_DATA		0x00000100

+/* HSSCCR */
 /* hss_config, cCR */
 /* Number of packetized clients, default =3D 1 */
+/* (HFIFO bits 26, 27) */
 #define CCR_NPE_HFIFO_2_HDLC		0x04000000
 #define CCR_NPE_HFIFO_3_OR_4HDLC	0x08000000

 /* default =3D no loopback */
+/* (LBACK bit 25) */
 #define CCR_LOOPBACK			0x02000000

 /* HSS number, default =3D 0 (first) */
+/* (COND bit 24) */
 #define CCR_SECOND_HSS			0x01000000

-
+/* HSSCLKCR */
 /* hss_config, clkCR: main:10, num:10, denom:12 */
 #define CLK42X_SPEED_EXP	((0x3FF << 22) | (  2 << 12) |   15) /*65 KHz=
*/

@@ -273,16 +299,28 @@
 	u8 log_channels[MAX_CHANNELS];
 };

+struct hss_t
+{
+	unsigned int id;
+	u8 hdlc_open;
+	u32 slots[MAX_CHANNELS];
+	u32 mask[MAX_CHANNELS];
+	struct port *npe_port_tab[HDLC_COUNT];
+	struct napi_struct napi;
+};
+
 struct port {
 	struct device *dev;
 	struct npe *npe;
 	struct net_device *netdev;
-	struct napi_struct napi;
 	struct hss_plat_info *plat;
 	buffer_t *rx_buff_tab[RX_DESCS], *tx_buff_tab[TX_DESCS];
 	struct desc *desc_tab;	/* coherent */
 	u32 desc_tab_phys;
+	u32 pending_phys;
 	unsigned int id;
+	struct hss_t* hss;
+	unsigned int hdlc;
 	atomic_t chan_tx_irq_number, chan_rx_irq_number;
 	wait_queue_head_t chan_tx_waitq, chan_rx_waitq;
 	u8 hdlc_cfg;
@@ -290,6 +328,7 @@
 	/* the following fields must be protected by npe_lock */
 	enum mode mode;
 	unsigned int clock_type, clock_rate, loopback;
+	unsigned int frame_sync_type;
 	unsigned int frame_size, frame_sync_offset;

 	struct chan_device *chan_devices[MAX_CHAN_DEVICES];
@@ -380,18 +419,73 @@
 static spinlock_t npe_lock;
 static DEFINE_MUTEX(firmware_mutex);

+static struct hss_t hss[HSS_COUNT] =3D {
+	{0, 0},
+	{1, 0},
+};
+
 static const struct {
 	int tx, txdone, rx, rxfree, chan;
-}queue_ids[2] =3D {{HSS0_PKT_TX0_QUEUE, HSS0_PKT_TXDONE_QUEUE, HSS0_PK=
T_RX_QUEUE,
+}queue_ids[8] =3D {{HSS0_PKT_TX0_QUEUE, HSS0_PKT_TXDONE_QUEUE, HSS0_PK=
T_RX_QUEUE,
 		  HSS0_PKT_RXFREE0_QUEUE, HSS0_CHL_RXTRIG_QUEUE},
+		 {HSS0_PKT_TX1_QUEUE, HSS0_PKT_TXDONE_QUEUE, HSS0_PKT_RX_QUEUE,
+		  HSS0_PKT_RXFREE1_QUEUE, HSS0_CHL_RXTRIG_QUEUE},
+		 {HSS0_PKT_TX2_QUEUE, HSS0_PKT_TXDONE_QUEUE, HSS0_PKT_RX_QUEUE,
+		  HSS0_PKT_RXFREE2_QUEUE, HSS0_CHL_RXTRIG_QUEUE},
+		 {HSS0_PKT_TX3_QUEUE, HSS0_PKT_TXDONE_QUEUE, HSS0_PKT_RX_QUEUE,
+		  HSS0_PKT_RXFREE3_QUEUE, HSS0_CHL_RXTRIG_QUEUE},
 		 {HSS1_PKT_TX0_QUEUE, HSS1_PKT_TXDONE_QUEUE, HSS1_PKT_RX_QUEUE,
 		  HSS1_PKT_RXFREE0_QUEUE, HSS1_CHL_RXTRIG_QUEUE},
+		 {HSS1_PKT_TX1_QUEUE, HSS1_PKT_TXDONE_QUEUE, HSS1_PKT_RX_QUEUE,
+		  HSS1_PKT_RXFREE1_QUEUE, HSS1_CHL_RXTRIG_QUEUE},
+		 {HSS1_PKT_TX2_QUEUE, HSS1_PKT_TXDONE_QUEUE, HSS1_PKT_RX_QUEUE,
+		  HSS1_PKT_RXFREE2_QUEUE, HSS1_CHL_RXTRIG_QUEUE},
+		 {HSS1_PKT_TX3_QUEUE, HSS1_PKT_TXDONE_QUEUE, HSS1_PKT_RX_QUEUE,
+		  HSS1_PKT_RXFREE3_QUEUE, HSS1_CHL_RXTRIG_QUEUE},
 };

 /*********************************************************************=
********
  * utility functions
  *********************************************************************=
*******/

+static u32 get_clock_config(u32 clock_rate) {
+	if (cpu_is_ixp42x()) {
+		switch (clock_rate) {
+			case 512000:
+				return CLK46X_SPEED_512KHZ;
+			case 1536000:
+				return CLK46X_SPEED_1536KHZ;
+			case 1544000:
+				return CLK46X_SPEED_1544KHZ;
+			case 2048000:
+				return CLK46X_SPEED_2048KHZ;
+			case 4096000:
+				return CLK46X_SPEED_4096KHZ;
+			case 8192000:
+				return CLK46X_SPEED_8192KHZ;
+			default:
+				return CLK46X_SPEED_2048KHZ;
+		}
+	} else {
+		switch (clock_rate) {
+			case 512000:
+				return CLK42X_SPEED_512KHZ;
+			case 1536000:
+				return CLK42X_SPEED_1536KHZ;
+			case 1544000:
+				return CLK42X_SPEED_1544KHZ;
+			case 2048000:
+				return CLK42X_SPEED_2048KHZ;
+			case 4096000:
+				return CLK42X_SPEED_4096KHZ;
+			case 8192000:
+				return CLK42X_SPEED_8192KHZ;
+			default:
+				return CLK42X_SPEED_2048KHZ;
+		}
+	}
+}
+
 static inline struct port* dev_to_port(struct net_device *dev)
 {
 	return dev_to_hdlc(dev)->priv;
@@ -521,18 +615,18 @@
 {
 	struct msg msg;
 	int chan_count =3D 0, log_chan =3D 0, i, ch;
-	u32 lut[MAX_CHANNELS / 4];

-	memset(lut, 0, sizeof(lut));
 	for (i =3D 0; i < MAX_CHAN_DEVICES; i++)
 		if (port->chan_devices[i])
 			port->chan_devices[i]->chan_count =3D 0;

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;

 	for (ch =3D 0; ch < MAX_CHANNELS; ch++) {
+		if (ch >=3D MAX_CHANNELS)
+			break;
 		struct chan_device *chdev =3D NULL;
 		unsigned int entry;

@@ -541,8 +635,15 @@

 		if (port->mode =3D=3D MODE_G704 && ch =3D=3D 0)
 			entry =3D TDMMAP_VOICE64K; /* PCM-31 pattern */
-		else if (port->mode =3D=3D MODE_HDLC ||
-			 port->channels[ch] =3D=3D CHANNEL_HDLC)
+		else if (port->mode =3D=3D MODE_HDLC) {
+			if (port->hss->slots[ch] && port->hss->slots[ch]) {
+				entry =3D TDMMAP_HDLC;
+			}
+			else {
+				entry =3D TDMMAP_UNASSIGNED;
+			}
+		}
+		else if (port->channels[ch] =3D=3D CHANNEL_HDLC)
 			entry =3D TDMMAP_HDLC;
 		else if (chdev && chdev->open_count) {
 			entry =3D TDMMAP_VOICE64K;
@@ -571,7 +672,7 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_NUM_CHANS_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data8a =3D chan_count;
 	hss_npe_send(port, &msg, "CHAN_NUM_CHANS_WRITE");

@@ -598,38 +699,59 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.index =3D HSS_CONFIG_TX_PCR;
-	msg.data32 =3D PCR_FRM_SYNC_OUTPUT_RISING | PCR_MSB_ENDIAN |
-		PCR_TX_DATA_ENABLE;
+	msg.data32 =3D PCR_TX_DATA_ENABLE;
+	msg.data32 |=3D PCR_MSB_ENDIAN;
+	//msg.data32 |=3D PCR_FRM_SYNC_ACTIVE_HIGH;
+	if (port->frame_sync_type =3D=3D  FRAME_SYNC_INT_RISE)
+		msg.data32 |=3D PCR_FRM_SYNC_OUTPUT_RISING;
+	else if (port->frame_sync_type =3D=3D  FRAME_SYNC_INT_FALL)
+		msg.data32 |=3D PCR_FRM_SYNC_OUTPUT_FALLING;
 	if (port->frame_size % 8 =3D=3D 0)
 		msg.data32 |=3D PCR_SOF_NO_FBIT;
 	if (port->clock_type =3D=3D CLOCK_INT)
 		msg.data32 |=3D PCR_SYNC_CLK_DIR_OUTPUT;
+	//msg.data32 |=3D PCR_DCLK_EDGE_RISING;
 	hss_npe_send(port, &msg, "HSS_SET_TX_PCR");

 	msg.index =3D HSS_CONFIG_RX_PCR;
-	msg.data32 ^=3D PCR_TX_DATA_ENABLE | PCR_DCLK_EDGE_RISING;
+	msg.data32 =3D 0;
+	msg.data32 |=3D PCR_MSB_ENDIAN;
+	//msg.data32 ^=3D PCR_FRM_SYNC_ACTIVE_HIGH;
+	if (port->frame_sync_type =3D=3D  FRAME_SYNC_INT_RISE)
+		msg.data32 |=3D PCR_FRM_SYNC_OUTPUT_RISING;
+	else if (port->frame_sync_type =3D=3D  FRAME_SYNC_INT_FALL)
+		msg.data32 |=3D PCR_FRM_SYNC_OUTPUT_FALLING;
+	if (port->frame_size % 8 =3D=3D 0)
+		msg.data32 |=3D PCR_SOF_NO_FBIT;
+	if (port->clock_type =3D=3D CLOCK_INT)
+		msg.data32 |=3D PCR_SYNC_CLK_DIR_OUTPUT;
+	msg.data32 |=3D PCR_DCLK_EDGE_RISING;
 	hss_npe_send(port, &msg, "HSS_SET_RX_PCR");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.index =3D HSS_CONFIG_CORE_CR;
 	msg.data32 =3D (port->loopback ? CCR_LOOPBACK : 0) |
-		(port->id ? CCR_SECOND_HSS : 0);
+		(port->hss->id ? CCR_SECOND_HSS : 0);
+	if ((256 < port->frame_size) && (port->frame_size <=3D 512))
+		msg.data32 |=3D CCR_NPE_HFIFO_2_HDLC;
+	else if (port->frame_size > 512)
+		msg.data32 |=3D CCR_NPE_HFIFO_3_OR_4HDLC;
 	hss_npe_send(port, &msg, "HSS_SET_CORE_CR");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.index =3D HSS_CONFIG_CLOCK_CR;
-	msg.data32 =3D CLK42X_SPEED_2048KHZ /* FIXME */;
+	msg.data32 =3D get_clock_config(port->clock_rate);
 	hss_npe_send(port, &msg, "HSS_SET_CLOCK_CR");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.index =3D HSS_CONFIG_TX_FCR;
 	msg.data16a =3D TX_FRAME_SYNC_OFFSET;
 	msg.data16b =3D port->frame_size - 1;
@@ -637,7 +759,7 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.index =3D HSS_CONFIG_RX_FCR;
 	msg.data16a =3D port->frame_sync_offset;
 	msg.data16b =3D port->frame_size - 1;
@@ -647,7 +769,7 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_CONFIG_LOAD;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	hss_npe_send(port, &msg, "HSS_LOAD_CONFIG");

 	if (npe_recv_message(port->npe, &msg, "HSS_LOAD_CONFIG") ||
@@ -668,7 +790,8 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PKT_PIPE_HDLC_CFG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
+	msg.index =3D port->hdlc;
 	msg.data8a =3D port->hdlc_cfg; /* rx_cfg */
 	msg.data8b =3D port->hdlc_cfg | (PKT_EXTRA_FLAGS << 3); /* tx_cfg */
 	hss_npe_send(port, &msg, "HSS_SET_HDLC_CFG");
@@ -680,7 +803,7 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PORT_ERROR_READ;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	hss_npe_send(port, &msg, "PORT_ERROR_READ");
 	if (npe_recv_message(port->npe, &msg, "PORT_ERROR_READ")) {
 		printk(KERN_CRIT "HSS-%i: unable to read HSS status\n",
@@ -700,19 +823,19 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_RX_BUF_ADDR_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data32 =3D port->chan_rx_buf_phys;
 	hss_npe_send(port, &msg, "CHAN_RX_BUF_ADDR_WRITE");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_TX_BUF_ADDR_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data32 =3D chan_tx_lists_phys(port);
 	hss_npe_send(port, &msg, "CHAN_TX_BUF_ADDR_WRITE");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_FLOW_ENABLE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	hss_npe_send(port, &msg, "CHAN_FLOW_ENABLE");
 	port->chan_started =3D 1;
 }
@@ -726,7 +849,7 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_FLOW_DISABLE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	hss_npe_send(port, &msg, "CHAN_FLOW_DISABLE");

 	hss_get_status(port); /* make sure it's halted */
@@ -739,7 +862,8 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PKT_PIPE_FLOW_ENABLE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
+	msg.index =3D port->hdlc;
 	msg.data32 =3D 0;
 	hss_npe_send(port, &msg, "HSS_ENABLE_PKT_PIPE");
 }
@@ -750,7 +874,8 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PKT_PIPE_FLOW_DISABLE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
+	msg.index =3D port->hdlc;
 	hss_npe_send(port, &msg, "HSS_DISABLE_PKT_PIPE");
 	hss_get_status(port); /* make sure it's halted */
 }
@@ -774,32 +899,37 @@
 	/* HDLC mode configuration */
 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D PKT_NUM_PIPES_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
+	msg.index =3D 0;
 	msg.data8a =3D PKT_NUM_PIPES;
 	hss_npe_send(port, &msg, "HSS_SET_PKT_PIPES");

 	msg.cmd =3D PKT_PIPE_FIFO_SIZEW_WRITE;
+	msg.index =3D port->hdlc;
 	msg.data8a =3D PKT_PIPE_FIFO_SIZEW;
 	hss_npe_send(port, &msg, "HSS_SET_PKT_FIFO");

 	msg.cmd =3D PKT_PIPE_MODE_WRITE;
+	msg.index =3D port->hdlc;
 	msg.data8a =3D NPE_PKT_MODE_HDLC;
 	/* msg.data8b =3D inv_mask */
 	/* msg.data8c =3D or_mask */
 	hss_npe_send(port, &msg, "HSS_SET_PKT_MODE");

 	msg.cmd =3D PKT_PIPE_RX_SIZE_WRITE;
+	msg.index =3D port->hdlc;
 	msg.data16a =3D HDLC_MAX_MRU; /* including CRC */
 	hss_npe_send(port, &msg, "HSS_SET_PKT_RX_SIZE");

 	msg.cmd =3D PKT_PIPE_IDLE_PATTERN_WRITE;
+	msg.index =3D port->hdlc;
 	msg.data32 =3D 0x7F7F7F7F; /* ??? FIXME */
 	hss_npe_send(port, &msg, "HSS_SET_PKT_IDLE");

 	/* Channelized operation settings */
 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_TX_BLK_CFG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data8b =3D (CHAN_TX_LIST_FRAMES & ~7) / 2;
 	msg.data8a =3D msg.data8b / 4;
 	msg.data8d =3D CHAN_TX_LIST_FRAMES - msg.data8b;
@@ -808,14 +938,14 @@

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_RX_BUF_CFG_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data8a =3D CHAN_RX_TRIGGER / 8;
 	msg.data8b =3D CHAN_RX_FRAMES;
 	hss_npe_send(port, &msg, "CHAN_RX_BUF_CFG_WRITE");

 	memset(&msg, 0, sizeof(msg));
 	msg.cmd =3D CHAN_TX_BUF_SIZE_WRITE;
-	msg.hss_port =3D port->id;
+	msg.hss_port =3D port->hss->id;
 	msg.data8a =3D CHAN_TX_LISTS;
 	hss_npe_send(port, &msg, "CHAN_TX_BUF_SIZE_WRITE");

@@ -839,9 +969,9 @@
 	for (i =3D 0; i < len; i++) {
 		if (i >=3D DEBUG_PKT_BYTES)
 			break;
-		printk(KERN_DEBUG "%s%02X", !(i % 4) ? " " : "", data[i]);
+		printk("%s%02X", !(i % 4) ? " " : "", data[i]);
 	}
-	printk(KERN_DEBUG "\n");
+	printk("\n");
 #endif
 }

@@ -862,14 +992,26 @@
 		int queue;
 		char *name;
 	} names[] =3D {
-		{ HSS0_PKT_TX0_QUEUE, "TX#0 " },
+		{ HSS0_PKT_TX0_QUEUE, "TX#0-0 " },
+		{ HSS0_PKT_TX1_QUEUE, "TX#0-1 " },
+		{ HSS0_PKT_TX2_QUEUE, "TX#0-2 " },
+		{ HSS0_PKT_TX3_QUEUE, "TX#0-3 " },
 		{ HSS0_PKT_TXDONE_QUEUE, "TX-done#0 " },
 		{ HSS0_PKT_RX_QUEUE, "RX#0 " },
-		{ HSS0_PKT_RXFREE0_QUEUE, "RX-free#0 " },
-		{ HSS1_PKT_TX0_QUEUE, "TX#1 " },
+		{ HSS0_PKT_RXFREE0_QUEUE, "RX-free#0-0 " },
+		{ HSS0_PKT_RXFREE1_QUEUE, "RX-free#0-1 " },
+		{ HSS0_PKT_RXFREE2_QUEUE, "RX-free#0-2 " },
+		{ HSS0_PKT_RXFREE3_QUEUE, "RX-free#0-3 " },
+		{ HSS1_PKT_TX0_QUEUE, "TX#1-0 " },
+		{ HSS1_PKT_TX1_QUEUE, "TX#1-1 " },
+		{ HSS1_PKT_TX2_QUEUE, "TX#1-2 " },
+		{ HSS1_PKT_TX3_QUEUE, "TX#1-3 " },
 		{ HSS1_PKT_TXDONE_QUEUE, "TX-done#1 " },
 		{ HSS1_PKT_RX_QUEUE, "RX#1 " },
-		{ HSS1_PKT_RXFREE0_QUEUE, "RX-free#1 " },
+		{ HSS1_PKT_RXFREE0_QUEUE, "RX-free#1-0 " },
+		{ HSS1_PKT_RXFREE1_QUEUE, "RX-free#1-1 " },
+		{ HSS1_PKT_RXFREE2_QUEUE, "RX-free#1-2 " },
+		{ HSS1_PKT_RXFREE3_QUEUE, "RX-free#1-3 " },
 	};
 	int i;

@@ -890,16 +1032,12 @@
 	return phys;
 }

-static inline int queue_get_desc(unsigned int queue, struct port *port=
,
-				 int is_tx)
+static inline int phys_to_ndesc(struct port *port, int is_tx, u32 phys=
)
 {
-	u32 phys, tab_phys, n_desc;
+	u32 tab_phys, n_desc;
 	struct desc *tab;

-	if (!(phys =3D queue_get_entry(queue)))
-		return -1;
-
-	BUG_ON(phys & 0x1F);
+	//BUG_ON(phys & 0x1F);
 	tab_phys =3D is_tx ? tx_desc_phys(port, 0) : rx_desc_phys(port, 0);
 	tab =3D is_tx ? tx_desc_ptr(port, 0) : rx_desc_ptr(port, 0);
 	n_desc =3D (phys - tab_phys) / sizeof(struct desc);
@@ -909,12 +1047,23 @@
 	return n_desc;
 }

-static inline void queue_put_desc(unsigned int queue, u32 phys,
-				  struct desc *desc)
+static inline int queue_get_desc(unsigned int queue, struct port *port=
,
+				 int is_tx)
+{
+	u32 phys;
+
+	if (!(phys =3D queue_get_entry(queue)))
+		return -1;
+
+	return phys_to_ndesc(port, is_tx, phys);
+}
+
+static inline void queue_put_desc(unsigned int queue,
+				  u32 phys, struct desc *desc)
 {
 	debug_queue(queue, 0, phys);
 	debug_desc(phys, desc);
-	BUG_ON(phys & 0x1F);
+	//BUG_ON(phys & 0x1F);
 	qmgr_put_entry(queue, phys);
 	BUG_ON(qmgr_stat_overflow(queue));
 }
@@ -950,60 +1099,79 @@
 	spin_unlock_irqrestore(&npe_lock, flags);
 }

-static void hss_hdlc_rx_irq(void *pdev)
+static void hss_hdlc_rx_irq(void *pdev, int hssid)
 {
-	struct net_device *dev =3D pdev;
-	struct port *port =3D dev_to_port(dev);
-
 #if DEBUG_RX
-	printk(KERN_DEBUG "%s: hss_hdlc_rx_irq\n", dev->name);
+	printk(KERN_DEBUG "hss%d: hss_hdlc_rx_irq\n", hssid);
 #endif
-	qmgr_disable_irq(queue_ids[port->id].rx);
-	netif_rx_schedule(dev, &port->napi);
+	qmgr_disable_irq(queue_ids[hssid * 4].rx);
+	napi_schedule(&hss[hssid].napi);
+}
+
+static void hss_hdlc_rx_irq0(void *pdev)
+{
+	hss_hdlc_rx_irq(pdev, 0);
+}
+
+static void hss_hdlc_rx_irq1(void *pdev)
+{
+	hss_hdlc_rx_irq(pdev, 1);
 }

 static int hss_hdlc_poll(struct napi_struct *napi, int budget)
 {
-	struct port *port =3D container_of(napi, struct port, napi);
-	struct net_device *dev =3D port->netdev;
-	unsigned int rxq =3D queue_ids[port->id].rx;
-	unsigned int rxfreeq =3D queue_ids[port->id].rxfree;
-	struct net_device_stats *stats =3D hdlc_stats(dev);
+	struct hss_t *hss =3D container_of(napi, struct hss_t, napi);
+	unsigned int rxq =3D queue_ids[hss->id * 4].rx;
 	int received =3D 0;

 #if DEBUG_RX
-	printk(KERN_DEBUG "%s: hss_hdlc_poll\n", dev->name);
+	printk(KERN_DEBUG "hss%d: hss_hdlc_poll\n", hss->id);
 #endif

 	while (received < budget) {
 		struct sk_buff *skb;
 		struct desc *desc;
-		int n;
+		int n =3D -1;
+		struct port *port =3D NULL;
+		struct net_device *dev =3D NULL;
+		unsigned int rxfreeq =3D -1;
+		struct net_device_stats *stats =3D NULL;
 #ifdef __ARMEB__
 		struct sk_buff *temp;
 		u32 phys;
 #endif
-
-		if ((n =3D queue_get_desc(rxq, port, 0)) < 0) {
+		u32 rxphys =3D queue_get_entry(queue_ids[hss->id * 4].rx);
+		if (rxphys !=3D 0) {
+			u32 npe_id =3D rxphys & 3;
+			BUG_ON(npe_id >=3D HDLC_COUNT);
+			port =3D hss->npe_port_tab[npe_id];
+			if (port !=3D NULL) {
+				dev =3D port->netdev;
+				rxfreeq =3D queue_ids[port->hss->id * 4 + port->hdlc].rxfree;
+				stats =3D hdlc_stats(dev);
+				n =3D phys_to_ndesc(port, 0, rxphys);
+			}
+		}	=09
+		if (n < 0) {
 #if DEBUG_RX
-			printk(KERN_DEBUG "%s: hss_hdlc_poll"
-			       " netif_rx_complete\n", dev->name);
+			printk(KERN_DEBUG "hss%d: hss_hdlc_poll"
+			       " netif_rx_complete\n", hss->id);
 #endif
-			netif_rx_complete(dev, napi);
+			napi_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
-			    netif_rx_reschedule(dev, napi)) {
+			    napi_reschedule(napi)) {
 #if DEBUG_RX
-				printk(KERN_DEBUG "%s: hss_hdlc_poll"
+				printk(KERN_DEBUG "hss%d: hss_hdlc_poll"
 				       " netif_rx_reschedule succeeded\n",
-				       dev->name);
+				       hss->id);
 #endif
 				qmgr_disable_irq(rxq);
 				continue;
 			}
 #if DEBUG_RX
-			printk(KERN_DEBUG "%s: hss_hdlc_poll all done\n",
-			       dev->name);
+			printk(KERN_DEBUG "hss%d: hss_hdlc_poll all done\n",
+			       hss->id);
 #endif
 			return received; /* all work done */
 		}
@@ -1100,38 +1268,52 @@
 	return received;	/* not all work done */
 }

-
-static void hss_hdlc_txdone_irq(void *pdev)
+static void hss_hdlc_txdone_irq(void *pdev, int hssid)
 {
-	struct net_device *dev =3D pdev;
-	struct port *port =3D dev_to_port(dev);
-	struct net_device_stats *stats =3D hdlc_stats(dev);
-	int n_desc;
+	u32 phys;

 #if DEBUG_TX
 	printk(KERN_DEBUG DRV_NAME ": hss_hdlc_txdone_irq\n");
 #endif
-	while ((n_desc =3D queue_get_desc(queue_ids[port->id].txdone,
-					port, 1)) >=3D 0) {
+=09
+	while ((phys =3D queue_get_entry(queue_ids[hssid * 4].txdone)) !=3D 0=
) {
+		u32 npe_id, n_desc;
+		struct port *port;
 		struct desc *desc;
 		int start;

-		desc =3D tx_desc_ptr(port, n_desc);
+		npe_id =3D phys & 3;

-		stats->tx_packets++;
-		stats->tx_bytes +=3D desc->pkt_len;
+		BUG_ON(npe_id >=3D HDLC_COUNT);
+		port =3D hss[hssid].npe_port_tab[npe_id];
+		BUG_ON(!port);
+		phys &=3D ~0x1F; /* mask out non-address bits */
+		n_desc =3D (phys - tx_desc_phys(port, 0)) / sizeof(struct desc);
+		BUG_ON(n_desc >=3D TX_DESCS);
+		desc =3D tx_desc_ptr(port, n_desc);
+		debug_desc(phys, desc);
+		struct net_device *dev =3D port->netdev;
+		struct net_device_stats *stats =3D hdlc_stats(dev);
+
+//#if DEBUG_TX
+//		printk(KERN_DEBUG "hss_hdlc_txdone_irq1\n");
+//#endif
+//		break;
+		if (port->tx_buff_tab[n_desc]) { /* not the draining packet */
+			stats->tx_packets++;
+			stats->tx_bytes +=3D desc->pkt_len;

-		dma_unmap_tx(port, desc);
+			dma_unmap_tx(port, desc);
 #if DEBUG_TX
-		printk(KERN_DEBUG "%s: hss_hdlc_txdone_irq free %p\n",
+			printk(KERN_DEBUG "%s: hss_hdlc_txdone_irq free %p\n",
 		       dev->name, port->tx_buff_tab[n_desc]);
 #endif
-		free_buffer_irq(port->tx_buff_tab[n_desc]);
-		port->tx_buff_tab[n_desc] =3D NULL;
+			free_buffer_irq(port->tx_buff_tab[n_desc]);
+			port->tx_buff_tab[n_desc] =3D NULL;
+		}

 		start =3D qmgr_stat_empty(port->plat->txreadyq);
-		queue_put_desc(port->plat->txreadyq,
-			       tx_desc_phys(port, n_desc), desc);
+		queue_put_desc(port->plat->txreadyq, phys, desc);
 		if (start) {
 #if DEBUG_TX
 			printk(KERN_DEBUG "%s: hss_hdlc_txdone_irq xmit"
@@ -1142,6 +1324,16 @@
 	}
 }

+static void hss_hdlc_txdone_irq0(void *pdev)
+{
+	hss_hdlc_txdone_irq(pdev, 0);
+}
+
+static void hss_hdlc_txdone_irq1(void *pdev)
+{
+	hss_hdlc_txdone_irq(pdev, 1);
+}
+
 static int hss_hdlc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct port *port =3D dev_to_port(dev);
@@ -1205,7 +1397,8 @@
 	desc->buf_len =3D desc->pkt_len =3D len;

 	wmb();
-	queue_put_desc(queue_ids[port->id].tx, tx_desc_phys(port, n), desc);
+	queue_put_desc(queue_ids[port->hss->id * 4 + port->hdlc].tx,
+	               tx_desc_phys(port, n) | port->hdlc, desc);
 	dev->trans_start =3D jiffies;

 	if (qmgr_stat_empty(txreadyq)) {
@@ -1234,15 +1427,17 @@
 {
 	int err;

-	err =3D qmgr_request_queue(queue_ids[port->id].rxfree, RX_DESCS, 0, 0=
);
+	err =3D qmgr_request_queue(queue_ids[port->hss->id * 4 +
port->hdlc].rxfree, RX_DESCS, 0, 0);
 	if (err)
 		return err;

-	err =3D qmgr_request_queue(queue_ids[port->id].rx, RX_DESCS, 0, 0);
-	if (err)
-		goto rel_rxfree;
+	if (!port->hss->hdlc_open) {
+		err =3D qmgr_request_queue(queue_ids[port->hss->id * 4 +
port->hdlc].rx, RX_DESCS, 0, 0);
+		if (err)
+			goto rel_rxfree;
+	}

-	err =3D qmgr_request_queue(queue_ids[port->id].tx, TX_DESCS, 0, 0);
+	err =3D qmgr_request_queue(queue_ids[port->hss->id * 4 +
port->hdlc].tx, TX_DESCS, 0, 0);
 	if (err)
 		goto rel_rx;

@@ -1250,19 +1445,23 @@
 	if (err)
 		goto rel_tx;

-	err =3D qmgr_request_queue(queue_ids[port->id].txdone, TX_DESCS, 0, 0=
);
-	if (err)
-		goto rel_txready;
+	if (!port->hss->hdlc_open) {
+		err =3D qmgr_request_queue(queue_ids[port->hss->id * 4 +
port->hdlc].txdone, TX_DESCS, 0, 0);
+		if (err)
+			goto rel_txready;
+	}
+
 	return 0;

 rel_txready:
 	qmgr_release_queue(port->plat->txreadyq);
 rel_tx:
-	qmgr_release_queue(queue_ids[port->id].tx);
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].tx);
 rel_rx:
-	qmgr_release_queue(queue_ids[port->id].rx);
+	if (!port->hss->hdlc_open)
+		qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].rx);
 rel_rxfree:
-	qmgr_release_queue(queue_ids[port->id].rxfree);
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].rxfree);
 	printk(KERN_DEBUG "%s: unable to request hardware queues\n",
 	       port->netdev->name);
 	return err;
@@ -1270,10 +1469,12 @@

 static void release_hdlc_queues(struct port *port)
 {
-	qmgr_release_queue(queue_ids[port->id].rxfree);
-	qmgr_release_queue(queue_ids[port->id].rx);
-	qmgr_release_queue(queue_ids[port->id].txdone);
-	qmgr_release_queue(queue_ids[port->id].tx);
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].rxfree);
+	if (!port->hss->hdlc_open) {
+		qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].rx);
+		qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].txdone)=
;
+	}
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].tx);
 	qmgr_release_queue(port->plat->txreadyq);
 }

@@ -1281,6 +1482,8 @@
 {
 	int i;

+	port->pending_phys =3D 0;
+=09
 	if (!ports_open)
 		if (!(dma_pool =3D dma_pool_create(DRV_NAME, NULL,
 						 POOL_ALLOC_SIZE, 32, 0)))
@@ -1385,7 +1588,7 @@
 			}

 	if (!port->chan_open_count && port->plat->open)
-		if ((err =3D port->plat->open(port->id, dev,
+		if ((err =3D port->plat->open(port->hss->id, dev,
 					    hss_hdlc_set_carrier)))
 			goto err_unlock;

@@ -1401,21 +1604,40 @@
 			       tx_desc_phys(port, i), tx_desc_ptr(port, i));

 	for (i =3D 0; i < RX_DESCS; i++)
-		queue_put_desc(queue_ids[port->id].rxfree,
-			       rx_desc_phys(port, i), rx_desc_ptr(port, i));
+		queue_put_desc(queue_ids[port->hss->id * 4 + port->hdlc].rxfree,
+		       rx_desc_phys(port, i), rx_desc_ptr(port, i));

-	napi_enable(&port->napi);
+	if (port->hss->hdlc_open =3D=3D 0) {
+		napi_enable(&port->hss->napi);
+	}
 	netif_start_queue(dev);

-	qmgr_set_irq(queue_ids[port->id].rx, QUEUE_IRQ_SRC_NOT_EMPTY,
-		     hss_hdlc_rx_irq, dev);
+	if (port->hss->hdlc_open =3D=3D 0) {
+		if (port->hss->id =3D=3D 0) {
+			qmgr_set_irq(queue_ids[port->hss->id * 4 + port->hdlc].rx,
QUEUE_IRQ_SRC_NOT_EMPTY,
+			     hss_hdlc_rx_irq0, NULL);
+			qmgr_set_irq(queue_ids[port->hss->id * 4 + port->hdlc].txdone,
QUEUE_IRQ_SRC_NOT_EMPTY,
+			     hss_hdlc_txdone_irq0, NULL);
+		}
+		else {
+			qmgr_set_irq(queue_ids[port->hss->id * 4 + port->hdlc].rx,
QUEUE_IRQ_SRC_NOT_EMPTY,
+			     hss_hdlc_rx_irq1, NULL);
+			qmgr_set_irq(queue_ids[port->hss->id * 4 + port->hdlc].txdone,
QUEUE_IRQ_SRC_NOT_EMPTY,
+			     hss_hdlc_txdone_irq1, NULL);
+		}

-	qmgr_set_irq(queue_ids[port->id].txdone, QUEUE_IRQ_SRC_NOT_EMPTY,
-		     hss_hdlc_txdone_irq, dev);
-	qmgr_enable_irq(queue_ids[port->id].txdone);
+		qmgr_enable_irq(queue_ids[port->hss->id * 4 + port->hdlc].txdone);
+	}

 	ports_open++;
 	port->hdlc_open =3D 1;
+	port->hss->hdlc_open++;
+
+	// Init LUT mask
+	for (i =3D 0; i < MAX_CHANNELS; i++) {
+		if ((i % HDLC_COUNT) =3D=3D port->hdlc)
+			port->hss->mask[i] =3D 1;
+	}

 	hss_set_hdlc_cfg(port);
 	hss_config(port);
@@ -1426,7 +1648,7 @@
 	hss_start_hdlc(port);

 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	napi_schedule(&port->hss->napi);
 	return 0;

 err_plat_close:
@@ -1448,21 +1670,29 @@
 	unsigned long flags;
 	int i, buffs =3D RX_DESCS; /* allocated RX buffers */

+	// Init LUT mask
+	for (i =3D 0; i < MAX_CHANNELS; i++) {
+		if ((i % HDLC_COUNT) =3D=3D port->hdlc)
+			port->hss->mask[i] =3D 0;
+	}
+
 	spin_lock_irqsave(&npe_lock, flags);
 	ports_open--;
 	port->hdlc_open =3D 0;
-	qmgr_disable_irq(queue_ids[port->id].rx);
+	port->hss->hdlc_open--;
+	qmgr_disable_irq(queue_ids[port->hss->id * 4 + port->hdlc].rx);
 	netif_stop_queue(dev);
-	napi_disable(&port->napi);
+	if (port->hss->hdlc_open =3D=3D 0)
+		napi_disable(&port->hss->napi);

 	hss_stop_hdlc(port);

 	if (port->mode =3D=3D MODE_G704 && !port->chan_open_count)
 		hss_shutdown_chan(port);

-	while (queue_get_desc(queue_ids[port->id].rxfree, port, 0) >=3D 0)
+	while (queue_get_desc(queue_ids[port->hss->id * 4 +
port->hdlc].rxfree, port, 0) >=3D 0)
 		buffs--;
-	while (queue_get_desc(queue_ids[port->id].rx, port, 0) >=3D 0)
+	while (queue_get_desc(queue_ids[port->hss->id * 4 + port->hdlc].rx,
port, 0) >=3D 0)
 		buffs--;

 	if (buffs)
@@ -1470,7 +1700,7 @@
 		       " left in NPE\n", dev->name, buffs);

 	buffs =3D TX_DESCS;
-	while (queue_get_desc(queue_ids[port->id].tx, port, 1) >=3D 0)
+	while (queue_get_desc(queue_ids[port->hss->id * 4 + port->hdlc].tx,
port, 1) >=3D 0)
 		buffs--; /* cancel TX */

 	i =3D 0;
@@ -1488,7 +1718,7 @@
 	if (!buffs)
 		printk(KERN_DEBUG "Draining TX queues took %i cycles\n", i);
 #endif
-	qmgr_disable_irq(queue_ids[port->id].txdone);
+	qmgr_disable_irq(queue_ids[port->hss->id * 4 + port->hdlc].txdone);

 	if (!port->chan_open_count && port->plat->close)
 		port->plat->close(port->id, dev);
@@ -1800,7 +2030,7 @@
 	printk(KERN_DEBUG DRV_NAME ": hss_chan_irq\n");
 #endif
 	spin_lock(&npe_lock);
-	while ((v =3D qmgr_get_entry(queue_ids[port->id].chan))) {
+	while ((v =3D qmgr_get_entry(queue_ids[port->hss->id * 4 + port->hdlc=
].chan))) {
 		unsigned int first, errors, tx_list, rx_frame;
 		int i, bad;

@@ -1873,7 +2103,7 @@
 {
 	int err;

-	if ((err =3D qmgr_request_queue(queue_ids[port->id].chan,
+	if ((err =3D qmgr_request_queue(queue_ids[port->id * 4 + port->hdlc].=
chan,
 				      CHAN_QUEUE_LEN, 0, 0)))
 		return err;

@@ -1901,9 +2131,9 @@
 		goto unmap_tx;
 	}

-	qmgr_set_irq(queue_ids[port->id].chan, QUEUE_IRQ_SRC_NOT_EMPTY,
+	qmgr_set_irq(queue_ids[port->hss->id * 4 + port->hdlc].chan,
QUEUE_IRQ_SRC_NOT_EMPTY,
 		     hss_chan_irq, port);
-	qmgr_enable_irq(queue_ids[port->id].chan);
+	qmgr_enable_irq(queue_ids[port->hss->id * 4 + port->hdlc].chan);
 	hss_chan_irq(port);
 	return 0;

@@ -1915,7 +2145,7 @@
 	kfree(port->chan_buf);
 	port->chan_buf =3D NULL;
 release_queue:
-	qmgr_release_queue(queue_ids[port->id].chan);
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].chan);
 	return err;
 }

@@ -1923,7 +2153,7 @@
 {
 	hss_stop_chan(port);

-	qmgr_disable_irq(queue_ids[port->id].chan);
+	qmgr_disable_irq(queue_ids[port->hss->id * 4 + port->hdlc].chan);

 	dma_unmap_single(port->dev, port->chan_tx_buf_phys,
 			 chan_tx_buf_len(port) + chan_tx_lists_len(port),
@@ -1932,7 +2162,7 @@
 			 chan_rx_buf_len(port), DMA_FROM_DEVICE);
 	kfree(port->chan_buf);
 	port->chan_buf =3D NULL;
-	qmgr_release_queue(queue_ids[port->id].chan);
+	qmgr_release_queue(queue_ids[port->hss->id * 4 + port->hdlc].chan);
 }

 static int hss_chan_open(struct inode *inode, struct file *file)
@@ -2437,7 +2667,6 @@
 static ssize_t set_clock_rate(struct device *dev, struct
device_attribute *attr,
 			      const char *buf, size_t len)
 {
-#if 0
 	struct port *port =3D dev_get_drvdata(dev);
 	size_t orig_len =3D len;
 	unsigned long flags;
@@ -2453,10 +2682,11 @@

 	spin_lock_irqsave(&npe_lock, flags);
 	port->clock_rate =3D rate;
+	if (port->chan_open_count || port->hdlc_open)
+		hss_config(port);
+
 	spin_unlock_irqrestore(&npe_lock, flags);
 	return orig_len;
-#endif
-	return -EINVAL; /* FIXME not yet supported */
 }

 static ssize_t show_frame_size(struct device *dev,
@@ -2464,9 +2694,6 @@
 {
 	struct port *port =3D dev_get_drvdata(dev);

-	if (port->mode !=3D MODE_RAW && port->mode !=3D MODE_G704)
-		return -EINVAL;
-
 	sprintf(buf, "%u\n", port->frame_size);
 	return strlen(buf) + 1;
 }
@@ -2488,14 +2715,11 @@
 		return -EINVAL;

 	spin_lock_irqsave(&npe_lock, flags);
-	if (port->mode !=3D MODE_RAW && port->mode !=3D MODE_G704)
-		ret =3D -EINVAL;
-	else if (port->chan_open_count || port->hdlc_open)
-		ret =3D -EBUSY;
-	else {
-		port->frame_size =3D size;
-		port->frame_sync_offset =3D 0;
-	}
+	port->frame_size =3D size;
+	port->frame_sync_offset =3D 0;
+	if (port->chan_open_count || port->hdlc_open)
+		hss_config(port);
+
 	spin_unlock_irqrestore(&npe_lock, flags);
 	return ret;
 }
@@ -2630,6 +2854,109 @@
 	return ret;
 }

+static ssize_t show_slots(struct device *dev, struct device_attribute =
*attr,
+			 char *buf)
+{
+	struct port *port =3D dev_get_drvdata(dev);
+	unsigned int slot;
+
+	sprintf(buf, "active slots: ");
+	for (slot =3D 0; slot < MAX_CHANNELS; slot++) {
+		if ((slot % HDLC_COUNT) =3D=3D port->hdlc) {
+			if (port->hss->slots[slot]) {
+				char aux[5];
+				memset(aux, 0, 5);
+				sprintf(aux, " %d", slot / HDLC_COUNT);
+				strcat(buf, aux);
+			}
+		}
+	}
+	strcat(buf, "\n");
+
+	return strlen(buf) + 1;
+}
+
+static ssize_t set_slots(struct device *dev, struct device_attribute *=
attr,
+			const char *buf, size_t len)
+{
+	struct port *port =3D dev_get_drvdata(dev);
+	u8 channels[MAX_CHANNELS];
+	size_t orig_len =3D len;
+	unsigned long flags;
+	unsigned int slot;
+	int err;
+
+	if ((err =3D parse_channels(&buf, &len, channels)) < 0)
+		return err;
+
+	spin_lock_irqsave(&npe_lock, flags);
+
+	if (port->mode !=3D MODE_HDLC) {
+		err =3D -EINVAL;
+		goto err;
+	}
+=09
+	for (slot =3D 0; slot < MAX_CHANNELS/HDLC_COUNT; slot++) {
+		port->hss->slots[slot * HDLC_COUNT + port->hdlc] =3D channels[slot];
+	}
+
+	if (port->hss->hdlc_open)
+		hss_config(port);
+
+	spin_unlock_irqrestore(&npe_lock, flags);
+
+	return orig_len;
+
+err:
+	spin_unlock_irqrestore(&npe_lock, flags);
+	return err;
+}
+
+static ssize_t show_frame_sync(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct port *port =3D dev_get_drvdata(dev);
+
+	strcpy(buf, port->frame_sync_type =3D=3D FRAME_SYNC_EXT?"ext\n":
+				port->frame_sync_type =3D=3D FRAME_SYNC_INT_RISE?"rise\n":"fall\n"=
);
+	return strlen(buf) + 1;
+}
+
+static ssize_t set_frame_sync(struct device *dev, struct
device_attribute *attr,
+			      const char *buf, size_t len)
+{
+	struct port *port =3D dev_get_drvdata(dev);
+	size_t orig_len =3D len;
+	unsigned long flags;
+	unsigned int frame_sync, err;
+
+	if (len && buf[len - 1] =3D=3D '\n')
+		len--;
+
+	if (len > 4)
+		return -EINVAL;
+	if (!memcmp(buf, "ext", 3))
+		frame_sync =3D FRAME_SYNC_EXT;
+	else if (!memcmp(buf, "ris", 3))
+		frame_sync =3D FRAME_SYNC_INT_RISE;
+	else if (!memcmp(buf, "fal", 3))
+		frame_sync =3D FRAME_SYNC_INT_FALL;
+	else
+		return -EINVAL;
+
+	spin_lock_irqsave(&npe_lock, flags);
+	port->frame_sync_type =3D frame_sync;
+	if (port->chan_open_count || port->hdlc_open)
+		hss_config(port);
+
+	spin_unlock_irqrestore(&npe_lock, flags);
+
+	return orig_len;
+err:
+	spin_unlock_irqrestore(&npe_lock, flags);
+	return err;
+}
+
 static struct device_attribute hss_attrs[] =3D {
 	__ATTR(create_chan, 0200, NULL, create_chan),
 	__ATTR(hdlc_chan, 0644, show_hdlc_chan, set_hdlc_chan),
@@ -2639,6 +2966,8 @@
 	__ATTR(frame_offset, 0644, show_frame_offset, set_frame_offset),
 	__ATTR(loopback, 0644, show_loopback, set_loopback),
 	__ATTR(mode, 0644, show_mode, set_mode),
+	__ATTR(slots, 0644, show_slots, set_slots),
+	__ATTR(frame_sync, 0644, show_frame_sync, set_frame_sync),
 };

 /*********************************************************************=
********
@@ -2669,6 +2998,10 @@
 		goto err_plat;
 	}

+	port->hss =3D &hss[port->plat->hss];
+	port->hdlc =3D port->plat->hdlc;
+	port->hss->npe_port_tab[port->hdlc] =3D port;
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	hdlc =3D dev_to_hdlc(dev);
 	hdlc->attach =3D hss_hdlc_attach;
@@ -2677,13 +3010,14 @@
 	dev->stop =3D hss_hdlc_close;
 	dev->do_ioctl =3D hss_hdlc_ioctl;
 	dev->tx_queue_len =3D 100;
-	port->clock_type =3D CLOCK_EXT;
-	port->clock_rate =3D 2048000;
-	port->frame_size =3D 256; /* E1 */
+	port->clock_type =3D CLOCK_EXT; // :TOSEE: If not default value,
unable to config
+	port->frame_sync_type =3D FRAME_SYNC_INT_FALL; // :TOSEE: If not
default value, unable to config
+	port->clock_rate =3D 8192000;
+	port->frame_size =3D 1024; /* 4 * E1 */  // :TOSEE: If not default
value, unable to config
 	memset(port->channels, CHANNEL_UNUSED, sizeof(port->channels));
 	init_waitqueue_head(&port->chan_tx_waitq);
 	init_waitqueue_head(&port->chan_rx_waitq);
-	netif_napi_add(dev, &port->napi, hss_hdlc_poll, NAPI_WEIGHT);
+	netif_napi_add(NULL, &port->hss->napi, hss_hdlc_poll, NAPI_WEIGHT);

 	if ((err =3D register_hdlc_device(dev))) /* HDLC mode by default */
 		goto err_free_netdev;
@@ -2698,8 +3032,8 @@
 	free_netdev(dev);
 err_plat:
 	npe_release(port->npe);
-	platform_set_drvdata(pdev, NULL);
 err_free:
+	platform_set_drvdata(pdev, NULL);
 	kfree(port);
 	return err;
 }
@@ -2713,6 +3047,7 @@
 		device_remove_file(port->dev, &hss_attrs[i]);

 	unregister_hdlc_device(port->netdev);
+	port->hss->npe_port_tab[port->hdlc] =3D NULL;
 	free_netdev(port->netdev);
 	npe_release(port->npe);
 	platform_set_drvdata(pdev, NULL);
@@ -2751,6 +3086,15 @@
 		goto destroy_class;

 	chan_major =3D MAJOR(rdev);
+
+	int hssnum, ch;
+	for (hssnum =3D 0; hssnum < 2; hssnum++) {
+		for (ch =3D 0; ch < MAX_CHANNELS; ch++) {
+			hss[hssnum].slots[ch] =3D 1;
+			hss[hssnum].mask[ch] =3D 0;
+		}
+	}
+
 	return 0;

 destroy_class:
diff -urN linux-2.6.26.7/include/asm-arm/arch-ixp4xx/platform.h
linux-2.6.26.7_hss/include/asm-arm/arch-ixp4xx/platform.h
--- linux-2.6.26.7/include/asm-arm/arch-ixp4xx/platform.h	2008-10-22
23:46:18.000000000 +0200
+++ linux-2.6.26.7_hss/include/asm-arm/arch-ixp4xx/platform.h	2009-02-0=
3
15:50:44.000000000 +0100
@@ -110,6 +110,8 @@
 		    void (*set_carrier_cb)(void *pdev, int carrier));
 	void (*close)(int port, void *pdev);
 	u8 txreadyq;
+	u8 hss;
+	u8 hdlc;
 };

 /*

Thanks

Miguel =C1ngel =C1lvarez
