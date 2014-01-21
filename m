From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_core: Remove unnecessary validation for port number
Date: Tue, 21 Jan 2014 10:19:37 +0200
Message-ID: <1390292377-11806-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44885 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751226AbaAUIUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 03:20:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.co.il>

This is a fix to a regression introduced by commit:
"982290a net/mlx4_core: Check port number for validity
before accessing data"

IPoIB could not attach to multicast group and we get this in dmesg:
[144214.145008] ib0: failed to attach to multicast group, ret = -22
[144214.145016] ib0: couldn't attach QP to multicast group ff12:401b:ffff:0000:0000:0000:ffff:ffff
[144214.145019] ib0: multicast join failed for ff12:401b:ffff:0000:0000:0000:ffff:ffff, status -22

The cause to the problem is because port is extracted from gid[5].
Which is only valid for Ethernet.
Removed this validation in mlx4_qp_attach_common(), which is accessed
from both Ethernet and IB flows.
Error flow for bad port value in Ethernet is already exists in that
function.

Signed-off-by: Moni Shoua <monis@mellanox.co.il>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index bfe65f7..aefb74f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -943,9 +943,6 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	u8 port = gid[5];
 	u8 new_entry = 0;
 
-	if (port < 1 || port > dev->caps.num_ports)
-		return -EINVAL;
-
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-- 
1.8.3.4
