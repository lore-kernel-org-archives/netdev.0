From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] sis190: read the mac address from the eeprom first
Date: Mon, 18 Feb 2008 21:20:32 +0100
Message-ID: <20080218202032.GA2565@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	dsd@gentoo.org, "Gabriel A. Devenyi" <ace@staticwave.ca>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48101 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752076AbYBRUjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 15:39:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading a serie of zero from the cmos sram area do not work
well with is_valid_ether_addr(). Let's read the mac address
from the eeprom first as it seems more reliable.

Fix for http://bugzilla.kernel.org/show_bug.cgi?id=9831

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 202fdf3..20745fd 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1633,13 +1633,18 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
 					 struct net_device *dev)
 {
-	u8 from;
+	int rc;
+
+	rc = sis190_get_mac_addr_from_eeprom(pdev, dev);
+	if (rc < 0) {
+		u8 reg;
 
-	pci_read_config_byte(pdev, 0x73, &from);
+		pci_read_config_byte(pdev, 0x73, &reg);
 
-	return (from & 0x00000001) ?
-		sis190_get_mac_addr_from_apc(pdev, dev) :
-		sis190_get_mac_addr_from_eeprom(pdev, dev);
+		if (reg & 0x00000001)
+			rc = sis190_get_mac_addr_from_apc(pdev, dev);
+	}
+	return rc;
 }
 
 static void sis190_set_speed_auto(struct net_device *dev)
-- 
1.5.3.3

