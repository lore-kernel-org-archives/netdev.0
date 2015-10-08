From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/5] net/mlx4: Avoid going into legacy completion mode when unnecessary
Date: Thu,  8 Oct 2015 15:26:16 +0300
Message-ID: <1444307179-16105-3-git-send-email-ogerlitz@mellanox.com>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57450 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754233AbbJHM0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:26:49 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If we get MAX_MSIX interrupts we can have each receive ring
to get their own msix interrupt line. As such, it's wrong to
go into legacy mode on that case, avoid that.

Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
Acked-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 006757f..cc3a989 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2669,14 +2669,11 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 
 	if (msi_x) {
 		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
-		bool shared_ports = false;
 
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
 			     nreq);
-		if (nreq > MAX_MSIX) {
+		if (nreq > MAX_MSIX)
 			nreq = MAX_MSIX;
-			shared_ports = true;
-		}
 
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
@@ -2699,9 +2696,6 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 		bitmap_zero(priv->eq_table.eq[MLX4_EQ_ASYNC].actv_ports.ports,
 			    dev->caps.num_ports);
 
-		if (MLX4_IS_LEGACY_EQ_MODE(dev->caps))
-			shared_ports = true;
-
 		for (i = 0; i < dev->caps.num_comp_vectors + 1; i++) {
 			if (i == MLX4_EQ_ASYNC)
 				continue;
@@ -2709,7 +2703,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			priv->eq_table.eq[i].irq =
 				entries[i + 1 - !!(i > MLX4_EQ_ASYNC)].vector;
 
-			if (shared_ports) {
+			if (MLX4_IS_LEGACY_EQ_MODE(dev->caps)) {
 				bitmap_fill(priv->eq_table.eq[i].actv_ports.ports,
 					    dev->caps.num_ports);
 				/* We don't set affinity hint when there
-- 
2.3.7
