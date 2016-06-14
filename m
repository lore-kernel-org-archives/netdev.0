From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 6/9] liquidio: Consider PTP for packet size calculations
Date: Tue, 14 Jun 2016 16:54:48 -0700
Message-ID: <1465948491-10541-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0065.outbound.protection.outlook.com ([65.55.169.65]:2156
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751332AbcFOALe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:11:34 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to refactor packet size calculations to support PTP enabled
for 66xx and 68xx cards and also other cards that do not support PTP.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 34 +++++++++++++---------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  6 ++--
 2 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 3a4f31f..aa28790 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -84,6 +84,8 @@ static int conf_type;
 module_param(conf_type, int, 0);
 MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
 
+static int ptp_enable = 1;
+
 /* Bit mask values for lio->ifstate */
 #define   LIO_IFSTATE_DROQ_OPS             0x01
 #define   LIO_IFSTATE_REGISTERED           0x02
@@ -1851,6 +1853,7 @@ liquidio_push_packet(u32 octeon_id,
 	if (netdev) {
 		int packet_was_received;
 		struct lio *lio = GET_LIO(netdev);
+		struct octeon_device *oct = lio->oct_dev;
 
 		/* Do not proceed if the interface is not in RUNNING state. */
 		if (!ifstate_check(lio, LIO_IFSTATE_RUNNING)) {
@@ -1889,21 +1892,26 @@ liquidio_push_packet(u32 octeon_id,
 			put_page(pg_info->page);
 		}
 
-		if (rh->r_dh.has_hwtstamp) {
-			/* timestamp is included from the hardware at the
-			 * beginning of the packet.
-			 */
-			if (ifstate_check(lio,
-					  LIO_IFSTATE_RX_TIMESTAMP_ENABLED)) {
-				/* Nanoseconds are in the first 64-bits
-				 * of the packet.
+		if (((oct->chip_id == OCTEON_CN66XX) ||
+		     (oct->chip_id == OCTEON_CN68XX)) &&
+		    ptp_enable) {
+			if (rh->r_dh.has_hwtstamp) {
+				/* timestamp is included from the hardware at
+				 * the beginning of the packet.
 				 */
-				memcpy(&ns, (skb->data), sizeof(ns));
-				shhwtstamps = skb_hwtstamps(skb);
-				shhwtstamps->hwtstamp =
-					ns_to_ktime(ns + lio->ptp_adjust);
+				if (ifstate_check
+				    (lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED)) {
+					/* Nanoseconds are in the first 64-bits
+					 * of the packet.
+					 */
+					memcpy(&ns, (skb->data), sizeof(ns));
+					shhwtstamps = skb_hwtstamps(skb);
+					shhwtstamps->hwtstamp =
+						ns_to_ktime(ns +
+							    lio->ptp_adjust);
+				}
+				skb_pull(skb, sizeof(ns));
 			}
-			skb_pull(skb, sizeof(ns));
 		}
 
 		skb->protocol = eth_type_trans(skb, skb->dev);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 00b3ef5..84ffcae 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -174,9 +174,11 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 /*------------------------- End Scatter/Gather ---------------------------*/
 
 #define   OCTNET_FRM_PTP_HEADER_SIZE  8
-#define   OCTNET_FRM_HEADER_SIZE     30 /* PTP timestamp + VLAN + Ethernet */
 
-#define   OCTNET_MIN_FRM_SIZE        (64  + OCTNET_FRM_PTP_HEADER_SIZE)
+#define   OCTNET_FRM_HEADER_SIZE     22 /* VLAN + Ethernet */
+
+#define   OCTNET_MIN_FRM_SIZE        64
+
 #define   OCTNET_MAX_FRM_SIZE        (16000 + OCTNET_FRM_HEADER_SIZE)
 
 #define   OCTNET_DEFAULT_FRM_SIZE    (1500 + OCTNET_FRM_HEADER_SIZE)
-- 
1.8.3.1
