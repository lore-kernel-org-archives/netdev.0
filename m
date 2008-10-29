From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Doubts about the get_phy_id function.
Date: Wed, 29 Oct 2008 10:12:22 +0100
Message-ID: <490828F6.4000307@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aob014.obsmtp.com ([207.126.144.118]:33199 "EHLO
	eu1sys200aob110.obsmtp.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752326AbYJ2Jhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:37:54 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id F11E5DAB8
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 09:11:39 +0000 (GMT)
Received: from mail1.ctn.st.com (mail1.ctn.st.com [164.130.116.128])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id ABE784C026
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 09:11:39 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
Using a bad PHY address, the physical device is erroneously attached to 
the MAC device driver.
This happens because the get_phy_id function reads zero from the 
PHYIR1/2 regs and never fails.
I'm facing this problem on some PHY devices (*) but I've not clear 
enough if this can actually depend on an HW issue (e.g.invalid  phy 
addresses have been left floating) or we need to apply the patch below. 
Indeed, it helps me to catch the problem and, as final result, the 
phy_connect always fails on wrong PHY address and the network interface 
cannot be opened.

(*) on other ones, the get_phy_id function reads 0xffff from PHYIR1/2 
regs and fails (as expected results) when I try to attach a wrong PHY 
address.

Welcome advice.
Best Regards,
Peppe

PS: if it makes sense for you, I can rework the patch and send it to the 
ML again.

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8ad602c..8a1baf9 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -192,7 +192,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 
*phy_id)
         * in the upper half */
        phy_reg = bus->read(bus, addr, MII_PHYSID1);
 
-       if (phy_reg < 0)
+       if (phy_reg <= 0)
                return -EIO;
 
        *phy_id = (phy_reg & 0xffff) << 16;
@@ -200,7 +200,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 
*phy_id)
        /* Grab the bits from PHYIR2, and put them in the lower half */
        phy_reg = bus->read(bus, addr, MII_PHYSID2);
 
-       if (phy_reg < 0)
+       if (phy_reg <= 0)
                return -EIO;
 
        *phy_id |= (phy_reg & 0xffff);
