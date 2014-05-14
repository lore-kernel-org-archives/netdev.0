From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 3/8] net/mlx4_en: Fix errors in MAC address changing when port is down
Date: Wed, 14 May 2014 12:15:12 +0300
Message-ID: <1400058917-26313-4-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com, Shani Michaelli <shanim@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51152 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751747AbaENJPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:15:30 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaelli <shanim@mellanox.com>

This patch fix an issue that happen when changing the MAC address when
the port is down, described as follows:
1. Set the port down.
2. Change the MAC address - mlx4_en_set_mac() will change dev->dev_addr.
3. Set the port up - will result in mlx4_en_do_uc_filter that will
   remove the prev_mac entry from the mac_hash db.
4. Changing the MAC address again will eventually trigger the call to
   mlx4_en_replace_mac() in order to replace prev_mac with dev_addr but
   the prev_mac entry is already not exist in the mac_hash db therefore
   the operation fails.

The fix is to set the prev_mac with the new MAC address so in step 3
above, after setting the port up mlx4_en_get_qp() is updating the
mac_hash with the entry of dev_addr which is equal to prev_mac.
Therefore in step 4, when calling mlx4_en_replace_mac, the entry related
to prev_mac exist in mac_hash and the replace operation succeed.


Reviewed-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fba3c8e..eea7868 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -770,11 +770,12 @@ static int mlx4_en_do_set_mac(struct mlx4_en_priv *priv)
 					  priv->dev->dev_addr, priv->prev_mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
-		memcpy(priv->prev_mac, priv->dev->dev_addr,
-		       sizeof(priv->prev_mac));
 	} else
 		en_dbg(HW, priv, "Port is down while registering mac, exiting...\n");
 
+	memcpy(priv->prev_mac, priv->dev->dev_addr,
+	       sizeof(priv->prev_mac));
+
 	return err;
 }
 
-- 
1.7.1
