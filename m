From: Brandon Philips <brandon@ifup.org>
Subject: [PATCH] sky2: enable rx/tx in sky2_phy_reinit()
Date: Wed, 16 Jun 2010 19:21:58 -0700
Message-ID: <20100617022158.GA4135@jenkins.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f186.google.com ([209.85.211.186]:58703 "EHLO
	mail-yw0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab0FQC2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 22:28:32 -0400
Received: by ywh16 with SMTP id 16so4588361ywh.21
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 19:28:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sky2_phy_reinit is called by the ethtool helpers sky2_set_settings,
sky2_nway_reset and sky2_set_pauseparam when netif_running.

However, at the end of sky2_phy_init GM_GP_CTRL has GM_GPCR_RX_ENA and
GM_GPCR_TX_ENA cleared. So, doing these commands causes the device to
stop working:

$ ethtool -r eth0
$ ethtool -A eth0 autoneg off

Fix this issue by enabling Rx/Tx after running sky2_phy_init in
sky2_phy_reinit.

Signed-off-by: Brandon Philips <bphilips@suse.de>
Tested-by: Brandon Philips <bphilips@suse.de>
Cc: stable@kernel.org

---
 drivers/net/sky2.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 2111c7b..7985165 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -717,11 +717,24 @@ static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
+/* Enable Rx/Tx */
+static void sky2_enable_rx_tx(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	u16 reg;
+
+	reg = gma_read16(hw, port, GM_GP_CTRL);
+	reg |= GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
+	gma_write16(hw, port, GM_GP_CTRL, reg);
+}
+
 /* Force a renegotiation */
 static void sky2_phy_reinit(struct sky2_port *sky2)
 {
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_init(sky2->hw, sky2->port);
+	sky2_enable_rx_tx(sky2);
 	spin_unlock_bh(&sky2->phy_lock);
 }
 
@@ -2040,7 +2053,6 @@ static void sky2_link_up(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u16 reg;
 	static const char *fc_name[] = {
 		[FC_NONE]	= "none",
 		[FC_TX]		= "tx",
@@ -2048,10 +2060,7 @@ static void sky2_link_up(struct sky2_port *sky2)
 		[FC_BOTH]	= "both",
 	};
 
-	/* enable Rx/Tx */
-	reg = gma_read16(hw, port, GM_GP_CTRL);
-	reg |= GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
-	gma_write16(hw, port, GM_GP_CTRL, reg);
+	sky2_enable_rx_tx(sky2);
 
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
-- 
1.7.1


