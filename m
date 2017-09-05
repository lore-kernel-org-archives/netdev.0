From: =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>
Subject: [PATCH net] rds: Fix non-atomic operation on shared flag variable
Date: Tue,  5 Sep 2017 17:42:01 +0200
Message-ID: <20170905154201.30198-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        knut.omang@oracle.com, wei.lin.guay@oracle.com
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bits in m_flags in struct rds_message are used for a plurality of
reasons, and from different contexts. To avoid any missing updates to
m_flags, use the atomic set_bit() instead of the non-atomic equivalent.

Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Knut Omang <knut.omang@oracle.com>
Reviewed-by: Wei Lin Guay <wei.lin.guay@oracle.com>
---
 net/rds/send.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 41b9f0f..058a407 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -273,7 +273,7 @@ int rds_send_xmit(struct rds_conn_path *cp)
 			len = ntohl(rm->m_inc.i_hdr.h_len);
 			if (cp->cp_unacked_packets == 0 ||
 			    cp->cp_unacked_bytes < len) {
-				__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
+				set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
 
 				cp->cp_unacked_packets =
 					rds_sysctl_max_unacked_packets;
@@ -829,7 +829,7 @@ static int rds_send_queue_rm(struct rds_sock *rs, struct rds_connection *conn,
 		 * throughput hits a certain threshold.
 		 */
 		if (rs->rs_snd_bytes >= rds_sk_sndbuf(rs) / 2)
-			__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
+			set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
 
 		list_add_tail(&rm->m_sock_item, &rs->rs_send_queue);
 		set_bit(RDS_MSG_ON_SOCK, &rm->m_flags);
-- 
2.9.3
