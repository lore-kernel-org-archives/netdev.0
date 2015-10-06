From: clsoto@linux.vnet.ibm.com
Subject: [PATCH 1/2 net] net/mlx4_core: Test interrupts fail if not all comp vectors called request_irq
Date: Tue,  6 Oct 2015 17:27:08 -0400
Message-ID: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:58867 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbJFV1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:27:32 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 18:27:30 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 4092B1DC006F
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 17:26:25 -0400 (EDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t96LRt0E4333656
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 18:27:55 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t96LRQcs017282
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 18:27:27 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

Test interrupts fails if not all completion vectors called
request_irq. This case can happen if only mlx4_en loads and
we have more completion vectors than rx rings. 

Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
Acked-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 8e81e53..c344884 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 	 * and performing a NOP command
 	 */
 	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
+		/* Make sure request_irq was called */
+		if (!priv->eq_table.eq[i].have_irq)
+			continue;
+
 		/* Temporary use polling for command completions */
 		mlx4_cmd_use_polling(dev);
 
-- 
Can we push this patch to 4.2-stable as the bug was introduced in 4.2-rc1 
1.8.3.1
