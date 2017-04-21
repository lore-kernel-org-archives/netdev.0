From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: Check for RSS key before setting value
Date: Thu, 20 Apr 2017 18:50:27 -0700
Message-ID: <20170421015029.18994-10-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53037 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034443AbdDUBvI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:51:08 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

The RSS key is being repopulated every time the interface is brought up
regardless of whether there is an existing value. If the user sets the RSS
key and the interface is brought up (e.g. reset), the user specified RSS
key will be overwritten.

This patch changes the rss_key to a pointer so we can check to see if the
key has been populated and preserve it accordingly.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 +---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 30 ++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  2 +-
 4 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 85b1afb345e3..76263762bea1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -769,7 +769,7 @@ struct ixgbe_adapter {
 	u8 rss_indir_tbl[IXGBE_MAX_RETA_ENTRIES];
 
 #define IXGBE_RSS_KEY_SIZE     40  /* size of RSS Hash Key in bytes */
-	u32 rss_key[IXGBE_RSS_KEY_SIZE / sizeof(u32)];
+	u32 *rss_key;
 };
 
 static inline u8 ixgbe_max_rss_indices(struct ixgbe_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b0fd2f58a69c..7e5e336d7dcc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2967,9 +2967,7 @@ static int ixgbe_rss_indir_tbl_max(struct ixgbe_adapter *adapter)
 
 static u32 ixgbe_get_rxfh_key_size(struct net_device *netdev)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	return sizeof(adapter->rss_key);
+	return IXGBE_RSS_KEY_SIZE;
 }
 
 static u32 ixgbe_rss_indir_size(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e1e0ca408d61..51eda19c08b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3637,6 +3637,28 @@ void ixgbe_store_key(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_init_rss_key - Initialize adapter RSS key
+ * @adapter: device handle
+ *
+ * Allocates and initializes the RSS key if it is not allocated.
+ **/
+static inline int ixgbe_init_rss_key(struct ixgbe_adapter *adapter)
+{
+	u32 *rss_key;
+
+	if (!adapter->rss_key) {
+		rss_key = kzalloc(IXGBE_RSS_KEY_SIZE, GFP_KERNEL);
+		if (unlikely(!rss_key))
+			return -ENOMEM;
+
+		netdev_rss_key_fill(rss_key, IXGBE_RSS_KEY_SIZE);
+		adapter->rss_key = rss_key;
+	}
+
+	return 0;
+}
+
+/**
  * ixgbe_store_reta - Write the RETA table to HW
  * @adapter: device handle
  *
@@ -3738,7 +3760,7 @@ static void ixgbe_setup_vfreta(struct ixgbe_adapter *adapter)
 	/* Fill out hash function seeds */
 	for (i = 0; i < 10; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_PFVFRSSRK(i, pf_pool),
-				adapter->rss_key[i]);
+				*(adapter->rss_key + i));
 
 	/* Fill out the redirection table */
 	for (i = 0, j = 0; i < 64; i++, j++) {
@@ -3799,7 +3821,6 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
 		rss_field |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
 
-	netdev_rss_key_fill(adapter->rss_key, sizeof(adapter->rss_key));
 	if ((hw->mac.type >= ixgbe_mac_X550) &&
 	    (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)) {
 		unsigned int pf_pool = adapter->num_vfs;
@@ -6013,6 +6034,9 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter,
 	if (!adapter->mac_table)
 		return -ENOMEM;
 
+	if (ixgbe_init_rss_key(adapter))
+		return -ENOMEM;
+
 	/* Set MAC specific capability flags and exceptions */
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
@@ -10390,6 +10414,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	iounmap(adapter->io_addr);
 	kfree(adapter->jump_tables[0]);
 	kfree(adapter->mac_table);
+	kfree(adapter->rss_key);
 err_ioremap:
 	disable_dev = !test_and_set_bit(__IXGBE_DISABLED, &adapter->state);
 	free_netdev(netdev);
@@ -10474,6 +10499,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	}
 
 	kfree(adapter->mac_table);
+	kfree(adapter->rss_key);
 	disable_dev = !test_and_set_bit(__IXGBE_DISABLED, &adapter->state);
 	free_netdev(netdev);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 58897d97412e..8baf298a8516 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1113,7 +1113,7 @@ static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
 		return -EOPNOTSUPP;
 	}
 
-	memcpy(rss_key, adapter->rss_key, sizeof(adapter->rss_key));
+	memcpy(rss_key, adapter->rss_key, IXGBE_RSS_KEY_SIZE);
 
 	return 0;
 }
-- 
2.12.2
