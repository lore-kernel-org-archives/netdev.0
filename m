From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] igbvf: work around i350 erratum
Date: Wed, 28 Nov 2012 05:06:12 -0800
Message-ID: <1354107978-24731-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44342 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab2K1NGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:22 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

On i350 VF devices, VLAN tags will be byte-swapped in the receive
descriptor only when received packets are looped back from other
VFs. Check for this condition and swab the tag if needed.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/defines.h |  1 +
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c  | 15 +++++++++++++--
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/defines.h b/drivers/net/ethernet/intel/igbvf/defines.h
index 3e18045..d9fa999 100644
--- a/drivers/net/ethernet/intel/igbvf/defines.h
+++ b/drivers/net/ethernet/intel/igbvf/defines.h
@@ -46,6 +46,7 @@
 #define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
 #define E1000_RXD_SPC_VLAN_MASK 0x0FFF  /* VLAN ID is in lower 12 bits */
 
+#define E1000_RXDEXT_STATERR_LB    0x00040000
 #define E1000_RXDEXT_STATERR_CE    0x01000000
 #define E1000_RXDEXT_STATERR_SE    0x02000000
 #define E1000_RXDEXT_STATERR_SEQ   0x04000000
diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index a895e2f..fdca7b6 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -295,7 +295,7 @@ struct igbvf_info {
 
 /* hardware capability, feature, and workaround flags */
 #define IGBVF_FLAG_RX_CSUM_DISABLED             (1 << 0)
-
+#define IGBVF_FLAG_RX_LB_VLAN_BSWAP		(1 << 1)
 #define IGBVF_RX_DESC_ADV(R, i)     \
 	(&((((R).desc))[i].rx_desc))
 #define IGBVF_TX_DESC_ADV(R, i)     \
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 4051ec4..b44b9d3 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -107,12 +107,19 @@ static void igbvf_receive_skb(struct igbvf_adapter *adapter,
                               struct sk_buff *skb,
                               u32 status, u16 vlan)
 {
+	u16 vid;
+
 	if (status & E1000_RXD_STAT_VP) {
-		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
+		if ((adapter->flags & IGBVF_FLAG_RX_LB_VLAN_BSWAP) &&
+		    (status & E1000_RXDEXT_STATERR_LB))
+			vid = be16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
+		else
+			vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
 		if (test_bit(vid, adapter->active_vlans))
 			__vlan_hwaccel_put_tag(skb, vid);
 	}
-	netif_receive_skb(skb);
+
+	napi_gro_receive(&adapter->rx_ring->napi, skb);
 }
 
 static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
@@ -2767,6 +2774,10 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	igbvf_reset(adapter);
 
+	/* set hardware-specific flags */
+	if (adapter->hw.mac.type == e1000_vfadapt_i350)
+		adapter->flags |= IGBVF_FLAG_RX_LB_VLAN_BSWAP;
+
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
-- 
1.7.11.7
