From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v2 6/8] forcedeth: Fix a race during rmmod of forcedeth
Date: Thu,  3 Nov 2011 18:41:21 -0700
Message-ID: <267015997eb594f2fd859acd572aa20dfc3e3e63.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Salman Qazi <sqazi@google.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salman Qazi <sqazi@google.com>

The race was between del_timer_sync and nv_do_stats_poll called through
nv_get_ethtool_stats.  To prevent this, we have to introduce mutual
exclusion between nv_get_ethtool_stats and del_timer_sync.  Notice
that we don't put the mutual exclusion in nv_do_stats_poll.  That's
because doing so would result in a deadlock, since it is a timer
callback and hence already waited for by timer deletion.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0af12a8..7996782 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3937,6 +3937,10 @@ static void nv_poll_controller(struct net_device *dev)
 }
 #endif
 
+/* No locking is needed as long as this is in the timer
+ * callback.  However, any other callers must call this
+ * function with np->lock held.
+ */
 static void nv_do_stats_poll(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -4589,12 +4593,17 @@ static int nv_get_sset_count(struct net_device *dev, int sset)
 
 static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *estats, u64 *buffer)
 {
+	unsigned long flags;
 	struct fe_priv *np = netdev_priv(dev);
 
+	spin_lock_irqsave(&np->lock, flags);
+
 	/* update stats */
 	nv_do_stats_poll((unsigned long)dev);
 
 	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
+
+	spin_unlock_irqrestore(&np->lock, flags);
 }
 
 static int nv_link_test(struct net_device *dev)
@@ -5189,13 +5198,13 @@ static int nv_close(struct net_device *dev)
 
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
+	del_timer_sync(&np->stats_poll);
 	spin_unlock_irq(&np->lock);
 	nv_napi_disable(dev);
 	synchronize_irq(np->pci_dev->irq);
 
 	del_timer_sync(&np->oom_kick);
 	del_timer_sync(&np->nic_poll);
-	del_timer_sync(&np->stats_poll);
 
 	netif_stop_queue(dev);
 	spin_lock_irq(&np->lock);
-- 
1.7.3.1
