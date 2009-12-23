From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 3/6] enic: minimize pkt filter updates to firmware
Date: Wed, 23 Dec 2009 15:27:43 -0800
Message-ID: <20091223232743.19428.59938.stgit@savbu-pc100.cisco.com>
References: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6154 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149AbZLWX1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:43 -0500
In-Reply-To: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

In set_multicast(), only push pkt filter changes down to firmware if
pkt filter actually changes.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    1 +
 drivers/net/enic/enic_main.c |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 8dd0105..b090d65 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -89,6 +89,7 @@ struct enic {
 	spinlock_t devcmd_lock;
 	u8 mac_addr[ETH_ALEN];
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
+	unsigned int flags;
 	unsigned int mc_count;
 	int csum_rx_enabled;
 	u32 port_mtu;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 452a6b7..019b148 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -771,6 +771,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	int promisc = (netdev->flags & IFF_PROMISC) ? 1 : 0;
 	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
 	    (netdev->mc_count > ENIC_MULTICAST_PERFECT_FILTERS);
+	unsigned int flags = netdev->flags | (allmulti ? IFF_ALLMULTI : 0);
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
 	unsigned int mc_count = netdev->mc_count;
 	unsigned int i, j;
@@ -780,8 +781,11 @@ static void enic_set_multicast_list(struct net_device *netdev)
 
 	spin_lock(&enic->devcmd_lock);
 
-	vnic_dev_packet_filter(enic->vdev, directed,
-		multicast, broadcast, promisc, allmulti);
+	if (enic->flags != flags) {
+		enic->flags = flags;
+		vnic_dev_packet_filter(enic->vdev, directed,
+			multicast, broadcast, promisc, allmulti);
+	}
 
 	/* Is there an easier way?  Trying to minimize to
 	 * calls to add/del multicast addrs.  We keep the

