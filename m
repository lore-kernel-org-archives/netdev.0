From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH net-next] RDS: fix rds-ping deadlock over TCP transport
Date: Fri, 16 Oct 2015 20:26:50 -0400
Message-ID: <1445041610-30133-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org, sowmini.varadhan@oracle.com,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sowmini found hang with rds-ping while testing RDS over TCP. Its
a corner case and doesn't happen always. The issue is not reproducible
with IB transport. Its clear from below dump why we see it with RDS TCP.

 [<ffffffff8153b7e5>] do_tcp_setsockopt+0xb5/0x740
 [<ffffffff8153bec4>] tcp_setsockopt+0x24/0x30
 [<ffffffff814d57d4>] sock_common_setsockopt+0x14/0x20
 [<ffffffffa096071d>] rds_tcp_xmit_prepare+0x5d/0x70 [rds_tcp]
 [<ffffffffa093b5f7>] rds_send_xmit+0xd7/0x740 [rds]
 [<ffffffffa093bda2>] rds_send_pong+0x142/0x180 [rds]
 [<ffffffffa0939d34>] rds_recv_incoming+0x274/0x330 [rds]
 [<ffffffff810815ae>] ? ttwu_queue+0x11e/0x130
 [<ffffffff814dcacd>] ? skb_copy_bits+0x6d/0x2c0
 [<ffffffffa0960350>] rds_tcp_data_recv+0x2f0/0x3d0 [rds_tcp]
 [<ffffffff8153d836>] tcp_read_sock+0x96/0x1c0
 [<ffffffffa0960060>] ? rds_tcp_recv_init+0x40/0x40 [rds_tcp]
 [<ffffffff814d6a90>] ? sock_def_write_space+0xa0/0xa0
 [<ffffffffa09604d1>] rds_tcp_data_ready+0xa1/0xf0 [rds_tcp]
 [<ffffffff81545249>] tcp_data_queue+0x379/0x5b0
 [<ffffffffa0960cdb>] ? rds_tcp_write_space+0xbb/0x110 [rds_tcp]
 [<ffffffff81547fd2>] tcp_rcv_established+0x2e2/0x6e0
 [<ffffffff81552602>] tcp_v4_do_rcv+0x122/0x220
 [<ffffffff81553627>] tcp_v4_rcv+0x867/0x880
 [<ffffffff8152e0b3>] ip_local_deliver_finish+0xa3/0x220

This happens because rds_send_xmit() chain wants to take
sock_lock which is already taken by tcp_v4_rcv() on its
way to rds_tcp_data_ready(). Commit db6526dcb51b ("RDS: use
rds_send_xmit() state instead of RDS_LL_SEND_FULL") which
was trying to opportunistically finish the send request
in same thread context.

But because of above recursive lock hang with RDS TCP,
the send work from rds_send_pong() needs to deferred to
worker to avoid lock up. Given RDS ping is more of connectivity
test than performance critical path, its should be ok even
for transport like IB.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index ee49c25..7a377a1 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1182,9 +1182,8 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
 	rds_stats_inc(s_send_queued);
 	rds_stats_inc(s_send_pong);
 
-	ret = rds_send_xmit(conn);
-	if (ret == -ENOMEM || ret == -EAGAIN)
-		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
+	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
+		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 	rds_message_put(rm);
 	return 0;
-- 
1.9.1
