From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 03/13] tile: avoid bug in tilepro net driver built with old hypervisor
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <05a1a2179d26849d97cb5ea15f8381cf6e93f6f4.1375385120.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building against headers from an older Tilera hypervisor can cause
the frags[] array to be overrun.  Don't enable TSO in that case.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 327ff7b..2f4b7b9 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1929,7 +1929,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 	unsigned int csum_start = skb_checksum_start_offset(skb);
 
-	lepp_frag_t frags[LEPP_MAX_FRAGS];
+	lepp_frag_t frags[1 + MAX_SKB_FRAGS];
 
 	unsigned int num_frags;
 
@@ -1944,7 +1944,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	unsigned int cmd_head, cmd_tail, cmd_next;
 	unsigned int comp_tail;
 
-	lepp_cmd_t cmds[LEPP_MAX_FRAGS];
+	lepp_cmd_t cmds[1 + MAX_SKB_FRAGS];
 
 
 	/*
@@ -2332,7 +2332,10 @@ static void tile_net_setup(struct net_device *dev)
 	features |= NETIF_F_LLTX;
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
-	features |= NETIF_F_TSO;
+
+	/* We support TSO iff the HV supports sufficient frags. */
+	if (LEPP_MAX_FRAGS >= 1 + MAX_SKB_FRAGS)
+		features |= NETIF_F_TSO;
 
 	/* We can't support HIGHDMA without hash_default, since we need
 	 * to be able to finv() with a VA if we don't have hash_default.
-- 
1.8.3.1
