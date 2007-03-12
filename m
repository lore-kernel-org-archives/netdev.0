From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] skge: set mac address bonding fix
Date: Mon, 12 Mar 2007 15:16:26 -0700
Message-ID: <20070312151626.60d00e30@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
	<20070308113427.6344a7f6@freekitty>
	<Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
	<20070308134811.38a8ec81@freekitty>
	<Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
	<23552.1173395045@death>
	<Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
	<Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45837 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932881AbXCLWW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 18:22:59 -0400
In-Reply-To: <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When bonding does fail over it calls set_mac_address.  When this happens
as the result of another port going down, the phy_mutex that is common to
both ports is held, so it deadlocks. Setting the address doesn't need to do
anything that needs the phy_mutex, it already has the RTNL to protect against
other admin actions.

This change just disables the receiver to avoid any hardware confusion
while address is changing.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/skge.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index eea75a4..8fecf1b 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3275,24 +3275,30 @@ static int skge_set_mac_address(struct net_device *dev, void *p)
 	struct skge_hw *hw = skge->hw;
 	unsigned port = skge->port;
 	const struct sockaddr *addr = p;
+	u16 ctrl;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	mutex_lock(&hw->phy_mutex);
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_1 + port*8,
-		    dev->dev_addr, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_2 + port*8,
-		    dev->dev_addr, ETH_ALEN);
 
-	if (hw->chip_id == CHIP_ID_GENESIS)
-		xm_outaddr(hw, port, XM_SA, dev->dev_addr);
-	else {
-		gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
-		gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
+	/* disable Rx */
+	ctrl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
+
+	memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+	memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+
+	if (netif_running(dev)) {
+		if (hw->chip_id == CHIP_ID_GENESIS)
+			xm_outaddr(hw, port, XM_SA, dev->dev_addr);
+		else {
+			gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
+			gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
+		}
 	}
-	mutex_unlock(&hw->phy_mutex);
+
+	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
 	return 0;
 }
-- 
1.5.0.2

