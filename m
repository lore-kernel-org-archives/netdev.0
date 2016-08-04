From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net 2/3] mlxsw: spectrum: Do not override PAUSE settings
Date: Thu, 4 Aug 2016 17:36:21 +0300
Message-ID: <1470321382-10426-3-git-send-email-idosch@mellanox.com>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0080.outbound.protection.outlook.com ([104.47.1.80]:10240
	"EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759000AbcHDWUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 18:20:41 -0400
In-Reply-To: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PFCC register is used to configure both PAUSE and PFC frames.
Therefore, when PFC frames are disabled we must make sure we don't
mistakenly also disable PAUSE frames (which might be enabled).

Fix this by packing the PFCC register with the current PAUSE settings.

Note that this register is also accessed via ethtool ops, but there we
are guaranteed to have PFC disabled.

Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 3c4a178..b6ed7f7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -341,6 +341,8 @@ static int mlxsw_sp_port_pfc_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	char pfcc_pl[MLXSW_REG_PFCC_LEN];
 
 	mlxsw_reg_pfcc_pack(pfcc_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_pfcc_pprx_set(pfcc_pl, mlxsw_sp_port->link.rx_pause);
+	mlxsw_reg_pfcc_pptx_set(pfcc_pl, mlxsw_sp_port->link.tx_pause);
 	mlxsw_reg_pfcc_prio_pack(pfcc_pl, pfc->pfc_en);
 
 	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pfcc),
-- 
2.8.2
