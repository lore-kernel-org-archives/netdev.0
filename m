From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40evf: refactor ethtool RSS handling
Date: Fri, 21 Nov 2014 21:55:04 -0800
Message-ID: <1416635708-4765-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26255 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbaKVFzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:19 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add support for setting the RSS key as it is now implemented.

Change-ID: I9290ae3ea99d0e46053540650f95e24a24e453f1
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 66 ++++++++++++++++------
 1 file changed, 50 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 69a269b..ed0e4dc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -608,6 +608,19 @@ static void i40evf_get_channels(struct net_device *netdev,
 	ch->combined_count = adapter->num_active_queues;
 }
 
+#define I40EVF_HLUT_ARRAY_SIZE ((I40E_VFQF_HLUT_MAX_INDEX + 1) * 4)
+#define I40EVF_HKEY_ARRAY_SIZE ((I40E_VFQF_HKEY_MAX_INDEX * 1) * 4)
+/**
+ * i40evf_get_rxfh_key_size - get the RSS hash key size
+ * @netdev: network interface device structure
+ *
+ * Returns the table size.
+ **/
+static u32 i40evf_get_rxfh_key_size(struct net_device *netdev)
+{
+	return I40EVF_HKEY_ARRAY_SIZE;
+}
+
 /**
  * i40evf_get_rxfh_indir_size - get the rx flow hash indirection table size
  * @netdev: network interface device structure
@@ -616,7 +629,7 @@ static void i40evf_get_channels(struct net_device *netdev,
  **/
 static u32 i40evf_get_rxfh_indir_size(struct net_device *netdev)
 {
-	return (I40E_VFQF_HLUT_MAX_INDEX + 1) * 4;
+	return I40EVF_HLUT_ARRAY_SIZE;
 }
 
 /**
@@ -631,19 +644,28 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_hw *hw = &adapter->hw;
-	u32 hlut_val;
+	u32 reg_val;
 	int i, j;
 
 	for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
-		hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
-		indir[j++] = hlut_val & 0xff;
-		indir[j++] = (hlut_val >> 8) & 0xff;
-		indir[j++] = (hlut_val >> 16) & 0xff;
-		indir[j++] = (hlut_val >> 24) & 0xff;
+		reg_val = rd32(hw, I40E_VFQF_HLUT(i));
+		indir[j++] = reg_val & 0xff;
+		indir[j++] = (reg_val >> 8) & 0xff;
+		indir[j++] = (reg_val >> 16) & 0xff;
+		indir[j++] = (reg_val >> 24) & 0xff;
+	}
+
+	if (key) {
+		for (i = 0, j = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++) {
+			reg_val = rd32(hw, I40E_VFQF_HKEY(i));
+			key[j++] = (u8)(reg_val & 0xff);
+			key[j++] = (u8)((reg_val >> 8) & 0xff);
+			key[j++] = (u8)((reg_val >> 16) & 0xff);
+			key[j++] = (u8)((reg_val >> 24) & 0xff);
+		}
 	}
 	return 0;
 }
-
 /**
  * i40evf_set_rxfh - set the rx flow hash indirection table
  * @netdev: network interface device structure
@@ -658,17 +680,27 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_hw *hw = &adapter->hw;
-	u32 hlut_val;
+	u32 reg_val;
 	int i, j;
 
-	for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
-		hlut_val = indir[j++];
-		hlut_val |= indir[j++] << 8;
-		hlut_val |= indir[j++] << 16;
-		hlut_val |= indir[j++] << 24;
-		wr32(hw, I40E_VFQF_HLUT(i), hlut_val);
+	if (indir) {
+		for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
+			reg_val = indir[j++];
+			reg_val |= indir[j++] << 8;
+			reg_val |= indir[j++] << 16;
+			reg_val |= indir[j++] << 24;
+			wr32(hw, I40E_VFQF_HLUT(i), reg_val);
+		}
+	}
+	if (key) {
+		for (i = 0, j = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++) {
+			reg_val = key[j++];
+			reg_val |= key[j++] << 8;
+			reg_val |= key[j++] << 16;
+			reg_val |= key[j++] << 24;
+			wr32(hw, I40E_VFQF_HKEY(i), reg_val);
+		}
 	}
-
 	return 0;
 }
 
@@ -687,10 +719,12 @@ static const struct ethtool_ops i40evf_ethtool_ops = {
 	.set_coalesce		= i40evf_set_coalesce,
 	.get_rxnfc		= i40evf_get_rxnfc,
 	.set_rxnfc		= i40evf_set_rxnfc,
+	.get_rxfh_key_size	= i40evf_get_rxfh_key_size,
 	.get_rxfh_indir_size	= i40evf_get_rxfh_indir_size,
 	.get_rxfh		= i40evf_get_rxfh,
 	.set_rxfh		= i40evf_set_rxfh,
 	.get_channels		= i40evf_get_channels,
+
 };
 
 /**
-- 
1.9.3
