From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] Add VLAN (802.1q) support to sis900 driver
Date: Mon, 17 Apr 2006 13:25:53 +0200
Message-ID: <20060417112553.GA22890@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-132-98.38-151.net24.it ([151.38.98.132]:47276 "HELO
	renditai.milesteg.arr") by vger.kernel.org with SMTP
	id S1750764AbWDQL0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 07:26:02 -0400
To: NetDev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached patch adds support for VLANs to the sis900 driver and bumps
the version number. It is based on an old (2003) patch for the 2.4
series by Hamid Hashemi Golpayegani. It applies on top of 2.6.16(.5).
I have one report that it works and behaves as intended.
Please review and consider for inclusion.

Signed-off-by: Daniele Venzano <venza@brownhat.org>

-- 
------------------------------
Daniele Venzano
Web: http://teg.homeunix.org

--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="802q.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revisione 130)
+++ b/drivers/net/sis900.c	(copia locale)
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.09 Sep. 19 2005
+   Revision:	1.08.10 Apr. 2 2006
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -17,9 +17,10 @@
    SiS 7014 Single Chip 100BASE-TX/10BASE-T Physical Layer Solution,
    preliminary Rev. 1.0 Jan. 18, 1998
 
+   Rev 1.08.10 Apr.  2 2006 Daniele Venzano add vlan (jumbo packets) support
    Rev 1.08.09 Sep. 19 2005 Daniele Venzano add Wake on LAN support
    Rev 1.08.08 Jan. 22 2005 Daniele Venzano use netif_msg for debugging messages
-   Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
+   Rev 1.08.07 Nov.  2 2003 Daniele Venzano <venza@brownhat.org> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
    Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
    Rev 1.08.04 Apr. 25 2002 Mufasa Yang <mufasa@sis.com.tw> added SiS962 support
@@ -77,7 +78,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.09 Sep. 19 2005"
+#define SIS900_DRV_VERSION "v1.08.10 Apr. 2 2006"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
@@ -1400,6 +1401,11 @@
 		rx_flags |= RxATX;
 	}
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	/* Can accept Jumbo packet */
+	rx_flags |= RxAJAB;
+#endif
+
 	outl (tx_flags, ioaddr + txcfg);
 	outl (rx_flags, ioaddr + rxcfg);
 }
@@ -1712,18 +1718,26 @@
 
 	while (rx_status & OWN) {
 		unsigned int rx_size;
+		unsigned int data_size;
 
 		if (--rx_work_limit < 0)
 			break;
 
-		rx_size = (rx_status & DSIZE) - CRC_SIZE;
+		data_size = rx_status & DSIZE;
+		rx_size = data_size - CRC_SIZE;
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+		/* ``TOOLONG'' flag means jumbo packet recived. */
+		if ((rx_status & TOOLONG) && data_size <= MAX_FRAME_SIZE)
+			rx_status &= (~ ((unsigned int)TOOLONG));
+#endif
+
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
 			if (netif_msg_rx_err(sis_priv))
 				printk(KERN_DEBUG "%s: Corrupted packet "
-				       "received, buffer status = 0x%8.8x.\n",
-				       net_dev->name, rx_status);
+				       "received, buffer status = 0x%8.8x/%d.\n",
+				       net_dev->name, rx_status, data_size);
 			sis_priv->stats.rx_errors++;
 			if (rx_status & OVERRUN)
 				sis_priv->stats.rx_over_errors++;
Index: sis900.h
===================================================================
--- a/drivers/net/sis900.h	(revisione 130)
+++ b/drivers/net/sis900.h	(copia locale)
@@ -310,9 +310,15 @@
 #define CRC_SIZE                4
 #define MAC_HEADER_SIZE         14
 
-#define TX_BUF_SIZE     1536
-#define RX_BUF_SIZE     1536
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define MAX_FRAME_SIZE  (1518 + 4)
+#else
+#define MAX_FRAME_SIZE  1518
+#endif /* CONFIG_VLAN_802_1Q */
 
+#define TX_BUF_SIZE     (MAX_FRAME_SIZE+18)
+#define RX_BUF_SIZE     (MAX_FRAME_SIZE+18)
+
 #define NUM_TX_DESC     16      	/* Number of Tx descriptor registers. */
 #define NUM_RX_DESC     16       	/* Number of Rx descriptor registers. */
 #define TX_TOTAL_SIZE	NUM_TX_DESC*sizeof(BufferDesc)

--qMm9M+Fa2AknHoGS--
