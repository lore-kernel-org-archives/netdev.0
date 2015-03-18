From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] IB/mlx4: Verify net device validity on port change event
Date: Wed, 18 Mar 2015 16:24:50 +0200
Message-ID: <1426688693-18980-2-git-send-email-ogerlitz@mellanox.com>
References: <1426688693-18980-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46602 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933348AbbCROY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:24:57 -0400
In-Reply-To: <1426688693-18980-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Processing an event is done in a different context from the one when
the event was dispatched. This requires a check that the slave
net device is still valid when the event is being processed. The check is done
under the iboe lock which ensure correctness.

Fixes: a57500903093 ('IB/mlx4: Add port aggregation support')
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index ac6e2b7..b972c0b 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2697,8 +2697,12 @@ static void handle_bonded_port_state_event(struct work_struct *work)
 	spin_lock_bh(&ibdev->iboe.lock);
 	for (i = 0; i < MLX4_MAX_PORTS; ++i) {
 		struct net_device *curr_netdev = ibdev->iboe.netdevs[i];
+		enum ib_port_state curr_port_state;
 
-		enum ib_port_state curr_port_state =
+		if (!curr_netdev)
+			continue;
+
+		curr_port_state =
 			(netif_running(curr_netdev) &&
 			 netif_carrier_ok(curr_netdev)) ?
 			IB_PORT_ACTIVE : IB_PORT_DOWN;
-- 
1.7.1
