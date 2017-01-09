From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Marvell Phy (1510) issue since v4.7 kernel
Date: Mon, 9 Jan 2017 17:38:39 -0500
Message-ID: <587410EF.5090607@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Kwok, WingMan" <w-kwok2@ti.com>
To: Andrew Lunn <andrew@lunn.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:47604 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933050AbdAIWjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Charles-Antoine, Andrew,

We have recently upgraded our kernel to v4.9 and started seeing an issue
on our Keystone EVMs (K2E/L) that uses Marvel Phy 1510. The issue is that
when we do a reboot command from the Linux console or do a SoC reset,
the DHCP times out at U-Boot due to Phy auto negotiation failure. This works
fine when the board is power cycled.

This is traced back to v4.7 where following commits were introduced:-

3758be3dc162b56ea Marvell phy: add functions to suspend and resume both interfaces: fiber and copper links.
78301ebe9b5a2645d Marvell phy: add configuration of autonegociation for fiber link.
2170fef78a400ca3c Marvell phy: add field to get errors from fiber link.
6cfb3bcc064110995 Marvell phy: check link status in case of fiber link 

Specifically the commit 6cfb3bcc0641109951a124019cd2e0623107d18d which changed
the marvell_read_status() behavior

Once we add the below HACK, this works fine.

commit e5bd8bfe7f544df03772c094331bb27e1a5a5600
Author: Murali Karicheri <m-karicheri2@ti.com>
Date:   Fri Jan 6 12:22:13 2017 -0500

    TEMP: work around in marvel Phy driver for u-boot dhcp timeout
    
    Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index c2dcf02..e91bdd3 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1194,7 +1194,7 @@ static int marvell_read_status(struct phy_device *phydev)
        int err;
 
        /* Check the fiber mode first */
-       if (phydev->supported & SUPPORTED_FIBRE) {
+       if (!(phydev->supported & SUPPORTED_FIBRE)) {
                err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
                if (err < 0)
                        goto error;


Also we see comments/logic in the code that contradicts with each other

For example in marvell_read_status(), it says "Check the fiber mode first and
uses the logic 
     if (phydev->supported & SUPPORTED_FIBRE)

Where as in  marvell_resume() comment says 'Resume the fiber mode first' and
uses the logic 

     if (!(phydev->supported & SUPPORTED_FIBRE))

Both are not symmetrical. Could you please explain?

-- 
Murali Karicheri
Linux Kernel, Keystone
