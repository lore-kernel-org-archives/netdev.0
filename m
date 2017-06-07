From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/5] net: dsa: mv88e6xxx: define membership on VLAN add
Date: Wed,  7 Jun 2017 18:12:13 -0400
Message-ID: <20170607221217.2323-2-vivien.didelot@savoirfairelinux.com>
References: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58410 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdFGWOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 18:14:30 -0400
In-Reply-To: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the target port membership of the VLAN entry in
mv88e6xxx_port_vlan_add where ds is scoped.

Allow the DSA core to call later the port_vlan_add operation for CPU or
DSA ports, by using the Unmodified membership for these ports, as in the
current behavior.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 44c87027623b..962b4e873bf9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1274,7 +1274,7 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 }
 
 static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
-				    u16 vid, bool untagged)
+				    u16 vid, u8 member)
 {
 	struct mv88e6xxx_vtu_entry vlan;
 	int err;
@@ -1283,9 +1283,7 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	vlan.member[port] = untagged ?
-		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
-		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+	vlan.member[port] = member;
 
 	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
 }
@@ -1297,15 +1295,23 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	u8 member;
 	u16 vid;
 
 	if (!chip->info->max_vid)
 		return;
 
+	if (dsa_is_dsa_port(ds, port) || dsa_is_cpu_port(ds, port))
+		member = GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+	else if (untagged)
+		member = GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED;
+	else
+		member = GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+
 	mutex_lock(&chip->reg_lock);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
-		if (_mv88e6xxx_port_vlan_add(chip, port, vid, untagged))
+		if (_mv88e6xxx_port_vlan_add(chip, port, vid, member))
 			netdev_err(ds->ports[port].netdev,
 				   "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
-- 
2.13.1
