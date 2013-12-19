From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] tile_net: Always enable PTP clock support on TILE-Gx
Date: Thu, 19 Dec 2013 19:21:14 +0000
Message-ID: <1387480874.1876.33.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40096 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab3LSTVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:21:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All other net drivers with PTP support enable it unconditionally.
Make tile_net consistent with this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Totally untested as I don't have even a compiler for this.

Ben.

 drivers/net/ethernet/tile/Kconfig  | 12 +-----------
 drivers/net/ethernet/tile/tilegx.c | 24 ------------------------
 2 files changed, 1 insertion(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
index 4083ba8839e1..f59a6c265331 100644
--- a/drivers/net/ethernet/tile/Kconfig
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -9,20 +9,10 @@ config TILE_NET
 	select CRC32
 	select TILE_GXIO_MPIPE if TILEGX
 	select HIGH_RES_TIMERS if TILEGX
+	select PTP_1588_CLOCK if TILEGX
 	---help---
 	  This is a standard Linux network device driver for the
 	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called tile_net.
-
-config PTP_1588_CLOCK_TILEGX
-        tristate "Tilera TILE-Gx mPIPE as PTP clock"
-        select PTP_1588_CLOCK
-        depends on TILE_NET
-        depends on TILEGX
-        ---help---
-          This driver adds support for using the mPIPE as a PTP
-          clock. This clock is only useful if your PTP programs are
-          getting hardware time stamps on the PTP Ethernet packets
-          using the SO_TIMESTAMPING API.
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 858f9a786b8c..570495be77f3 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -187,10 +187,8 @@ struct tile_net_priv {
 	int echannel;
 	/* mPIPE instance, 0 or 1. */
 	int instance;
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	/* The timestamp config. */
 	struct hwtstamp_config stamp_cfg;
-#endif
 };
 
 static struct mpipe_data {
@@ -229,14 +227,12 @@ static struct mpipe_data {
 	int first_bucket;
 	int num_buckets;
 
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	/* PTP-specific data. */
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info caps;
 
 	/* Lock for ptp accessors. */
 	struct mutex ptp_lock;
-#endif
 
 } mpipe_data[NR_MPIPE_MAX] = {
 	[0 ... (NR_MPIPE_MAX - 1)] {
@@ -451,20 +447,17 @@ static void tile_net_provide_needed_buffers(void)
 static void tile_rx_timestamp(struct tile_net_priv *priv, struct sk_buff *skb,
 			      gxio_mpipe_idesc_t *idesc)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	if (unlikely(priv->stamp_cfg.rx_filter != HWTSTAMP_FILTER_NONE)) {
 		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 		shhwtstamps->hwtstamp = ktime_set(idesc->time_stamp_sec,
 						  idesc->time_stamp_ns);
 	}
-#endif
 }
 
 /* Get TX timestamp, and store it in the skb. */
 static void tile_tx_timestamp(struct sk_buff *skb, int instance)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct skb_shared_info *shtx = skb_shinfo(skb);
 	if (unlikely((shtx->tx_flags & SKBTX_HW_TSTAMP) != 0)) {
 		struct mpipe_data *md = &mpipe_data[instance];
@@ -477,13 +470,11 @@ static void tile_tx_timestamp(struct sk_buff *skb, int instance)
 		shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
 		skb_tstamp_tx(skb, &shhwtstamps);
 	}
-#endif
 }
 
 /* Use ioctl() to enable or disable TX or RX timestamping. */
 static int tile_hwtstamp_set(struct net_device *dev, struct ifreq *rq)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct hwtstamp_config config;
 	struct tile_net_priv *priv = netdev_priv(dev);
 
@@ -529,14 +520,10 @@ static int tile_hwtstamp_set(struct net_device *dev, struct ifreq *rq)
 
 	priv->stamp_cfg = config;
 	return 0;
-#else
-	return -EOPNOTSUPP;
-#endif
 }
 
 static int tile_hwtstamp_get(struct net_device *dev, struct ifreq *rq)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct tile_net_priv *priv = netdev_priv(dev);
 
 	if (copy_to_user(rq->ifr_data, &priv->stamp_cfg,
@@ -544,9 +531,6 @@ static int tile_hwtstamp_get(struct net_device *dev, struct ifreq *rq)
 		return -EFAULT;
 
 	return 0;
-#else
-	return -EOPNOTSUPP;
-#endif
 }
 
 static inline bool filter_packet(struct net_device *dev, void *buf)
@@ -828,8 +812,6 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	return HRTIMER_NORESTART;
 }
 
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
-
 /* PTP clock operations. */
 
 static int ptp_mpipe_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
@@ -896,12 +878,9 @@ static struct ptp_clock_info ptp_mpipe_caps = {
 	.enable		= ptp_mpipe_enable,
 };
 
-#endif /* CONFIG_PTP_1588_CLOCK_TILEGX */
-
 /* Sync mPIPE's timestamp up with Linux system time and register PTP clock. */
 static void register_ptp_clock(struct net_device *dev, struct mpipe_data *md)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct timespec ts;
 
 	getnstimeofday(&ts);
@@ -913,16 +892,13 @@ static void register_ptp_clock(struct net_device *dev, struct mpipe_data *md)
 	if (IS_ERR(md->ptp_clock))
 		netdev_err(dev, "ptp_clock_register failed %ld\n",
 			   PTR_ERR(md->ptp_clock));
-#endif
 }
 
 /* Initialize PTP fields in a new device. */
 static void init_ptp_dev(struct tile_net_priv *priv)
 {
-#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	priv->stamp_cfg.rx_filter = HWTSTAMP_FILTER_NONE;
 	priv->stamp_cfg.tx_type = HWTSTAMP_TX_OFF;
-#endif
 }
 
 /* Helper functions for "tile_net_update()". */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
