From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 20/23 v3] mlx4_core: binding virtual function to physical
 function
Date: Thu, 04 Feb 2010 17:57:01 +0200
Message-ID: <4B6AEE4D.1020206@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49892 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933121Ab0BDP5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:57:04 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c   |    8 ++++++++
 drivers/net/mlx4/fw.c    |   23 +++++++++++++++++++++++
 drivers/net/mlx4/fw.h    |    1 +
 drivers/net/mlx4/main.c  |    4 ++--
 drivers/net/mlx4/mcg.c   |    3 ++-
 drivers/net/mlx4/mlx4.h  |    2 ++
 drivers/net/mlx4/port.c  |    5 +++--
 include/linux/mlx4/cmd.h |    1 +
 8 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index e437d74..2605344 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -422,9 +422,11 @@ static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 						       struct mlx4_cmd_mailbox *inbox,
 						       struct mlx4_cmd_mailbox *outbox)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
 	u32 param1 = *((u32 *) &vhcr->in_param);
 	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);
 	int ret;
+	u8 pf_num = priv->mfunc.master.slave_state[slave].pf_num;
 
 #if 0
 	char *res[] = {"QP", "CQ", "SRQ", "MPT", "MTT"};
@@ -507,6 +509,7 @@ static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 			mlx4_free_mtt_range(dev, param1 /* first */, param2 /* order */);
 		break;
 	case RES_MAC:
+		vhcr->in_param |= (u64) (pf_num) << 48;
 		switch (vhcr->op) {
 		case MLX4_CMD_ALLOC_RES:
 			ret = mlx4_register_mac(dev, vhcr->op_modifier,
@@ -1119,6 +1122,11 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd, u16 para
 		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR2)
 			goto reset_slave;
 		slave_state[slave].vhcr_dma |= param;
+		if (mlx4_QUERY_FUNC(dev, slave, &slave_state[slave].pf_num)) {
+			mlx4_err(dev, "Failed to determine physical function "
+				      "number for slave %d\n", slave);
+			goto reset_slave;
+		}
 		break;
 	case MLX4_COMM_CMD_VHCR_POST:
 		if ((slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_EN) &&
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 202a256..18294c3 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -1038,3 +1038,26 @@ int mlx4_NOP(struct mlx4_dev *dev)
 	/* Input modifier of 0x1f means "finish as soon as possible." */
 	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100);
 }
+
+int mlx4_QUERY_FUNC(struct mlx4_dev *dev, int func, u8 *pf_num)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	u8 *outbox;
+	int ret;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	outbox = mailbox->buf;
+
+	ret = mlx4_cmd_box(dev, 0, mailbox->dma, func & 0xff, 0,
+			   MLX4_CMD_QUERY_FUNC, MLX4_CMD_TIME_CLASS_A);
+	if (ret)
+		goto out;
+
+	*pf_num = outbox[3];
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return ret;
+}
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index e033d26..4ec92f4 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -181,5 +181,6 @@ int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev);
 int mlx4_NOP(struct mlx4_dev *dev);
 int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg);
+int mlx4_QUERY_FUNC(struct mlx4_dev *dev, int func, u8 *pf_num);
 
 #endif /* MLX4_FW_H */
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index d825cc1..b57bac2 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -276,7 +276,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		}
 	}
 
-	mlx4_set_port_mask(dev, &dev->caps, dev->caps.pf_num);
+	mlx4_set_port_mask(dev, &dev->caps, dev->caps.function);
 
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] = dev_cap->reserved_qps;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_ETH_ADDR] =
@@ -389,7 +389,7 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 				goto out;
 			}
 		}
-		mlx4_set_port_mask(dev, &dev->caps, dev->caps.pf_num);
+		mlx4_set_port_mask(dev, &dev->caps, dev->caps.function);
 		err = mlx4_register_device(dev);
 	}
 
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 9a678d2..4e2b422 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -361,9 +361,10 @@ int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 	struct mlx4_qp qp; /* dummy for calling attach/detach */
 	u8 *gid = inbox->buf;
 	enum mlx4_protocol prot = (vhcr->in_modifier >> 28) & 0x7;
+	u8 pf_num = mlx4_priv(dev)->mfunc.master.slave_state[slave].pf_num;
 
 	if (prot == MLX4_PROT_ETH)
-		gid[7] = slave << 4;
+		gid[7] = pf_num << 4;
 
 	qp.qpn = vhcr->in_modifier & 0xffffff;
 	if (vhcr->op_modifier)
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 1cc4c13..cdf6aff 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -238,6 +238,8 @@ struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
 	u8 init_port_mask;
+	u8 pf_num;
+	u8 function;
 	dma_addr_t vhcr_dma;
 	u16 mtu[MLX4_MAX_PORTS + 1];
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index e94a373..22a224e 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -104,7 +104,8 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 		if (!err)
 			*qpn = out_param;
 		return err;
-	}
+	} else
+		mac |= (u64) (dev->caps.function) << 48;
 
 	mlx4_dbg(dev, "Registering MAC: 0x%llx\n", (unsigned long long) mac);
 	mutex_lock(&table->mutex);
@@ -115,7 +116,7 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 		}
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
-			/* MAC already registered, Must not have duplicates */
+			/* MAC + PF already registered, Must not have duplicates */
 			err = -EEXIST;
 			goto out;
 		}
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 9526dfd..0b68447 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -57,6 +57,7 @@ enum {
 	MLX4_CMD_QUERY_PORT	 = 0x43,
 	MLX4_CMD_SENSE_PORT	 = 0x4d,
 	MLX4_CMD_SET_PORT	 = 0xc,
+	MLX4_CMD_QUERY_FUNC	 = 0x56,
 	MLX4_CMD_ACCESS_DDR	 = 0x2e,
 	MLX4_CMD_MAP_ICM	 = 0xffa,
 	MLX4_CMD_UNMAP_ICM	 = 0xff9,
-- 
1.6.1.3


