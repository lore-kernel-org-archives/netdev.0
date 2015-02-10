From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2] rds: rds_cong_queue_updates needs to defer the congestion
 update transmission
Date: Tue, 10 Feb 2015 13:33:37 -0500
Message-ID: <20150210183337.GX337@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sowmini.varadhan@oracle.com
To: chien.yen@oracle.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When the RDS transport is TCP, we cannot inline the call to rds_send_xmit
from rds_cong_queue_update because
(a) we are already holding the sock_lock in the recv path, and
    will deadlock when tcp_setsockopt/tcp_sendmsg try to get the sock
    lock
(b) cong_queue_update does an irqsave on the rds_cong_lock, and this
    will trigger warnings (for a good reason) from functions called
    out of sock_lock.

This patch reverts the change introduced by
2fa57129d ("RDS: Bypass workqueue when queueing cong updates").

The patch has been verified for both RDS/TCP as well as RDS/RDMA
to ensure that there are not regressions for either transport:
 - for verification of  RDS/TCP a client-server unit-test was used,
   with the server blocked in gdb and thus unable to drain its rcvbuf,
   eventually triggering a RDS congestion update.
 - for RDS/RDMA, the standard IB regression tests were used


Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
changes from v1: incorporate feedback from Chuck Lever

 net/rds/cong.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index e5b65ac..765d18f 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -221,7 +221,21 @@ void rds_cong_queue_updates(struct rds_cong_map *map)
 	list_for_each_entry(conn, &map->m_conn_list, c_map_item) {
 		if (!test_and_set_bit(0, &conn->c_map_queued)) {
 			rds_stats_inc(s_cong_update_queued);
-			rds_send_xmit(conn);
+			/* We cannot inline the call to rds_send_xmit() here
+			 * for two reasons (both pertaining to a TCP transport):
+			 * 1. When we get here from the receive path, we
+			 *    are already holding the sock_lock (held by
+			 *    tcp_v4_rcv()). So inlining calls to
+			 *    tcp_setsockopt and/or tcp_sendmsg will deadlock
+			 *    when it tries to get the sock_lock())
+			 * 2. Interrupts are masked so that we can mark the
+			 *    the port congested from both send and recv paths.
+			 *    (See comment around declaration of rdc_cong_lock).
+			 *    An attempt to get the sock_lock() here will
+			 *    therefore trigger warnings.
+			 * Defer the xmit to rds_send_worker() instead.
+			 */
+			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 		}
 	}
 
-- 
1.7.1
