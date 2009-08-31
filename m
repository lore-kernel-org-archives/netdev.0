From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] drop_monitor: make last_rx timestamp private
Date: Mon, 31 Aug 2009 15:58:47 -0400
Message-ID: <20090831195847.GA6506@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56469 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbZHaT6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 15:58:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-


It was recently pointed out to me that the last_rx field of the net_device
structure wasn't updated regularly.  In fact only the bonding driver really uses
it currently.  Since the drop_monitor code relies on the last_rx field to detect
drops on recevie in hardware, We need to find a more reliable way to rate limit
our drop checks (so that we don't check for drops on every frame recevied, which
would be inefficient.  This patch makes a last_rx timestamp that is private to
the drop monitor code and is updated for every device that we track.

Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drop_monitor.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 9d66fa9..34a05ce 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -52,6 +52,7 @@ struct per_cpu_dm_data {
 
 struct dm_hw_stat_delta {
 	struct net_device *dev;
+	unsigned long last_rx;
 	struct list_head list;
 	struct rcu_head rcu;
 	unsigned long last_drop_val;
@@ -179,18 +180,21 @@ static void trace_napi_poll_hit(struct napi_struct *napi)
 {
 	struct dm_hw_stat_delta *new_stat;
 
-	/*
-	 * Ratelimit our check time to dm_hw_check_delta jiffies
-	 */
-	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
-		return;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+		/*
+		 * only add a note to our monitor buffer if:
+		 * 1) this is the dev we received on
+		 * 2) its after the last_rx delta
+		 * 3) our rx_dropped count has gone up
+		 */
 		if ((new_stat->dev == napi->dev)  &&
+		    (time_after(jiffies, new_stat->last_rx + dm_hw_check_delta)) &&
 		    (napi->dev->stats.rx_dropped != new_stat->last_drop_val)) {
 			trace_drop_common(NULL, NULL);
 			new_stat->last_drop_val = napi->dev->stats.rx_dropped;
+			new_stat->last_rx = jiffies;
 			break;
 		}
 	}
@@ -286,6 +290,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 			goto out;
 
 		new_stat->dev = dev;
+		new_stat->last_rx = jiffies;
 		INIT_RCU_HEAD(&new_stat->rcu);
 		spin_lock(&trace_state_lock);
 		list_add_rcu(&new_stat->list, &hw_stats_list);
