From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net 1/3] mlxsw: spectrum: Do not assume PAUSE frames are disabled
Date: Thu, 4 Aug 2016 17:36:20 +0300
Message-ID: <1470321382-10426-2-git-send-email-idosch@mellanox.com>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0075.outbound.protection.outlook.com ([104.47.2.75]:22992
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965491AbcHDTRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 15:17:36 -0400
In-Reply-To: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ieee_setpfc() gets called, PAUSE frames are not necessarily
disabled on the port.

Check if PAUSE frames are disabled or enabled and configure the port's
headroom buffer accordingly.

Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 01cfb75..3c4a178 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -351,17 +351,17 @@ static int mlxsw_sp_dcbnl_ieee_setpfc(struct net_device *dev,
 				      struct ieee_pfc *pfc)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	bool pause_en = mlxsw_sp_port_is_pause_en(mlxsw_sp_port);
 	int err;
 
-	if ((mlxsw_sp_port->link.tx_pause || mlxsw_sp_port->link.rx_pause) &&
-	    pfc->pfc_en) {
+	if (pause_en && pfc->pfc_en) {
 		netdev_err(dev, "PAUSE frames already enabled on port\n");
 		return -EINVAL;
 	}
 
 	err = __mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
 					   mlxsw_sp_port->dcb.ets->prio_tc,
-					   false, pfc);
+					   pause_en, pfc);
 	if (err) {
 		netdev_err(dev, "Failed to configure port's headroom for PFC\n");
 		return err;
@@ -380,7 +380,7 @@ static int mlxsw_sp_dcbnl_ieee_setpfc(struct net_device *dev,
 
 err_port_pfc_set:
 	__mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
-				     mlxsw_sp_port->dcb.ets->prio_tc, false,
+				     mlxsw_sp_port->dcb.ets->prio_tc, pause_en,
 				     mlxsw_sp_port->dcb.pfc);
 	return err;
 }
-- 
2.8.2
