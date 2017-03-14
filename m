From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 08/12] net: bcmgenet: correct return value of __bcmgenet_tx_reclaim
Date: Mon, 13 Mar 2017 17:41:38 -0700
Message-ID: <20170314004142.4746-9-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reclaim function should return the number of buffer descriptors
reclaimed, not just the number corresponding to skb packets.

Also, remove the unnecessary computation when updating the consumer
index.

While this is not a functional problem it could degrade performance
of napi in a fragmented transmit stream.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1f94ba1773dd..d90d366b286f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1218,7 +1218,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	}
 
 	ring->free_bds += txbds_processed;
-	ring->c_index = (ring->c_index + txbds_processed) & DMA_C_INDEX_MASK;
+	ring->c_index = c_index;
 
 	dev->stats.tx_packets += pkts_compl;
 	dev->stats.tx_bytes += bytes_compl;
@@ -1231,7 +1231,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 			netif_tx_wake_queue(txq);
 	}
 
-	return pkts_compl;
+	return txbds_processed;
 }
 
 static unsigned int bcmgenet_tx_reclaim(struct net_device *dev,
-- 
2.11.1
