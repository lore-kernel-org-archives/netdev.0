From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Fix incorrect reuse of MID entries
Date: Sun, 30 Oct 2016 10:09:22 +0100
Message-ID: <1477818562-30185-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35151 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbcJ3JJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 05:09:25 -0400
Received: by mail-wm0-f68.google.com with SMTP id 68so7165797wmz.2
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 02:09:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In the device, a MID entry represents a group of local ports, which can
later be bound to a MDB entry.

The lookup of an existing MID entry is currently done using the provided
MC MAC address and VID, from the Linux bridge. However, this can result
in an incorrect reuse of the same MID index in different VLAN-unaware
bridges (same IP MC group and VID 0).

Fix this by performing the lookup based on FID instead of VID, which is
unique across different bridges.

Fixes: 3a49b4fde2a1 ("mlxsw: Adding layer 2 multicast support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 9b22863..97bbc1d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -115,7 +115,7 @@ struct mlxsw_sp_rif {
 struct mlxsw_sp_mid {
 	struct list_head list;
 	unsigned char addr[ETH_ALEN];
-	u16 vid;
+	u16 fid;
 	u16 mid;
 	unsigned int ref_count;
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 5e00c79..1e2c8ec 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -929,12 +929,12 @@ static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
 
 static struct mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp *mlxsw_sp,
 					      const unsigned char *addr,
-					      u16 vid)
+					      u16 fid)
 {
 	struct mlxsw_sp_mid *mid;
 
 	list_for_each_entry(mid, &mlxsw_sp->br_mids.list, list) {
-		if (ether_addr_equal(mid->addr, addr) && mid->vid == vid)
+		if (ether_addr_equal(mid->addr, addr) && mid->fid == fid)
 			return mid;
 	}
 	return NULL;
@@ -942,7 +942,7 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp *mlxsw_sp,
 
 static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 						const unsigned char *addr,
-						u16 vid)
+						u16 fid)
 {
 	struct mlxsw_sp_mid *mid;
 	u16 mid_idx;
@@ -958,7 +958,7 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 
 	set_bit(mid_idx, mlxsw_sp->br_mids.mapped);
 	ether_addr_copy(mid->addr, addr);
-	mid->vid = vid;
+	mid->fid = fid;
 	mid->mid = mid_idx;
 	mid->ref_count = 0;
 	list_add_tail(&mid->list, &mlxsw_sp->br_mids.list);
@@ -991,9 +991,9 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
-	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, mdb->vid);
+	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, fid);
 	if (!mid) {
-		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, mdb->addr, mdb->vid);
+		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, mdb->addr, fid);
 		if (!mid) {
 			netdev_err(dev, "Unable to allocate MC group\n");
 			return -ENOMEM;
@@ -1137,7 +1137,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 mid_idx;
 	int err = 0;
 
-	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, mdb->vid);
+	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, fid);
 	if (!mid) {
 		netdev_err(dev, "Unable to remove port from MC DB\n");
 		return -EINVAL;
-- 
2.5.5
