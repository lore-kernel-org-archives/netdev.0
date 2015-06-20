From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 3/6] dsa: mv88x6xxx: Refactor getting a single statistic
Date: Sat, 20 Jun 2015 18:42:30 +0200
Message-ID: <1434818553-10239-4-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59980 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755233AbbFTQtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:49:20 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code to retrieve a statistics counter into a function of its
own, so it can later be reused.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 63 ++++++++++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx.h |  4 +++
 2 files changed, 40 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6e684f3d377c..43c1515a8319 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -681,6 +681,40 @@ static void _mv88e6xxx_get_strings(struct dsa_switch *ds,
 	}
 }
 
+static uint64_t _mv88e6xxx_get_ethtool_stat(struct dsa_switch *ds,
+					    int stat,
+					    struct mv88e6xxx_hw_stat *stats,
+					    int port)
+{
+	struct mv88e6xxx_hw_stat *s = stats + stat;
+	u32 low;
+	u32 high = 0;
+	int ret;
+	u64 value;
+
+	if (s->reg >= 0x100) {
+		ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
+					  s->reg - 0x100);
+		if (ret < 0)
+			return UINT64_MAX;
+
+		low = ret;
+		if (s->sizeof_stat == 4) {
+			ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
+						  s->reg - 0x100 + 1);
+			if (ret < 0)
+				return UINT64_MAX;
+			high = ret;
+		}
+	} else {
+		_mv88e6xxx_stats_read(ds, s->reg, &low);
+		if (s->sizeof_stat == 8)
+			_mv88e6xxx_stats_read(ds, s->reg + 1, &high);
+	}
+	value = (((u64)high) << 16) | low;
+	return value;
+}
+
 static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 					 int nr_stats,
 					 struct mv88e6xxx_hw_stat *stats,
@@ -699,34 +733,9 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 	}
 
 	/* Read each of the counters. */
-	for (i = 0; i < nr_stats; i++) {
-		struct mv88e6xxx_hw_stat *s = stats + i;
-		u32 low;
-		u32 high = 0;
+	for (i = 0; i < nr_stats; i++)
+		data[i] = _mv88e6xxx_get_ethtool_stat(ds, i, stats, port);
 
-		if (s->reg >= 0x100) {
-			ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
-						  s->reg - 0x100);
-			if (ret < 0)
-				goto error;
-			low = ret;
-			if (s->sizeof_stat == 4) {
-				ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
-							  s->reg - 0x100 + 1);
-				if (ret < 0)
-					goto error;
-				high = ret;
-			}
-			data[i] = (((u64)high) << 16) | low;
-			continue;
-		}
-		_mv88e6xxx_stats_read(ds, s->reg, &low);
-		if (s->sizeof_stat == 8)
-			_mv88e6xxx_stats_read(ds, s->reg + 1, &high);
-
-		data[i] = (((u64)high) << 32) | low;
-	}
-error:
 	mutex_unlock(&ps->smi_mutex);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8b9c76b66ddb..7cccff202586 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,6 +11,10 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
+#ifndef UINT64_MAX
+#define UINT64_MAX		(u64)(~((u64)0))
+#endif
+
 #define SMI_CMD			0x00
 #define SMI_CMD_BUSY		BIT(15)
 #define SMI_CMD_CLAUSE_22	BIT(12)
-- 
2.1.4
