From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 08/12] nfnetlink: use y2038 safe timestamp
Date: Wed, 30 Sep 2015 13:26:38 +0200
Message-ID: <1443612402-3000775-9-git-send-email-arnd@arndb.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __build_packet_message function fills a nfulnl_msg_packet_timestamp
structure that uses 64-bit seconds and is therefore y2038 safe, but
it uses an intermediate 'struct timespec' which is not.

This trivially changes the code to use 'struct timespec64' instead,
to correct the result on 32-bit architectures.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
---
 net/netfilter/nfnetlink_log.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4670821b569d..cc2300f4e177 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -538,9 +538,9 @@ __build_packet_message(struct nfnl_log_net *log,
 
 	if (skb->tstamp.tv64) {
 		struct nfulnl_msg_packet_timestamp ts;
-		struct timeval tv = ktime_to_timeval(skb->tstamp);
-		ts.sec = cpu_to_be64(tv.tv_sec);
-		ts.usec = cpu_to_be64(tv.tv_usec);
+		struct timespec64 kts = ktime_to_timespec64(skb->tstamp);
+		ts.sec = cpu_to_be64(kts.tv_sec);
+		ts.usec = cpu_to_be64(kts.tv_nsec / NSEC_PER_USEC);
 
 		if (nla_put(inst->skb, NFULA_TIMESTAMP, sizeof(ts), &ts))
 			goto nla_put_failure;
-- 
2.1.0.rc2
