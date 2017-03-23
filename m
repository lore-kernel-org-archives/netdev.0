From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v3 net 4/5] net:ethernet:aquantia: Fix for LSO with IPv6.
Date: Thu, 23 Mar 2017 14:19:44 +0300
Message-ID: <8f9be4922f65c7a39027fb386434b6ec3d80dd9b.1490267633.git.pavel.belous@aquantia.com>
References: <cover.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0051.outbound.protection.outlook.com ([104.47.34.51]:11640
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751235AbdCWLU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 07:20:27 -0400
In-Reply-To: <cover.1490267633.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Fix Context Command bit: L3 type = "0" for IPv4, "1" for IPv6.

Fixes: bab6de8fd180 ("net: ethernet: aquantia:
 Atlantic A0 and B0 specific functions.")

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c           | 3 +++
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h          | 3 ++-
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c | 3 +++
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 3 +++
 4 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index db2b51d..cdb0299 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -487,6 +487,9 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 		dx_buff->mss = skb_shinfo(skb)->gso_size;
 		dx_buff->is_txc = 1U;
 
+		dx_buff->is_ipv6 =
+			(ip_hdr(skb)->version == 6) ? 1U : 0U;
+
 		dx = aq_ring_next_dx(ring, dx);
 		dx_buff = &ring->buff_ring[dx];
 		++ret;
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index 2572546..eecd6d1 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -58,7 +58,8 @@ struct __packed aq_ring_buff_s {
 			u8 len_l2;
 			u8 len_l3;
 			u8 len_l4;
-			u8 rsvd2;
+			u8 is_ipv6:1;
+			u8 rsvd2:7;
 			u32 len_pkt;
 		};
 	};
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index a2b746a..a536875 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -433,6 +433,9 @@ static int hw_atl_a0_hw_ring_tx_xmit(struct aq_hw_s *self,
 				    buff->len_l3 +
 				    buff->len_l2);
 			is_gso = true;
+
+			if (buff->is_ipv6)
+				txd->ctl |= HW_ATL_A0_TXD_CTL_CMD_IPV6;
 		} else {
 			buff_pa_len = buff->len;
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index cab2931..69488c9 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -471,6 +471,9 @@ static int hw_atl_b0_hw_ring_tx_xmit(struct aq_hw_s *self,
 				    buff->len_l3 +
 				    buff->len_l2);
 			is_gso = true;
+
+			if (buff->is_ipv6)
+				txd->ctl |= HW_ATL_B0_TXD_CTL_CMD_IPV6;
 		} else {
 			buff_pa_len = buff->len;
 
-- 
2.7.4
