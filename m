From: Zoran Markovic <zoran.markovic@linaro.org>
Subject: [RFC PATCH] net: core: move core networking work to power efficient workqueue
Date: Thu, 30 Jan 2014 16:33:22 -0800
Message-ID: <1391128402-10725-1-git-send-email-zoran.markovic@linaro.org>
Cc: netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Eric Dumazet <edumazet@google.com>,
	Julian Anastasov <ja@ssi.bg>, Flavio Leitner <fbl@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amerigo Wang <amwang@redhat.com>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Simon Horman <horms@verge.net.au>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Zoran Markovic <zoran.markovic@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaibal Dutta <shaibal.dutta@broadcom.com>

This patch moves the following work to the power efficient workqueue:
  - Transmit work of netpoll
  - Destination cache garbage collector work
  - Link watch event handler work

In general, assignment of CPUs to pending work could be deferred to
the scheduler in order to extend idle residency time and improve
power efficiency. I would value community's opinion on the migration
of this work to the power efficient workqueue, with an emphasis on
migration of netpoll's transmit work.

This functionality is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Flavio Leitner <fbl@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Amerigo Wang <amwang@redhat.com>
Cc: Joe Perches <joe@perches.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Antonio Quartulli <antonio@meshcoding.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Shaibal Dutta <shaibal.dutta@broadcom.com>
[zoran.markovic@linaro.org: Rebased to latest kernel version. Edited
calls to mod_delayed_work to reference power efficient workqueue.
Added commit message.]
Signed-off-by: Zoran Markovic <zoran.markovic@linaro.org>
---
 net/core/dst.c        |    5 +++--
 net/core/link_watch.c |    5 +++--
 net/core/netpoll.c    |    6 ++++--
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index ca4231e..cc28352 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -135,7 +135,8 @@ loop:
 		 */
 		if (expires > 4*HZ)
 			expires = round_jiffies_relative(expires);
-		schedule_delayed_work(&dst_gc_work, expires);
+		queue_delayed_work(system_power_efficient_wq,
+			&dst_gc_work, expires);
 	}
 
 	spin_unlock_bh(&dst_garbage.lock);
@@ -223,7 +224,7 @@ void __dst_free(struct dst_entry *dst)
 	if (dst_garbage.timer_inc > DST_GC_INC) {
 		dst_garbage.timer_inc = DST_GC_INC;
 		dst_garbage.timer_expires = DST_GC_MIN;
-		mod_delayed_work(system_wq, &dst_gc_work,
+		mod_delayed_work(system_power_efficient_wq, &dst_gc_work,
 				 dst_garbage.timer_expires);
 	}
 	spin_unlock_bh(&dst_garbage.lock);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 9c3a839..0ae3994 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -135,9 +135,10 @@ static void linkwatch_schedule_work(int urgent)
 	 * override the existing timer.
 	 */
 	if (test_bit(LW_URGENT, &linkwatch_flags))
-		mod_delayed_work(system_wq, &linkwatch_work, 0);
+		mod_delayed_work(system_power_efficient_wq, &linkwatch_work, 0);
 	else
-		schedule_delayed_work(&linkwatch_work, delay);
+		queue_delayed_work(system_power_efficient_wq,
+			&linkwatch_work, delay);
 }
 
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c03f3de..2c8f839 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -101,7 +101,8 @@ static void queue_process(struct work_struct *work)
 			__netif_tx_unlock(txq);
 			local_irq_restore(flags);
 
-			schedule_delayed_work(&npinfo->tx_work, HZ/10);
+			queue_delayed_work(system_power_efficient_wq,
+				&npinfo->tx_work, HZ/10);
 			return;
 		}
 		__netif_tx_unlock(txq);
@@ -423,7 +424,8 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 
 	if (status != NETDEV_TX_OK) {
 		skb_queue_tail(&npinfo->txq, skb);
-		schedule_delayed_work(&npinfo->tx_work,0);
+		queue_delayed_work(system_power_efficient_wq,
+			&npinfo->tx_work, 0);
 	}
 }
 EXPORT_SYMBOL(netpoll_send_skb_on_dev);
-- 
1.7.9.5
