From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 3/5] net/mlx4_core: Looking for promiscuous entries on the correct port
Date: Thu,  6 Sep 2012 11:50:50 +0300
Message-ID: <1346921452-2035-4-git-send-email-yevgenyp@mellanox.com>
References: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, Aviad Yehezkel <aviadye@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:43502 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754466Ab2IFIvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:51:23 -0400
In-Reply-To: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviad Yehezkel <aviadye@mellanox.com>

The search for promisc entries was always done on the first port,
While the addition is done on the correct port.
This lead to resource leackage of promisc entries on the second
port and brought to a state where we could no longer enter to
promiscuous mode after enough iterations of "ifconfig promisc"
on the second port.
Fix that by using the correct port when searching.

Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 2673f3b..e151c21 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -137,11 +137,11 @@ static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 	return err;
 }
 
-static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 pf_num,
+static struct mlx4_promisc_qp *get_promisc_qp(struct mlx4_dev *dev, u8 port,
 					      enum mlx4_steer_type steer,
 					      u32 qpn)
 {
-	struct mlx4_steer *s_steer = &mlx4_priv(dev)->steer[pf_num];
+	struct mlx4_steer *s_steer = &mlx4_priv(dev)->steer[port - 1];
 	struct mlx4_promisc_qp *pqp;
 
 	list_for_each_entry(pqp, &s_steer->promisc_qps[steer], list) {
@@ -182,7 +182,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 	/* If the given qpn is also a promisc qp,
 	 * it should be inserted to duplicates list
 	 */
-	pqp = get_promisc_qp(dev, 0, steer, qpn);
+	pqp = get_promisc_qp(dev, port, steer, qpn);
 	if (pqp) {
 		dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
 		if (!dqp) {
@@ -256,7 +256,7 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
-	pqp = get_promisc_qp(dev, 0, steer, qpn);
+	pqp = get_promisc_qp(dev, port, steer, qpn);
 	if (!pqp)
 		return 0; /* nothing to do */
 
@@ -302,7 +302,7 @@ static bool check_duplicate_entry(struct mlx4_dev *dev, u8 port,
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	/* if qp is not promisc, it cannot be duplicated */
-	if (!get_promisc_qp(dev, 0, steer, qpn))
+	if (!get_promisc_qp(dev, port, steer, qpn))
 		return false;
 
 	/* The qp is promisc qp so it is a duplicate on this index
@@ -352,7 +352,7 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
 	for (i = 0;  i < members_count; i++) {
 		qpn = be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK;
-		if (!get_promisc_qp(dev, 0, steer, qpn) && qpn != tqpn) {
+		if (!get_promisc_qp(dev, port, steer, qpn) && qpn != tqpn) {
 			/* the qp is not promisc, the entry can't be removed */
 			goto out;
 		}
@@ -398,7 +398,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	if (get_promisc_qp(dev, 0, steer, qpn)) {
+	if (get_promisc_qp(dev, port, steer, qpn)) {
 		err = 0;  /* Noting to do, already exists */
 		goto out_mutex;
 	}
@@ -503,7 +503,7 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	s_steer = &mlx4_priv(dev)->steer[port - 1];
 	mutex_lock(&priv->mcg_table.mutex);
 
-	pqp = get_promisc_qp(dev, 0, steer, qpn);
+	pqp = get_promisc_qp(dev, port, steer, qpn);
 	if (unlikely(!pqp)) {
 		mlx4_warn(dev, "QP %x is not promiscuous QP\n", qpn);
 		/* nothing to do */
-- 
1.7.7
