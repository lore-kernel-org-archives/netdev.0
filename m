From: =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>
Subject: [PATCH net] rds: Make sure updates to cp_send_gen can be observed
Date: Thu, 20 Jul 2017 12:28:55 +0200
Message-ID: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>,
        =?UTF-8?q?H=C3=A5kon=20Bugge?= <haakon.bugge@oracle.com>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cp->cp_send_gen is treated as a normal variable, although it may be
used by different threads.

This is fixed by using {READ,WRITE}_ONCE when it is incremented and
READ_ONCE when it is read outside the {acquire,release}_in_xmit
protection.

Normative reference from the Linux-Kernel Memory Model:

    Loads from and stores to shared (but non-atomic) variables should
    be protected with the READ_ONCE(), WRITE_ONCE(), and
    ACCESS_ONCE().

Clause 5.1.2.4/25 in the C standard is also relevant.

Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Knut Omang <knut.omang@oracle.com>
---
 net/rds/send.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 5cc6403..fa0368c 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -170,8 +170,8 @@ int rds_send_xmit(struct rds_conn_path *cp)
 	 * The acquire_in_xmit() check above ensures that only one
 	 * caller can increment c_send_gen at any time.
 	 */
-	cp->cp_send_gen++;
-	send_gen = cp->cp_send_gen;
+	send_gen = READ_ONCE(cp->cp_send_gen) + 1;
+	WRITE_ONCE(cp->cp_send_gen, send_gen);
 
 	/*
 	 * rds_conn_shutdown() sets the conn state and then tests RDS_IN_XMIT,
@@ -431,7 +431,7 @@ int rds_send_xmit(struct rds_conn_path *cp)
 		smp_mb();
 		if ((test_bit(0, &conn->c_map_queued) ||
 		     !list_empty(&cp->cp_send_queue)) &&
-		    send_gen == cp->cp_send_gen) {
+			send_gen == READ_ONCE(cp->cp_send_gen)) {
 			rds_stats_inc(s_send_lock_queue_raced);
 			if (batch_count < send_batch_count)
 				goto restart;
-- 
2.9.3
