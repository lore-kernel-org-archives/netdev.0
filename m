From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 09/14] RDS: Make sure we do a signaled send for large-send
Date: Sat, 22 Aug 2015 15:45:30 -0700
Message-ID: <1440283535-4800-10-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WR(Work Requests )always generate a WC(Work Completion) with
signaled send. Default RDS ib code is setup for un-signaled
completion. Since RDS connction is persistent, we can end up
sending the data even after large-send when the remote end is
not active(for any reason).

By doing  a signaled send at least once per large-send,
we can at least detect the problem in work completion
handler there by avoiding sending more data to
inactive remote.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_send.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 5d0a704..c576ebe 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -709,6 +709,11 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	if (scat == &rm->data.op_sg[rm->data.op_count]) {
 		prev->s_op = ic->i_data_op;
 		prev->s_wr.send_flags |= IB_SEND_SOLICITED;
+		if (!(prev->s_wr.send_flags & IB_SEND_SIGNALED)) {
+			ic->i_unsignaled_wrs = rds_ib_sysctl_max_unsig_wrs;
+			prev->s_wr.send_flags |= IB_SEND_SIGNALED;
+			nr_sig++;
+		}
 		ic->i_data_op = NULL;
 	}
 
-- 
1.9.1
