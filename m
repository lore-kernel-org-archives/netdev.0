From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH v2 3/3] net: sctp: Convert log timestamps to be y2038 safe
Date: Sat, 27 Feb 2016 00:32:17 -0800
Message-ID: <1456561938-7653-4-git-send-email-deepa.kernel@gmail.com>
References: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org, y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34139 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbcB0IdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 03:33:05 -0500
In-Reply-To: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP probe log timestamps use struct timespec which is
not y2038 safe.
Use struct timespec64 which is 2038 safe instead.

Use monotonic time instead of real time as only time
differences are logged.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
---
 net/sctp/probe.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 5e68b94..6cc2152 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -65,7 +65,7 @@ static struct {
 	struct kfifo	  fifo;
 	spinlock_t	  lock;
 	wait_queue_head_t wait;
-	struct timespec	  tstart;
+	struct timespec64 tstart;
 } sctpw;
 
 static __printf(1, 2) void printl(const char *fmt, ...)
@@ -85,7 +85,7 @@ static __printf(1, 2) void printl(const char *fmt, ...)
 static int sctpprobe_open(struct inode *inode, struct file *file)
 {
 	kfifo_reset(&sctpw.fifo);
-	getnstimeofday(&sctpw.tstart);
+	ktime_get_ts64(&sctpw.tstart);
 
 	return 0;
 }
@@ -138,7 +138,7 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 	struct sk_buff *skb = chunk->skb;
 	struct sctp_transport *sp;
 	static __u32 lcwnd = 0;
-	struct timespec now;
+	struct timespec64 now;
 
 	sp = asoc->peer.primary_path;
 
@@ -149,8 +149,8 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 	    (full || sp->cwnd != lcwnd)) {
 		lcwnd = sp->cwnd;
 
-		getnstimeofday(&now);
-		now = timespec_sub(now, sctpw.tstart);
+		ktime_get_ts64(&now);
+		now = timespec64_sub(now, sctpw.tstart);
 
 		printl("%lu.%06lu ", (unsigned long) now.tv_sec,
 		       (unsigned long) now.tv_nsec / NSEC_PER_USEC);
-- 
1.9.1
