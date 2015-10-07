From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net] net/mlx4: Remove shared_ports variable at mlx4_enable_msi_x
Date: Wed,  7 Oct 2015 12:31:46 -0400
Message-ID: <1444235506-3099-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, matanb@mellanox.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:58786 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbbJGQb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:31:57 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Wed, 7 Oct 2015 13:31:55 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 177E71DC006A
	for <netdev@vger.kernel.org>; Wed,  7 Oct 2015 12:30:50 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t97GU9Zw48759010
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 13:30:10 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t97GVpQq023768
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 12:31:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If we get MAX_MSIX interrupts would like to have each receive ring
with his own msix interrupt line. Do not need the shared_ports
variable at mlx4_enable_msix

Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
Acked-by: Matan Barak <matanb@mellanox.com>

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
1.8.3.1
