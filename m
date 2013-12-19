From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 10/10] net/mlx4_core: Check port number for validity before accessing data
Date: Thu, 19 Dec 2013 21:20:18 +0200
Message-ID: <1387480818-3932-11-git-send-email-amirv@mellanox.com>
References: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60359 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755669Ab3LSTUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 14:20:42 -0500
In-Reply-To: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Need to validate port number at mlx4_promisc_qp() before use.
Since port number is extracted from gid, as a cooked or corrupted gid
could lead to a crash.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 4059405..7c83e6c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -125,9 +125,14 @@ static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 port,
 					      enum mlx4_steer_type steer,
 					      u32 qpn)
 {
-	struct mlx4_steer *s_steer = &mlx4_priv(dev)->steer[port - 1];
+	struct mlx4_steer *s_steer;
 	struct mlx4_promisc_qp *pqp;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return NULL;
+
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
+
 	list_for_each_entry(pqp, &s_steer->promisc_qps[steer], list) {
 		if (pqp->qpn == qpn)
 			return pqp;
@@ -154,6 +159,9 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 	u32 prot;
 	int err;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return -EINVAL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 	new_entry = kzalloc(sizeof *new_entry, GFP_KERNEL);
 	if (!new_entry)
@@ -238,6 +246,9 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 	struct mlx4_promisc_qp *pqp;
 	struct mlx4_promisc_qp *dqp;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return -EINVAL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	pqp = get_promisc_qp(dev, port, steer, qpn);
@@ -283,6 +294,9 @@ static bool check_duplicate_entry(struct mlx4_dev *dev, u8 port,
 	struct mlx4_steer_index *tmp_entry, *entry = NULL;
 	struct mlx4_promisc_qp *dqp, *tmp_dqp;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return NULL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	/* if qp is not promisc, it cannot be duplicated */
@@ -324,6 +338,9 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 	bool ret = false;
 	int i;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return NULL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -378,6 +395,9 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	int err;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return -EINVAL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	mutex_lock(&priv->mcg_table.mutex);
@@ -484,6 +504,9 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	int loc, i;
 	int err;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return -EINVAL;
+
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 	mutex_lock(&priv->mcg_table.mutex);
 
@@ -910,6 +933,9 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	u8 port = gid[5];
 	u8 new_entry = 0;
 
+	if (port < 1 || port > dev->caps.num_ports)
+		return -EINVAL;
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-- 
1.8.3.4
