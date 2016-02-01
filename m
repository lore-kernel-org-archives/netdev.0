From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v3 3/4] team: track sum of rx_nohandler for all slaves
Date: Mon,  1 Feb 2016 18:51:06 -0500
Message-ID: <1454370667-2328-4-git-send-email-jarod@redhat.com>
References: <1453996188-29965-1-git-send-email-jarod@redhat.com>
 <1454370667-2328-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454370667-2328-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: Jiri Pirko <jiri@resnulli.us>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/team/team.c | 10 +++++++---
 include/linux/if_team.h |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 718ceea..00558e1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -758,6 +758,8 @@ static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
 		u64_stats_update_end(&pcpu_stats->syncp);
 
 		skb->dev = team->dev;
+	} else if (res == RX_HANDLER_EXACT) {
+		this_cpu_inc(team->pcpu_stats->rx_nohandler);
 	} else {
 		this_cpu_inc(team->pcpu_stats->rx_dropped);
 	}
@@ -1807,7 +1809,7 @@ team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	struct team *team = netdev_priv(dev);
 	struct team_pcpu_stats *p;
 	u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_bytes;
-	u32 rx_dropped = 0, tx_dropped = 0;
+	u32 rx_dropped = 0, tx_dropped = 0, rx_nohandler = 0;
 	unsigned int start;
 	int i;
 
@@ -1828,14 +1830,16 @@ team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_packets	+= tx_packets;
 		stats->tx_bytes		+= tx_bytes;
 		/*
-		 * rx_dropped & tx_dropped are u32, updated
-		 * without syncp protection.
+		 * rx_dropped, tx_dropped & rx_nohandler are u32,
+		 * updated without syncp protection.
 		 */
 		rx_dropped	+= p->rx_dropped;
 		tx_dropped	+= p->tx_dropped;
+		rx_nohandler	+= p->rx_nohandler;
 	}
 	stats->rx_dropped	= rx_dropped;
 	stats->tx_dropped	= tx_dropped;
+	stats->rx_nohandler	= rx_nohandler;
 	return stats;
 }
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index b84e49c..174f43f 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -24,6 +24,7 @@ struct team_pcpu_stats {
 	struct u64_stats_sync	syncp;
 	u32			rx_dropped;
 	u32			tx_dropped;
+	u32			rx_nohandler;
 };
 
 struct team;
-- 
1.8.3.1
