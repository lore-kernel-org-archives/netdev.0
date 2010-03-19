From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbevf: Fix VF Stats accounting after reset
Date: Fri, 19 Mar 2010 05:59:52 -0700
Message-ID: <20100319125950.9799.70157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:34173
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162Ab0CSNAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 09:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The counters in the 82599 Virtual Function are not clear on read.  They
accumulate to the maximum value and then roll over.  They are also not
cleared when the VF executes a soft reset, so it is possible they are
non-zero when the driver loads and starts.  This has all been accounted
for in the code that keeps the stats up to date but there is one case
that is not.  When the PF driver is reset the counters in the VF are
all reset to zero.  This adds an additional accounting overhead into
the VF driver when the PF is reset under its feet.  This patch adds
additional counters that are used by the VF driver to accumulate and
save stats after a PF reset has been detected.  Prior to this patch
displaying the stats in the VF after the PF has reset would show
bogus data.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ethtool.c      |   42 +++++++++++++++-------
 drivers/net/ixgbevf/ixgbevf_main.c |   68 +++++++++++++++++++++++-------------
 drivers/net/ixgbevf/vf.h           |    6 +++
 3 files changed, 78 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 399be0c..6fdd651 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -46,22 +46,32 @@ struct ixgbe_stats {
 	int sizeof_stat;
 	int stat_offset;
 	int base_stat_offset;
+	int saved_reset_offset;
 };
 
-#define IXGBEVF_STAT(m, b)  sizeof(((struct ixgbevf_adapter *)0)->m), \
-			    offsetof(struct ixgbevf_adapter, m),      \
-			    offsetof(struct ixgbevf_adapter, b)
+#define IXGBEVF_STAT(m, b, r)  sizeof(((struct ixgbevf_adapter *)0)->m), \
+			    offsetof(struct ixgbevf_adapter, m),         \
+			    offsetof(struct ixgbevf_adapter, b),         \
+			    offsetof(struct ixgbevf_adapter, r)
 static struct ixgbe_stats ixgbe_gstrings_stats[] = {
-	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc)},
-	{"tx_packets", IXGBEVF_STAT(stats.vfgptc, stats.base_vfgptc)},
-	{"rx_bytes", IXGBEVF_STAT(stats.vfgorc, stats.base_vfgorc)},
-	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc)},
-	{"tx_busy", IXGBEVF_STAT(tx_busy, zero_base)},
-	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc)},
-	{"rx_csum_offload_good", IXGBEVF_STAT(hw_csum_rx_good, zero_base)},
-	{"rx_csum_offload_errors", IXGBEVF_STAT(hw_csum_rx_error, zero_base)},
-	{"tx_csum_offload_ctxt", IXGBEVF_STAT(hw_csum_tx_good, zero_base)},
-	{"rx_header_split", IXGBEVF_STAT(rx_hdr_split, zero_base)},
+	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc,
+				    stats.saved_reset_vfgprc)},
+	{"tx_packets", IXGBEVF_STAT(stats.vfgptc, stats.base_vfgptc,
+				    stats.saved_reset_vfgptc)},
+	{"rx_bytes", IXGBEVF_STAT(stats.vfgorc, stats.base_vfgorc,
+				  stats.saved_reset_vfgorc)},
+	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc,
+				  stats.saved_reset_vfgotc)},
+	{"tx_busy", IXGBEVF_STAT(tx_busy, zero_base, zero_base)},
+	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc,
+				   stats.saved_reset_vfmprc)},
+	{"rx_csum_offload_good", IXGBEVF_STAT(hw_csum_rx_good, zero_base,
+					      zero_base)},
+	{"rx_csum_offload_errors", IXGBEVF_STAT(hw_csum_rx_error, zero_base,
+						zero_base)},
+	{"tx_csum_offload_ctxt", IXGBEVF_STAT(hw_csum_tx_good, zero_base,
+					      zero_base)},
+	{"rx_header_split", IXGBEVF_STAT(rx_hdr_split, zero_base, zero_base)},
 };
 
 #define IXGBE_QUEUE_STATS_LEN 0
@@ -455,10 +465,14 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 			ixgbe_gstrings_stats[i].stat_offset;
 		char *b = (char *)adapter +
 			ixgbe_gstrings_stats[i].base_stat_offset;
+		char *r = (char *)adapter +
+			ixgbe_gstrings_stats[i].saved_reset_offset;
 		data[i] = ((ixgbe_gstrings_stats[i].sizeof_stat ==
 			    sizeof(u64)) ? *(u64 *)p : *(u32 *)p) -
 			  ((ixgbe_gstrings_stats[i].sizeof_stat ==
-			    sizeof(u64)) ? *(u64 *)b : *(u32 *)b);
+			    sizeof(u64)) ? *(u64 *)b : *(u32 *)b) +
+			  ((ixgbe_gstrings_stats[i].sizeof_stat ==
+			    sizeof(u64)) ? *(u64 *)r : *(u32 *)r);
 	}
 }
 
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index ca653c4..43927e1 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1610,6 +1610,44 @@ static inline void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
 				(adapter->rx_ring[rxr].count - 1));
 }
 
+static void ixgbevf_save_reset_stats(struct ixgbevf_adapter *adapter)
+{
+	/* Only save pre-reset stats if there are some */
+	if (adapter->stats.vfgprc || adapter->stats.vfgptc) {
+		adapter->stats.saved_reset_vfgprc += adapter->stats.vfgprc -
+			adapter->stats.base_vfgprc;
+		adapter->stats.saved_reset_vfgptc += adapter->stats.vfgptc -
+			adapter->stats.base_vfgptc;
+		adapter->stats.saved_reset_vfgorc += adapter->stats.vfgorc -
+			adapter->stats.base_vfgorc;
+		adapter->stats.saved_reset_vfgotc += adapter->stats.vfgotc -
+			adapter->stats.base_vfgotc;
+		adapter->stats.saved_reset_vfmprc += adapter->stats.vfmprc -
+			adapter->stats.base_vfmprc;
+	}
+}
+
+static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	adapter->stats.last_vfgprc = IXGBE_READ_REG(hw, IXGBE_VFGPRC);
+	adapter->stats.last_vfgorc = IXGBE_READ_REG(hw, IXGBE_VFGORC_LSB);
+	adapter->stats.last_vfgorc |=
+		(((u64)(IXGBE_READ_REG(hw, IXGBE_VFGORC_MSB))) << 32);
+	adapter->stats.last_vfgptc = IXGBE_READ_REG(hw, IXGBE_VFGPTC);
+	adapter->stats.last_vfgotc = IXGBE_READ_REG(hw, IXGBE_VFGOTC_LSB);
+	adapter->stats.last_vfgotc |=
+		(((u64)(IXGBE_READ_REG(hw, IXGBE_VFGOTC_MSB))) << 32);
+	adapter->stats.last_vfmprc = IXGBE_READ_REG(hw, IXGBE_VFMPRC);
+
+	adapter->stats.base_vfgprc = adapter->stats.last_vfgprc;
+	adapter->stats.base_vfgorc = adapter->stats.last_vfgorc;
+	adapter->stats.base_vfgptc = adapter->stats.last_vfgptc;
+	adapter->stats.base_vfgotc = adapter->stats.last_vfgotc;
+	adapter->stats.base_vfmprc = adapter->stats.last_vfmprc;
+}
+
 static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1656,6 +1694,9 @@ static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	/* enable transmits */
 	netif_tx_start_all_queues(netdev);
 
+	ixgbevf_save_reset_stats(adapter);
+	ixgbevf_init_last_counter_stats(adapter);
+
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
@@ -2228,27 +2269,6 @@ out:
 	return err;
 }
 
-static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	adapter->stats.last_vfgprc = IXGBE_READ_REG(hw, IXGBE_VFGPRC);
-	adapter->stats.last_vfgorc = IXGBE_READ_REG(hw, IXGBE_VFGORC_LSB);
-	adapter->stats.last_vfgorc |=
-		(((u64)(IXGBE_READ_REG(hw, IXGBE_VFGORC_MSB))) << 32);
-	adapter->stats.last_vfgptc = IXGBE_READ_REG(hw, IXGBE_VFGPTC);
-	adapter->stats.last_vfgotc = IXGBE_READ_REG(hw, IXGBE_VFGOTC_LSB);
-	adapter->stats.last_vfgotc |=
-		(((u64)(IXGBE_READ_REG(hw, IXGBE_VFGOTC_MSB))) << 32);
-	adapter->stats.last_vfmprc = IXGBE_READ_REG(hw, IXGBE_VFMPRC);
-
-	adapter->stats.base_vfgprc = adapter->stats.last_vfgprc;
-	adapter->stats.base_vfgorc = adapter->stats.last_vfgorc;
-	adapter->stats.base_vfgptc = adapter->stats.last_vfgptc;
-	adapter->stats.base_vfgotc = adapter->stats.last_vfgotc;
-	adapter->stats.base_vfmprc = adapter->stats.last_vfmprc;
-}
-
 #define UPDATE_VF_COUNTER_32bit(reg, last_counter, counter)	\
 	{							\
 		u32 current_counter = IXGBE_READ_REG(hw, reg);	\
@@ -2416,9 +2436,9 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 		}
 	}
 
-pf_has_reset:
 	ixgbevf_update_stats(adapter);
 
+pf_has_reset:
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = true;
 
@@ -3390,8 +3410,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	/* setup the private structure */
 	err = ixgbevf_sw_init(adapter);
 
-	ixgbevf_init_last_counter_stats(adapter);
-
 #ifdef MAX_SKB_FRAGS
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
@@ -3449,6 +3467,8 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 
 	adapter->netdev_registered = true;
 
+	ixgbevf_init_last_counter_stats(adapter);
+
 	/* print the MAC address */
 	hw_dbg(hw, "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
 	       netdev->dev_addr[0],
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 799600e..1f31b05 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -157,6 +157,12 @@ struct ixgbevf_hw_stats {
 	u64 vfgorc;
 	u64 vfgotc;
 	u64 vfmprc;
+
+	u64 saved_reset_vfgprc;
+	u64 saved_reset_vfgptc;
+	u64 saved_reset_vfgorc;
+	u64 saved_reset_vfgotc;
+	u64 saved_reset_vfmprc;
 };
 
 struct ixgbevf_info {

