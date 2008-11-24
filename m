From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Mon, 24 Nov 2008 13:15:54 +0100
Message-ID: <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <m3fxlksncm.fsf@maximus.localdomain>
	 <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:6502 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbYKXMP4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:15:56 -0500
Received: by rn-out-0910.google.com with SMTP id k40so1604621rnd.17
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 04:15:55 -0800 (PST)
In-Reply-To: <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I show you here the first steps of the adding of a physical_mode
configuration for ixp4xx_hss. The changes are not complete at all, but
I wanted to send this just to get some initial impressions.

diff -urN linux-2.6.26.7_hssorig/arch/arm/mach-ixp4xx/ixdp425-setup.c
linux-2.6.26.7/arch/arm/mach-ixp4xx/ixdp425-setup.c
--- linux-2.6.26.7_hssorig/arch/arm/mach-ixp4xx/ixdp425-setup.c	2008-11=
-24
11:21:07.000000000 +0100
+++ linux-2.6.26.7/arch/arm/mach-ixp4xx/ixdp425-setup.c	2008-11-24
11:29:05.000000000 +0100
@@ -350,11 +350,13 @@
 		.open		=3D hss_open,
 		.close		=3D hss_close,
 		.txreadyq	=3D 2,
+		.physical_mode =3D IXP4XX_HSS_4_E1,
 	}, {
 		.set_clock	=3D hss_set_clock,
 		.open		=3D hss_open,
 		.close		=3D hss_close,
 		.txreadyq	=3D 19,
+		.physical_mode =3D IXP4XX_HSS_4_E1,
 	}
 };

diff -urN linux-2.6.26.7_hssorig/drivers/net/wan/ixp4xx_hss.c
linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c
--- linux-2.6.26.7_hssorig/drivers/net/wan/ixp4xx_hss.c	2008-11-24
11:22:09.000000000 +0100
+++ linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c	2008-11-24
12:55:26.000000000 +0100
@@ -302,6 +302,7 @@
 	/* assigned channels, may be invalid with given frame length or mode =
*/
 	u8 channels[MAX_CHANNELS];
 	int msg_count;
+	u8 phmode_pos;
 };

 /* NPE message structure */
@@ -388,6 +389,21 @@
 		  HSS1_PKT_RXFREE0_QUEUE, HSS1_CHL_RXTRIG_QUEUE},
 };

+struct physical_modes {
+	u8 id;
+	unsigned int frame_size;
+	unsigned int clock_rate;
+	u32 clock_config;
+};
+
+static const struct physical_modes phmodes[] =3D {
+	{IXP4XX_HSS_T1, 193, 1544000, CLK42X_SPEED_1544KHZ},
+	{IXP4XX_HSS_E1, 256, 2048000, CLK42X_SPEED_2048KHZ},
+	{IXP4XX_HSS_2_E1, 512, 4096000, CLK42X_SPEED_4096KHZ},
+	{IXP4XX_HSS_4_E1, 1024, 8192000, CLK42X_SPEED_8192KHZ},
+	{0, 256, 2048000, CLK42X_SPEED_2048KHZ}
+};
+
 /*********************************************************************=
********
  * utility functions
  *********************************************************************=
*******/
@@ -624,7 +640,7 @@
 	msg.cmd =3D PORT_CONFIG_WRITE;
 	msg.hss_port =3D port->id;
 	msg.index =3D HSS_CONFIG_CLOCK_CR;
-	msg.data32 =3D CLK42X_SPEED_2048KHZ /* FIXME */;
+	msg.data32 =3D phmodes[port->phmode_pos].clock_config;
 	hss_npe_send(port, &msg, "HSS_SET_CLOCK_CR");

 	memset(&msg, 0, sizeof(msg));
@@ -2459,6 +2475,7 @@
 	return -EINVAL; /* FIXME not yet supported */
 }

+#if 0
 static ssize_t show_frame_size(struct device *dev,
 			       struct device_attribute *attr, char *buf)
 {
@@ -2499,6 +2516,7 @@
 	spin_unlock_irqrestore(&npe_lock, flags);
 	return ret;
 }
+#endif

 static ssize_t show_frame_offset(struct device *dev,
 				 struct device_attribute *attr, char *buf)
@@ -2635,7 +2653,7 @@
 	__ATTR(hdlc_chan, 0644, show_hdlc_chan, set_hdlc_chan),
 	__ATTR(clock_type, 0644, show_clock_type, set_clock_type),
 	__ATTR(clock_rate, 0644, show_clock_rate, set_clock_rate),
-	__ATTR(frame_size, 0644, show_frame_size, set_frame_size),
+	//__ATTR(frame_size, 0644, show_frame_size, set_frame_size),
 	__ATTR(frame_offset, 0644, show_frame_offset, set_frame_offset),
 	__ATTR(loopback, 0644, show_loopback, set_loopback),
 	__ATTR(mode, 0644, show_mode, set_mode),
@@ -2651,6 +2669,7 @@
 	struct net_device *dev;
 	hdlc_device *hdlc;
 	int i, err;
+	struct physical_modes* mode;

 	if ((port =3D kzalloc(sizeof(*port), GFP_KERNEL)) =3D=3D NULL)
 		return -ENOMEM;
@@ -2669,6 +2688,17 @@
 		goto err_plat;
 	}

+	i =3D 0;
+	mode =3D &phmodes[0];
+	while (mode->id !=3D 0) {
+		if (mode->id =3D=3D port->plat->physical_mode) {
+			port->phmode_pos =3D i;
+			break;
+		}
+		i++;
+		mode =3D &phmodes[i];
+	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	hdlc =3D dev_to_hdlc(dev);
 	hdlc->attach =3D hss_hdlc_attach;
@@ -2678,8 +2708,8 @@
 	dev->do_ioctl =3D hss_hdlc_ioctl;
 	dev->tx_queue_len =3D 100;
 	port->clock_type =3D CLOCK_EXT;
-	port->clock_rate =3D 2048000;
-	port->frame_size =3D 256; /* E1 */
+	port->clock_rate =3D mode->clock_rate;
+	port->frame_size =3D mode->frame_size;
 	memset(port->channels, CHANNEL_UNUSED, sizeof(port->channels));
 	init_waitqueue_head(&port->chan_tx_waitq);
 	init_waitqueue_head(&port->chan_rx_waitq);
diff -urN linux-2.6.26.7_hssorig/include/asm-arm/arch-ixp4xx/platform.h
linux-2.6.26.7/include/asm-arm/arch-ixp4xx/platform.h
--- linux-2.6.26.7_hssorig/include/asm-arm/arch-ixp4xx/platform.h	2008-=
11-24
11:22:42.000000000 +0100
+++ linux-2.6.26.7/include/asm-arm/arch-ixp4xx/platform.h	2008-11-24
12:06:42.000000000 +0100
@@ -103,6 +103,11 @@
 	u8 hwaddr[6];
 };

+#define IXP4XX_HSS_T1     0x10
+#define IXP4XX_HSS_E1     0x11
+#define IXP4XX_HSS_2_E1   0x21
+#define IXP4XX_HSS_4_E1   0x41
+
 /* Information about built-in HSS (synchronous serial) interfaces */
 struct hss_plat_info {
 	int (*set_clock)(int port, unsigned int clock_type);
@@ -110,6 +115,7 @@
 		    void (*set_carrier_cb)(void *pdev, int carrier));
 	void (*close)(int port, void *pdev);
 	u8 txreadyq;
+	u8 physical_mode;
 };

 /*

I have some questions to continue the changes:
- How should all these changes interact with show_frame_size and set_fr=
ame_size?
- I am a bit lost with MAX_CHANNELS and MAX_CHAN_DEVICES... Which are
the differences between both?
- As MAX_CHANNELS and MAX_CHAN_DEVICES should not be set by defines, I
am going to alloc memory for chan_devices... I am going to do it in
init_one... Is it OK?.

My first intention for all this is to set HSS into MVIP mode and have
4 HDLC channels in a packetized mode.
- How could I set this MVIP mode?
- How could I interface with generic HDLC so that hss_hdlc_xmit sends
the data for each stream to a different FIFO?

Thanks

Miguel =C1ngel =C1lvarez
