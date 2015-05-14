From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 14:18:23 -0700
Message-ID: <20150514211721.1391.44501.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161158AbbENVS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 17:18:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx_dropped stat wasn't being reported when ip_tunnel_get_stats64 was
called.  This was leading to some confusing results in my debug as I was
seeing rx_errors increment but no other value which pointed me toward the
type of error being seen.

This change corrects that by using netdev_stats_to_stats64 to copy all
available dev stats instead of just the few that were hand picked.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

v2: Replaced manual copy with netdev_stats_to_stats64

 net/ipv4/ip_tunnel_core.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 3998b1822d85..b04f2dbb76c4 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -185,21 +185,7 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 		tot->tx_bytes   += tx_bytes;
 	}
 
-	tot->multicast = dev->stats.multicast;
-
-	tot->rx_crc_errors = dev->stats.rx_crc_errors;
-	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
-	tot->rx_length_errors = dev->stats.rx_length_errors;
-	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-	tot->rx_errors = dev->stats.rx_errors;
-
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	tot->collisions  = dev->stats.collisions;
+	netdev_stats_to_stats64(tot, &dev->stats);
 
 	return tot;
 }
