From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH for-net 2/2] net/mlx4_core: Call synchronize_irq() before freeing EQ buffer
Date: Thu, 23 Oct 2014 15:57:27 +0300
Message-ID: <1414069047-30865-3-git-send-email-eli@mellanox.com>
References: <1414069047-30865-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39911 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbaJWM5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 08:57:40 -0400
Received: by mail-wg0-f43.google.com with SMTP id m15so1020115wgh.26
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 05:57:38 -0700 (PDT)
In-Reply-To: <1414069047-30865-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After moving the EQ ownership to software effectively destroying it, call
synchronize_irq() to ensure that any handler routines running on other CPU
cores finish execution. Only then free the EQ buffer.
The same thing is done when we destroy a CQ which is one of the sources
generating interrupts. In the case of CQ we want to avoid completion handlers
on a CQ that was destroyed. In the case we do the same to avoid receiving
asynchronous events after the EQ has been destroyed and its buffers freed.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index a49c9d11d8a5..49290a405903 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1026,6 +1026,7 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 				pr_cont("\n");
 		}
 	}
+	synchronize_irq(eq->irq);
 
 	mlx4_mtt_cleanup(dev, &eq->mtt);
 	for (i = 0; i < npages; ++i)
-- 
2.1.2
