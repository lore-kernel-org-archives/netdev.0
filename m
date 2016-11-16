From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netronome: don't access real_num_rx_queues directly
Date: Wed, 16 Nov 2016 15:10:49 +0100
Message-ID: <20161116141118.1893244-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Rolf Neugebauer <rolf.neugebauer@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netdev->real_num_rx_queues setting is only available if CONFIG_SYSFS
is enabled, so we now get a build failure when that is turned off:

netronome/nfp/nfp_net_common.c: In function 'nfp_net_ring_swap_enable':
netronome/nfp/nfp_net_common.c:2489:18: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?

As far as I can tell, the check here is only used as an optimization that
we can skip in order to fix the compilation. If sysfs is disabled,
the following netif_set_real_num_rx_queues() has no effect.

Fixes: 164d1e9e5d52 ("nfp: add support for ethtool .set_channels")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 99edb9fd84bf..eb3715700c95 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2486,15 +2486,13 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
 
-	if (nn->netdev->real_num_rx_queues != nn->num_rx_rings) {
-		if (!netif_is_rxfh_configured(nn->netdev))
-			nfp_net_rss_init_itbl(nn);
+	if (!netif_is_rxfh_configured(nn->netdev))
+		nfp_net_rss_init_itbl(nn);
 
-		err = netif_set_real_num_rx_queues(nn->netdev,
-						   nn->num_rx_rings);
-		if (err)
-			return err;
-	}
+	err = netif_set_real_num_rx_queues(nn->netdev,
+					   nn->num_rx_rings);
+	if (err)
+		return err;
 
 	if (nn->netdev->real_num_tx_queues != nn->num_stack_tx_rings) {
 		err = netif_set_real_num_tx_queues(nn->netdev,
-- 
2.9.0
