From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 5/6] be2net: Fix mac address collision in some configurations
Date: Wed,  7 Sep 2016 19:57:53 +0530
Message-ID: <20160907142754.13284-6-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S935667AbcIGOp4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:56 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@broadcom.com>

If the device mac address is updated using ndo_set_mac_address(),
while the same mac address is already programmed, the driver does not
detect this condition if its netdev->dev_addr has been changed. The
driver tries to add the same mac address resulting in mac address
collision error. This has been observed in bonding mode-5 configuration.

To fix this, store the mac address configured in HW in the adapter
structure. Use this to compare against the new address being updated
to avoid collision.

Signed-off-by: Suresh Reddy <Suresh.Reddy@broadcom.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index eecf24e..30a26aa 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -693,6 +693,7 @@ struct be_adapter {
 	u32 fat_dump_len;
 	u16 serial_num[CNTL_SERIAL_NUM_WORDS];
 	u8 phy_state; /* state of sfp optics (functional, faulted, etc.,) */
+	u8 dev_mac[ETH_ALEN];
 	u32 priv_flags; /* ethtool get/set_priv_flags() */
 	struct be_error_recovery error_recovery;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a1c9920..34f63ef 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -316,7 +316,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	/* Proceed further only if, User provided MAC is different
 	 * from active MAC
 	 */
-	if (ether_addr_equal(addr->sa_data, netdev->dev_addr))
+	if (ether_addr_equal(addr->sa_data, adapter->dev_mac))
 		return 0;
 
 	/* if device is not running, copy MAC to netdev->dev_addr */
@@ -357,6 +357,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 		goto err;
 	}
 done:
+	ether_addr_copy(adapter->dev_mac, addr->sa_data);
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 	dev_info(dev, "MAC address changed to %pM\n", addr->sa_data);
 	return 0;
@@ -1662,7 +1663,7 @@ static void be_clear_mc_list(struct be_adapter *adapter)
 static int be_uc_mac_add(struct be_adapter *adapter, int uc_idx)
 {
 	if (ether_addr_equal((u8 *)&adapter->uc_list[uc_idx * ETH_ALEN],
-			     adapter->netdev->dev_addr)) {
+			     adapter->dev_mac)) {
 		adapter->pmac_id[uc_idx + 1] = adapter->pmac_id[0];
 		return 0;
 	}
@@ -3774,6 +3775,7 @@ static int be_enable_if_filters(struct be_adapter *adapter)
 		status = be_dev_mac_add(adapter, adapter->netdev->dev_addr);
 		if (status)
 			return status;
+		ether_addr_copy(adapter->dev_mac, adapter->netdev->dev_addr);
 	}
 
 	if (adapter->vlans_added)
-- 
2.10.0.rc2.20.g5b18e70
