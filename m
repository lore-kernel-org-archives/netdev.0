From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 09/11] net/mlx4: Fix memory corruption in mlx4_MAD_IFC_wrapper
Date: Tue, 27 Jan 2015 15:58:07 +0200
Message-ID: <1422367089-13419-10-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46330 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756154AbbA0N7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:08 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Fix a memory corruption at mlx4_MAD_IFC_wrapper.

A table of size dev->caps.pkey_table_len[port]*sizeof(*table)
was allocated, but get_full_pkey_table() assumes that the number
of entries in the table is a multiplication of 32 (which isn't always
correct).

Fixes: 0a9a018 ('mlx4: MAD_IFC paravirtualization')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 928b706..154effb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -901,7 +901,9 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 				index = be32_to_cpu(smp->attr_mod);
 				if (port < 1 || port > dev->caps.num_ports)
 					return -EINVAL;
-				table = kcalloc(dev->caps.pkey_table_len[port], sizeof *table, GFP_KERNEL);
+				table = kcalloc((dev->caps.pkey_table_len[port] / 32) + 1,
+						sizeof(*table) * 32, GFP_KERNEL);
+
 				if (!table)
 					return -ENOMEM;
 				/* need to get the full pkey table because the paravirtualized
-- 
1.9.3
