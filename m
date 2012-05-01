From: Michele Cucchi <cucchimichele@tiscali.it>
Subject: [PATCH 1/1] sky2: fix YUKON FE+ rev. A0, ingress VLAN tagged frame problem
Date: Tue,  1 May 2012 17:49:00 +0200
Message-ID: <1335887340-24284-1-git-send-email-cucchimichele@tiscali.it>
Cc: netdev@vger.kernel.org, Michele Cucchi <cucchimichele@tiscali.it>
To: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from santino.mail.tiscali.it ([213.205.33.245]:39043 "EHLO
	santino.mail.tiscali.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab2EAPyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 11:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cards based on chip YUKON FE+ revision A0, fails to correctly receive VLAN tagged frames. The ingress frames stays on raw physical interface and don't reach VLANS allocated interfaces.
The problem is the double call of __vlan_hwaccel_put_tag function, one in the sky2_skb_rx function and the other in the vlans global function vlan_untag.
Adding a check of card version and revision in the sky2_skb_rx function allow to skip the first time call of __vlan_hwaccel_put_tag and to fix the problem.

This fix is tested on 3.4-rc5.

Signed-off-by: Michele Cucchi <cucchimichele@tiscali.it>
---
 drivers/net/ethernet/marvell/sky2.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index c9b504e..2be0351 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2649,7 +2649,10 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
 			       u32 status, struct sk_buff *skb)
 {
-	if (status & GMR_FS_VLAN)
+	/* Workaround for YUKON FE+ rev. A0, vlan untag problem */
+	if ((status & GMR_FS_VLAN) &&
+	(!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)))
 		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
 
 	if (skb->ip_summed == CHECKSUM_NONE)
-- 
1.7.2.5
