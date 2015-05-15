From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: properly propagate carrier down state for MoCA
Date: Fri, 15 May 2015 12:38:01 -0700
Message-ID: <1431718681-8925-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37847 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932810AbbEOTi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 15:38:26 -0400
Received: by igbsb11 with SMTP id sb11so3189947igb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 12:38:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MoCA interfaces require the use of an user-space daemon (mocad) which
will typically use cmd->autoneg to force the link. This is causing other
network manager applications not to get proper carrier down
notifications because of the following sequence of events:

- link down interrupt is received, link is set to 0 by the interrupt
  handler
- fixed_link update callback runs and updates the BMSR register
  accordingly
- PHY library polls the PHY for link status, sees the link is down,
  proceeds with reporting that
- mocad gets notified of the link state and call phy_ethtool_sset()
  with cmd->autoneg set to the link status (0)
- phy_start_aneg() is called at the end of phy_ethtool_sset() and sets
  the PHY state to PHY_FORCING

Just make sure we notify the interface carrier appropriately when we
detect that the link is down in our fixed_link update callback. This is
made local to the bcm_sf2 driver as the PHY library does the right thing
in any case. This is similar to the GENET change introduced in
54d7c01d3ed699cfc213115eaecfe1175cfaff8f ("net: bcmgenet: enable MoCA
link state change detection").

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index cedb572bf25a..103fde3da476 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -911,6 +911,13 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 	 */
 	if (port == 7) {
 		status->link = priv->port_sts[port].link;
+		/* For MoCA interfaces, also force a link down notification
+		 * since some version of the user-space daemon (mocad) use
+		 * cmd->autoneg to force the link, which messes up the PHY
+		 * state machine and make it go in PHY_FORCING state instead.
+		 */
+		if (!status->link)
+			netif_carrier_off(ds->ports[port]);
 		status->duplex = 1;
 	} else {
 		status->link = 1;
-- 
2.1.0
