From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4: Setting new port types after all interfaces unregistered
Date: Tue, 21 Feb 2012 15:41:07 +0200
Message-ID: <4F439EF3.8050702@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:37507 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752647Ab2BUNl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 08:41:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In port type change flow, need to set the new port types only after
all interfaces have finished the unregister process.
Otherwise, during unregister, one of the interfaces might issue a SET_PORT
command with wrong port types, it can cause bad FW behavior.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5c655a2..32f8799 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -531,15 +531,14 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 	for (port = 0; port <  dev->caps.num_ports; port++) {
 		/* Change the port type only if the new type is different
 		 * from the current, and not set to Auto */
-		if (port_types[port] != dev->caps.port_type[port + 1]) {
+		if (port_types[port] != dev->caps.port_type[port + 1])
 			change = 1;
-			dev->caps.port_type[port + 1] = port_types[port];
-		}
 	}
 	if (change) {
 		mlx4_unregister_device(dev);
 		for (port = 1; port <= dev->caps.num_ports; port++) {
 			mlx4_CLOSE_PORT(dev, port);
+			dev->caps.port_type[port + 1] = port_types[port];
 			err = mlx4_SET_PORT(dev, port);
 			if (err) {
 				mlx4_err(dev, "Failed to set port %d, "
-- 
1.5.4.3
