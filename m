From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3 net-next] tg3: Fix poor tx performance on 57766
 after MTU change
Date: Sun, 4 Mar 2012 16:48:15 -0800
Message-ID: <1330908495-3758-3-git-send-email-mchan@broadcom.com>
References: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
 <1330908495-3758-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2532 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754963Ab2CEAkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 19:40:43 -0500
In-Reply-To: <1330908495-3758-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRC reset causes the read DMA engine to go into a mode that breaks up
requests into 256 bytes.  A PHY reset is required to bring it back to
the normal mode.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0da93db..a8490a4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12267,7 +12267,7 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int err;
+	int err, reset_phy = 0;
 
 	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
 		return -EINVAL;
@@ -12290,7 +12290,13 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 
 	tg3_set_mtu(dev, tp, new_mtu);
 
-	err = tg3_restart_hw(tp, 0);
+	/* Reset PHY, otherwise the read DMA engine will be in a mode that
+	 * breaks all requests to 256 bytes.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57766)
+		reset_phy = 1;
+
+	err = tg3_restart_hw(tp, reset_phy);
 
 	if (!err)
 		tg3_netif_start(tp);
-- 
1.7.1
