From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 4/6] be2net: fix to dynamically generate MAC
 Address for VFs
Date: Sun, 22 Aug 2010 14:56:38 +0530
Message-ID: <20100822092629.GA22288@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2282 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab0HVJ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 05:26:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BE ASIC/firmware doesnot reserve and assign MAC address for VFs.
This results in the VF interfaces being created with MAC Address 0.
The code change proposed takes the MAC address of PF to generate a seed.
MAC Address for VFs are assigned incrementally starting from the seed.
These addresses are programmed in the ASIC by the PF and the VF driver
queries for the MAC address during its probe.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |   14 +++++++++++
 drivers/net/benet/be_main.c |   54 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 53306bf..4faf696 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -414,6 +414,20 @@ static inline void be_check_sriov_fn_type(struct be_adapter *adapter)
 	adapter->is_virtfn = (data != 0xAA);
 }
 
+static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
+{
+	u32 addr;
+
+	addr = jhash(adapter->netdev->dev_addr, ETH_ALEN, 0);
+
+	mac[5] = (u8)(addr & 0xFF);
+	mac[4] = (u8)((addr >> 8) & 0xFF);
+	mac[3] = (u8)((addr >> 16) & 0xFF);
+	mac[2] = 0xC9;
+	mac[1] = 0x00;
+	mac[0] = 0x00;
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6eda7a0..949d9a1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2084,6 +2084,47 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	return status;
 }
 
+/*
+ * Generate a seed MAC address from the PF MAC Address using jhash.
+ * MAC Address for VFs are assigned incrementally starting from the seed.
+ * These addresses are programmed in the ASIC by the PF and the VF driver
+ * queries for the MAC address during its probe.
+ */
+static inline int be_vf_eth_addr_config(struct be_adapter *adapter)
+{
+	u32 vf = 0;
+	int status;
+	u8 mac[ETH_ALEN];
+
+	be_vf_eth_addr_generate(adapter, mac);
+
+	for (vf = 0; vf < num_vfs; vf++) {
+		status = be_cmd_pmac_add(adapter, mac,
+					adapter->vf_cfg[vf].vf_if_handle,
+					&adapter->vf_cfg[vf].vf_pmac_id);
+		if (status)
+			dev_err(&adapter->pdev->dev,
+				"Mac address add failed for VF %d\n", vf);
+		else
+			memcpy(adapter->vf_cfg[vf].vf_mac_addr, mac, ETH_ALEN);
+
+		mac[5] += 1;
+	}
+	return status;
+}
+
+static inline void be_vf_eth_addr_rem(struct be_adapter *adapter)
+{
+	u32 vf;
+
+	for (vf = 0; vf < num_vfs; vf++) {
+		if (adapter->vf_cfg[vf].vf_pmac_id != BE_INVALID_PMAC_ID)
+			be_cmd_pmac_del(adapter,
+					adapter->vf_cfg[vf].vf_if_handle,
+					adapter->vf_cfg[vf].vf_pmac_id);
+	}
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -2143,10 +2184,20 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
+	if (be_physfn(adapter)) {
+		status = be_vf_eth_addr_config(adapter);
+		if (status)
+			goto mcc_q_destroy;
+	}
+
 	adapter->link_speed = -1;
 
 	return 0;
 
+mcc_q_destroy:
+	if (be_physfn(adapter))
+		be_vf_eth_addr_rem(adapter);
+	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
@@ -2163,6 +2214,9 @@ do_none:
 
 static int be_clear(struct be_adapter *adapter)
 {
+	if (be_physfn(adapter))
+		be_vf_eth_addr_rem(adapter);
+
 	be_mcc_queues_destroy(adapter);
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
-- 
1.7.0.4

