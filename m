From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: mlx5: fix sizeof usage in health_care's reg_handler
Date: Fri,  2 Aug 2013 12:16:17 +0200
Message-ID: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928Ab3HBKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 06:16:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mlx5's function health_care() the callback handler reg_handler() is
being called that checks the devices registers like:

  reg_handler(dev->pdev, health->health, sizeof(health->health));

health->health is a pointer to the member "struct health_buffer __iomem
*health" of mlx5_core_health, where health buffer itself looks like:

  struct health_buffer {
        __be32          assert_var[5];
        __be32          rsvd0[3];
        __be32          assert_exit_ptr;
        __be32          assert_callra;
        __be32          rsvd1[2];
        ...
        __be16          ext_sync;
  };

Therefore, I strongly assume sizeof(*health->health) is being meant
to be passed as an argument. Interestingly, there are actually no
in-tree users of mlx5_[un]register_health_report_handler(), but some
debugging modules might want to know the correct size instead.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 748f10a..3592e43 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -101,7 +101,7 @@ static void health_care(struct work_struct *work)
 		spin_lock_irq(&health_lock);
 		if (reg_handler)
 			reg_handler(dev->pdev, health->health,
-				    sizeof(health->health));
+				    sizeof(*health->health));
 
 		list_del_init(&health->list);
 		spin_unlock_irq(&health_lock);
-- 
1.7.11.7
