From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: store the L4 hash of rx packets in skb
Date: Fri, 6 Jan 2017 16:55:42 -0800
Message-ID: <20170107005542.GA16278@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0044.outbound.protection.outlook.com ([104.47.32.44]:55952
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1034654AbdAGA4l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 19:56:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

Store the L4 hash of received packets in the skb; the hash is computed in
the NIC firmware.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 17 +++++++++++++++--
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c     | 15 ++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h |  2 ++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 39a9665..adae858 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2263,6 +2263,7 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 	struct skb_shared_hwtstamps *shhwtstamps;
 	u64 ns;
 	u16 vtag = 0;
+	u32 r_dh_off;
 	struct net_device *netdev = (struct net_device *)arg;
 	struct octeon_droq *droq = container_of(param, struct octeon_droq,
 						napi);
@@ -2308,6 +2309,8 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 			put_page(pg_info->page);
 		}
 
+		r_dh_off = (rh->r_dh.len - 1) * BYTES_PER_DHLEN_UNIT;
+
 		if (((oct->chip_id == OCTEON_CN66XX) ||
 		     (oct->chip_id == OCTEON_CN68XX)) &&
 		    ptp_enable) {
@@ -2320,16 +2323,26 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 					/* Nanoseconds are in the first 64-bits
 					 * of the packet.
 					 */
-					memcpy(&ns, (skb->data), sizeof(ns));
+					memcpy(&ns, (skb->data + r_dh_off),
+					       sizeof(ns));
+					r_dh_off -= BYTES_PER_DHLEN_UNIT;
 					shhwtstamps = skb_hwtstamps(skb);
 					shhwtstamps->hwtstamp =
 						ns_to_ktime(ns +
 							    lio->ptp_adjust);
 				}
-				skb_pull(skb, sizeof(ns));
 			}
 		}
 
+		if (rh->r_dh.has_hash) {
+			u32 hash = be32_to_cpu(*(u32 *)(skb->data + r_dh_off));
+
+			skb_set_hash(skb, hash, PKT_HASH_TYPE_L4);
+			r_dh_off -= BYTES_PER_DHLEN_UNIT;
+		}
+
+		skb_pull(skb, rh->r_dh.len * BYTES_PER_DHLEN_UNIT);
+
 		skb->protocol = eth_type_trans(skb, skb->dev);
 		if ((netdev->features & NETIF_F_RXCSUM) &&
 		    (((rh->r_dh.encap_on) &&
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 70d96c1..c0ee746 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1497,6 +1497,7 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 	struct net_device *netdev = (struct net_device *)arg;
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
 	u16 vtag = 0;
+	u32 r_dh_off;
 
 	if (netdev) {
 		struct lio *lio = GET_LIO(netdev);
@@ -1540,7 +1541,19 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 			put_page(pg_info->page);
 		}
 
-		skb_pull(skb, rh->r_dh.len * 8);
+		r_dh_off = (rh->r_dh.len - 1) * BYTES_PER_DHLEN_UNIT;
+
+		if (rh->r_dh.has_hwtstamp)
+			r_dh_off -= BYTES_PER_DHLEN_UNIT;
+
+		if (rh->r_dh.has_hash) {
+			u32 hash = be32_to_cpu(*(u32 *)(skb->data + r_dh_off));
+
+			skb_set_hash(skb, hash, PKT_HASH_TYPE_L4);
+			r_dh_off -= BYTES_PER_DHLEN_UNIT;
+		}
+
+		skb_pull(skb, rh->r_dh.len * BYTES_PER_DHLEN_UNIT);
 		skb->protocol = eth_type_trans(skb, skb->dev);
 
 		if ((netdev->features & NETIF_F_RXCSUM) &&
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index ba329f6..bc0af8a 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -98,6 +98,8 @@ enum octeon_tag_type {
 #define CVM_DRV_INVALID_APP         (CVM_DRV_APP_START + 0x2)
 #define CVM_DRV_APP_END             (CVM_DRV_INVALID_APP - 1)
 
+#define BYTES_PER_DHLEN_UNIT        8
+
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
 	if ((index + count) >= max)
