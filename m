From: =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>
Subject: [PATCH] rds: Fix inaccurate accounting of unsignaled wrs
Date: Tue, 24 Oct 2017 16:16:28 +0200
Message-ID: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The number of unsignaled work-requests posted to the IB send queue is
tracked by a counter in the rds_ib_connection struct. When it reaches
zero, or the caller explicitly asks for it, the send-signaled bit is
set in send_flags and the counter is reset. This is performed by the
rds_ib_set_wr_signal_state() function.

However, this function is not always used which yields inaccurate
accounting. This commit fixes this, re-factors a code bloat related to
the matter, and makes the actual parameter type to the function
consistent.

Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
---
 net/rds/ib_send.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 6ab39db..d07ecb0 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -661,13 +661,15 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 			}
 		}
 
-		rds_ib_set_wr_signal_state(ic, send, 0);
+		rds_ib_set_wr_signal_state(ic, send, false);
 
 		/*
 		 * Always signal the last one if we're stopping due to flow control.
 		 */
-		if (ic->i_flowctl && flow_controlled && i == (work_alloc-1))
-			send->s_wr.send_flags |= IB_SEND_SIGNALED | IB_SEND_SOLICITED;
+		if (ic->i_flowctl && flow_controlled && i == (work_alloc - 1)) {
+			rds_ib_set_wr_signal_state(ic, send, true);
+			send->s_wr.send_flags |= IB_SEND_SOLICITED;
+		}
 
 		if (send->s_wr.send_flags & IB_SEND_SIGNALED)
 			nr_sig++;
@@ -705,11 +707,8 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	if (scat == &rm->data.op_sg[rm->data.op_count]) {
 		prev->s_op = ic->i_data_op;
 		prev->s_wr.send_flags |= IB_SEND_SOLICITED;
-		if (!(prev->s_wr.send_flags & IB_SEND_SIGNALED)) {
-			ic->i_unsignaled_wrs = rds_ib_sysctl_max_unsig_wrs;
-			prev->s_wr.send_flags |= IB_SEND_SIGNALED;
-			nr_sig++;
-		}
+		if (!(prev->s_wr.send_flags & IB_SEND_SIGNALED))
+			nr_sig += rds_ib_set_wr_signal_state(ic, prev, true);
 		ic->i_data_op = NULL;
 	}
 
-- 
1.8.3.1
