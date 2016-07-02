From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/12] mlxsw: spectrum: Send untagged packets through a port netdev
Date: Sat,  2 Jul 2016 11:00:09 +0200
Message-ID: <1467450020-23415-2-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34031 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcGBJA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so10302591wmz.1
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:25 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Port netdevs (e.g. swXpY) that are not bridged are represented in the
device using a vPort with VID=PVID=1 (the PVID vPort), as untagged
packets entering the switch are internally tagged with the PVID VLAN.
When these packets are routed through a different port netdev they
should egress untagged.

This wasn't a problem until now, as non-bridged traffic only originated
from the CPU, which transmits packets out of the port as-is.

When a vPort is created with VID 1 mark it as egress untagged.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index a453fff..afd06dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -816,6 +816,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
+	bool untagged = vid == 1;
 	int err;
 
 	/* VLAN 0 is added to HW filter when device goes up, but it is
@@ -859,7 +860,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		goto err_port_vid_learning_set;
 	}
 
-	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, true, false);
+	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, true, untagged);
 	if (err) {
 		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
 			   vid);
-- 
2.5.5
