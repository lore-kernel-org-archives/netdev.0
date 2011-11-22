From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 2/4] net-e1000e: ethtool loopback
	support
Date: Tue, 22 Nov 2011 11:23:36 -0800
Message-ID: <e466f23702aec3c748cf5800f56ddea4117fa2e9.1321989502.git.david.decotigny@google.com>
References: <cover.1321989502.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Decotigny <david.decotigny@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1321989502.git.david.decotigny@google.com>
In-Reply-To: <cover.1321989502.git.david.decotigny@google.com>
References: <cover.1321989502.git.david.decotigny@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This allows ethtool to activate loopback via the get/set_features API.

Tested:
  - HW = 80003ES2LAN (copper), x86_64
  - incoming external 200Mbps, loopback on/off, verified that incoming
    stream resumed
  - incoming external 200Mbps, ifconfig down, loopback on/off,
    ifconfig up, verified that incoming stream resumed
  - incoming external 200Mbps, loopback on, ifconfig down, loopback
    off, ifconfig up, verified that incoming stream resumed
  - in each case, ifconfig rx&tx errors = 0 but rx_dropped can be != 0
  - the same with a pktgen when loopback is enabled: verifying that
    tx_packets = rx_packets + rx_missed_errors, and that tx_packets is
    very close to pktgen_packets (1 or 2 packets difference, not
    more). Note that rx_missed_errors >> 0
  - artificially simulated failure of enabling loopback -> reported by
    set_features and kept loopback feature marked as not configured.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |    2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c |    6 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c  |   21 ++++++++++++++++++++-
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 9fe18d1..786cf31 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -485,6 +485,8 @@ extern const char e1000e_driver_version[];
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
 extern void e1000e_set_ethtool_ops(struct net_device *netdev);
+extern int e1000_loopback_setup(struct e1000_adapter *adapter);
+extern void e1000_loopback_cleanup(struct e1000_adapter *adapter);
 
 extern int e1000e_up(struct e1000_adapter *adapter);
 extern void e1000e_down(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index fb2c28e..259add2 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1410,7 +1410,7 @@ static int e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
+int e1000_loopback_setup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
@@ -1438,7 +1438,7 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 	return 7;
 }
 
-static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
+void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
@@ -1593,7 +1593,7 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	if (*data)
 		goto out;
 
-	*data = e1000_setup_loopback_test(adapter);
+	*data = e1000_loopback_setup(adapter);
 	if (*data)
 		goto err_loopback;
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a83a108..ca45a12 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3256,6 +3256,14 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_configure_rx(adapter);
 	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring),
 			      GFP_KERNEL);
+
+	if (adapter->netdev->features & NETIF_F_LOOPBACK) {
+		if (e1000_loopback_setup(adapter)) {
+			e_warn("Could not activate loopback mode\n");
+			adapter->netdev->features &= ~NETIF_F_LOOPBACK;
+		} else
+			e_info("Loopback mode activated\n");
+	}
 }
 
 /**
@@ -5910,7 +5918,7 @@ static int e1000_set_features(struct net_device *netdev,
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-			 NETIF_F_RXCSUM)))
+			 NETIF_F_RXCSUM | NETIF_F_LOOPBACK)))
 		return 0;
 
 	/* We will make sure to return 1 below so that we can change
@@ -5919,6 +5927,14 @@ static int e1000_set_features(struct net_device *netdev,
 	 * overriding it. */
 	netdev->features = features;
 
+	/* disable loopback if requested */
+	if ((changed & NETIF_F_LOOPBACK) && (!(features & NETIF_F_LOOPBACK))) {
+		netdev_dbg(netdev, "Disabling loopback mode\n");
+		e1000_loopback_cleanup(adapter);
+	}
+	/* otherwise loopback is enabled via e1000e_reinit_locked
+	 * below and each time the device is up'ed */
+
 	if (netif_running(netdev))
 		e1000e_reinit_locked(adapter);
 	else
@@ -6116,6 +6132,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* Set user-changeable features (subset of all device features) */
 	netdev->hw_features = netdev->features;
 
+	/* Add capabilities, disabled by default */
+	netdev->hw_features |= NETIF_F_LOOPBACK;
+
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
 
-- 
1.7.3.1


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
