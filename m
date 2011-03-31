From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4: Fixing use after free
Date: Thu, 31 Mar 2011 11:28:52 +0200
Message-ID: <4D944954.9000701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<error27@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53776 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933184Ab1CaJ24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 05:28:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In case of allocation failure, tried to use the promiscuous QP
entry that was previously freed.
Now freeing this entry only in case we will not put it back to the list
of promiscuous entries.

Reported-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mcg.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index e71372a..37150b2 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -469,7 +469,6 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 vep_num, u8 port,
 
 	/*remove from list of promisc qps */
 	list_del(&pqp->list);
-	kfree(pqp);
 
 	/* set the default entry not to include the removed one */
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -528,6 +527,8 @@ out_mailbox:
 out_list:
 	if (back_to_list)
 		list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
+	else
+		kfree(pqp);
 out_mutex:
 	mutex_unlock(&priv->mcg_table.mutex);
 	return err;
-- 
1.6.0.2



