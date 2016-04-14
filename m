From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/18] mlxsw: core: Introduce support for asynchronous EMAD register access
Date: Thu, 14 Apr 2016 18:19:29 +0200
Message-ID: <1460650770-19382-18-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37097 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932929AbcDNQT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:57 -0400
Received: by mail-wm0-f51.google.com with SMTP id n3so133919080wmn.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:56 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far it was possible to have one EMAD register access at a time,
locked by mutex. This patch extends this interface to allow multiple
EMAD register accesses to be in fly at once. That allows faster
processing on firmware side avoiding unused time in between EMADs.
Measured speedup is ~30% for shared occupancy snapshot operation.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 494 +++++++++++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/core.h |  13 +
 2 files changed, 334 insertions(+), 173 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index a14e422..b0a0b01 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -44,7 +44,7 @@
 #include <linux/seq_file.h>
 #include <linux/u64_stats_sync.h>
 #include <linux/netdevice.h>
-#include <linux/wait.h>
+#include <linux/completion.h>
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/types.h>
@@ -96,11 +96,9 @@ struct mlxsw_core {
 	struct list_head rx_listener_list;
 	struct list_head event_listener_list;
 	struct {
-		struct sk_buff *resp_skb;
-		u64 tid;
-		wait_queue_head_t wait;
-		bool trans_active;
-		struct mutex lock; /* One EMAD transaction at a time. */
+		atomic64_t tid;
+		struct list_head trans_list;
+		spinlock_t trans_list_lock; /* protects trans_list writes */
 		bool use_emad;
 	} emad;
 	struct mlxsw_core_pcpu_stats __percpu *pcpu_stats;
@@ -293,7 +291,7 @@ static void mlxsw_emad_pack_reg_tlv(char *reg_tlv,
 static void mlxsw_emad_pack_op_tlv(char *op_tlv,
 				   const struct mlxsw_reg_info *reg,
 				   enum mlxsw_core_reg_access_type type,
-				   struct mlxsw_core *mlxsw_core)
+				   u64 tid)
 {
 	mlxsw_emad_op_tlv_type_set(op_tlv, MLXSW_EMAD_TLV_TYPE_OP);
 	mlxsw_emad_op_tlv_len_set(op_tlv, MLXSW_EMAD_OP_TLV_LEN);
@@ -309,7 +307,7 @@ static void mlxsw_emad_pack_op_tlv(char *op_tlv,
 					     MLXSW_EMAD_OP_TLV_METHOD_WRITE);
 	mlxsw_emad_op_tlv_class_set(op_tlv,
 				    MLXSW_EMAD_OP_TLV_CLASS_REG_ACCESS);
-	mlxsw_emad_op_tlv_tid_set(op_tlv, mlxsw_core->emad.tid);
+	mlxsw_emad_op_tlv_tid_set(op_tlv, tid);
 }
 
 static int mlxsw_emad_construct_eth_hdr(struct sk_buff *skb)
@@ -331,7 +329,7 @@ static void mlxsw_emad_construct(struct sk_buff *skb,
 				 const struct mlxsw_reg_info *reg,
 				 char *payload,
 				 enum mlxsw_core_reg_access_type type,
-				 struct mlxsw_core *mlxsw_core)
+				 u64 tid)
 {
 	char *buf;
 
@@ -342,7 +340,7 @@ static void mlxsw_emad_construct(struct sk_buff *skb,
 	mlxsw_emad_pack_reg_tlv(buf, reg, payload);
 
 	buf = skb_push(skb, MLXSW_EMAD_OP_TLV_LEN * sizeof(u32));
-	mlxsw_emad_pack_op_tlv(buf, reg, type, mlxsw_core);
+	mlxsw_emad_pack_op_tlv(buf, reg, type, tid);
 
 	mlxsw_emad_construct_eth_hdr(skb);
 }
@@ -379,58 +377,16 @@ static bool mlxsw_emad_is_resp(const struct sk_buff *skb)
 	return (mlxsw_emad_op_tlv_r_get(op_tlv) == MLXSW_EMAD_OP_TLV_RESPONSE);
 }
 
-#define MLXSW_EMAD_TIMEOUT_MS 200
-
-static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
-				 struct sk_buff *skb,
-				 const struct mlxsw_tx_info *tx_info)
-{
-	int err;
-	int ret;
-
-	mlxsw_core->emad.trans_active = true;
-
-	err = mlxsw_core_skb_transmit(mlxsw_core, skb, tx_info);
-	if (err) {
-		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
-			mlxsw_core->emad.tid);
-		dev_kfree_skb(skb);
-		goto trans_inactive_out;
-	}
-
-	ret = wait_event_timeout(mlxsw_core->emad.wait,
-				 !(mlxsw_core->emad.trans_active),
-				 msecs_to_jiffies(MLXSW_EMAD_TIMEOUT_MS));
-	if (!ret) {
-		dev_warn(mlxsw_core->bus_info->dev, "EMAD timed-out (tid=%llx)\n",
-			 mlxsw_core->emad.tid);
-		err = -EIO;
-		goto trans_inactive_out;
-	}
-
-	return 0;
-
-trans_inactive_out:
-	mlxsw_core->emad.trans_active = false;
-	return err;
-}
-
-static int mlxsw_emad_process_status(struct mlxsw_core *mlxsw_core,
-				     char *op_tlv)
+static int mlxsw_emad_process_status(char *op_tlv,
+				     enum mlxsw_emad_op_tlv_status *p_status)
 {
-	enum mlxsw_emad_op_tlv_status status;
-	u64 tid;
-
-	status = mlxsw_emad_op_tlv_status_get(op_tlv);
-	tid = mlxsw_emad_op_tlv_tid_get(op_tlv);
+	*p_status = mlxsw_emad_op_tlv_status_get(op_tlv);
 
-	switch (status) {
+	switch (*p_status) {
 	case MLXSW_EMAD_OP_TLV_STATUS_SUCCESS:
 		return 0;
 	case MLXSW_EMAD_OP_TLV_STATUS_BUSY:
 	case MLXSW_EMAD_OP_TLV_STATUS_MESSAGE_RECEIPT_ACK:
-		dev_warn(mlxsw_core->bus_info->dev, "Reg access status again (tid=%llx,status=%x(%s))\n",
-			 tid, status, mlxsw_emad_op_tlv_status_str(status));
 		return -EAGAIN;
 	case MLXSW_EMAD_OP_TLV_STATUS_VERSION_NOT_SUPPORTED:
 	case MLXSW_EMAD_OP_TLV_STATUS_UNKNOWN_TLV:
@@ -441,70 +397,150 @@ static int mlxsw_emad_process_status(struct mlxsw_core *mlxsw_core,
 	case MLXSW_EMAD_OP_TLV_STATUS_RESOURCE_NOT_AVAILABLE:
 	case MLXSW_EMAD_OP_TLV_STATUS_INTERNAL_ERROR:
 	default:
-		dev_err(mlxsw_core->bus_info->dev, "Reg access status failed (tid=%llx,status=%x(%s))\n",
-			tid, status, mlxsw_emad_op_tlv_status_str(status));
 		return -EIO;
 	}
 }
 
-static int mlxsw_emad_process_status_skb(struct mlxsw_core *mlxsw_core,
-					 struct sk_buff *skb)
+static int
+mlxsw_emad_process_status_skb(struct sk_buff *skb,
+			      enum mlxsw_emad_op_tlv_status *p_status)
 {
-	return mlxsw_emad_process_status(mlxsw_core, mlxsw_emad_op_tlv(skb));
+	return mlxsw_emad_process_status(mlxsw_emad_op_tlv(skb), p_status);
+}
+
+struct mlxsw_reg_trans {
+	struct list_head list;
+	struct list_head bulk_list;
+	struct mlxsw_core *core;
+	struct sk_buff *tx_skb;
+	struct mlxsw_tx_info tx_info;
+	struct delayed_work timeout_dw;
+	unsigned int retries;
+	u64 tid;
+	struct completion completion;
+	atomic_t active;
+	mlxsw_reg_trans_cb_t *cb;
+	unsigned long cb_priv;
+	const struct mlxsw_reg_info *reg;
+	enum mlxsw_core_reg_access_type type;
+	int err;
+	enum mlxsw_emad_op_tlv_status emad_status;
+	struct rcu_head rcu;
+};
+
+#define MLXSW_EMAD_TIMEOUT_MS 200
+
+static void mlxsw_emad_trans_timeout_schedule(struct mlxsw_reg_trans *trans)
+{
+	unsigned long timeout = msecs_to_jiffies(MLXSW_EMAD_TIMEOUT_MS);
+
+	mlxsw_core_schedule_dw(&trans->timeout_dw, timeout);
 }
 
 static int mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
-			       struct sk_buff *skb,
-			       const struct mlxsw_tx_info *tx_info)
+			       struct mlxsw_reg_trans *trans)
 {
-	struct sk_buff *trans_skb;
-	int n_retry;
+	struct sk_buff *skb;
 	int err;
 
-	n_retry = 0;
-retry:
-	/* We copy the EMAD to a new skb, since we might need
-	 * to retransmit it in case of failure.
-	 */
-	trans_skb = skb_copy(skb, GFP_KERNEL);
-	if (!trans_skb) {
-		err = -ENOMEM;
-		goto out;
+	skb = skb_copy(trans->tx_skb, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	atomic_set(&trans->active, 1);
+	err = mlxsw_core_skb_transmit(mlxsw_core, skb, &trans->tx_info);
+	if (err) {
+		dev_kfree_skb(skb);
+		return err;
 	}
+	mlxsw_emad_trans_timeout_schedule(trans);
+	return 0;
+}
 
-	err = __mlxsw_emad_transmit(mlxsw_core, trans_skb, tx_info);
-	if (!err) {
-		struct sk_buff *resp_skb = mlxsw_core->emad.resp_skb;
+static void mlxsw_emad_trans_finish(struct mlxsw_reg_trans *trans, int err)
+{
+	struct mlxsw_core *mlxsw_core = trans->core;
+
+	dev_kfree_skb(trans->tx_skb);
+	spin_lock_bh(&mlxsw_core->emad.trans_list_lock);
+	list_del_rcu(&trans->list);
+	spin_unlock_bh(&mlxsw_core->emad.trans_list_lock);
+	trans->err = err;
+	complete(&trans->completion);
+}
+
+static void mlxsw_emad_transmit_retry(struct mlxsw_core *mlxsw_core,
+				      struct mlxsw_reg_trans *trans)
+{
+	int err;
 
-		err = mlxsw_emad_process_status_skb(mlxsw_core, resp_skb);
-		if (err)
-			dev_kfree_skb(resp_skb);
-		if (!err || err != -EAGAIN)
-			goto out;
+	if (trans->retries < MLXSW_EMAD_MAX_RETRY) {
+		trans->retries++;
+		err = mlxsw_emad_transmit(trans->core, trans);
+		if (err == 0)
+			return;
+	} else {
+		err = -EIO;
 	}
-	if (n_retry++ < MLXSW_EMAD_MAX_RETRY)
-		goto retry;
+	mlxsw_emad_trans_finish(trans, err);
+}
 
-out:
-	dev_kfree_skb(skb);
-	mlxsw_core->emad.tid++;
-	return err;
+static void mlxsw_emad_trans_timeout_work(struct work_struct *work)
+{
+	struct mlxsw_reg_trans *trans = container_of(work,
+						     struct mlxsw_reg_trans,
+						     timeout_dw.work);
+
+	if (!atomic_dec_and_test(&trans->active))
+		return;
+
+	mlxsw_emad_transmit_retry(trans->core, trans);
 }
 
+static void mlxsw_emad_process_response(struct mlxsw_core *mlxsw_core,
+					struct mlxsw_reg_trans *trans,
+					struct sk_buff *skb)
+{
+	int err;
+
+	if (!atomic_dec_and_test(&trans->active))
+		return;
+
+	err = mlxsw_emad_process_status_skb(skb, &trans->emad_status);
+	if (err == -EAGAIN) {
+		mlxsw_emad_transmit_retry(mlxsw_core, trans);
+	} else {
+		if (err == 0) {
+			char *op_tlv = mlxsw_emad_op_tlv(skb);
+
+			if (trans->cb)
+				trans->cb(mlxsw_core,
+					  mlxsw_emad_reg_payload(op_tlv),
+					  trans->reg->len, trans->cb_priv);
+		}
+		mlxsw_emad_trans_finish(trans, err);
+	}
+}
+
+/* called with rcu read lock held */
 static void mlxsw_emad_rx_listener_func(struct sk_buff *skb, u8 local_port,
 					void *priv)
 {
 	struct mlxsw_core *mlxsw_core = priv;
+	struct mlxsw_reg_trans *trans;
 
-	if (mlxsw_emad_is_resp(skb) &&
-	    mlxsw_core->emad.trans_active &&
-	    mlxsw_emad_get_tid(skb) == mlxsw_core->emad.tid) {
-		mlxsw_core->emad.resp_skb = skb;
-		mlxsw_core->emad.trans_active = false;
-		wake_up(&mlxsw_core->emad.wait);
-	} else {
-		dev_kfree_skb(skb);
+	if (!mlxsw_emad_is_resp(skb))
+		goto free_skb;
+
+	list_for_each_entry_rcu(trans, &mlxsw_core->emad.trans_list, list) {
+		if (mlxsw_emad_get_tid(skb) == trans->tid) {
+			mlxsw_emad_process_response(mlxsw_core, trans, skb);
+			break;
+		}
 	}
+
+free_skb:
+	dev_kfree_skb(skb);
 }
 
 static const struct mlxsw_rx_listener mlxsw_emad_rx_listener = {
@@ -531,18 +567,19 @@ static int mlxsw_emad_traps_set(struct mlxsw_core *mlxsw_core)
 
 static int mlxsw_emad_init(struct mlxsw_core *mlxsw_core)
 {
+	u64 tid;
 	int err;
 
 	/* Set the upper 32 bits of the transaction ID field to a random
 	 * number. This allows us to discard EMADs addressed to other
 	 * devices.
 	 */
-	get_random_bytes(&mlxsw_core->emad.tid, 4);
-	mlxsw_core->emad.tid = mlxsw_core->emad.tid << 32;
+	get_random_bytes(&tid, 4);
+	tid <<= 32;
+	atomic64_set(&mlxsw_core->emad.tid, tid);
 
-	init_waitqueue_head(&mlxsw_core->emad.wait);
-	mlxsw_core->emad.trans_active = false;
-	mutex_init(&mlxsw_core->emad.lock);
+	INIT_LIST_HEAD(&mlxsw_core->emad.trans_list);
+	spin_lock_init(&mlxsw_core->emad.trans_list_lock);
 
 	err = mlxsw_core_rx_listener_register(mlxsw_core,
 					      &mlxsw_emad_rx_listener,
@@ -600,6 +637,59 @@ static struct sk_buff *mlxsw_emad_alloc(const struct mlxsw_core *mlxsw_core,
 	return skb;
 }
 
+static int mlxsw_emad_reg_access(struct mlxsw_core *mlxsw_core,
+				 const struct mlxsw_reg_info *reg,
+				 char *payload,
+				 enum mlxsw_core_reg_access_type type,
+				 struct mlxsw_reg_trans *trans,
+				 struct list_head *bulk_list,
+				 mlxsw_reg_trans_cb_t *cb,
+				 unsigned long cb_priv, u64 tid)
+{
+	struct sk_buff *skb;
+	int err;
+
+	dev_dbg(mlxsw_core->bus_info->dev, "EMAD reg access (tid=%llx,reg_id=%x(%s),type=%s)\n",
+		trans->tid, reg->id, mlxsw_reg_id_str(reg->id),
+		mlxsw_core_reg_access_type_str(type));
+
+	skb = mlxsw_emad_alloc(mlxsw_core, reg->len);
+	if (!skb)
+		return -ENOMEM;
+
+	list_add_tail(&trans->bulk_list, bulk_list);
+	trans->core = mlxsw_core;
+	trans->tx_skb = skb;
+	trans->tx_info.local_port = MLXSW_PORT_CPU_PORT;
+	trans->tx_info.is_emad = true;
+	INIT_DELAYED_WORK(&trans->timeout_dw, mlxsw_emad_trans_timeout_work);
+	trans->tid = tid;
+	init_completion(&trans->completion);
+	trans->cb = cb;
+	trans->cb_priv = cb_priv;
+	trans->reg = reg;
+	trans->type = type;
+
+	mlxsw_emad_construct(skb, reg, payload, type, trans->tid);
+	mlxsw_core->driver->txhdr_construct(skb, &trans->tx_info);
+
+	spin_lock_bh(&mlxsw_core->emad.trans_list_lock);
+	list_add_tail_rcu(&trans->list, &mlxsw_core->emad.trans_list);
+	spin_unlock_bh(&mlxsw_core->emad.trans_list_lock);
+	err = mlxsw_emad_transmit(mlxsw_core, trans);
+	if (err)
+		goto err_out;
+	return 0;
+
+err_out:
+	spin_lock_bh(&mlxsw_core->emad.trans_list_lock);
+	list_del_rcu(&trans->list);
+	spin_unlock_bh(&mlxsw_core->emad.trans_list_lock);
+	list_del(&trans->bulk_list);
+	dev_kfree_skb(trans->tx_skb);
+	return err;
+}
+
 /*****************
  * Core functions
  *****************/
@@ -689,24 +779,6 @@ static const struct file_operations mlxsw_core_rx_stats_dbg_ops = {
 	.llseek = seq_lseek
 };
 
-static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
-				    const char *buf, size_t size)
-{
-	__be32 *m = (__be32 *) buf;
-	int i;
-	int count = size / sizeof(__be32);
-
-	for (i = count - 1; i >= 0; i--)
-		if (m[i])
-			break;
-	i++;
-	count = i ? i : 1;
-	for (i = 0; i < count; i += 4)
-		dev_dbg(mlxsw_core->bus_info->dev, "%04x - %08x %08x %08x %08x\n",
-			i * 4, be32_to_cpu(m[i]), be32_to_cpu(m[i + 1]),
-			be32_to_cpu(m[i + 2]), be32_to_cpu(m[i + 3]));
-}
-
 int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver)
 {
 	spin_lock(&mlxsw_core_driver_list_lock);
@@ -1264,56 +1336,112 @@ void mlxsw_core_event_listener_unregister(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_event_listener_unregister);
 
+static u64 mlxsw_core_tid_get(struct mlxsw_core *mlxsw_core)
+{
+	return atomic64_inc_return(&mlxsw_core->emad.tid);
+}
+
 static int mlxsw_core_reg_access_emad(struct mlxsw_core *mlxsw_core,
 				      const struct mlxsw_reg_info *reg,
 				      char *payload,
-				      enum mlxsw_core_reg_access_type type)
+				      enum mlxsw_core_reg_access_type type,
+				      struct list_head *bulk_list,
+				      mlxsw_reg_trans_cb_t *cb,
+				      unsigned long cb_priv)
 {
+	u64 tid = mlxsw_core_tid_get(mlxsw_core);
+	struct mlxsw_reg_trans *trans;
 	int err;
-	char *op_tlv;
-	struct sk_buff *skb;
-	struct mlxsw_tx_info tx_info = {
-		.local_port = MLXSW_PORT_CPU_PORT,
-		.is_emad = true,
-	};
 
-	skb = mlxsw_emad_alloc(mlxsw_core, reg->len);
-	if (!skb)
+	trans = kzalloc(sizeof(*trans), GFP_KERNEL);
+	if (!trans)
 		return -ENOMEM;
 
-	mlxsw_emad_construct(skb, reg, payload, type, mlxsw_core);
-	mlxsw_core->driver->txhdr_construct(skb, &tx_info);
+	err = mlxsw_emad_reg_access(mlxsw_core, reg, payload, type, trans,
+				    bulk_list, cb, cb_priv, tid);
+	if (err) {
+		kfree(trans);
+		return err;
+	}
+	return 0;
+}
 
-	dev_dbg(mlxsw_core->bus_info->dev, "EMAD send (tid=%llx)\n",
-		mlxsw_core->emad.tid);
-	mlxsw_core_buf_dump_dbg(mlxsw_core, skb->data, skb->len);
+int mlxsw_reg_trans_query(struct mlxsw_core *mlxsw_core,
+			  const struct mlxsw_reg_info *reg, char *payload,
+			  struct list_head *bulk_list,
+			  mlxsw_reg_trans_cb_t *cb, unsigned long cb_priv)
+{
+	return mlxsw_core_reg_access_emad(mlxsw_core, reg, payload,
+					  MLXSW_CORE_REG_ACCESS_TYPE_QUERY,
+					  bulk_list, cb, cb_priv);
+}
+EXPORT_SYMBOL(mlxsw_reg_trans_query);
 
-	err = mlxsw_emad_transmit(mlxsw_core, skb, &tx_info);
-	if (!err) {
-		op_tlv = mlxsw_emad_op_tlv(mlxsw_core->emad.resp_skb);
-		memcpy(payload, mlxsw_emad_reg_payload(op_tlv),
-		       reg->len);
+int mlxsw_reg_trans_write(struct mlxsw_core *mlxsw_core,
+			  const struct mlxsw_reg_info *reg, char *payload,
+			  struct list_head *bulk_list,
+			  mlxsw_reg_trans_cb_t *cb, unsigned long cb_priv)
+{
+	return mlxsw_core_reg_access_emad(mlxsw_core, reg, payload,
+					  MLXSW_CORE_REG_ACCESS_TYPE_WRITE,
+					  bulk_list, cb, cb_priv);
+}
+EXPORT_SYMBOL(mlxsw_reg_trans_write);
 
-		dev_dbg(mlxsw_core->bus_info->dev, "EMAD recv (tid=%llx)\n",
-			mlxsw_core->emad.tid - 1);
-		mlxsw_core_buf_dump_dbg(mlxsw_core,
-					mlxsw_core->emad.resp_skb->data,
-					mlxsw_core->emad.resp_skb->len);
+static int mlxsw_reg_trans_wait(struct mlxsw_reg_trans *trans)
+{
+	struct mlxsw_core *mlxsw_core = trans->core;
+	int err;
 
-		dev_kfree_skb(mlxsw_core->emad.resp_skb);
-	}
+	wait_for_completion(&trans->completion);
+	cancel_delayed_work_sync(&trans->timeout_dw);
+	err = trans->err;
 
+	if (trans->retries)
+		dev_warn(mlxsw_core->bus_info->dev, "EMAD retries (%d/%d) (tid=%llx)\n",
+			 trans->retries, MLXSW_EMAD_MAX_RETRY, trans->tid);
+	if (err)
+		dev_err(mlxsw_core->bus_info->dev, "EMAD reg access failed (tid=%llx,reg_id=%x(%s),type=%s,status=%x(%s))\n",
+			trans->tid, trans->reg->id,
+			mlxsw_reg_id_str(trans->reg->id),
+			mlxsw_core_reg_access_type_str(trans->type),
+			trans->emad_status,
+			mlxsw_emad_op_tlv_status_str(trans->emad_status));
+
+	list_del(&trans->bulk_list);
+	kfree_rcu(trans, rcu);
 	return err;
 }
 
+int mlxsw_reg_trans_bulk_wait(struct list_head *bulk_list)
+{
+	struct mlxsw_reg_trans *trans;
+	struct mlxsw_reg_trans *tmp;
+	int sum_err = 0;
+	int err;
+
+	list_for_each_entry_safe(trans, tmp, bulk_list, bulk_list) {
+		err = mlxsw_reg_trans_wait(trans);
+		if (err && sum_err == 0)
+			sum_err = err; /* first error to be returned */
+	}
+	return sum_err;
+}
+EXPORT_SYMBOL(mlxsw_reg_trans_bulk_wait);
+
 static int mlxsw_core_reg_access_cmd(struct mlxsw_core *mlxsw_core,
 				     const struct mlxsw_reg_info *reg,
 				     char *payload,
 				     enum mlxsw_core_reg_access_type type)
 {
+	enum mlxsw_emad_op_tlv_status status;
 	int err, n_retry;
 	char *in_mbox, *out_mbox, *tmp;
 
+	dev_dbg(mlxsw_core->bus_info->dev, "Reg cmd access (reg_id=%x(%s),type=%s)\n",
+		reg->id, mlxsw_reg_id_str(reg->id),
+		mlxsw_core_reg_access_type_str(type));
+
 	in_mbox = mlxsw_cmd_mbox_alloc();
 	if (!in_mbox)
 		return -ENOMEM;
@@ -1324,7 +1452,8 @@ static int mlxsw_core_reg_access_cmd(struct mlxsw_core *mlxsw_core,
 		goto free_in_mbox;
 	}
 
-	mlxsw_emad_pack_op_tlv(in_mbox, reg, type, mlxsw_core);
+	mlxsw_emad_pack_op_tlv(in_mbox, reg, type,
+			       mlxsw_core_tid_get(mlxsw_core));
 	tmp = in_mbox + MLXSW_EMAD_OP_TLV_LEN * sizeof(u32);
 	mlxsw_emad_pack_reg_tlv(tmp, reg, payload);
 
@@ -1332,60 +1461,61 @@ static int mlxsw_core_reg_access_cmd(struct mlxsw_core *mlxsw_core,
 retry:
 	err = mlxsw_cmd_access_reg(mlxsw_core, in_mbox, out_mbox);
 	if (!err) {
-		err = mlxsw_emad_process_status(mlxsw_core, out_mbox);
-		if (err == -EAGAIN && n_retry++ < MLXSW_EMAD_MAX_RETRY)
-			goto retry;
+		err = mlxsw_emad_process_status(out_mbox, &status);
+		if (err) {
+			if (err == -EAGAIN && n_retry++ < MLXSW_EMAD_MAX_RETRY)
+				goto retry;
+			dev_err(mlxsw_core->bus_info->dev, "Reg cmd access status failed (status=%x(%s))\n",
+				status, mlxsw_emad_op_tlv_status_str(status));
+		}
 	}
 
 	if (!err)
 		memcpy(payload, mlxsw_emad_reg_payload(out_mbox),
 		       reg->len);
 
-	mlxsw_core->emad.tid++;
 	mlxsw_cmd_mbox_free(out_mbox);
 free_in_mbox:
 	mlxsw_cmd_mbox_free(in_mbox);
+	if (err)
+		dev_err(mlxsw_core->bus_info->dev, "Reg cmd access failed (reg_id=%x(%s),type=%s)\n",
+			reg->id, mlxsw_reg_id_str(reg->id),
+			mlxsw_core_reg_access_type_str(type));
 	return err;
 }
 
+static void mlxsw_core_reg_access_cb(struct mlxsw_core *mlxsw_core,
+				     char *payload, size_t payload_len,
+				     unsigned long cb_priv)
+{
+	char *orig_payload = (char *) cb_priv;
+
+	memcpy(orig_payload, payload, payload_len);
+}
+
 static int mlxsw_core_reg_access(struct mlxsw_core *mlxsw_core,
 				 const struct mlxsw_reg_info *reg,
 				 char *payload,
 				 enum mlxsw_core_reg_access_type type)
 {
-	u64 cur_tid;
+	LIST_HEAD(bulk_list);
 	int err;
 
-	if (mutex_lock_interruptible(&mlxsw_core->emad.lock)) {
-		dev_err(mlxsw_core->bus_info->dev, "Reg access interrupted (reg_id=%x(%s),type=%s)\n",
-			reg->id, mlxsw_reg_id_str(reg->id),
-			mlxsw_core_reg_access_type_str(type));
-		return -EINTR;
-	}
-
-	cur_tid = mlxsw_core->emad.tid;
-	dev_dbg(mlxsw_core->bus_info->dev, "Reg access (tid=%llx,reg_id=%x(%s),type=%s)\n",
-		cur_tid, reg->id, mlxsw_reg_id_str(reg->id),
-		mlxsw_core_reg_access_type_str(type));
-
 	/* During initialization EMAD interface is not available to us,
 	 * so we default to command interface. We switch to EMAD interface
 	 * after setting the appropriate traps.
 	 */
 	if (!mlxsw_core->emad.use_emad)
-		err = mlxsw_core_reg_access_cmd(mlxsw_core, reg,
-						payload, type);
-	else
-		err = mlxsw_core_reg_access_emad(mlxsw_core, reg,
+		return mlxsw_core_reg_access_cmd(mlxsw_core, reg,
 						 payload, type);
 
+	err = mlxsw_core_reg_access_emad(mlxsw_core, reg,
+					 payload, type, &bulk_list,
+					 mlxsw_core_reg_access_cb,
+					 (unsigned long) payload);
 	if (err)
-		dev_err(mlxsw_core->bus_info->dev, "Reg access failed (tid=%llx,reg_id=%x(%s),type=%s)\n",
-			cur_tid, reg->id, mlxsw_reg_id_str(reg->id),
-			mlxsw_core_reg_access_type_str(type));
-
-	mutex_unlock(&mlxsw_core->emad.lock);
-	return err;
+		return err;
+	return mlxsw_reg_trans_bulk_wait(&bulk_list);
 }
 
 int mlxsw_reg_query(struct mlxsw_core *mlxsw_core,
@@ -1536,6 +1666,24 @@ void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port)
 }
 EXPORT_SYMBOL(mlxsw_core_port_fini);
 
+static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
+				    const char *buf, size_t size)
+{
+	__be32 *m = (__be32 *) buf;
+	int i;
+	int count = size / sizeof(__be32);
+
+	for (i = count - 1; i >= 0; i--)
+		if (m[i])
+			break;
+	i++;
+	count = i ? i : 1;
+	for (i = 0; i < count; i += 4)
+		dev_dbg(mlxsw_core->bus_info->dev, "%04x - %08x %08x %08x %08x\n",
+			i * 4, be32_to_cpu(m[i]), be32_to_cpu(m[i + 1]),
+			be32_to_cpu(m[i + 2]), be32_to_cpu(m[i + 3]));
+}
+
 int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
 		   u32 in_mod, bool out_mbox_direct,
 		   char *in_mbox, size_t in_mbox_size,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index b41ebf8..436bc49 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -109,6 +109,19 @@ void mlxsw_core_event_listener_unregister(struct mlxsw_core *mlxsw_core,
 					  const struct mlxsw_event_listener *el,
 					  void *priv);
 
+typedef void mlxsw_reg_trans_cb_t(struct mlxsw_core *mlxsw_core, char *payload,
+				  size_t payload_len, unsigned long cb_priv);
+
+int mlxsw_reg_trans_query(struct mlxsw_core *mlxsw_core,
+			  const struct mlxsw_reg_info *reg, char *payload,
+			  struct list_head *bulk_list,
+			  mlxsw_reg_trans_cb_t *cb, unsigned long cb_priv);
+int mlxsw_reg_trans_write(struct mlxsw_core *mlxsw_core,
+			  const struct mlxsw_reg_info *reg, char *payload,
+			  struct list_head *bulk_list,
+			  mlxsw_reg_trans_cb_t *cb, unsigned long cb_priv);
+int mlxsw_reg_trans_bulk_wait(struct list_head *bulk_list);
+
 int mlxsw_reg_query(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_reg_info *reg, char *payload);
 int mlxsw_reg_write(struct mlxsw_core *mlxsw_core,
-- 
2.5.5
