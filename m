From: =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>
Subject: [PATCH net v2] rds: Fix incorrect statistics counting
Date: Wed,  6 Sep 2017 18:35:51 +0200
Message-ID: <20170906163551.20387-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        knut.omang@oracle.com
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34630 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753775AbdIFQgm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 12:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rds_send_xmit() there is logic to batch the sends. However, if
another thread has acquired the lock and has incremented the send_gen,
it is considered a race and we yield. The code incrementing the
s_send_lock_queue_raced statistics counter did not count this event
correctly.

This commit counts the race condition correctly.

Changes from v1:
- Removed check for *someone_on_xmit()*
- Fixed incorrect indentation

Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Knut Omang <knut.omang@oracle.com>
---
 net/rds/send.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 058a407..b52cdc8 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -428,14 +428,18 @@ int rds_send_xmit(struct rds_conn_path *cp)
 	 * some work and we will skip our goto
 	 */
 	if (ret == 0) {
+		bool raced;
+
 		smp_mb();
+		raced = send_gen != READ_ONCE(cp->cp_send_gen);
+
 		if ((test_bit(0, &conn->c_map_queued) ||
-		     !list_empty(&cp->cp_send_queue)) &&
-			send_gen == READ_ONCE(cp->cp_send_gen)) {
-			rds_stats_inc(s_send_lock_queue_raced);
+		    !list_empty(&cp->cp_send_queue)) && !raced) {
 			if (batch_count < send_batch_count)
 				goto restart;
 			queue_delayed_work(rds_wq, &cp->cp_send_w, 1);
+		} else if (raced) {
+			rds_stats_inc(s_send_lock_queue_raced);
 		}
 	}
 out:
-- 
2.9.3
