From: Min Zhang <mzhang@mvista.com>
Subject: [PATCH] mlx4: set carrier off after register netdev
Date: Fri, 5 Oct 2012 11:28:17 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1210051058420.16216@linux-acr3.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51129 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932708Ab2JES23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 14:28:29 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so2072583pad.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 11:28:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifconfig mlx4_en port reported RUNNING even though the link was down.

mlx4_en_init_netdev didn't initialize the dev operstate properly so
the operstate stayed as default IF_OPER_UNKNOWN, then ifconfig treated
the UNKNOWN as RUNNING state for backward compatiblity per RFC2863.

The fix calls netif_carrier_off which is supposed to set operstate
after register_netdev. Calling it before register_netdev has no effect
since the dev->state is still NETREG_UNINITIALIZED

Tested by removing the physical link signal to the mellanox 10G port,
modprobe mlx4_en, then ifconfig up. Verify there is no RUNNING status.

Signed-off-by: Min Zhang <mzhang@mvista.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c96113b..8c562f7a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1306,12 +1306,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	mdev->pndev[port] = dev;
 
-	netif_carrier_off(dev);
 	err = register_netdev(dev);
 	if (err) {
 		mlx4_err(mdev, "Netdev registration failed for port %d\n", port);
 		goto out;
 	}
+	netif_carrier_off(dev);
 
 	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
-- 
1.7.7.4
