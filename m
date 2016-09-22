From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/4] net: dsa: b53: implement DSA port fast ageing
Date: Thu, 22 Sep 2016 16:49:23 -0400
Message-ID: <20160922204924.16229-4-vivien.didelot@savoirfairelinux.com>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the fast ageing logic from b53_br_set_stp_state and implement the
new DSA switch port_fast_age operation instead.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 31 +++++++++++--------------------
 1 file changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 1a492c0..64be66d 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1402,16 +1402,12 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 	}
 }
 
-static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
-				 u8 state)
+static void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 {
 	struct b53_device *dev = ds->priv;
-	u8 hw_state, cur_hw_state;
+	u8 hw_state;
 	u8 reg;
 
-	b53_read8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), &reg);
-	cur_hw_state = reg & PORT_CTRL_STP_STATE_MASK;
-
 	switch (state) {
 	case BR_STATE_DISABLED:
 		hw_state = PORT_CTRL_DIS_STATE;
@@ -1433,26 +1429,20 @@ static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
 		return;
 	}
 
-	/* Fast-age ARL entries if we are moving a port from Learning or
-	 * Forwarding (cur_hw_state) state to Disabled, Blocking or Listening
-	 * state (hw_state)
-	 */
-	if (cur_hw_state != hw_state) {
-		if (cur_hw_state >= PORT_CTRL_LEARN_STATE &&
-		    hw_state <= PORT_CTRL_LISTEN_STATE) {
-			if (b53_fast_age_port(dev, port)) {
-				dev_err(ds->dev, "fast ageing failed\n");
-				return;
-			}
-		}
-	}
-
 	b53_read8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), &reg);
 	reg &= ~PORT_CTRL_STP_STATE_MASK;
 	reg |= hw_state;
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
 
+static void b53_br_fast_age(struct dsa_switch *ds, int port, u8 state)
+{
+	struct b53_device *dev = ds->priv;
+
+	if (b53_fast_age_port(dev, port))
+		dev_err(ds->dev, "fast ageing failed\n");
+}
+
 static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 {
 	return DSA_TAG_PROTO_NONE;
@@ -1472,6 +1462,7 @@ static struct dsa_switch_ops b53_switch_ops = {
 	.port_bridge_join	= b53_br_join,
 	.port_bridge_leave	= b53_br_leave,
 	.port_stp_state_set	= b53_br_set_stp_state,
+	.port_fast_age		= b53_br_fast_age,
 	.port_vlan_filtering	= b53_vlan_filtering,
 	.port_vlan_prepare	= b53_vlan_prepare,
 	.port_vlan_add		= b53_vlan_add,
-- 
2.10.0
