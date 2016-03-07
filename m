From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: avoid writing the same mode
Date: Mon,  7 Mar 2016 18:24:52 -0500
Message-ID: <1457393092-22826-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48026 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933148AbcCGXY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 18:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to change the 802.1Q port mode for the same value.
Thus avoid such message:

    [  401.954836] dsa dsa@0 lan0: 802.1Q Mode: Disabled (was Disabled)

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1aee42d..5f07524 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1765,16 +1765,21 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 
 	old = ret & PORT_CONTROL_2_8021Q_MASK;
 
-	ret &= ~PORT_CONTROL_2_8021Q_MASK;
-	ret |= new & PORT_CONTROL_2_8021Q_MASK;
+	if (new != old) {
+		ret &= ~PORT_CONTROL_2_8021Q_MASK;
+		ret |= new & PORT_CONTROL_2_8021Q_MASK;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2, ret);
-	if (ret < 0)
-		goto unlock;
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2,
+					   ret);
+		if (ret < 0)
+			goto unlock;
+
+		netdev_dbg(ds->ports[port], "802.1Q Mode %s (was %s)\n",
+			   mv88e6xxx_port_8021q_mode_names[new],
+			   mv88e6xxx_port_8021q_mode_names[old]);
+	}
 
-	netdev_dbg(ds->ports[port], "802.1Q Mode: %s (was %s)\n",
-		   mv88e6xxx_port_8021q_mode_names[new],
-		   mv88e6xxx_port_8021q_mode_names[old]);
+	ret = 0;
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
-- 
2.7.2
