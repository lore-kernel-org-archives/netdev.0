From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: Avoid double dumping of the PF device capabilities
Date: Sun, 14 Dec 2014 16:18:05 +0200
Message-ID: <1418566685-9855-3-git-send-email-ogerlitz@mellanox.com>
References: <1418566685-9855-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60987 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750782AbaLNOSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 09:18:15 -0500
In-Reply-To: <1418566685-9855-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support asymmetric EQ allocations, we should query the device
capabilities prior to enabling SRIOV. As a side effect of adding that,
we are dumping the PF device capabilities twice. Avoid that by moving
the printing into a helper function which is called once.

Fixes: 7ae0e400cd93 ('net/mlx4_core: Flexible (asymmetric) allocation of
		     EQs and MSI-X vectors for PF/VFs')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   26 +++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |    1 +
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index ef3b95b..51807bb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -787,11 +787,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		if ((1 << (field & 0x3f)) > (PAGE_SIZE / dev_cap->bf_reg_size))
 			field = 3;
 		dev_cap->bf_regs_per_page = 1 << (field & 0x3f);
-		mlx4_dbg(dev, "BlueFlame available (reg size %d, regs/page %d)\n",
-			 dev_cap->bf_reg_size, dev_cap->bf_regs_per_page);
 	} else {
 		dev_cap->bf_reg_size = 0;
-		mlx4_dbg(dev, "BlueFlame not available\n");
 	}
 
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_SG_SQ_OFFSET);
@@ -902,9 +899,6 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 			goto out;
 	}
 
-	mlx4_dbg(dev, "Base MM extensions: flags %08x, rsvd L_Key %08x\n",
-		 dev_cap->bmme_flags, dev_cap->reserved_lkey);
-
 	/*
 	 * Each UAR has 4 EQ doorbells; so if a UAR is reserved, then
 	 * we can't use any EQs whose doorbell falls on that page,
@@ -916,6 +910,21 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	else
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_SYS_EQS;
 
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+void mlx4_dev_cap_dump(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
+{
+	if (dev_cap->bf_reg_size > 0)
+		mlx4_dbg(dev, "BlueFlame available (reg size %d, regs/page %d)\n",
+			 dev_cap->bf_reg_size, dev_cap->bf_regs_per_page);
+	else
+		mlx4_dbg(dev, "BlueFlame not available\n");
+
+	mlx4_dbg(dev, "Base MM extensions: flags %08x, rsvd L_Key %08x\n",
+		 dev_cap->bmme_flags, dev_cap->reserved_lkey);
 	mlx4_dbg(dev, "Max ICM size %lld MB\n",
 		 (unsigned long long) dev_cap->max_icm_sz >> 20);
 	mlx4_dbg(dev, "Max QPs: %d, reserved QPs: %d, entry size: %d\n",
@@ -949,13 +958,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 dev_cap->dmfs_high_rate_qpn_base);
 	mlx4_dbg(dev, "DMFS high rate steer QPn range: %d\n",
 		 dev_cap->dmfs_high_rate_qpn_range);
-
 	dump_dev_cap_flags(dev, dev_cap->flags);
 	dump_dev_cap_flags2(dev, dev_cap->flags2);
-
-out:
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
 }
 
 int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_cap)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 794e282..62562b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -224,6 +224,7 @@ struct mlx4_set_ib_param {
 	u32 cap_mask;
 };
 
+void mlx4_dev_cap_dump(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
 int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_cap);
 int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index c2ef266..b935bf3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -305,6 +305,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting\n");
 		return err;
 	}
+	mlx4_dev_cap_dump(dev, dev_cap);
 
 	if (dev_cap->min_page_sz > PAGE_SIZE) {
 		mlx4_err(dev, "HCA minimum page size of %d bigger than kernel PAGE_SIZE of %ld, aborting\n",
-- 
1.7.1
