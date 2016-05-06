From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/21] net: dsa: mv88e6xxx: factorize registers access
Date: Fri,  6 May 2016 17:57:10 -0400
Message-ID: <1462571843-14397-9-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only 6131 was not supporting the port registers access yet. Assume such
support and use the unlock access routines in the meantime.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c | 2 ++
 drivers/net/dsa/mv88e6xxx.c | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 432d3c4..3fb06af 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -157,6 +157,8 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6xxx_get_temp,
 	.get_temp_limit		= mv88e6xxx_get_temp_limit,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f76cdc9..7a4ab4b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -787,13 +787,17 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 
 	memset(p, 0xff, 32 * sizeof(u16));
 
+	mutex_lock(&ps->smi_mutex);
+
 	for (i = 0; i < 32; i++) {
 		int ret;
 
-		ret = mv88e6xxx_reg_read(ps, REG_PORT(port), i);
+		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), i);
 		if (ret >= 0)
 			p[i] = ret;
 	}
+
+	mutex_unlock(&ps->smi_mutex);
 }
 
 static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
-- 
2.8.2
