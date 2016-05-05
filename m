From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 13/20] net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL setup
Date: Thu,  5 May 2016 18:40:57 -0400
Message-ID: <1462488064-1841-14-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All switch models configure the GLOBAL_CONTROL register with slightly
differences.

Assume a common setup to enable the PHY Polling Unit if present, discard
packets with excessive collisions, set the maximum frame size to 1632,
and mask all interrupt sources.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  8 --------
 drivers/net/dsa/mv88e6131.c | 11 -----------
 drivers/net/dsa/mv88e6171.c |  9 ---------
 drivers/net/dsa/mv88e6352.c |  9 ---------
 drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
 5 files changed, 14 insertions(+), 37 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 938d5ca..077fe30 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -61,14 +61,6 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Disable the PHY polling unit (since there won't be any
-	 * external PHYs to poll), don't discard packets with
-	 * excessive collisions, and mask all interrupt sources.
-	 */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
-	if (ret)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2c43348..013668c 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -77,17 +77,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Enable the PHY polling unit, don't discard packets with
-	 * excessive collisions, use a weighted fair queueing scheme
-	 * to arbitrate between packet queues, set the maximum frame
-	 * size to 1632, and mask all interrupt sources.
-	 */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
-				  GLOBAL_CONTROL_PPU_ENABLE |
-				  GLOBAL_CONTROL_MAX_FRAME_1632);
-	if (ret)
-		return ret;
-
 	/* Set the VLAN ethertype to 0x8100. */
 	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
 	if (ret)
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index fcdb5a7..f7dbf78 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -93,15 +93,6 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Discard packets with excessive collisions, mask all
-	 * interrupt sources, enable PPU.
-	 */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
-				  GLOBAL_CONTROL_PPU_ENABLE |
-				  GLOBAL_CONTROL_DISCARD_EXCESS);
-	if (ret)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 94a2698..54849f5 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -144,15 +144,6 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Discard packets with excessive collisions,
-	 * mask all interrupt sources, enable PPU (bit 14, undocumented).
-	 */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
-				  GLOBAL_CONTROL_PPU_ENABLE |
-				  GLOBAL_CONTROL_DISCARD_EXCESS);
-	if (ret)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7ec532d..1cba078 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2912,9 +2912,23 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 
 static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 {
+	u16 reg;
 	int err;
 	int i;
 
+	/* Enable the PHY Polling Unit if present, discard packets with
+	 * excessive collisions, set the maximum frame size to 1632, and mask
+	 * all interrupt sources.
+	 */
+	reg = GLOBAL_CONTROL_DISCARD_EXCESS | GLOBAL_CONTROL_MAX_FRAME_1632;
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU) ||
+	    mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU_ACTIVE))
+		reg |= GLOBAL_CONTROL_PPU_ENABLE;
+
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	if (err)
+		return err;
+
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
-- 
2.8.2
