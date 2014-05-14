From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 6/8] net/mlx4_en: Protect MAC address modification with the state_lock mutex
Date: Wed, 14 May 2014 12:15:15 +0300
Message-ID: <1400058917-26313-7-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com, Shani Michaelli <shanim@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44621 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753665AbaENJYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:24:23 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaelli <shanim@mellanox.com>

This Patches solves an issue that could raise when modifying the
device's MAC. It occurs due to a simultaneous access to priv->mac_hash
from two contexts. The buggy scenario described below:
Context 1: copy the new mac address to the dev->dev_addr field.
Context 2: mlx4_en_do_uc_filter removes prev_mac entry from the mac_hash
           db since it is not in dev->uc and not equal to dev->dev_addr.
Context 1: mlx4_en_do_set_mac() calls mlx4_en_replace_mac() to replace
           prev_mac with dev_addr but it fails to update the mac_hash db
           since it no longer contains prev_mac, therefore it returns
           with an error.

The fix is to prevent mlx4_en_do_uc_filter from being executed by both
of the context 1 calls described above, This is done by putting them
both under the mdev->state_lock lock, it will solve this issue since
mlx4_en_do_uc_filter is already protected by the mdev->state_lock.


Reviewed-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index eea7868..9090643 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -789,9 +789,8 @@ static int mlx4_en_set_mac(struct net_device *dev, void *addr)
 	if (!is_valid_ether_addr(saddr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
-
 	mutex_lock(&mdev->state_lock);
+	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
 	err = mlx4_en_do_set_mac(priv);
 	mutex_unlock(&mdev->state_lock);
 
-- 
1.7.1
