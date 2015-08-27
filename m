From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next 1/2] net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX
Date: Thu, 27 Aug 2015 14:43:25 -0500
Message-ID: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Matan Barak <matanb@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:37109 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbH0TsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 15:48:12 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Thu, 27 Aug 2015 16:48:09 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id BA4C13520092
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:47:00 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7RJkRx662390308
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:46:28 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7RJlwVt008626
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:47:58 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

We currently manage IRQs in pool_bm which is a bit field
of MAX_MSIX bits. Thus, allocating more than MAX_MSIX
interrupts can't be managed in pool_bm.
Fixing this by capping number of requested MSIXs to
MAX_MSIX.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 121c579..006757f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2669,9 +2669,14 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 
 	if (msi_x) {
 		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
+		bool shared_ports = false;
 
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
 			     nreq);
+		if (nreq > MAX_MSIX) {
+			nreq = MAX_MSIX;
+			shared_ports = true;
+		}
 
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
@@ -2694,6 +2699,9 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 		bitmap_zero(priv->eq_table.eq[MLX4_EQ_ASYNC].actv_ports.ports,
 			    dev->caps.num_ports);
 
+		if (MLX4_IS_LEGACY_EQ_MODE(dev->caps))
+			shared_ports = true;
+
 		for (i = 0; i < dev->caps.num_comp_vectors + 1; i++) {
 			if (i == MLX4_EQ_ASYNC)
 				continue;
@@ -2701,7 +2709,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			priv->eq_table.eq[i].irq =
 				entries[i + 1 - !!(i > MLX4_EQ_ASYNC)].vector;
 
-			if (MLX4_IS_LEGACY_EQ_MODE(dev->caps)) {
+			if (shared_ports) {
 				bitmap_fill(priv->eq_table.eq[i].actv_ports.ports,
 					    dev->caps.num_ports);
 				/* We don't set affinity hint when there
-- 
1.8.3.1
