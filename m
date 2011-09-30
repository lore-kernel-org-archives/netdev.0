From: David Daney <david.daney@cavium.com>
Subject: [RFD PATCH] netdev/phy/of: Augment device tree bindings for PHYs to specify IEEE802.3-2005 Section 45 addressing.
Date: Fri, 30 Sep 2011 16:09:42 -0700
Message-ID: <1317424182-29252-1-git-send-email-david.daney@cavium.com>
Cc: David Daney <david.daney@cavium.com>
To: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1702 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab1I3XKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 19:10:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many 10 gigabit Ethernet PHY devices are interfaced to the MDIO bus
using a protocol called IEEE802.3-2005 Section 45.  Where as PHYS for
1G, 100M and 10M usually use IEEE802.3-2005 Section 22.  These two
protocols can be present on the same MDIO bus.

If we look at the Linux PHY probing code in drivers/of/of_mdio.c and
drivers/net/phy/phy_device.c, we have the situation where we need to
read the PHY registers to get the PHY ID out so that we can use this
to bind to a compatible driver.  However we can only read these
registers if we know the proper MDIO bus protocol to use.

My idea is as follows:

o Add an optional property "mdio-clause-45" to the PHY's device tree
  node to indicate that clause 45 addressing is used.

o When calling get_phy_id() we will set MII_ADDR_C45 in the address
  if we know that clause 45 addressing is required for the PHY.
  get_phy_id() will then use the proper bus protocol and register
  numbers to read PHY ID based on MII_ADDR_C45.

o of_mdiobus_register() will signal MII_ADDR_C45 for PHYs tagged with
  "mdio-clause-45"

o Existing PHYs without "mdio-clause-45" are unaffected.

o If no specific driver for the probed PHY ID is present, we can still
  communicate with the PHY and perhaps use a generic 10G phy driver.
  If the MDIO bus protocol were just to depend on the "compatible"
  property, then we could not use generic drivers for unknown PHY IDs

Comments/other ideas welcome.

Thanks,

Signed-off-by: David Daney <david.daney@cavium.com>
---
 Documentation/devicetree/bindings/net/phy.txt |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index bb8c742..69fd948 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -14,6 +14,11 @@ Required properties:
  - linux,phandle :  phandle for this node; likely referenced by an
    ethernet controller node.
 
+Optional properties:
+
+ - mdio-clause-45 : Optional.  If present, IEEE802.3-2005 Section 45
+   protocol is used for register access (usually for 10G PHYs).
+
 Example:
 
 ethernet-phy@0 {
-- 
1.7.2.3
