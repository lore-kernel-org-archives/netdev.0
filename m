From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH 2/2] net/pch_gbe: Changed PTP supporting mode
Date: Fri, 23 Mar 2012 11:18:59 +0900
Message-ID: <1332469139-2654-2-git-send-email-tshimizu818@gmail.com>
References: <1332469139-2654-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332469139-2654-1-git-send-email-tshimizu818@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    1 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index dd14915..9f3dbc4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -660,6 +660,7 @@ extern u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
 extern u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
 extern u64 pch_rx_snap_read(struct pci_dev *pdev);
 extern u64 pch_tx_snap_read(struct pci_dev *pdev);
+extern int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
 #endif
 
 /* pch_gbe_param.c */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 56089ca..776bcf2 100644
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
@@ -235,6 +238,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	struct hwtstamp_config cfg;
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev;
+	u8 station[20];
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
 		return -EFAULT;
@@ -268,9 +272,17 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
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
-- 
1.7.4.4
