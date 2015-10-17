From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/35] netfilter: nfnetlink_queue: use y2038 safe timestamp
Date: Sat, 17 Oct 2015 13:32:39 +0200
Message-ID: <1445081590-2924-5-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __build_packet_message function fills a nfulnl_msg_packet_timestamp
structure that uses 64-bit seconds and is therefore y2038 safe, but
it uses an intermediate 'struct timespec' which is not.

This trivially changes the code to use 'struct timespec64' instead,
to correct the result on 32-bit architectures.

This is a copy and paste of Arnd's original patch for nfnetlink_log.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index b1f1c74..0d2e856 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -500,9 +500,10 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 
 	if (entskb->tstamp.tv64) {
 		struct nfqnl_msg_packet_timestamp ts;
-		struct timeval tv = ktime_to_timeval(entskb->tstamp);
-		ts.sec = cpu_to_be64(tv.tv_sec);
-		ts.usec = cpu_to_be64(tv.tv_usec);
+		struct timespec64 kts = ktime_to_timespec64(skb->tstamp);
+
+		ts.sec = cpu_to_be64(kts.tv_sec);
+		ts.usec = cpu_to_be64(kts.tv_nsec / NSEC_PER_USEC);
 
 		if (nla_put(skb, NFQA_TIMESTAMP, sizeof(ts), &ts))
 			goto nla_put_failure;
-- 
2.1.4

