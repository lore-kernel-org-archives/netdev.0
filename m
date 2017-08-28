From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net v2 3/6] net:ethernet:aquantia: Workaround for HW checksum bug.
Date: Mon, 28 Aug 2017 21:52:10 +0300
Message-ID: <f9da8832eb2534b18fe228b736aac99e63279162.1503945861.git.pavel.belous@aquantia.com>
References: <cover.1503945861.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0065.outbound.protection.outlook.com ([104.47.32.65]:55610
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751306AbdH1SxS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 14:53:18 -0400
In-Reply-To: <cover.1503945861.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The hardware has the HW Checksum Offload bug when small
TCP patckets (with length <= 60 bytes) has wrong "checksum valid" bit.

The solution is - ignore checksum valid bit for small packets
(with length <= 60 bytes) and mark this as CHECKSUM_NONE to allow
network stack recalculate checksum itself.

Fixes: ccf9a5ed14be ("net: ethernet: aquantia: Atlantic A0 and B0 specific functions.")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c | 6 ++++++
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index faeb493..c5a02df 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -629,6 +629,12 @@ static int hw_atl_a0_hw_ring_rx_receive(struct aq_hw_s *self,
 				buff->is_udp_cso = (is_err & 0x10U) ? 0 : 1;
 			else if (0x0U == (pkt_type & 0x1CU))
 				buff->is_tcp_cso = (is_err & 0x10U) ? 0 : 1;
+
+			/* Checksum offload workaround for small packets */
+			if (rxd_wb->pkt_len <= 60) {
+				buff->is_ip_cso = 0U;
+				buff->is_cso_err = 0U;
+			}
 		}
 
 		is_err &= ~0x18U;
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 1bceb73..21784cc 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -645,6 +645,12 @@ static int hw_atl_b0_hw_ring_rx_receive(struct aq_hw_s *self,
 				buff->is_udp_cso = buff->is_cso_err ? 0U : 1U;
 			else if (0x0U == (pkt_type & 0x1CU))
 				buff->is_tcp_cso = buff->is_cso_err ? 0U : 1U;
+
+			/* Checksum offload workaround for small packets */
+			if (rxd_wb->pkt_len <= 60) {
+				buff->is_ip_cso = 0U;
+				buff->is_cso_err = 0U;
+			}
 		}
 
 		is_err &= ~0x18U;
-- 
2.7.4
