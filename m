From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH net] mdio: mux: fix parsing mux registers outside of the PHY address range
Date: Mon, 10 Jul 2017 14:35:23 +0200
Message-ID: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
Cc: linux-amlogic@lists.infradead.org, jon.mason@broadcom.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36198 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753889AbdGJMfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 08:35:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id 77so24640950wrb.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 05:35:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdio_mux_init parses the child nodes of the MDIO mux. When using
"mdio-mux-mmioreg" the child nodes are describing the register value
that is written to switch between the MDIO busses.

The change which makes the error messages more verbose changed the
parsing of the "reg" property from a simple of_property_read_u32 call
to of_mdio_parse_addr. On a Khadas VIM (based on the Meson GXL SoC,
which uses mdio-mux-mmioreg) this prevents registering the MDIO mux
(because the "reg" values on the MDIO mux child nodes are 0x2009087f
and 0xe40908ff) and leads to the following errors:
  mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff PHY address -469169921 is too large
  mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@e40908ff
  mdio-mux-mmioreg c883455c.eth-phy-mux: /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f PHY address 537462911 is too large
  mdio-mux-mmioreg c883455c.eth-phy-mux: Error: Failed to find reg for child /soc/periphs@c8834000/eth-phy-mux/mdio@2009087f
  mdio-mux-mmioreg c883455c.eth-phy-mux: Error: No acceptable child buses found
  mdio-mux-mmioreg c883455c.eth-phy-mux: failed to register mdio-mux bus /soc/periphs@c8834000/eth-phy-mux
(as a result of that ethernet is not working, because the PHY which is
connected through the mux' child MDIO bus, which is not being
registered).

Fix this by reverting the change from of_mdio_parse_addr to
of_mdio_parse_addr.

Fixes: 342fa1964439 ("mdio: mux: make child bus walking more permissive and errors more verbose")
Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/phy/mdio-mux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 00755b6a42cf..c608e1dfaf09 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -135,8 +135,8 @@ int mdio_mux_init(struct device *dev,
 	for_each_available_child_of_node(dev->of_node, child_bus_node) {
 		int v;
 
-		v = of_mdio_parse_addr(dev, child_bus_node);
-		if (v < 0) {
+		r = of_property_read_u32(child_bus_node, "reg", &v);
+		if (r) {
 			dev_err(dev,
 				"Error: Failed to find reg for child %s\n",
 				of_node_full_name(child_bus_node));
-- 
2.13.2
