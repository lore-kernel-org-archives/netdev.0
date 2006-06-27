From: Brent Cook <bcook@bpointsys.com>
Subject: [PATCH 3/3] mv643xx fixes - Support BCM5461 PHY initialization
Date: Tue, 27 Jun 2006 09:52:11 -0500
Message-ID: <200606270952.11163.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:10773 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1030643AbWF0Ov6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:51:58 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of PrPMC MV64x60 boards have Broadcom BCM5461 PHYs rather than 
Marvell. This patch adds the initialization bits required by these PHYs. 

There was infrastructure prior to the 2.6.16 kernel for the ppc platform 
support to add extra flags to the ethernet ports during initialization but 
driver simplifaction removed this ability, so I just put the required 
TX_CLK_DELAY flag in the main driver instead. This does not appear to have 
any affect on the Marvell PHY-based board that I tested it on.

Signed-off-by: Brent Cook <bcook@bpointsys.com>

--- a/drivers/net/mv643xx_eth.c	2006-05-04 00:51:47.000000000 -0500
+++ b/drivers/net/mv643xx_eth.c	2006-06-27 09:20:58.000000000 -0500
@@ -1788,6 +1795,7 @@
 		MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII    |
 		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX     |
 		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	   |
+		MV643XX_ETH_TX_CLK_DELAY		   |
 		MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED;
 
 	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
@@ -2275,6 +2283,7 @@
 static void ethernet_phy_reset(unsigned int eth_port_num)
 {
 	unsigned int phy_reg_data;
+	unsigned int id1, id2;
 
 	/* Reset the PHY */
 	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
@@ -2286,6 +2295,14 @@
 		udelay(1);
 		eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
 	} while (phy_reg_data & 0x8000);
+
+	/* Check PHY type */
+	eth_port_read_smi_reg(eth_port_num, 0x02, &id1);
+	eth_port_read_smi_reg(eth_port_num, 0x03, &id2);
+	if ((id1 == 0x0020) && ((id2 & 0xfff0) == 0x60c0)) {
+		/* BCM5461 fixup: Disable GTXC delay */
+		eth_port_write_smi_reg(eth_port_num, 0x1c, 0x8c00);
+	}
 }
 
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
