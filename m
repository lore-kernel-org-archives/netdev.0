From: kaber@trash.net
Subject: [PATCH 4/8] netfilter: nf_queue: reject NF_STOLEN verdicts from userspace
Date: Tue, 30 Aug 2011 16:41:17 +0200
Message-ID: <1314715281-26233-5-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

A userspace listener may send (bogus) NF_STOLEN verdict, which causes skb leak.

This problem was previously fixed via
64507fdbc29c3a622180378210ecea8659b14e40 (netfilter:
nf_queue: fix NF_STOLEN skb leak) but this had to be reverted because
NF_STOLEN can also be returned by a netfilter hook when iterating the
rules in nf_reinject.

Reject userspace NF_STOLEN verdict, as suggested by Michal Miroslaw.

This is complementary to commit fad54440438a7c231a6ae347738423cbabc936d9
(netfilter: avoid double free in nf_reinject).

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_queue.c   |   11 ++++-------
 net/ipv6/netfilter/ip6_queue.c  |   11 ++++-------
 net/netfilter/nfnetlink_queue.c |    4 ++--
 3 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 48f7d5b..e59aabd 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -314,7 +314,7 @@ ipq_set_verdict(struct ipq_verdict_msg *vmsg, unsigned int len)
 {
 	struct nf_queue_entry *entry;
 
-	if (vmsg->value > NF_MAX_VERDICT)
+	if (vmsg->value > NF_MAX_VERDICT || vmsg->value == NF_STOLEN)
 		return -EINVAL;
 
 	entry = ipq_find_dequeue_entry(vmsg->id);
@@ -359,12 +359,9 @@ ipq_receive_peer(struct ipq_peer_msg *pmsg,
 		break;
 
 	case IPQM_VERDICT:
-		if (pmsg->msg.verdict.value > NF_MAX_VERDICT)
-			status = -EINVAL;
-		else
-			status = ipq_set_verdict(&pmsg->msg.verdict,
-						 len - sizeof(*pmsg));
-			break;
+		status = ipq_set_verdict(&pmsg->msg.verdict,
+					 len - sizeof(*pmsg));
+		break;
 	default:
 		status = -EINVAL;
 	}
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 87b243a..e63c397 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -314,7 +314,7 @@ ipq_set_verdict(struct ipq_verdict_msg *vmsg, unsigned int len)
 {
 	struct nf_queue_entry *entry;
 
-	if (vmsg->value > NF_MAX_VERDICT)
+	if (vmsg->value > NF_MAX_VERDICT || vmsg->value == NF_STOLEN)
 		return -EINVAL;
 
 	entry = ipq_find_dequeue_entry(vmsg->id);
@@ -359,12 +359,9 @@ ipq_receive_peer(struct ipq_peer_msg *pmsg,
 		break;
 
 	case IPQM_VERDICT:
-		if (pmsg->msg.verdict.value > NF_MAX_VERDICT)
-			status = -EINVAL;
-		else
-			status = ipq_set_verdict(&pmsg->msg.verdict,
-						 len - sizeof(*pmsg));
-			break;
+		status = ipq_set_verdict(&pmsg->msg.verdict,
+					 len - sizeof(*pmsg));
+		break;
 	default:
 		status = -EINVAL;
 	}
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 00bd475..a80b0cb 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -646,8 +646,8 @@ verdicthdr_get(const struct nlattr * const nfqa[])
 		return NULL;
 
 	vhdr = nla_data(nfqa[NFQA_VERDICT_HDR]);
-	verdict = ntohl(vhdr->verdict);
-	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
+	verdict = ntohl(vhdr->verdict) & NF_VERDICT_MASK;
+	if (verdict > NF_MAX_VERDICT || verdict == NF_STOLEN)
 		return NULL;
 	return vhdr;
 }
-- 
1.7.2.3

