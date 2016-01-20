From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mvneta: fix trivial cut-off issue in mvneta_ethtool_update_stats
Date: Wed, 20 Jan 2016 16:36:25 +0800
Message-ID: <1453278985-6433-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <rmk+kernel@arm.linux.org.uk>,
	Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When s->type is T_REG_64, the high 32bits are lost in val. This patch
fixes this trivial issue.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Fixes: 9b0cdefa4cd5 ("net: mvneta: add ethtool statistics")
---
 drivers/net/ethernet/marvell/mvneta.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 6bb709a..ea3b034 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3244,26 +3244,25 @@ static void mvneta_ethtool_update_stats(struct mvneta_port *pp)
 	const struct mvneta_statistic *s;
 	void __iomem *base = pp->base;
 	u32 high, low, val;
+	u64 val64;
 	int i;
 
 	for (i = 0, s = mvneta_statistics;
 	     s < mvneta_statistics + ARRAY_SIZE(mvneta_statistics);
 	     s++, i++) {
-		val = 0;
-
 		switch (s->type) {
 		case T_REG_32:
 			val = readl_relaxed(base + s->offset);
+			pp->ethtool_stats[i] += val;
 			break;
 		case T_REG_64:
 			/* Docs say to read low 32-bit then high */
 			low = readl_relaxed(base + s->offset);
 			high = readl_relaxed(base + s->offset + 4);
-			val = (u64)high << 32 | low;
+			val64 = (u64)high << 32 | low;
+			pp->ethtool_stats[i] += val64;
 			break;
 		}
-
-		pp->ethtool_stats[i] += val;
 	}
 }
 
-- 
2.7.0.rc3
