From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6] mlx4:  make functions local and remove dead
 code.
Date: Mon, 18 Oct 2010 08:30:59 -0700
Message-ID: <20101018083059.164fc8d8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41642 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388Ab0JRPbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 11:31:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a whole section of code in this driver related to vlan tables
which is not accessed from any kernel code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/mlx4/cq.c       |    3 +
 drivers/net/mlx4/en_rx.c    |    3 -
 drivers/net/mlx4/icm.c      |   28 ------------
 drivers/net/mlx4/icm.h      |    2 
 drivers/net/mlx4/mlx4_en.h  |    3 -
 drivers/net/mlx4/port.c     |   97 --------------------------------------------
 include/linux/mlx4/device.h |    3 -
 7 files changed, 6 insertions(+), 133 deletions(-)

--- a/drivers/net/mlx4/en_rx.c	2010-10-15 16:06:32.842275374 -0700
+++ b/drivers/net/mlx4/en_rx.c	2010-10-15 16:06:44.642682840 -0700
@@ -524,7 +524,8 @@ out_loopback:
 	dev_kfree_skb_any(skb);
 }
 
-int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
+static int mlx4_en_process_rx_cq(struct net_device *dev,
+				 struct mlx4_en_cq *cq, int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cqe *cqe;
--- a/drivers/net/mlx4/icm.c	2010-10-15 16:03:02.783025372 -0700
+++ b/drivers/net/mlx4/icm.c	2010-10-15 16:08:09.977629991 -0700
@@ -210,38 +210,12 @@ static int mlx4_MAP_ICM(struct mlx4_dev
 	return mlx4_map_cmd(dev, MLX4_CMD_MAP_ICM, icm, virt);
 }
 
-int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count)
+static int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count)
 {
 	return mlx4_cmd(dev, virt, page_count, 0, MLX4_CMD_UNMAP_ICM,
 			MLX4_CMD_TIME_CLASS_B);
 }
 
-int mlx4_MAP_ICM_page(struct mlx4_dev *dev, u64 dma_addr, u64 virt)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	__be64 *inbox;
-	int err;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	inbox = mailbox->buf;
-
-	inbox[0] = cpu_to_be64(virt);
-	inbox[1] = cpu_to_be64(dma_addr);
-
-	err = mlx4_cmd(dev, mailbox->dma, 1, 0, MLX4_CMD_MAP_ICM,
-		       MLX4_CMD_TIME_CLASS_B);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-
-	if (!err)
-		mlx4_dbg(dev, "Mapped page at %llx to %llx for ICM.\n",
-			  (unsigned long long) dma_addr, (unsigned long long) virt);
-
-	return err;
-}
-
 int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm)
 {
 	return mlx4_map_cmd(dev, MLX4_CMD_MAP_ICM_AUX, icm, -1);
--- a/drivers/net/mlx4/icm.h	2010-10-15 16:05:35.580298413 -0700
+++ b/drivers/net/mlx4/icm.h	2010-10-15 16:05:54.912965820 -0700
@@ -128,8 +128,6 @@ static inline unsigned long mlx4_icm_siz
 	return sg_dma_len(&iter->chunk->mem[iter->page_idx]);
 }
 
-int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count);
-int mlx4_MAP_ICM_page(struct mlx4_dev *dev, u64 dma_addr, u64 virt);
 int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev);
 
--- a/drivers/net/mlx4/port.c	2010-10-15 16:03:13.639399914 -0700
+++ b/drivers/net/mlx4/port.c	2010-10-15 16:11:09.571835685 -0700
@@ -161,103 +161,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_mac);
 
-static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
-				    __be32 *entries)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	u32 in_mod;
-	int err;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-
-	memcpy(mailbox->buf, entries, MLX4_VLAN_TABLE_SIZE);
-	in_mod = MLX4_SET_PORT_VLAN_TABLE << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-
-	return err;
-}
-
-int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
-{
-	struct mlx4_vlan_table *table = &mlx4_priv(dev)->port[port].vlan_table;
-	int i, err = 0;
-	int free = -1;
-
-	mutex_lock(&table->mutex);
-	for (i = MLX4_VLAN_REGULAR; i < MLX4_MAX_VLAN_NUM; i++) {
-		if (free < 0 && (table->refs[i] == 0)) {
-			free = i;
-			continue;
-		}
-
-		if (table->refs[i] &&
-		    (vlan == (MLX4_VLAN_MASK &
-			      be32_to_cpu(table->entries[i])))) {
-			/* Vlan already registered, increase refernce count */
-			*index = i;
-			++table->refs[i];
-			goto out;
-		}
-	}
-
-	if (table->total == table->max) {
-		/* No free vlan entries */
-		err = -ENOSPC;
-		goto out;
-	}
-
-	/* Register new MAC */
-	table->refs[free] = 1;
-	table->entries[free] = cpu_to_be32(vlan | MLX4_VLAN_VALID);
-
-	err = mlx4_set_port_vlan_table(dev, port, table->entries);
-	if (unlikely(err)) {
-		mlx4_warn(dev, "Failed adding vlan: %u\n", vlan);
-		table->refs[free] = 0;
-		table->entries[free] = 0;
-		goto out;
-	}
-
-	*index = free;
-	++table->total;
-out:
-	mutex_unlock(&table->mutex);
-	return err;
-}
-EXPORT_SYMBOL_GPL(mlx4_register_vlan);
-
-void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
-{
-	struct mlx4_vlan_table *table = &mlx4_priv(dev)->port[port].vlan_table;
-
-	if (index < MLX4_VLAN_REGULAR) {
-		mlx4_warn(dev, "Trying to free special vlan index %d\n", index);
-		return;
-	}
-
-	mutex_lock(&table->mutex);
-	if (!table->refs[index]) {
-		mlx4_warn(dev, "No vlan entry for index %d\n", index);
-		goto out;
-	}
-	if (--table->refs[index]) {
-		mlx4_dbg(dev, "Have more references for index %d,"
-			 "no need to modify vlan table\n", index);
-		goto out;
-	}
-	table->entries[index] = 0;
-	mlx4_set_port_vlan_table(dev, port, table->entries);
-	--table->total;
-out:
-	mutex_unlock(&table->mutex);
-}
-EXPORT_SYMBOL_GPL(mlx4_unregister_vlan);
-
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 {
 	struct mlx4_cmd_mailbox *inmailbox, *outmailbox;
--- a/include/linux/mlx4/device.h	2010-10-15 16:07:38.204532549 -0700
+++ b/include/linux/mlx4/device.h	2010-10-15 16:07:44.988766865 -0700
@@ -474,9 +474,6 @@ int mlx4_multicast_detach(struct mlx4_de
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index);
 
-int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
-
 int mlx4_map_phys_fmr(struct mlx4_dev *dev, struct mlx4_fmr *fmr, u64 *page_list,
 		      int npages, u64 iova, u32 *lkey, u32 *rkey);
 int mlx4_fmr_alloc(struct mlx4_dev *dev, u32 pd, u32 access, int max_pages,
--- a/drivers/net/mlx4/mlx4_en.h	2010-10-15 16:08:26.146188502 -0700
+++ b/drivers/net/mlx4/mlx4_en.h	2010-10-15 16:08:31.706380578 -0700
@@ -518,9 +518,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4
 int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv);
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_rx_ring *ring);
-int mlx4_en_process_rx_cq(struct net_device *dev,
-			  struct mlx4_en_cq *cq,
-			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 			     int is_tx, int rss, int qpn, int cqn,
--- a/drivers/net/mlx4/cq.c	2010-10-15 16:02:59.774921596 -0700
+++ b/drivers/net/mlx4/cq.c	2010-10-15 16:11:49.937227452 -0700
@@ -73,6 +73,9 @@ struct mlx4_cq_context {
 #define MLX4_CQ_STATE_ARMED_SOL		( 6 <<  8)
 #define MLX4_EQ_STATE_FIRED		(10 <<  8)
 
+static int mlx4_ib_umem_write_mtt(struct mlx4_ib_dev *dev, struct mlx4_mtt *mtt,
+				  struct ib_umem *umem);
+
 void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
 {
 	struct mlx4_cq *cq;
