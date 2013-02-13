From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/2] gianfar: remove largely unused gfar_stats struct
Date: Tue, 12 Feb 2013 19:24:23 -0500
Message-ID: <1360715064-2689-2-git-send-email-paul.gortmaker@windriver.com>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38060 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759221Ab3BMAYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:24:44 -0500
In-Reply-To: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gfar_stats struct is only used in copying out data
via ethtool.  It is declared as the extra stats, followed
by the rmon stats.  However, the rmon stats are never
actually ever used in the driver; instead the rmon data
is a u32 register read that is cast directly into the
ethtool buf.

It seems the only reason rmon is in the struct at all is
to give the offset(s) at which it should be exported into
the ethtool buffer.  But note gfar_stats doesn't contain
a gfar_extra_stats as a substruct -- instead it contains
a u64 array of equal element count.  This implicitly means
we have two independent declarations of what gfar_extra_stats
really is.  Rather than have this duality, we already have
defines which give us the offset directly, and hence do not
need the struct at all.

Further, since we know the extra_stats is unconditionally
always present, we can write it out to the ethtool buf
1st, and then optionally write out the rmon data.  There
is no need for two independent loops, both of which are
simply copying out the extra_stats to buf offset zero.

This also helps pave the way towards allowing the extra
stats fields to be converted to atomic64_t values, without
having their types directly influencing the ethtool stats
export code (gfar_fill_stats) that expects to deal with u64.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar.h         |  8 +-------
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 15 ++++++---------
 2 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 71793f4..61b1785 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -646,15 +646,9 @@ struct gfar_extra_stats {
 #define GFAR_RMON_LEN ((sizeof(struct rmon_mib) - 16)/sizeof(u32))
 #define GFAR_EXTRA_STATS_LEN (sizeof(struct gfar_extra_stats)/sizeof(u64))
 
-/* Number of stats in the stats structure (ignore car and cam regs)*/
+/* Number of stats exported via ethtool */
 #define GFAR_STATS_LEN (GFAR_RMON_LEN + GFAR_EXTRA_STATS_LEN)
 
-struct gfar_stats {
-	u64 extra[GFAR_EXTRA_STATS_LEN];
-	u64 rmon[GFAR_RMON_LEN];
-};
-
-
 struct gfar {
 	u32	tsec_id;	/* 0x.000 - Controller ID register */
 	u32	tsec_id2;	/* 0x.004 - Controller ID2 register */
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 45e59d5..172acb9 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -151,18 +151,15 @@ static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u64 *extra = (u64 *) & priv->extra_stats;
 
+	for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++)
+		buf[i] = extra[i];
+
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
 		u32 __iomem *rmon = (u32 __iomem *) &regs->rmon;
-		struct gfar_stats *stats = (struct gfar_stats *) buf;
-
-		for (i = 0; i < GFAR_RMON_LEN; i++)
-			stats->rmon[i] = (u64) gfar_read(&rmon[i]);
 
-		for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++)
-			stats->extra[i] = extra[i];
-	} else
-		for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++)
-			buf[i] = extra[i];
+		for (; i < GFAR_STATS_LEN; i++, rmon++)
+			buf[i] = (u64) gfar_read(rmon);
+	}
 }
 
 static int gfar_sset_count(struct net_device *dev, int sset)
-- 
1.8.1.2
