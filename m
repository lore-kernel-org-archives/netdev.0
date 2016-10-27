From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 05/10] net/mlx4_en: Process all completions in RX rings after port goes up
Date: Thu, 27 Oct 2016 16:27:17 +0300
Message-ID: <1477574842-29688-6-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57537 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941586AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Currently there is a race between incoming traffic and
initialization flow. HW is able to receive the packets
after INIT_PORT is done and unicast steering is configured.
Before we set priv->port_up NAPI is not scheduled and
receive queues become full. Therefore we never get
new interrupts about the completions.
This issue could happen if running heavy traffic during
bringing port up.
The resolution is to schedule NAPI once port_up is set.
If receive queues were full this will process all cqes
and release them.

Fixes: c27a02cd94d6 ("mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC")
Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7e703bed7b82..e25c11dff525 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1733,6 +1733,13 @@ int mlx4_en_start_port(struct net_device *dev)
 		udp_tunnel_get_rx_info(dev);
 
 	priv->port_up = true;
+
+	/* Process all completions if exist to prevent
+	 * the queues freezing if they are full
+	 */
+	for (i = 0; i < priv->rx_ring_num; i++)
+		napi_schedule(&priv->rx_cq[i]->napi);
+
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
 
-- 
1.8.3.1
