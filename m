From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: mv88e6xxx: call _mv88e6xxx_stats_wait with SMI lock held
Date: Mon,  3 Aug 2015 09:17:44 -0400
Message-ID: <1438607864-17829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At switch setup, _mv88e6xxx_stats_wait was called without holding the
SMI mutex. Fix this by requesting the lock for this call.

Also, return the _mv88e6xxx_stats_wait code, since it may fail.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5e1dce1..8966cf2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1938,6 +1938,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
 	int i;
 
 	/* Set the default address aging time to 5 minutes, and
@@ -2036,9 +2037,11 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP, GLOBAL_STATS_OP_FLUSH_ALL);
 
 	/* Wait for the flush to complete. */
-	_mv88e6xxx_stats_wait(ds);
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_stats_wait(ds);
+	mutex_unlock(&ps->smi_mutex);
 
-	return 0;
+	return ret;
 }
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
-- 
2.4.6
