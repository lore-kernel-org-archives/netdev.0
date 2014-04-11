From: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Subject: PHY driver loading for clause 45 PHY
Date: Fri, 11 Apr 2014 13:47:41 +0000
Message-ID: <986457BC66A4884EBFFDEFEBEB20F84C15F28CB2@satlexdag03.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0188.outbound.protection.outlook.com ([207.46.163.188]:25541
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756817AbaDKNrs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:47:48 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding PHY library maintainer, Florian, directly...

I've encountered an issue trying to get a phy driver to load when the
phy supports clause 45.  I  call get_phy_device passing in an mii_bus
structure, an MMD address and true for is_c45.  The get_phy_device
function calls the get_phy_id function which calls the appropriate c45
routines to obtain the device ids for each available MMD device.
However, phy_id is set to zero upon return (by get_phy_c45_ids).  This
zero phy_id is used by phy_device_create to build a module name in an
attempt to load a phy driver that is associated with the phy_id. Since
the module name used doesn't match any of the ids associated with my
phy driver, my phy driver does not load.

I've worked around this for now by patching phy_device_create just
before calling request_module:

diff -rup linux-3.14/drivers/net/phy/phy_device.c linux-3.14-build/drivers/net/phy/phy_device.c
--- linux-3.14/drivers/net/phy/phy_device.c	2014-03-30 22:40:15.000000000 -0500
+++ linux-3.14-build/drivers/net/phy/phy_device.c	2014-04-08 15:51:24.000000000 -0500
@@ -195,6 +195,9 @@ struct phy_device *phy_device_create(str
 	 * driver will get bored and give up as soon as it finds that
 	 * there's no driver _already_ loaded.
 	 */
+	if (is_c45 && (addr < ARRAY_SIZE(c45_ids->device_ids)))
+		phy_id = c45_ids->device_ids[addr];
+
 	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
 
 	device_initialize(&dev->dev);

This builds the proper module name, but I'm not sure this is the proper
thing to do.  Should the code loop through all the device_ids and issue
a request_module for each non-zero id?  Or is there a better way to get
a phy driver that supports clause 45 loaded?

Thanks,
Tom
