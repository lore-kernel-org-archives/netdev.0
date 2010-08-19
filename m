From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/20] ixgbe: move setting of GSO size for 82598
	into ixgbe_configure_dcb
Date: Thu, 19 Aug 2010 16:34:04 -0700
Message-ID: <20100819233402.10335.66985.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:57553
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252Ab0HSXeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:34:24 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We are unnecessarily modifying the GSO size for all HW when we don't need
to.  The code can be simplified by moving the check for DCB and the
adjustment of the GSO size for 82598 into ixgbe_configure_dcb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5dceaf3..fffb1ce 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3157,6 +3157,15 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	u32 txdctl;
 	int i, j;
 
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED)) {
+		if (hw->mac.type == ixgbe_mac_82598EB)
+			netif_set_gso_max_size(adapter->netdev, 65536);
+		return;
+	}
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		netif_set_gso_max_size(adapter->netdev, 32768);
+
 	ixgbe_dcb_check_config(&adapter->dcb_cfg);
 	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_TX_CONFIG);
 	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_RX_CONFIG);
@@ -3188,17 +3197,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 
 	ixgbe_restore_vlan(adapter);
 #ifdef CONFIG_IXGBE_DCB
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		if (hw->mac.type == ixgbe_mac_82598EB)
-			netif_set_gso_max_size(netdev, 32768);
-		else
-			netif_set_gso_max_size(netdev, 65536);
-		ixgbe_configure_dcb(adapter);
-	} else {
-		netif_set_gso_max_size(netdev, 65536);
-	}
-#else
-	netif_set_gso_max_size(netdev, 65536);
+	ixgbe_configure_dcb(adapter);
 #endif
 
 #ifdef IXGBE_FCOE

