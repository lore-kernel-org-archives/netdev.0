From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: nfnetlink_acct: dump unmodified nfacct flags
Date: Thu, 31 Jul 2014 21:27:06 +0200
Message-ID: <1406834828-8500-8-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35671 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbaGaT1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:17 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Perevalov <a.perevalov@samsung.com>

NFNL_MSG_ACCT_GET_CTRZERO modifies dumped flags, in this case
client see unmodified (uncleared) counter value and cleared
overquota state - end user doesn't know anything about overquota state,
unless end user subscribed on overquota report.

Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 2baa125..11d863c 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -129,6 +129,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	u64 pkts, bytes;
+	u32 old_flags;
 
 	event |= NFNL_SUBSYS_ACCT << 8;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
@@ -143,6 +144,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	if (nla_put_string(skb, NFACCT_NAME, acct->name))
 		goto nla_put_failure;
 
+	old_flags = acct->flags;
 	if (type == NFNL_MSG_ACCT_GET_CTRZERO) {
 		pkts = atomic64_xchg(&acct->pkts, 0);
 		bytes = atomic64_xchg(&acct->bytes, 0);
@@ -160,7 +162,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	if (acct->flags & NFACCT_F_QUOTA) {
 		u64 *quota = (u64 *)acct->data;
 
-		if (nla_put_be32(skb, NFACCT_FLAGS, htonl(acct->flags)) ||
+		if (nla_put_be32(skb, NFACCT_FLAGS, htonl(old_flags)) ||
 		    nla_put_be64(skb, NFACCT_QUOTA, cpu_to_be64(*quota)))
 			goto nla_put_failure;
 	}
-- 
1.7.10.4
