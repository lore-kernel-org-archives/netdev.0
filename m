From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 6/7] net:ethernet:aquantia: Fix for multicast filter handling.
Date: Wed, 23 Aug 2017 17:05:07 +0300
Message-ID: <745a18bcae3b0ed1e2c4c178f4f30f5f4aed9ef1.1503496727.git.pavel.belous@aquantia.com>
References: <cover.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:6394
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754001AbdHWOHU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:07:20 -0400
In-Reply-To: <cover.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Russkikh <Igor.Russkikh.aquantia.com>

Since the HW supports up to 32 multicast filters we should
track count of multicast filters to avoid overflow.
If we attempt to add >32 multicast filter - just set NETIF_ALLMULTI flag
instead.

Fixes: 94f6c9e4cdf6 ("net: ethernet: aquantia: Support for NIC-specific code")
Signed-off-by: Igor Russkikh <Igor.Russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index dce17a5..6ac9e26 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -669,11 +669,26 @@ int aq_nic_set_multicast_list(struct aq_nic_s *self, struct net_device *ndev)
 	netdev_for_each_mc_addr(ha, ndev) {
 		ether_addr_copy(self->mc_list.ar[i++], ha->addr);
 		++self->mc_list.count;
+
+		if (i >= AQ_CFG_MULTICAST_ADDRESS_MAX)
+			break;
 	}
 
-	return self->aq_hw_ops.hw_multicast_list_set(self->aq_hw,
+	if (i >= AQ_CFG_MULTICAST_ADDRESS_MAX) {
+		/* Number of filters is too big: atlantic does not support this.
+		 * Force all multi filter to support this.
+		 * With this we disable all UC filters and setup "all pass"
+		 * multicast mask
+		 */
+		self->packet_filter |= IFF_ALLMULTI;
+		self->aq_hw->aq_nic_cfg->mc_list_count = 0;
+		return self->aq_hw_ops.hw_packet_filter_set(self->aq_hw,
+							self->packet_filter);
+	} else {
+		return self->aq_hw_ops.hw_multicast_list_set(self->aq_hw,
 						    self->mc_list.ar,
 						    self->mc_list.count);
+	}
 }
 
 int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
-- 
2.7.4
