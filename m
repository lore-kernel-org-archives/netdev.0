From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 6/6] DCB: setting pg will cause tx unit hangs
Date: Mon, 06 Oct 2008 20:07:51 -0700
Message-ID: <20081007030744.782.56910.stgit@gitlost.lost>
References: <20081007030540.782.28987.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:32776 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754699AbYJGDIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 23:08:11 -0400
In-Reply-To: <20081007030540.782.28987.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It seems like the configuration may be doing things while the adapter is
still up that it shouldn't.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 51d162d..615c280 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -135,7 +135,7 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			return;
 		} else {
-			if (netdev->flags & IFF_UP)
+			if (netif_running(netdev))
 				netdev->stop(netdev);
 			ixgbe_reset_interrupt_capability(adapter);
 			ixgbe_napi_del_all(adapter);
@@ -149,13 +149,13 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 			ixgbe_init_interrupt_scheme(adapter);
 			ixgbe_napi_add_all(adapter);
-			if (netdev->flags & IFF_UP)
+			if (netif_running(netdev))
 				netdev->open(netdev);
 		}
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			if (netdev->flags & IFF_UP)
+			if (netif_running(netdev))
 				netdev->stop(netdev);
 			ixgbe_reset_interrupt_capability(adapter);
 			ixgbe_napi_del_all(adapter);
@@ -169,7 +169,7 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 			ixgbe_init_interrupt_scheme(adapter);
 			ixgbe_napi_add_all(adapter);
-			if (netdev->flags & IFF_UP)
+			if (netif_running(netdev))
 				netdev->open(netdev);
 		} else {
 			return;
@@ -338,6 +338,9 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
+	if (netif_running(netdev))
+		ixgbe_down(adapter);
+
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
 				 adapter->ring_feature[RING_F_DCB].indices);
 	if (ret) {
@@ -345,8 +348,9 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return ret;
 	}
 
-	ixgbe_down(adapter);
-	ixgbe_up(adapter);
+	if (netif_running(netdev))
+		ixgbe_up(adapter);
+
 	adapter->dcb_set_bitmap = 0x00;
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return ret;

