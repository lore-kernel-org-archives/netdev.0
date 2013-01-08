From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1 net-next] net: fec: enable pause frame to improve rx prefomance for 1G network
Date: Tue, 8 Jan 2013 16:43:29 +0800
Message-ID: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:35315
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084Ab3AHJWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 04:22:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
There will be many packages lost because FIFO over run.

This patch enable pause frame flow control.

Before this patch
iperf -s -i 1
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.192.242.153 port 5001 connected with 10.192.242.94 port 49773
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 1.0 sec  6.35 MBytes  53.3 Mbits/sec
[  4]  1.0- 2.0 sec  3.39 MBytes  28.5 Mbits/sec
[  4]  2.0- 3.0 sec  2.63 MBytes  22.1 Mbits/sec
[  4]  3.0- 4.0 sec  1.10 MBytes  9.23 Mbits/sec

ifconfig
   RX packets:46195 errors:1859 dropped:1 overruns:1859 frame:1859

After this patch
iperf -s -i 1

[  4] local 10.192.242.153 port 5001 connected with 10.192.242.94 port 49757
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 1.0 sec  49.8 MBytes   418 Mbits/sec
[  4]  1.0- 2.0 sec  50.1 MBytes   420 Mbits/sec
[  4]  2.0- 3.0 sec  47.5 MBytes   399 Mbits/sec
[  4]  3.0- 4.0 sec  45.9 MBytes   385 Mbits/sec
[  4]  4.0- 5.0 sec  44.8 MBytes   376 Mbits/sec

ifconfig
   RX packets:2348454 errors:0 dropped:16 overruns:0 frame:0

Signed-off-by: Frank Li <Frank.Li@freescale.com>
Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   26 ++++++++++++++++++++++++++
 drivers/net/ethernet/freescale/fec.h |    4 ++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 6dc2094..4928260 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -68,6 +68,14 @@
 
 #define DRIVER_NAME	"fec"
 
+/* Pause frame feild and FIFO threshold */
+#define FEC_ENET_FCE	(1 << 5)
+#define FEC_ENET_RSEM_V	0x84
+#define FEC_ENET_RSFL_V	16
+#define FEC_ENET_RAEM_V	0x8
+#define FEC_ENET_RAFL_V	0x8
+#define FEC_ENET_OPD_V	0xFFF0
+
 /* Controller is ENET-MAC */
 #define FEC_QUIRK_ENET_MAC		(1 << 0)
 /* Controller needs driver to swap frame */
@@ -470,6 +478,21 @@ fec_restart(struct net_device *ndev, int duplex)
 		}
 #endif
 	}
+
+	/* enable pause frame*/
+	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
+		rcntl |= FEC_ENET_FCE;
+
+		/* set FIFO thresh hold parameter to reduce overrun */
+		writel(FEC_ENET_RSEM_V, fep->hwp + FEC_R_FIFO_RSEM);
+		writel(FEC_ENET_RSFL_V, fep->hwp + FEC_R_FIFO_RSFL);
+		writel(FEC_ENET_RAEM_V, fep->hwp + FEC_R_FIFO_RAEM);
+		writel(FEC_ENET_RAFL_V, fep->hwp + FEC_R_FIFO_RAFL);
+
+		/* OPD */
+		writel(FEC_ENET_OPD_V, fep->hwp + FEC_OPD);
+	}
+
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
@@ -1021,6 +1044,9 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	else
 		phy_dev->supported &= PHY_BASIC_FEATURES;
 
+	/* enable phy pause frame for any platform */
+	phy_dev->supported |= ADVERTISED_Pause;
+
 	phy_dev->advertising = phy_dev->supported;
 
 	fep->phy_dev = phy_dev;
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 4862394..7dac581 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -48,6 +48,10 @@
 #define FEC_R_DES_START		0x180 /* Receive descriptor ring */
 #define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
 #define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
+#define FEC_R_FIFO_RSFL		0x190 /* Receive FIFO section full threshold */
+#define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
+#define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
+#define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold */
 #define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
 #define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
 
-- 
1.7.1
