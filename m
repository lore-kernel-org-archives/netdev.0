From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix wrong information about link modes
 reported to ethtool
Date: Thu, 16 Mar 2017 16:16:17 -0700
Message-ID: <20170316231616.GA1819@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        manish.awasthi@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0063.outbound.protection.outlook.com ([104.47.40.63]:5009
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751871AbdCPXQY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 19:16:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Awasthi <manish.awasthi@cavium.com>

Information reported to ethtool about link modes is wrong for 25G NIC.  Fix
it by checking for presence of 25G NIC, checking the link speed reported by
NIC firmware, and then assigning proper values to the
ethtool_link_ksettings struct.

Signed-off-by: Manish Awasthi <manish.awasthi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 50384ce..6eef3b9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -213,17 +213,23 @@ static int lio_get_link_ksettings(struct net_device *netdev,
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct oct_link_info *linfo;
-	u32 supported, advertising;
+	u32 supported = 0, advertising = 0;
 
 	linfo = &lio->linfo;
 
 	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
 	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_XLAUI ||
 	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
 		ecmd->base.port = PORT_FIBRE;
-		supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
-			     SUPPORTED_Pause);
-		advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Pause);
+
+		if (linfo->link.s.speed == SPEED_10000) {
+			supported = SUPPORTED_10000baseT_Full;
+			advertising = ADVERTISED_10000baseT_Full;
+		}
+
+		supported |= SUPPORTED_FIBRE | SUPPORTED_Pause;
+		advertising |= ADVERTISED_Pause;
 		ethtool_convert_legacy_u32_to_link_mode(
 			ecmd->link_modes.supported, supported);
 		ethtool_convert_legacy_u32_to_link_mode(
