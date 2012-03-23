From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH 2/2] net/pch_gbe: Modified according to the mainter's comments
Date: Fri, 23 Mar 2012 11:12:40 +0900
Message-ID: <1332468760-2525-2-git-send-email-tshimizu818@gmail.com>
References: <1332468760-2525-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332468760-2525-1-git-send-email-tshimizu818@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   35 ++++++++-----------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 8035e5f..d983e76 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -101,13 +101,11 @@ const char pch_driver_version[] = DRV_VERSION;
 
 #ifdef CONFIG_PCH_PTP
 /* Macros for ieee1588 */
-#define TICKS_NS_SHIFT  5
-
 /* 0x40 Time Synchronization Channel Control Register Bits */
 #define MASTER_MODE   (1<<0)
-#define SLAVE_MODE    (0<<0)
+#define SLAVE_MODE    (0)
 #define V2_MODE       (1<<31)
-#define CAP_MODE0     (0<<16)
+#define CAP_MODE0     (0)
 #define CAP_MODE2     (1<<17)
 
 /* 0x44 Time Synchronization Channel Event Register Bits */
@@ -129,14 +127,13 @@ static struct sock_filter ptp_filter[] = {
 static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
 {
 	u8 *data = skb->data;
-	unsigned int offset;
+	unsigned int offset, sk_filter;
 	u16 *hi, *id;
 	u32 lo;
 
-	if ((sk_run_filter(skb, ptp_filter) != PTP_CLASS_V2_IPV4) &&
-		(sk_run_filter(skb, ptp_filter) != PTP_CLASS_V1_IPV4)) {
+	sk_filter = sk_run_filter(skb, ptp_filter);
+	if ((sk_filter != PTP_CLASS_V2) && (sk_filter != PTP_CLASS_V1))
 		return 0;
-	}
 
 	offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
 
@@ -153,8 +150,8 @@ static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
 		seqid  == *id);
 }
 
-static void pch_rx_timestamp(
-			struct pch_gbe_adapter *adapter, struct sk_buff *skb)
+static void
+pch_rx_timestamp(struct pch_gbe_adapter *adapter, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamps;
 	struct pci_dev *pdev;
@@ -183,7 +180,6 @@ static void pch_rx_timestamp(
 		goto out;
 
 	ns = pch_rx_snap_read(pdev);
-	ns <<= TICKS_NS_SHIFT;
 
 	shhwtstamps = skb_hwtstamps(skb);
 	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
@@ -192,8 +188,8 @@ out:
 	pch_ch_event_write(pdev, RX_SNAPSHOT_LOCKED);
 }
 
-static void pch_tx_timestamp(
-			struct pch_gbe_adapter *adapter, struct sk_buff *skb)
+static void
+pch_tx_timestamp(struct pch_gbe_adapter *adapter, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps shhwtstamps;
 	struct pci_dev *pdev;
@@ -202,11 +198,11 @@ static void pch_tx_timestamp(
 	u32 cnt, val;
 
 	shtx = skb_shinfo(skb);
-	if (unlikely(shtx->tx_flags & SKBTX_HW_TSTAMP && adapter->hwts_tx_en))
-		shtx->tx_flags |= SKBTX_IN_PROGRESS;
-	else
+	if (likely(!(shtx->tx_flags & SKBTX_HW_TSTAMP && adapter->hwts_tx_en)))
 		return;
 
+	shtx->tx_flags |= SKBTX_IN_PROGRESS;
+
 	/* Get ieee1588's dev information */
 	pdev = adapter->ptp_pdev;
 
@@ -226,7 +222,6 @@ static void pch_tx_timestamp(
 	}
 
 	ns = pch_tx_snap_read(pdev);
-	ns <<= TICKS_NS_SHIFT;
 
 	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 	shhwtstamps.hwtstamp = ns_to_ktime(ns);
@@ -267,15 +262,15 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		adapter->hwts_rx_en = 0;
-		pch_ch_control_write(pdev, (SLAVE_MODE | CAP_MODE0));
+		pch_ch_control_write(pdev, SLAVE_MODE | CAP_MODE0);
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		adapter->hwts_rx_en = 1;
-		pch_ch_control_write(pdev, (MASTER_MODE | CAP_MODE0));
+		pch_ch_control_write(pdev, MASTER_MODE | CAP_MODE0);
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 		adapter->hwts_rx_en = 1;
-		pch_ch_control_write(pdev, (V2_MODE | CAP_MODE2));
+		pch_ch_control_write(pdev, V2_MODE | CAP_MODE2);
 		break;
 	default:
 		return -ERANGE;
-- 
1.7.4.4
