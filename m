From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 08/10] net: dsa: mv88e6xxx: Replace stats mutex with SMI mutex
Date: Wed,  6 May 2015 01:09:54 +0200
Message-ID: <1430867396-2268-9-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44554 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933263AbbEEXQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:16:09 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMI bus is the bottleneck in all switch operations, not the
granularity of locks. Replace the stats mutex by the SMI mutex to make
the locking concept simpler.

The REG_READ/REG_WRITE macros cannot be used while holding the SMI
mutex, since they try to acquire it. Replace with calls to the
appropriate function which does not try to get the mutex.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 50 ++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e974d26c1a03..bd033e00c751 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -515,13 +515,14 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 	return false;
 }
 
-static int mv88e6xxx_stats_wait(struct dsa_switch *ds)
+/* Must be called with SMI mutex held */
+static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		ret = REG_READ(REG_GLOBAL, GLOBAL_STATS_OP);
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_OP);
 		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
@@ -529,7 +530,8 @@ static int mv88e6xxx_stats_wait(struct dsa_switch *ds)
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
+/* Must be called with SMI mutex held */
+static int _mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
 {
 	int ret;
 
@@ -537,42 +539,45 @@ static int mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
 		port = (port + 1) << 5;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP,
-		  GLOBAL_STATS_OP_CAPTURE_PORT |
-		  GLOBAL_STATS_OP_HIST_RX_TX | port);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+				   GLOBAL_STATS_OP_CAPTURE_PORT |
+				   GLOBAL_STATS_OP_HIST_RX_TX | port);
+	if (ret < 0)
+		return ret;
 
 	/* Wait for the snapshotting to complete. */
-	ret = mv88e6xxx_stats_wait(ds);
+	ret = _mv88e6xxx_stats_wait(ds);
 	if (ret < 0)
 		return ret;
 
 	return 0;
 }
 
-static void mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
+/* Must be called with SMI mutex held */
+static void _mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
 {
 	u32 _val;
 	int ret;
 
 	*val = 0;
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
-				  GLOBAL_STATS_OP_READ_CAPTURED |
-				  GLOBAL_STATS_OP_HIST_RX_TX | stat);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+				   GLOBAL_STATS_OP_READ_CAPTURED |
+				   GLOBAL_STATS_OP_HIST_RX_TX | stat);
 	if (ret < 0)
 		return;
 
-	ret = mv88e6xxx_stats_wait(ds);
+	ret = _mv88e6xxx_stats_wait(ds);
 	if (ret < 0)
 		return;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
 	if (ret < 0)
 		return;
 
 	_val = ret << 16;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
 	if (ret < 0)
 		return;
 
@@ -655,11 +660,11 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 	int ret;
 	int i;
 
-	mutex_lock(&ps->stats_mutex);
+	mutex_lock(&ps->smi_mutex);
 
-	ret = mv88e6xxx_stats_snapshot(ds, port);
+	ret = _mv88e6xxx_stats_snapshot(ds, port);
 	if (ret < 0) {
-		mutex_unlock(&ps->stats_mutex);
+		mutex_unlock(&ps->smi_mutex);
 		return;
 	}
 
@@ -676,8 +681,8 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 				goto error;
 			low = ret;
 			if (s->sizeof_stat == 4) {
-				ret = mv88e6xxx_reg_read(ds, REG_PORT(port),
-							 s->reg - 0x100 + 1);
+				ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
+							  s->reg - 0x100 + 1);
 				if (ret < 0)
 					goto error;
 				high = ret;
@@ -685,14 +690,14 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 			data[i] = (((u64)high) << 16) | low;
 			continue;
 		}
-		mv88e6xxx_stats_read(ds, s->reg, &low);
+		_mv88e6xxx_stats_read(ds, s->reg, &low);
 		if (s->sizeof_stat == 8)
-			mv88e6xxx_stats_read(ds, s->reg + 1, &high);
+			_mv88e6xxx_stats_read(ds, s->reg + 1, &high);
 
 		data[i] = (((u64)high) << 32) | low;
 	}
 error:
-	mutex_unlock(&ps->stats_mutex);
+	mutex_unlock(&ps->smi_mutex);
 }
 
 /* All the statistics in the table */
@@ -1573,7 +1578,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	mutex_init(&ps->smi_mutex);
-	mutex_init(&ps->stats_mutex);
 
 	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
 
-- 
2.1.4
