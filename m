From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 02/13] liquidio: Vlan offloads changes
Date: Tue, 21 Jun 2016 22:53:04 -0700
Message-ID: <1466574795-4306-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0089.outbound.protection.outlook.com ([65.55.169.89]:19264
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751438AbcFVFzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:20 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for vlan offloads for the driver and
receive header structures are also modified appropriately. Also
requestID will not be used in reveive header any more.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 26 +++++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 46 +++++++++++-----------
 2 files changed, 46 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 5a0977f..4b95dbf 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1849,6 +1849,7 @@ liquidio_push_packet(u32 octeon_id,
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
 	struct skb_shared_hwtstamps *shhwtstamps;
 	u64 ns;
+	u16 vtag = 0;
 	struct net_device *netdev = (struct net_device *)arg;
 	struct octeon_droq *droq = container_of(param, struct octeon_droq,
 						napi);
@@ -1925,6 +1926,16 @@ liquidio_push_packet(u32 octeon_id,
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 
+		/* inbound VLAN tag */
+		if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    (rh->r_dh.vlan != 0)) {
+			u16 vid = rh->r_dh.vlan;
+			u16 priority = rh->r_dh.priority;
+
+			vtag = priority << 13 | vid;
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vtag);
+		}
+
 		packet_was_received = napi_gro_receive(napi, skb) != GRO_DROP;
 
 		if (packet_was_received) {
@@ -2900,6 +2911,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
 	}
+	/* HW insert VLAN tag */
+	if (skb_vlan_tag_present(skb)) {
+		irh->priority = skb_vlan_tag_get(skb) >> 13;
+		irh->vlan = skb_vlan_tag_get(skb) & 0xfff;
+	}
 
 	xmit_more = skb->xmit_more;
 
@@ -3301,11 +3317,17 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 				| NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
-		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
-
 		netdev->vlan_features = lio->dev_capability;
+		/* Add any unchangeable hw features */
+		lio->dev_capability |=  NETIF_F_HW_VLAN_CTAG_RX |
+					NETIF_F_HW_VLAN_CTAG_TX;
+
+		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
 
 		netdev->hw_features = lio->dev_capability;
+		/*HW_VLAN_RX and HW_VLAN_FILTER is always on*/
+		netdev->hw_features = netdev->hw_features &
+			~NETIF_F_HW_VLAN_CTAG_RX;
 
 		/* Point to the  properties for octeon device to which this
 		 * interface belongs.
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 2179691..c86421f 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -482,15 +482,15 @@ struct octeon_instr_irh {
 	u64 opcode:4;
 	u64 rflag:1;
 	u64 subcode:7;
-	u64 len:3;
-	u64 rid:13;
-	u64 reserved:4;
+	u64 vlan:12;
+	u64 priority:3;
+	u64 reserved:5;
 	u64 ossp:32;             /* opcode/subcode specific parameters */
 #else
 	u64 ossp:32;             /* opcode/subcode specific parameters */
-	u64 reserved:4;
-	u64 rid:13;
-	u64 len:3;
+	u64 reserved:5;
+	u64 priority:3;
+	u64 vlan:12;
 	u64 subcode:7;
 	u64 rflag:1;
 	u64 opcode:4;
@@ -517,28 +517,27 @@ union octeon_rh {
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
-		u64 reserved:4;
-		u64 ossp:32;     /** opcode/subcode specific parameters */
+		u64 len:3;     /** additional 64-bit words */
+		u64 reserved:17;
+		u64 ossp:32;   /** opcode/subcode specific parameters */
 	} r;
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
-		u64 extra:24;
-		u64 link:8;
+		u64 len:3;     /** additional 64-bit words */
+		u64 extra:28;
+		u64 vlan:12;
+		u64 priority:3;
 		u64 csum_verified:3;     /** checksum verified. */
 		u64 has_hwtstamp:1;      /** Has hardware timestamp. 1 = yes. */
 	} r_dh;
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
+		u64 len:3;     /** additional 64-bit words */
+		u64 reserved:11;
 		u64 num_gmx_ports:8;
-		u64 max_nic_ports:8;
+		u64 max_nic_ports:10;
 		u64 app_cap_flags:4;
 		u64 app_mode:16;
 	} r_core_drv_init;
@@ -554,8 +553,7 @@ union octeon_rh {
 	u64 u64;
 	struct {
 		u64 ossp:32;  /** opcode/subcode specific parameters */
-		u64 reserved:4;
-		u64 rid:13;   /** req id in response to pkt sent by host */
+		u64 reserved:17;
 		u64 len:3;    /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
@@ -563,9 +561,9 @@ union octeon_rh {
 	struct {
 		u64 has_hwtstamp:1;      /** 1 = has hwtstamp */
 		u64 csum_verified:3;     /** checksum verified. */
-		u64 link:8;
-		u64 extra:24;
-		u64 rid:13;   /** req id in response to pkt sent by host */
+		u64 priority:3;
+		u64 vlan:12;
+		u64 extra:28;
 		u64 len:3;    /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
@@ -573,9 +571,9 @@ union octeon_rh {
 	struct {
 		u64 app_mode:16;
 		u64 app_cap_flags:4;
-		u64 max_nic_ports:8;
+		u64 max_nic_ports:10;
 		u64 num_gmx_ports:8;
-		u64 rid:13;
+		u64 reserved:11;
 		u64 len:3;       /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
-- 
1.8.3.1
