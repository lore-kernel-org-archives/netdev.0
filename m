From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in
 shutdown) on 3.3-rc1
Date: Wed, 29 Feb 2012 01:33:37 -0800
Message-ID: <1330508017.7993.3.camel@HP1>
References: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
 <qCQH7HfZS8E.A.x6F.98rRPB@chimera>
 <1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
 <20120228233225.GA1322@mcarlson.broadcom.com>
 <1330477116.2822.191.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	"Maciej Rutecki" <maciej.rutecki@gmail.com>,
	"Florian Mickler" <florian@mickler.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "James Bottomley" <James.Bottomley@HansenPartnership.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330477116.2822.191.camel@dabdike.int.hansenpartnership.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2012-02-28 at 18:58 -0600, James Bottomley wrote:
> Well, the patch needs some attention:
> 
>   CC [M]  drivers/net/ethernet/broadcom/tg3.o
> drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_get_estats':
> drivers/net/ethernet/broadcom/tg3.c:9882: warning: 'return' with a
> value, in function returning void
> 
> It also didn't apply incredibly well (the fuzz factors and line
> offsets
> are a lot higher than they should be):
> 
> patching file drivers/net/ethernet/broadcom/tg3.c
> Hunk #1 succeeded at 7886 (offset -115 lines).
> Hunk #2 succeeded at 7908 (offset -115 lines).
> Hunk #3 succeeded at 9845 (offset -278 lines).
> Hunk #4 succeeded at 9854 (offset -278 lines).
> Hunk #5 succeeded at 9873 (offset -278 lines).
> Hunk #6 succeeded at 9958 (offset -275 lines).
> Hunk #7 succeeded at 10007 with fuzz 1 (offset -275 lines).
> Hunk #8 succeeded at 10103 with fuzz 2 (offset -2096 lines).
> 
> but it seems to work.

I think Matt did the patch for the net-next tree.  Here's the same patch
for the net tree which is the correct tree for this patch.  Thanks.


Subject: [PATCH net] tg3: Fix tg3_get_stats64 for 5700 / 5701 devs

From: Matt Carlson <mcarlson@broadcom.com>

tg3_get_stats64() takes tp->lock when dealing with non-serdes bcm5700
and bcm5701 devices.  However, functions that call tg3_halt() have
already acquired tp->lock.  When tg3_get_stats64() is called in
tg3_halt(), deadlock will occur.

This patch fixes the problem by separating the stat gathering code into
a new tg3_get_nstats() function.  tg3_get_stats64() is recoded to call
this function and take tp->lock.  The code that takes tp->lock in
tg3_calc_crc_errors() has been removed.  Function signatures have been
cleaned up too.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   45 ++++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a1f2e0f..423d023 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7886,10 +7886,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *,
-						 struct rtnl_link_stats64 *);
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *,
-						struct tg3_ethtool_stats *);
+static void tg3_get_nstats(struct tg3 *, struct rtnl_link_stats64 *);
+static void tg3_get_estats(struct tg3 *, struct tg3_ethtool_stats *);
 
 /* tp->lock is held. */
 static int tg3_halt(struct tg3 *tp, int kind, int silent)
@@ -7910,7 +7908,7 @@ static int tg3_halt(struct tg3 *tp, int kind, int silent)
 
 	if (tp->hw_stats) {
 		/* Save the stats across chip resets... */
-		tg3_get_stats64(tp->dev, &tp->net_stats_prev),
+		tg3_get_nstats(tp, &tp->net_stats_prev),
 		tg3_get_estats(tp, &tp->estats_prev);
 
 		/* And make sure the next sample is new data */
@@ -9847,7 +9845,7 @@ static inline u64 get_stat64(tg3_stat64_t *val)
        return ((u64)val->high << 32) | ((u64)val->low);
 }
 
-static u64 calc_crc_errors(struct tg3 *tp)
+static u64 tg3_calc_crc_errors(struct tg3 *tp)
 {
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
@@ -9856,14 +9854,12 @@ static u64 calc_crc_errors(struct tg3 *tp)
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
 		u32 val;
 
-		spin_lock_bh(&tp->lock);
 		if (!tg3_readphy(tp, MII_TG3_TEST1, &val)) {
 			tg3_writephy(tp, MII_TG3_TEST1,
 				     val | MII_TG3_TEST1_CRC_EN);
 			tg3_readphy(tp, MII_TG3_RXR_COUNTERS, &val);
 		} else
 			val = 0;
-		spin_unlock_bh(&tp->lock);
 
 		tp->phy_crc_errors += val;
 
@@ -9877,14 +9873,13 @@ static u64 calc_crc_errors(struct tg3 *tp)
 	estats->member =	old_estats->member + \
 				get_stat64(&hw_stats->member)
 
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
-					       struct tg3_ethtool_stats *estats)
+static void tg3_get_estats(struct tg3 *tp, struct tg3_ethtool_stats *estats)
 {
 	struct tg3_ethtool_stats *old_estats = &tp->estats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
 	if (!hw_stats)
-		return old_estats;
+		return;
 
 	ESTAT_ADD(rx_octets);
 	ESTAT_ADD(rx_fragments);
@@ -9963,20 +9958,13 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
 	ESTAT_ADD(nic_tx_threshold_hit);
 
 	ESTAT_ADD(mbuf_lwm_thresh_hit);
-
-	return estats;
 }
 
-static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-						 struct rtnl_link_stats64 *stats)
+static void tg3_get_nstats(struct tg3 *tp, struct rtnl_link_stats64 *stats)
 {
-	struct tg3 *tp = netdev_priv(dev);
 	struct rtnl_link_stats64 *old_stats = &tp->net_stats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
-	if (!hw_stats)
-		return old_stats;
-
 	stats->rx_packets = old_stats->rx_packets +
 		get_stat64(&hw_stats->rx_ucast_packets) +
 		get_stat64(&hw_stats->rx_mcast_packets) +
@@ -10019,15 +10007,13 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 		get_stat64(&hw_stats->tx_carrier_sense_errors);
 
 	stats->rx_crc_errors = old_stats->rx_crc_errors +
-		calc_crc_errors(tp);
+		tg3_calc_crc_errors(tp);
 
 	stats->rx_missed_errors = old_stats->rx_missed_errors +
 		get_stat64(&hw_stats->rx_discards);
 
 	stats->rx_dropped = tp->rx_dropped;
 	stats->tx_dropped = tp->tx_dropped;
-
-	return stats;
 }
 
 static inline u32 calc_crc(unsigned char *buf, int len)
@@ -15409,6 +15395,21 @@ static void __devinit tg3_init_coal(struct tg3 *tp)
 	}
 }
 
+static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!tp->hw_stats)
+		return &tp->net_stats_prev;
+
+	spin_lock_bh(&tp->lock);
+	tg3_get_nstats(tp, stats);
+	spin_unlock_bh(&tp->lock);
+
+	return stats;
+}
+
 static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_open		= tg3_open,
 	.ndo_stop		= tg3_close,
-- 
1.7.1
