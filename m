From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: nfnetlink_log: fix maximum packet length logged to userspace
Date: Mon, 27 Oct 2014 22:38:05 +0100
Message-ID: <1414445887-5108-7-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

don't try to queue payloads > 0xffff - NLA_HDRLEN, it does not work.
The nla length includes the size of the nla struct, so anything larger
results in u16 integer overflow.

This patch is similar to
9cefbbc9c8f9abe (netfilter: nfnetlink_queue: cleanup copy_range usage).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 8117fba..2d02eac3 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -43,7 +43,8 @@
 #define NFULNL_NLBUFSIZ_DEFAULT	NLMSG_GOODSIZE
 #define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
-#define NFULNL_COPY_RANGE_MAX	0xFFFF	/* max packet size is limited by 16-bit struct nfattr nfa_len field */
+/* max packet size is limited by 16-bit struct nfattr nfa_len field */
+#define NFULNL_COPY_RANGE_MAX	(0xFFFF - NLA_HDRLEN)
 
 #define PRINTR(x, args...)	do { if (net_ratelimit()) \
 				     printk(x, ## args); } while (0);
@@ -252,6 +253,8 @@ nfulnl_set_mode(struct nfulnl_instance *inst, u_int8_t mode,
 
 	case NFULNL_COPY_PACKET:
 		inst->copy_mode = mode;
+		if (range == 0)
+			range = NFULNL_COPY_RANGE_MAX;
 		inst->copy_range = min_t(unsigned int,
 					 range, NFULNL_COPY_RANGE_MAX);
 		break;
@@ -679,8 +682,7 @@ nfulnl_log_packet(struct net *net,
 		break;
 
 	case NFULNL_COPY_PACKET:
-		if (inst->copy_range == 0
-		    || inst->copy_range > skb->len)
+		if (inst->copy_range > skb->len)
 			data_len = skb->len;
 		else
 			data_len = inst->copy_range;
-- 
1.7.10.4

