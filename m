From: "Matt Carlson" <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in
 shutdown) on 3.3-rc1
Date: Tue, 28 Feb 2012 15:32:25 -0800
Message-ID: <20120228233225.GA1322@mcarlson.broadcom.com>
References: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
 <qCQH7HfZS8E.A.x6F.98rRPB@chimera>
 <1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	"Linux Kernel Mailing List" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kernel Testers List" <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Maciej Rutecki" <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Florian Mickler" <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	"Matt Carlson" <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Ben Hutchings" <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "James Bottomley" <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1330386274.2822.105.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 05:44:34PM -0600, James Bottomley wrote:
> On Thu, 2012-02-23 at 23:55 +0100, Rafael J. Wysocki wrote:
> > This message has been generated automatically as a part of a summary report
> > of recent regressions.
> > 
> > The following bug entry is on the current list of known regressions
> > from 3.2.  Please verify if it still should be listed and let the tracking team
> > know (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=42707
> > Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc1
> > Submitter	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> > Date		: 2012-01-28 19:56 (27 days old)
> > Message-ID	: <1327780565.2924.24.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=132778076214873&w=2
> 
> Still present in 3.3-rc4; I've bisected it back to this commit:
> 
> commit 92feeabf3f673767c6ee4cfc7fc224098446c1c1
> Author: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Date:   Thu Dec 8 14:40:14 2011 +0000
> 
>     tg3: Save stats across chip resets
> 
> and sure enough, just reverting this single commit on 3.3-rc4 fixes the
> problem.
> 
> James

Are you dealing with a bcm5700 or bcm5701 device?  If so, can you try
the following patch?

Subject: [PATCH 1/1] tg3: Fix tg3_get_stats64 for 5700 / 5701 devs

tg3_get_stats64() takes tp->lock when dealing with non-serdes bcm5700
and bcm5701 devices.  However, functions that call tg3_halt() have
already acquired tp->lock.  When tg3_get_stats64() is called in
tg3_halt(), deadlock will occur.

This patch fixes the problem by separating the stat gathering code into
a new tg3_get_nstats() function.  tg3_get_stats64() is recoded to call
this function and take tp->lock.  The code that takes tp->lock in
tg3_calc_crc_errors() has been removed.  Function signatures have been
cleaned up too.

Signed-off-by: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/tg3.c |   43 ++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 97dcccd..76f33d5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8001,10 +8001,8 @@ static int tg3_chip_reset(struct tg3 *tp)
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
@@ -8025,7 +8023,7 @@ static int tg3_halt(struct tg3 *tp, int kind, int silent)
 
 	if (tp->hw_stats) {
 		/* Save the stats across chip resets... */
-		tg3_get_stats64(tp->dev, &tp->net_stats_prev),
+		tg3_get_nstats(tp, &tp->net_stats_prev);
 		tg3_get_estats(tp, &tp->estats_prev);
 
 		/* And make sure the next sample is new data */
@@ -10125,7 +10123,7 @@ static inline u64 get_stat64(tg3_stat64_t *val)
        return ((u64)val->high << 32) | ((u64)val->low);
 }
 
-static u64 calc_crc_errors(struct tg3 *tp)
+static u64 tg3_calc_crc_errors(struct tg3 *tp)
 {
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
@@ -10134,14 +10132,12 @@ static u64 calc_crc_errors(struct tg3 *tp)
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
 
@@ -10155,8 +10151,7 @@ static u64 calc_crc_errors(struct tg3 *tp)
 	estats->member =	old_estats->member + \
 				get_stat64(&hw_stats->member)
 
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
-					       struct tg3_ethtool_stats *estats)
+static void tg3_get_estats(struct tg3 *tp, struct tg3_ethtool_stats *estats)
 {
 	struct tg3_ethtool_stats *old_estats = &tp->estats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
@@ -10238,20 +10233,13 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
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
@@ -10294,15 +10282,13 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
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
 
 static int tg3_get_regs_len(struct net_device *dev)
@@ -12213,6 +12199,21 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
 };
 
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
 static void tg3_set_rx_mode(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-- 
1.7.3.4
