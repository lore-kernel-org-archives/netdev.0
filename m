From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v2 net 2/5] net:ethernet:aquantia: Fix packet type detection (TCP/UDP) for IPv6.
Date: Thu, 23 Mar 2017 00:19:22 +0300
Message-ID: <26947c0cfdf370bc4aef16941aaf28e433c052b3.1490217414.git.pavel.belous@aquantia.com>
References: <cover.1490217414.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:28576
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751368AbdCVVT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 17:19:58 -0400
In-Reply-To: <cover.1490217414.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

In order for the checksum offloads to work correctly we need to set the
packet type bit (TCP/UDP) in the TX context buffer.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index ee78444..db2b51d 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -510,10 +510,22 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		dx_buff->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ?
 			1U : 0U;
-		dx_buff->is_tcp_cso =
-			(ip_hdr(skb)->protocol == IPPROTO_TCP) ? 1U : 0U;
-		dx_buff->is_udp_cso =
-			(ip_hdr(skb)->protocol == IPPROTO_UDP) ? 1U : 0U;
+
+		if (ip_hdr(skb)->version == 4) {
+			dx_buff->is_tcp_cso =
+				(ip_hdr(skb)->protocol == IPPROTO_TCP) ?
+					1U : 0U;
+			dx_buff->is_udp_cso =
+				(ip_hdr(skb)->protocol == IPPROTO_UDP) ?
+					1U : 0U;
+		} else if (ip_hdr(skb)->version == 6) {
+			dx_buff->is_tcp_cso =
+				(ipv6_hdr(skb)->nexthdr == NEXTHDR_TCP) ?
+					1U : 0U;
+			dx_buff->is_udp_cso =
+				(ipv6_hdr(skb)->nexthdr == NEXTHDR_UDP) ?
+					1U : 0U;
+		}
 	}
 
 	for (; nr_frags--; ++frag_count) {
-- 
2.7.4
