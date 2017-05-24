From: gfree.wind@vip.163.com
Subject: [PATCH net-next] net: rps: Add the rfs_needed check when record flow hash
Date: Wed, 24 May 2017 15:35:59 +0800
Message-ID: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:38394 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966667AbdEXHgU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 03:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

There are two spots which invoke the sock_rps_record_flow_hash, one is
sock_rps_record_flow which has already checked rfs_needed. But the other
is tun_flow_update which doesn't check if the rfs is enabled.

Now rename the original function sock_rps_record_flow_hash to
_sock_rps_record_flow_hash, and add one helper func which checks the
rfs_needed.

The perf result of two functions is following.
When rfs is disabled, it could enhance 58% performance with checking
rfs_needed.
When rfs is enabled, the performanc is lower than current about 29%.

Because the RFS is disabled by default. I think it is useful to tun
driver.

The follow is test statistics.
test_rfs_check_rfs_key invokes _sock_rps_record_flow_hash 10000000 times.
test_rfs_no_check_rfs_key invokes sock_rps_record_flow_hash 10000000 times
too.
The test function is running with bh disabled, and the cycles is measured
by rdtscll.

[ 1716.374630] rfs_needed:1
[ 1716.388961] test_rfs_check_rfs_key costs 37119844 cycles
[ 1716.404495] test_rfs_check_rfs_key costs 40229886 cycles
[ 1716.419033] test_rfs_check_rfs_key costs 37668179 cycles
[ 1716.432618] test_rfs_no_check_rfs_key costs 35181759 cycles
[ 1716.443151] test_rfs_no_check_rfs_key costs 27290206 cycles
[ 1716.453496] test_rfs_no_check_rfs_key costs 26797500 cycles

[ 2635.215760] rfs_needed:0
[ 2635.219079] test_rfs_check_rfs_key costs 8455450 cycles
[ 2635.222381] test_rfs_check_rfs_key costs 8556322 cycles
[ 2635.225761] test_rfs_check_rfs_key costs 8758388 cycles
[ 2635.232230] test_rfs_no_check_rfs_key costs 16762130 cycles
[ 2635.239942] test_rfs_no_check_rfs_key costs 19982679 cycles
[ 2635.249172] test_rfs_no_check_rfs_key costs 23894840 cycles

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 include/net/sock.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3467d9e..584bb9a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -910,7 +910,7 @@ static inline void sk_incoming_cpu_update(struct sock *sk)
 	sk->sk_incoming_cpu = raw_smp_processor_id();
 }
 
-static inline void sock_rps_record_flow_hash(__u32 hash)
+static inline void _sock_rps_record_flow_hash(__u32 hash)
 {
 #ifdef CONFIG_RPS
 	struct rps_sock_flow_table *sock_flow_table;
@@ -922,6 +922,14 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
 #endif
 }
 
+static inline void sock_rps_record_flow_hash(__u32 hash)
+{
+#ifdef CONFIG_RPS
+	if (static_key_false(&rfs_needed))
+		_sock_rps_record_flow_hash(hash);
+#endif
+}
+
 static inline void sock_rps_record_flow(const struct sock *sk)
 {
 #ifdef CONFIG_RPS
@@ -937,7 +945,7 @@ static inline void sock_rps_record_flow(const struct sock *sk)
 		 * [1] : sk_state and sk_prot are in the same cache line.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED)
-			sock_rps_record_flow_hash(sk->sk_rxhash);
+			_sock_rps_record_flow_hash(sk->sk_rxhash);
 	}
 #endif
 }
-- 
1.9.1
