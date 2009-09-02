From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: make last_rx timestamp private
Date: Wed, 2 Sep 2009 09:36:20 -0400
Message-ID: <20090902133620.GC402@hmsreliant.think-freely.org>
References: <20090831195847.GA6506@hmsreliant.think-freely.org> <20090901.182127.96935772.davem@davemloft.net> <20090902105535.GB402@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38765 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbZIBNg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 09:36:26 -0400
Content-Disposition: inline
In-Reply-To: <20090902105535.GB402@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, heres a repost, unchanged saved for being massaged to fit in with the recent
changes that my origional patch raced against.  Thanks!
Neil


It was recently pointed out to me that the last_rx field of the net_device
structure wasn't updated regularly.  In fact only the bonding driver really uses
it currently.  Since the drop_monitor code relies on the last_rx field to detect
drops on recevie in hardware, We need to find a more reliable way to rate limit
our drop checks (so that we don't check for drops on every frame recevied, which
would be inefficient.  This patch makes a last_rx timestamp that is private to
the drop monitor code and is updated for every device that we track.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drop_monitor.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index d311202..0a113f2 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -52,6 +52,7 @@ struct per_cpu_dm_data {
 
 struct dm_hw_stat_delta {
 	struct net_device *dev;
+	unsigned long last_rx;
 	struct list_head list;
 	struct rcu_head rcu;
 	unsigned long last_drop_val;
@@ -180,18 +181,25 @@ static void trace_napi_poll_hit(struct napi_struct *napi)
 	struct dm_hw_stat_delta *new_stat;
 
 	/*
-	 * Ratelimit our check time to dm_hw_check_delta jiffies
+	 * Don't check napi structures with no associated device
 	 */
-	if (!napi->dev ||
-	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
+	if (!napi->dev)
 		return;
 
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
@@ -287,6 +295,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 			goto out;
 
 		new_stat->dev = dev;
+		new_stat->last_rx = jiffies;
 		INIT_RCU_HEAD(&new_stat->rcu);
 		spin_lock(&trace_state_lock);
 		list_add_rcu(&new_stat->list, &hw_stats_list);
