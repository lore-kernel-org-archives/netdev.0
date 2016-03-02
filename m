From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_core: Allow resetting VF admin mac to zero
Date: Wed,  2 Mar 2016 17:47:46 +0200
Message-ID: <1456933666-28949-4-git-send-email-ogerlitz@mellanox.com>
References: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48331 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754997AbcCBPsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:48:24 -0500
In-Reply-To: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The VF administrative mac addresses (stored in the PF driver) are
initialized to zero when the PF driver starts up.

These addresses may be modified in the PF driver through ndo calls
initiated by iproute2 or libvirt.

While we allow the PF/host to change the VF admin mac address from zero
to a valid unicast mac, we do not allow restoring the VF admin mac to
zero. We currently only allow changing this mac to a different unicast mac.

This leads to problems when libvirt scripts are used to deal with
VF mac addresses, and libvirt attempts to revoke the mac so this
host will not use it anymore.

Fix this by allowing resetting a VF administrative MAC back to zero.

Fixes: 8f7ba3ca12f6 ('net/mlx4: Add set VF mac address support')
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reported-by: Moshe Levi <moshele@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f191a16..21e2c09 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2245,7 +2245,7 @@ static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
 	struct mlx4_en_dev *mdev = en_priv->mdev;
 	u64 mac_u64 = mlx4_mac_to_u64(mac);
 
-	if (!is_valid_ether_addr(mac))
+	if (is_multicast_ether_addr(mac))
 		return -EINVAL;
 
 	return mlx4_set_vf_mac(mdev->dev, en_priv->port, queue, mac_u64);
-- 
2.3.7
