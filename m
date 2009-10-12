From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/3] mdio: Advertise pause (flow control) settings even if
	autoneg is off
Date: Mon, 12 Oct 2009 20:26:17 +0100
Message-ID: <1255375577.2931.11.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43796 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757547AbZJLT05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 15:26:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if pause autoneg is off we do not set either pause
advertising flag.  If autonegotiation of speed and duplex settings is
enabled, there is no way for the link partner to distinguish this from
our refusing to use pause frames.

We should instead set the advertising flags according to the forced
mode so that the link partner can follow our lead.  This is consistent
with the behaviour of other drivers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 21f8754..c0db9d7 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -344,11 +344,9 @@ void mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
 
 	old_adv = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
 				  MDIO_AN_ADVERTISE);
-	adv = old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-	if (ecmd->autoneg)
-		adv |= mii_advertise_flowctrl(
-			(ecmd->rx_pause ? FLOW_CTRL_RX : 0) |
-			(ecmd->tx_pause ? FLOW_CTRL_TX : 0));
+	adv = ((old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) |
+	       mii_advertise_flowctrl((ecmd->rx_pause ? FLOW_CTRL_RX : 0) |
+				      (ecmd->tx_pause ? FLOW_CTRL_TX : 0)));
 	if (adv != old_adv) {
 		mdio->mdio_write(mdio->dev, mdio->prtad, MDIO_MMD_AN,
 				 MDIO_AN_ADVERTISE, adv);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

