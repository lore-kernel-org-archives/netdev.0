From: emann@mrv.com (Eran Mann)
Subject: [patch] e100 MDI/MDIX bug(?)
Date: Fri, 31 Dec 2004 12:35:30 +0200
Message-ID: <41D52B72.3050803@mrv.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060600060702060607080608"
Cc: jgrazik@pobox.com, Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060600060702060607080608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

e100_phy_init() contains the following code to conditionally enable
MDI/MDI-X Autodetection on newer e100 chips:

         if((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
                 (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) &
0x8000) &&
                 (nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled)))
                 /* enable/disable MDI/MDI-X auto-switching */
                 mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
                         nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);


This code seems to include 4 problems:
1. e100_eeprom_load was called after e100_phy_init...
2. If the chip revision is >= mac_82550_D102 it enables the feature
    unconditionally, disregarding the eeprom.
3. According to Intel's errata, MDI/MDI-X Autodetection should never be
    enabled on 82551ER or 82551QM chips (see
    http://developer.intel.com/design/network/specupdt/82551ER_si.pdf).
4. If the eeprom disables the feature, it should be actively disabled,
    and not left as default.

suggested patch against 2.6.10 attached. An alternative would be to 
forcibly disable the feature for all chips with (nic->mac >= 
mac_82550_D102), as I'm not sure if there are chips for which it IS 
supported.

Signed-off-by: Eran Mann <emann@mrv.com>

-- 
Eran Mann
MRV International
www.mrv.com



--------------060600060702060607080608
Content-Type: text/plain;
 name="e100-mdix-2.6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e100-mdix-2.6.patch"

--- linux-2.6.x/drivers/net/e100.c	2004-12-31 11:23:51.326587040 +0200
+++ linux-2.6.x-fixed/drivers/net/e100.c	2004-12-31 11:30:26.059578504 +0200
@@ -1074,11 +1074,19 @@
 	}
 
 	if((nic->mac >= mac_82550_D102) || ((nic->flags & ich) && 
-		(mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) && 
-		(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled)))
-		/* enable/disable MDI/MDI-X auto-switching */
-		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
-			nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
+		(mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) 
+		& 0x8000))) {
+		/* enable/disable MDI/MDI-X auto-switching.
+		   According to errata  MDI/MDI-X auto-switching should 
+		   be disabled for 82551ER/QM chips */
+		if ((nic->mac == mac_82551_E) || (nic->mac == mac_82551_F) ||
+			(nic->mac == mac_82551_10) || (nic->mii.force_media) || 
+			!(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled)) 
+			mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG, 0);
+		else
+			mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
+				NCONFIG_AUTO_SWITCH);
+	}
 
 	return 0;
 }
@@ -2248,11 +2256,11 @@
 		goto err_out_iounmap;
 	}
 
-	e100_phy_init(nic);
-
 	if((err = e100_eeprom_load(nic)))
 		goto err_out_free;
 
+	e100_phy_init(nic);
+
 	memcpy(netdev->dev_addr, nic->eeprom, ETH_ALEN);
 	if(!is_valid_ether_addr(netdev->dev_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC address from "

--------------060600060702060607080608--
