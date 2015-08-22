From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 12/14] RDS: make sure rds_send_drop_to properly takes the m_rs_lock
Date: Sat, 22 Aug 2015 15:45:33 -0700
Message-ID: <1440283535-4800-13-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rds_send_drop_to() is used during socket tear down to find all the
messages on the socket and flush them .  It can race with the
acking code unless it takes the m_rs_lock on each and every message.

This plugs a hole where we didn't take m_rs_lock on any message that
didn't have the RDS_MSG_ON_CONN set.  Taking m_rs_lock avoids
double frees and other memory corruptions as the ack code trusts
the message m_rs pointer on a socket that had actually been freed.

We must take m_rs_lock to access m_rs.  Because of lock nesting and
rs access, we also need to acquire rs_lock.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 96ae38d..b0fe412 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -778,8 +778,22 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 	while (!list_empty(&list)) {
 		rm = list_entry(list.next, struct rds_message, m_sock_item);
 		list_del_init(&rm->m_sock_item);
-
 		rds_message_wait(rm);
+
+		/* just in case the code above skipped this message
+		 * because RDS_MSG_ON_CONN wasn't set, run it again here
+		 * taking m_rs_lock is the only thing that keeps us
+		 * from racing with ack processing.
+		 */
+		spin_lock_irqsave(&rm->m_rs_lock, flags);
+
+		spin_lock(&rs->rs_lock);
+		__rds_send_complete(rs, rm, RDS_RDMA_CANCELED);
+		spin_unlock(&rs->rs_lock);
+
+		rm->m_rs = NULL;
+		spin_unlock_irqrestore(&rm->m_rs_lock, flags);
+
 		rds_message_put(rm);
 	}
 }
-- 
1.9.1
