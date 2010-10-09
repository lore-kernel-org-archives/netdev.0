From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 09 Oct 2010 23:41:32 +0400
Message-ID: <4CB0C56C.2000106@kernel.org>
References: <20101009095346.GA12951@hera.kernel.org> <20101009132749.GA15074@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:48937 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760464Ab0JITl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 15:41:29 -0400
In-Reply-To: <20101009132749.GA15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2010 05:27 PM, Ben Hutchings wrote:
> Denis Kirjanov wrote:
>> Add initial ethtool statistics support 
> [...]
>> +static void get_ethtool_stats(struct net_device *dev,
>> +		struct ethtool_stats *stats, u64 *data)
>> +{
>> +	struct net_device_stats *netdev_stats = get_stats(dev);
>> +	int i = 0;
>> +
>> +	data[i++] = netdev_stats->tx_packets;
>> +	data[i++] = netdev_stats->tx_bytes;
>> +	data[i++] = netdev_stats->rx_packets;
>> +	data[i++] = netdev_stats->rx_bytes;
>> +	data[i++] = netdev_stats->tx_errors;
>> +	data[i++] = netdev_stats->tx_dropped;
>> +	data[i++] = netdev_stats->rx_errors;
>> +}
> [...]
> 
> There is no point in adding ethtool stats that merely mirror the baseline
> net device stats.
> 
> Ben.
> 

[PATCH -next v2] sundance: Add ethtool stats support

Add ethtool stats support

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
V2: 
 check for the ETH_SS_STATS in get_string()
 use xstats struct for ethtool stats

drivers/net/sundance.c |   90 ++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4283cc5..4e3ff71 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -363,6 +363,19 @@ struct netdev_private {
         dma_addr_t tx_ring_dma;
         dma_addr_t rx_ring_dma;
 	struct timer_list timer;		/* Media monitoring timer. */
+	/* ethtool extra stats */
+	struct {
+		unsigned long tx_multiple_collisions;
+		unsigned long tx_single_collisions;
+		unsigned long tx_late_collisions;
+		unsigned long tx_deffered;
+		unsigned long tx_deffered_excessive;
+		unsigned long tx_aborted;
+		unsigned long tx_bcasts;
+		unsigned long rx_bcasts;
+		unsigned long tx_mcasts;
+		unsigned long rx_mcasts;
+	} xstats;
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
 	int msg_enable;
@@ -1486,7 +1499,6 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
-	int i;
 	unsigned long flags;
 
 	spin_lock_irqsave(&np->statlock, flags);
@@ -1494,13 +1506,23 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 	dev->stats.rx_missed_errors	+= ioread8(ioaddr + RxMissed);
 	dev->stats.tx_packets += ioread16(ioaddr + TxFramesOK);
 	dev->stats.rx_packets += ioread16(ioaddr + RxFramesOK);
-	dev->stats.collisions += ioread8(ioaddr + StatsLateColl);
-	dev->stats.collisions += ioread8(ioaddr + StatsMultiColl);
-	dev->stats.collisions += ioread8(ioaddr + StatsOneColl);
 	dev->stats.tx_carrier_errors += ioread8(ioaddr + StatsCarrierError);
-	ioread8(ioaddr + StatsTxDefer);
-	for (i = StatsTxDefer; i <= StatsMcastRx; i++)
-		ioread8(ioaddr + i);
+
+	np->xstats.tx_multiple_collisions += ioread8(ioaddr + StatsMultiColl);
+	np->xstats.tx_single_collisions += ioread8(ioaddr + StatsOneColl);
+	np->xstats.tx_late_collisions += ioread8(ioaddr + StatsLateColl);
+	dev->stats.collisions += np->xstats.tx_multiple_collisions
+		+ np->xstats.tx_single_collisions
+		+ np->xstats.tx_late_collisions;
+
+	np->xstats.tx_deffered += ioread8(ioaddr + StatsTxDefer);
+	np->xstats.tx_deffered_excessive += ioread8(ioaddr + StatsTxXSDefer);
+	np->xstats.tx_aborted += ioread8(ioaddr + StatsTxAbort);
+	np->xstats.tx_bcasts += ioread8(ioaddr + StatsBcastTx);
+	np->xstats.rx_bcasts += ioread8(ioaddr + StatsBcastRx);
+	np->xstats.tx_mcasts += ioread8(ioaddr + StatsMcastTx);
+	np->xstats.rx_mcasts += ioread8(ioaddr + StatsMcastRx);
+
 	dev->stats.tx_bytes += ioread16(ioaddr + TxOctetsLow);
 	dev->stats.tx_bytes += ioread16(ioaddr + TxOctetsHigh) << 16;
 	dev->stats.rx_bytes += ioread16(ioaddr + RxOctetsLow);
@@ -1566,6 +1588,21 @@ static int __set_mac_addr(struct net_device *dev)
 	return 0;
 }
 
+static const struct {
+	const char name[ETH_GSTRING_LEN];
+} sundance_stats[] = {
+	{ "tx_multiple_collisions" },
+	{ "tx_single_collisions" },
+	{ "tx_late_collisions" },
+	{ "tx_deffered" },
+	{ "tx_deffered_excessive" },
+	{ "tx_aborted" },
+	{ "tx_bcasts" },
+	{ "rx_bcasts" },
+	{ "tx_mcasts" },
+	{ "rx_mcasts" },
+};
+
 static int check_if_running(struct net_device *dev)
 {
 	if (!netif_running(dev))
@@ -1624,6 +1661,42 @@ static void set_msglevel(struct net_device *dev, u32 val)
 	np->msg_enable = val;
 }
 
+static void get_strings(struct net_device *dev, u32 stringset,
+		u8 *data)
+{
+	if (stringset == ETH_SS_STATS)
+		memcpy(data, sundance_stats, sizeof(sundance_stats));
+}
+
+static int get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(sundance_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void get_ethtool_stats(struct net_device *dev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int i = 0;
+
+	get_stats(dev);
+	data[i++] = np->xstats.tx_multiple_collisions;
+	data[i++] = np->xstats.tx_single_collisions;
+	data[i++] = np->xstats.tx_late_collisions;
+	data[i++] = np->xstats.tx_deffered;
+	data[i++] = np->xstats.tx_deffered_excessive;
+	data[i++] = np->xstats.tx_aborted;
+	data[i++] = np->xstats.tx_bcasts;
+	data[i++] = np->xstats.rx_bcasts;
+	data[i++] = np->xstats.tx_mcasts;
+	data[i++] = np->xstats.rx_mcasts;
+}
+
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = get_drvinfo,
@@ -1633,6 +1706,9 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_link = get_link,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
+	.get_strings = get_strings,
+	.get_sset_count = get_sset_count,
+	.get_ethtool_stats = get_ethtool_stats,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.0

