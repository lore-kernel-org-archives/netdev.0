From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: disable SA learning for DSA and CPU ports
Date: Tue,  3 Nov 2015 10:52:36 -0500
Message-ID: <1446565956-14893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>

Frames with DSA headers passing to/from the CPU were taking place in the
MAC learning on these ports, resulting in incorrect ATU entries. Disable
learning on these ports.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 8 ++++++--
 drivers/net/dsa/mv88e6xxx.h | 5 +++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1f7dd92..3bec315 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2123,8 +2123,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR,
-				   1 << port);
+	reg = 1 << port;
+	/* Disable learning for DSA and CPU ports */
+	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+		reg = PORT_ASSOC_VECTOR_LOCKED_PORT;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
 	if (ret)
 		goto abort;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9b6f3d9..ade5d9e5 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -157,6 +157,11 @@
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
 #define PORT_ASSOC_VECTOR	0x0b
+#define PORT_ASSOC_VECTOR_HOLD_AT_1		BIT(15)
+#define PORT_ASSOC_VECTOR_INT_AGE_OUT		BIT(14)
+#define PORT_ASSOC_VECTOR_LOCKED_PORT		BIT(13)
+#define PORT_ASSOC_VECTOR_IGNORE_WRONG		BIT(12)
+#define PORT_ASSOC_VECTOR_REFRESH_LOCKED	BIT(11)
 #define PORT_ATU_CONTROL	0x0c
 #define PORT_PRI_OVERRIDE	0x0d
 #define PORT_ETH_TYPE		0x0f
-- 
2.6.2
