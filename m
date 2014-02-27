From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: don't disable VLAN tag stripping in promisc mode
Date: Thu, 27 Feb 2014 19:17:22 +0100
Message-ID: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rmody@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbaB0SRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 13:17:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit "fe1624c bna: RX Filter Enhancements" disables
VLAN tag stripping if the NIC is in promiscuous mode. Received VLAN tagged
packets are recognized by the driver via BNA_CQ_EF_VLAN flag and for such
packets the driver calls __vlan_hwaccel_put_tag(). The problem is the HW
marks the tagged packets with this flags also when the stripping is
disabled and thus __vlan_hwaccel_put_tag() should not be called for them.

A solution can be to call __vlan_hwaccel_put_tag() only when stripping is
enabled or to leave VLAN stripping engine enabled. The 2nd restores the
previous behavior and is IMHO better.

Cc: Rasesh Mody <rmody@brocade.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index cf64f3d..137e91a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3245,11 +3245,6 @@ bnad_set_rx_mode(struct net_device *netdev)
 			BNA_RXMODE_ALLMULTI;
 	bna_rx_mode_set(bnad->rx_info[0].rx, new_mode, mode_mask, NULL);
 
-	if (bnad->cfg_flags & BNAD_CF_PROMISC)
-		bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
-	else
-		bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
-
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
-- 
1.8.3.2
