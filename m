From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH 2/2] dsa: mv88e6131: support fixed PHYs
Date: Thu, 12 Feb 2015 15:13:17 +0100
Message-ID: <20150212141317.GB12318@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:44488 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228AbbBLONa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 09:13:30 -0500
Received: by lams18 with SMTP id s18so10232525lam.11
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 06:13:28 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id an8sm786322lbc.45.2015.02.12.06.13.25
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 06:13:26 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statically setup the PCS Control on the MAC to match the fixed PHY.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 drivers/net/dsa/mv88e6131.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index eadb27c..d2b2fcf 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -337,6 +337,48 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
 }
 
+static void mv88e6131_adjust_link(struct dsa_switch *ds, int port,
+				  struct phy_device *phy)
+{
+	u16 pcs_ctrl;
+
+	/* PPU will configure MACs with physical PHYs */
+	if (!fixed_phy_get_status(phy))
+		return;
+
+	pcs_ctrl = mv88e6xxx_reg_read(ds, REG_PORT(port), 1);
+
+	/* clear all forced settings */
+	pcs_ctrl &= ~0xff;
+	pcs_ctrl |= BIT(2) | BIT(4) | BIT(6);
+
+	switch (phy->speed) {
+	case 10:
+		break;
+	case 100:
+		pcs_ctrl |= BIT(0);
+		break;
+	case 1000:
+		pcs_ctrl |= BIT(1);
+		break;
+
+	default:
+		netdev_err(ds->ports[port], "unsupported speed: %d\n", phy->speed);
+	}
+
+	if (phy->duplex)
+		pcs_ctrl |= BIT(3);
+
+	if (phy->link)
+		pcs_ctrl |= BIT(5);
+
+	if (phy->pause)
+		pcs_ctrl |= BIT(7);
+
+	mv88e6xxx_reg_write(ds, REG_PORT(port), 1, pcs_ctrl);
+	return;
+}
+
 static struct mv88e6xxx_hw_stat mv88e6131_hw_stats[] = {
 	{ "in_good_octets", 8, 0x00, },
 	{ "in_bad_octets", 4, 0x02, },
@@ -398,6 +440,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
 	.phy_write		= mv88e6131_phy_write,
+	.adjust_link		= mv88e6131_adjust_link,
 	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6131_get_strings,
 	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
-- 
1.8.4.357.g8d83871.dirty
