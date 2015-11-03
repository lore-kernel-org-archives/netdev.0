From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: include DSA ports in VLANs
Date: Tue,  3 Nov 2015 10:52:52 -0500
Message-ID: <1446565972-4269-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58284 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbbKCQCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:02:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA ports must be members of a VLAN in order to ensure frame bridging
between chained switch chips.

Thus tag them in addition to the CPU port when adding a VLAN, and skip
them when deleting a VLAN and reporting VLAN members.

Also use the UNMODIFIED egress policy, so that frames egress on these
ports as they ingress, tagged or untagged.

Fixes: 0d3b33e60206 ("net: dsa: mv88e6xxx: add VLAN Load support")
Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3bec315..161e45c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1536,11 +1536,11 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 	};
 	int i;
 
-	/* exclude all ports except the CPU */
+	/* exclude all ports except the CPU and DSA ports */
 	for (i = 0; i < ps->num_ports; ++i)
-		vlan.data[i] = dsa_is_cpu_port(ds, i) ?
-			GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED :
-			GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
+			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
+			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
 	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
@@ -1639,7 +1639,7 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 
 	/* keep the VLAN unless all ports are excluded */
 	for (i = 0; i < ps->num_ports; ++i) {
-		if (dsa_is_cpu_port(ds, i))
+		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
 		if (vlan.data[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
@@ -1712,7 +1712,7 @@ int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 		clear_bit(port, ports);
 		clear_bit(port, untagged);
 
-		if (dsa_is_cpu_port(ds, port))
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
 			continue;
 
 		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED ||
-- 
2.6.2
