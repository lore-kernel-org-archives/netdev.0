From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] igb/igbvf: set rx csum always enabled in hw,
	disable via sw
Date: Wed, 06 May 2009 13:25:23 -0700
Message-ID: <20090506202523.17149.34162.stgit@localhost.localdomain>
References: <20090506202450.17149.18959.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:60557
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbZEFUZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:25:41 -0400
In-Reply-To: <20090506202450.17149.18959.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

An issue was found in which rx checksum could not be enabled without
resetting the interface.  The issue was the hardware enable was not being
done via ethtool.  To resolve this issue and prevent conflicts with VF
configuration we will leave the feature always enabled in hardware, and
then in software we will choose to ignore the results via a sw flag.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    2 +-
 drivers/net/igb/igb_ethtool.c |    8 ++++++--
 drivers/net/igb/igb_main.c    |   12 +++++-------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 4e8464b..154c5ac 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -238,7 +238,6 @@ struct igb_adapter {
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 	u32 alloc_rx_buff_failed;
-	bool rx_csum;
 	u32 gorc;
 	u64 gorc_old;
 	u16 rx_ps_hdr_size;
@@ -286,6 +285,7 @@ struct igb_adapter {
 #define IGB_FLAG_DCA_ENABLED       (1 << 1)
 #define IGB_FLAG_QUAD_PORT_A       (1 << 2)
 #define IGB_FLAG_NEED_CTX_IDX      (1 << 3)
+#define IGB_FLAG_RX_CSUM_DISABLED  (1 << 4)
 
 enum e1000_state_t {
 	__IGB_TESTING,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index b1367ce..b8551a5 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -275,13 +275,17 @@ static int igb_set_pauseparam(struct net_device *netdev,
 static u32 igb_get_rx_csum(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	return adapter->rx_csum;
+	return !(adapter->flags & IGB_FLAG_RX_CSUM_DISABLED);
 }
 
 static int igb_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	adapter->rx_csum = data;
+
+	if (data)
+		adapter->flags &= ~IGB_FLAG_RX_CSUM_DISABLED;
+	else
+		adapter->flags |= IGB_FLAG_RX_CSUM_DISABLED;
 
 	return 0;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bca7e9f..8de8629 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1395,8 +1395,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	igb_validate_mdi_setting(hw);
 
-	adapter->rx_csum = 1;
-
 	/* Initial Wake on LAN setting If APM wake is enabled in the EEPROM,
 	 * enable the ACPI Magic Packet filter
 	 */
@@ -2249,13 +2247,12 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	rxcsum = rd32(E1000_RXCSUM);
 	/* Disable raw packet checksumming */
 	rxcsum |= E1000_RXCSUM_PCSD;
-	/* Don't need to set TUOFL or IPOFL, they default to 1 */
-	if (!adapter->rx_csum)
-		rxcsum &= ~(E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPOFL);
-	else if (adapter->hw.mac.type == e1000_82576)
+
+	if (adapter->hw.mac.type == e1000_82576)
 		/* Enable Receive Checksum Offload for SCTP */
 		rxcsum |= E1000_RXCSUM_CRCOFL;
 
+	/* Don't need to set TUOFL or IPOFL, they default to 1 */
 	wr32(E1000_RXCSUM, rxcsum);
 
 	/* Set the default pool for the PF's first queue */
@@ -4455,7 +4452,8 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Ignore Checksum bit is set or checksum is disabled through ethtool */
-	if ((status_err & E1000_RXD_STAT_IXSM) || !adapter->rx_csum)
+	if ((status_err & E1000_RXD_STAT_IXSM) ||
+	    (adapter->flags & IGB_FLAG_RX_CSUM_DISABLED))
 		return;
 	/* TCP/UDP checksum error bit is set */
 	if (status_err &

