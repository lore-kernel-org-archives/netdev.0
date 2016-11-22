From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Tue, 22 Nov 2016 11:39:44 +0100
Message-ID: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:35001 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753324AbcKVKkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:40:20 -0500
Received: by mail-wj0-f196.google.com with SMTP id f8so5953941wje.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:40:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Egress multicast and egress unicast is only enabled for CPU/DSA ports
but for switching operation it seems it should be enabled for all ports.
Do I miss something here?

I did the following test:
brctl addbr br0
brctl addif br0 lan0
brctl addif br0 lan1

In this scenario the unicast and multicast packets were not forwarded,
therefore ARP requests were not resolved, and no connection could be
established.

If no bridge is configured we do not forward unicast and multicast
packets because the VLAN mapping is active.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 883fd98..fe76372 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2506,15 +2506,14 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6320_family(chip))
 		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
-		PORT_CONTROL_STATE_FORWARDING;
+		PORT_CONTROL_STATE_FORWARDING |
+		PORT_CONTROL_FORWARD_UNKNOWN_MC | PORT_CONTROL_FORWARD_UNKNOWN;
 	if (dsa_is_cpu_port(ds, port)) {
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
-			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
-				PORT_CONTROL_FORWARD_UNKNOWN_MC;
+			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
 		else
 			reg |= PORT_CONTROL_DSA_TAG;
-		reg |= PORT_CONTROL_EGRESS_ADD_TAG |
-			PORT_CONTROL_FORWARD_UNKNOWN;
+		reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 	}
 	if (dsa_is_dsa_port(ds, port)) {
 		if (mv88e6xxx_6095_family(chip) ||
-- 
2.9.3
