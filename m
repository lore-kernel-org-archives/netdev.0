From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 8/9] mlx5: Fix sparse warnings
Date: Tue,  2 Dec 2014 12:26:18 +0200
Message-ID: <1417515979-22418-9-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland@kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:49054 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493AbaLBK0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 05:26:51 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so20415577wiw.16
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 02:26:50 -0800 (PST)
In-Reply-To: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Add required __acquire/__release statements to balance spinlock usage.
2. Change the index parameter of begin_wqe() to be unsigned to match supplied
argument type.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 0e2ef9fe0e29..1cae1c7132b4 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1011,9 +1011,14 @@ static void mlx5_ib_lock_cqs(struct mlx5_ib_cq *send_cq, struct mlx5_ib_cq *recv
 			}
 		} else {
 			spin_lock_irq(&send_cq->lock);
+			__acquire(&recv_cq->lock);
 		}
 	} else if (recv_cq) {
 		spin_lock_irq(&recv_cq->lock);
+		__acquire(&send_cq->lock);
+	} else {
+		__acquire(&send_cq->lock);
+		__acquire(&recv_cq->lock);
 	}
 }
 
@@ -1033,10 +1038,15 @@ static void mlx5_ib_unlock_cqs(struct mlx5_ib_cq *send_cq, struct mlx5_ib_cq *re
 				spin_unlock_irq(&recv_cq->lock);
 			}
 		} else {
+			__release(&recv_cq->lock);
 			spin_unlock_irq(&send_cq->lock);
 		}
 	} else if (recv_cq) {
+		__release(&send_cq->lock);
 		spin_unlock_irq(&recv_cq->lock);
+	} else {
+		__release(&recv_cq->lock);
+		__release(&send_cq->lock);
 	}
 }
 
@@ -2411,7 +2421,7 @@ static u8 get_fence(u8 fence, struct ib_send_wr *wr)
 
 static int begin_wqe(struct mlx5_ib_qp *qp, void **seg,
 		     struct mlx5_wqe_ctrl_seg **ctrl,
-		     struct ib_send_wr *wr, int *idx,
+		     struct ib_send_wr *wr, unsigned *idx,
 		     int *size, int nreq)
 {
 	int err = 0;
@@ -2737,6 +2747,8 @@ out:
 
 		if (bf->need_lock)
 			spin_lock(&bf->lock);
+		else
+			__acquire(&bf->lock);
 
 		/* TBD enable WC */
 		if (0 && nreq == 1 && bf->uuarn && inl && size > 1 && size <= bf->buf_size / 16) {
@@ -2753,6 +2765,8 @@ out:
 		bf->offset ^= bf->buf_size;
 		if (bf->need_lock)
 			spin_unlock(&bf->lock);
+		else
+			__release(&bf->lock);
 	}
 
 	spin_unlock_irqrestore(&qp->sq.lock, flags);
-- 
2.1.3
