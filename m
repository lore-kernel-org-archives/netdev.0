From: Sathya Perla <sathya.perla@gmail.com>
Subject: [PATCH] be2net: cleanup rx/tx rate calculations
Date: Mon, 23 Mar 2009 17:21:09 +0530
Message-ID: <bdc3ac9f0903230451o60d3392akb390c9f5dc9aab20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:34779 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZCWLvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:51:11 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1459232wah.21
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 04:51:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Pls accept this patch to cleanup rx/tx rate calculations as follows:
- check for jiffies wraparound
- remove typecast of a denominator
- do rate calculation only in workqueue context periodically

thanks,
-Sathya


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |   12 +++---
 drivers/net/benet/be_main.c |   96 +++++++++++++++++++++++++++++-------------
 2 files changed, 72 insertions(+), 36 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f327be5..c49ddd0 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -100,9 +100,9 @@ struct be_drvr_stats {
 	u32 be_tx_wrbs;		/* number of tx WRBs used */
 	u32 be_tx_events;	/* number of tx completion events  */
 	u32 be_tx_compl;	/* number of tx completion entries processed */
-	u64 be_tx_jiffies;
-	ulong be_tx_bytes;
-	ulong be_tx_bytes_prev;
+	ulong be_tx_jiffies;
+	u64 be_tx_bytes;
+	u64 be_tx_bytes_prev;
 	u32 be_tx_rate;

 	u32 cache_barrier[16];
@@ -113,9 +113,9 @@ struct be_drvr_stats {
 	u32 be_rx_compl;	/* number of rx completion entries processed */
 	u32 be_lro_hgram_data[8];	/* histogram of LRO data packets */
 	u32 be_lro_hgram_ack[8];	/* histogram of LRO ACKs */
-	u64 be_rx_jiffies;
-	ulong be_rx_bytes;
-	ulong be_rx_bytes_prev;
+	ulong be_rx_jiffies;
+	u64 be_rx_bytes;
+	u64 be_rx_bytes_prev;
 	u32 be_rx_rate;
 	/* number of non ether type II frames dropped where
 	 * frame len > length field of Mac Hdr */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0ecaffb..f901fee 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -245,19 +245,29 @@ static void be_link_status_update(struct
be_adapter *adapter)
 /* Update the EQ delay n BE based on the RX frags consumed / sec */
 static void be_rx_eqd_update(struct be_adapter *adapter)
 {
-	u32 eqd;
 	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_drvr_stats *stats = &adapter->stats.drvr_stats;
+	ulong now = jiffies;
+	u32 eqd;
+
+	if (!rx_eq->enable_aic)
+		return;
+
+	/* Wrapped around */
+	if (time_before(now, stats->rx_fps_jiffies)) {
+		stats->rx_fps_jiffies = now;
+		return;
+	}

 	/* Update once a second */
-	if (((jiffies - stats->rx_fps_jiffies) < HZ) || rx_eq->enable_aic == 0)
+	if ((now - stats->rx_fps_jiffies) < HZ)
 		return;

 	stats->be_rx_fps = (stats->be_rx_frags - stats->be_prev_rx_frags) /
-			((jiffies - stats->rx_fps_jiffies) / HZ);
+			((now - stats->rx_fps_jiffies) / HZ);

-	stats->rx_fps_jiffies = jiffies;
+	stats->rx_fps_jiffies = now;
 	stats->be_prev_rx_frags = stats->be_rx_frags;
 	eqd = stats->be_rx_fps / 110000;
 	eqd = eqd << 3;
@@ -280,26 +290,38 @@ static struct net_device_stats
*be_get_stats(struct net_device *dev)
 	return &adapter->stats.net_stats;
 }

+static void be_tx_rate_update(struct be_adapter *adapter)
+{
+	struct be_drvr_stats *stats = drvr_stats(adapter);
+	ulong now = jiffies;
+
+	/* Wrapped around? */
+	if (time_before(now, stats->be_tx_jiffies)) {
+		stats->be_tx_jiffies = now;
+		return;
+	}
+
+	/* Update tx rate once in two seconds */
+	if ((now - stats->be_tx_jiffies) > 2 * HZ) {
+		u32 r;
+		r = (stats->be_tx_bytes - stats->be_tx_bytes_prev) /
+			((now - stats->be_tx_jiffies) / HZ);
+		r = r / 1000000;			/* M bytes/s */
+		stats->be_tx_rate = r * 8;	/* M bits/s */
+		stats->be_tx_jiffies = now;
+		stats->be_tx_bytes_prev = stats->be_tx_bytes;
+	}
+}
+
 static void be_tx_stats_update(struct be_adapter *adapter,
 			u32 wrb_cnt, u32 copied, bool stopped)
 {
-	struct be_drvr_stats *stats = &adapter->stats.drvr_stats;
+	struct be_drvr_stats *stats = drvr_stats(adapter);
 	stats->be_tx_reqs++;
 	stats->be_tx_wrbs += wrb_cnt;
 	stats->be_tx_bytes += copied;
 	if (stopped)
 		stats->be_tx_stops++;
-
-	/* Update tx rate once in two seconds */
-	if ((jiffies - stats->be_tx_jiffies) > 2 * HZ) {
-		u32 r;
-		r = (stats->be_tx_bytes - stats->be_tx_bytes_prev) /
-			((u32) (jiffies - stats->be_tx_jiffies) / HZ);
-		r = (r / 1000000);			/* M bytes/s */
-		stats->be_tx_rate = (r * 8);	/* M bits/s */
-		stats->be_tx_jiffies = jiffies;
-		stats->be_tx_bytes_prev = stats->be_tx_bytes;
-	}
 }

 /* Determine number of WRB entries needed to xmit data in an skb */
@@ -573,28 +595,40 @@ static void be_set_multicast_list(struct
net_device *netdev)
 	}
 }

-static void be_rx_rate_update(struct be_adapter *adapter, u32 pktsize,
-			u16 numfrags)
+static void be_rx_rate_update(struct be_adapter *adapter)
 {
-	struct be_drvr_stats *stats = &adapter->stats.drvr_stats;
+	struct be_drvr_stats *stats = drvr_stats(adapter);
+	ulong now = jiffies;
 	u32 rate;

-	stats->be_rx_compl++;
-	stats->be_rx_frags += numfrags;
-	stats->be_rx_bytes += pktsize;
+	/* Wrapped around */
+	if (time_before(now, stats->be_rx_jiffies)) {
+		stats->be_rx_jiffies = now;
+		return;
+	}

 	/* Update the rate once in two seconds */
-	if ((jiffies - stats->be_rx_jiffies) < 2 * HZ)
+	if ((now - stats->be_rx_jiffies) < 2 * HZ)
 		return;

 	rate = (stats->be_rx_bytes - stats->be_rx_bytes_prev) /
-		((u32) (jiffies - stats->be_rx_jiffies) / HZ);
-	rate = (rate / 1000000);	/* MB/Sec */
-	stats->be_rx_rate = (rate * 8); 	/* Mega Bits/Sec */
-	stats->be_rx_jiffies = jiffies;
+		((now - stats->be_rx_jiffies) / HZ);
+	rate = rate / 1000000;	/* MB/Sec */
+	stats->be_rx_rate = rate * 8; 	/* Mega Bits/Sec */
+	stats->be_rx_jiffies = now;
 	stats->be_rx_bytes_prev = stats->be_rx_bytes;
 }

+static void be_rx_stats_update(struct be_adapter *adapter,
+		u32 pktsize, u16 numfrags)
+{
+	struct be_drvr_stats *stats = drvr_stats(adapter);
+
+	stats->be_rx_compl++;
+	stats->be_rx_frags += numfrags;
+	stats->be_rx_bytes += pktsize;
+}
+
 static struct be_rx_page_info *
 get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
 {
@@ -700,7 +734,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 		memset(page_info, 0, sizeof(*page_info));
 	}

-	be_rx_rate_update(adapter, pktsize, num_rcvd);
+	be_rx_stats_update(adapter, pktsize, num_rcvd);
 	return;
 }

@@ -799,7 +833,7 @@ static void be_rx_compl_process_lro(struct
be_adapter *adapter,
 			vid, NULL, 0);
 	}

-	be_rx_rate_update(adapter, pkt_size, num_rcvd);
+	be_rx_stats_update(adapter, pkt_size, num_rcvd);
 	return;
 }

@@ -841,7 +875,6 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 	u64 page_dmaaddr = 0, frag_dmaaddr;
 	u32 posted, page_offset = 0;

-
 	page_info = &page_info_tbl[rxq->head];
 	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
 		if (!pagep) {
@@ -1305,6 +1338,9 @@ static void be_worker(struct work_struct *work)
 	/* Set EQ delay */
 	be_rx_eqd_update(adapter);

+	be_tx_rate_update(adapter);
+	be_rx_rate_update(adapter);
+
 	if (adapter->rx_post_starved) {
 		adapter->rx_post_starved = false;
 		be_post_rx_frags(adapter);
-- 
1.5.6.3
