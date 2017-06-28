From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] mlxsw: spectrum_router: Fix NULL pointer dereference
Date: Wed, 28 Jun 2017 09:03:12 +0300
Message-ID: <20170628060312.15768-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com, Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0040.outbound.protection.outlook.com ([104.47.1.40]:22862
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751489AbdF1GDh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 02:03:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a VLAN device is enslaved to a bridge we shouldn't create a
router interface (RIF) for it when it's configured with an IP address.
This is already handled by the driver for other types of netdevs, such
as physical ports and LAG devices.

If this IP address is then removed and the interface is subsequently
unlinked from the bridge, a NULL pointer dereference can happen, as the
original 802.1d FID was replaced with an rFID which was then deleted.

To reproduce:
$ ip link set dev enp3s0np9 up
$ ip link add name enp3s0np9.111 link enp3s0np9 type vlan id 111
$ ip link set dev enp3s0np9.111 up
$ ip link add name br0 type bridge
$ ip link set dev br0 up
$ ip link set enp3s0np9.111 master br0
$ ip address add dev enp3s0np9.111 192.168.0.1/24
$ ip address del dev enp3s0np9.111 192.168.0.1/24
$ ip link set dev enp3s0np9.111 nomaster

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Petr Machata <petrm@mellanox.com>
Tested-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Petr Machata <petrm@mellanox.com>
---
Dave, please consider this patch for 4.9.y and 4.11.y. Note that it
won't apply cleanly as I moved the function from spectrum.c to
spectrum_router.c in 4.12. I can do the backport myself and post it to
netdev after the patch gets to mainline.

Thanks
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 9f89c41..0744452 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3334,6 +3334,9 @@ static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
+	if (netif_is_bridge_port(vlan_dev))
+		return 0;
+
 	if (mlxsw_sp_port_dev_check(real_dev))
 		return mlxsw_sp_inetaddr_vport_event(vlan_dev, real_dev, event,
 						     vid);
-- 
2.9.4
