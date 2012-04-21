From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 7/9] pch_gbe: correct receive time stamp filtering
Date: Sat, 21 Apr 2012 06:50:34 +0200
Message-ID: <5678b66eb82302bf55fee639afd2f906eb97c806.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47181 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089Ab2DUEvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:51:07 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so6444599wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:51:07 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

This patch fixes the driver so that multicast PTP event messages can
be recognized by the hardware time stamping unit. The station address
register must be set according to the desired transport type.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   14 +++++++++++++-
 drivers/ptp/Kconfig                                |   10 +++++++---
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 799a85a..53ac2fb 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -111,6 +111,9 @@ const char pch_driver_version[] = DRV_VERSION;
 /* 0x44 Time Synchronization Channel Event Register Bits */
 #define TX_SNAPSHOT_LOCKED (1<<0)
 #define RX_SNAPSHOT_LOCKED (1<<1)
+
+#define PTP_L4_MULTICAST_SA "01:00:5e:00:01:81"
+#define PTP_L2_MULTICAST_SA "01:1b:19:00:00:00"
 #endif
 
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
@@ -236,6 +239,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	struct hwtstamp_config cfg;
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev;
+	u8 station[20];
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
 		return -EFAULT;
@@ -269,9 +273,17 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		adapter->hwts_rx_en = 1;
 		pch_ch_control_write(pdev, MASTER_MODE | CAP_MODE0);
 		break;
-	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+		adapter->hwts_rx_en = 1;
+		pch_ch_control_write(pdev, V2_MODE | CAP_MODE2);
+		strcpy(station, PTP_L4_MULTICAST_SA);
+		pch_set_station_address(station, pdev);
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
 		adapter->hwts_rx_en = 1;
 		pch_ch_control_write(pdev, V2_MODE | CAP_MODE2);
+		strcpy(station, PTP_L2_MULTICAST_SA);
+		pch_set_station_address(station, pdev);
 		break;
 	default:
 		return -ERANGE;
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index cd9bc3b..5648dad 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -78,9 +78,13 @@ config PTP_1588_CLOCK_PCH
 	depends on PCH_GBE
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
-	  clock. This clock is only useful if your PTP programs are
-	  getting hardware time stamps on the PTP Ethernet packets
-	  using the SO_TIMESTAMPING API.
+	  clock. The hardware supports time stamping of PTP packets
+	  when using the end-to-end delay (E2E) mechansim. The peer
+	  delay mechansim (P2P) is not supported.
+
+	  This clock is only useful if your PTP programs are getting
+	  hardware time stamps on the PTP Ethernet packets using the
+	  SO_TIMESTAMPING API.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_pch.
-- 
1.7.2.5
