From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 08/14] RDS: Mark message mapped before transmit
Date: Sat, 22 Aug 2015 15:45:29 -0700
Message-ID: <1440283535-4800-9-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rds_send_xmit() marks the rds message map flag after
xmit_[rdma/atomic]() which is clearly wrong.  We need
to maintain the ownership between transport and rds.

Also take care of error path.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index dbdf907..96ae38d 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -282,26 +282,34 @@ restart:
 		/* The transport either sends the whole rdma or none of it */
 		if (rm->rdma.op_active && !conn->c_xmit_rdma_sent) {
 			rm->m_final_op = &rm->rdma;
+			/* The transport owns the mapped memory for now.
+			 * You can't unmap it while it's on the send queue
+			 */
+			set_bit(RDS_MSG_MAPPED, &rm->m_flags);
 			ret = conn->c_trans->xmit_rdma(conn, &rm->rdma);
-			if (ret)
+			if (ret) {
+				clear_bit(RDS_MSG_MAPPED, &rm->m_flags);
+				wake_up_interruptible(&rm->m_flush_wait);
 				break;
+			}
 			conn->c_xmit_rdma_sent = 1;
 
-			/* The transport owns the mapped memory for now.
-			 * You can't unmap it while it's on the send queue */
-			set_bit(RDS_MSG_MAPPED, &rm->m_flags);
 		}
 
 		if (rm->atomic.op_active && !conn->c_xmit_atomic_sent) {
 			rm->m_final_op = &rm->atomic;
+			/* The transport owns the mapped memory for now.
+			 * You can't unmap it while it's on the send queue
+			 */
+			set_bit(RDS_MSG_MAPPED, &rm->m_flags);
 			ret = conn->c_trans->xmit_atomic(conn, &rm->atomic);
-			if (ret)
+			if (ret) {
+				clear_bit(RDS_MSG_MAPPED, &rm->m_flags);
+				wake_up_interruptible(&rm->m_flush_wait);
 				break;
+			}
 			conn->c_xmit_atomic_sent = 1;
 
-			/* The transport owns the mapped memory for now.
-			 * You can't unmap it while it's on the send queue */
-			set_bit(RDS_MSG_MAPPED, &rm->m_flags);
 		}
 
 		/*
-- 
1.9.1
