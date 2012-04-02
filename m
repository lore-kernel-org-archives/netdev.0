From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 12/51] nfnetlink_acct: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:02 -0400
Message-ID: <1333335521-1348-13-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2DBC7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:22 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_acct.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index d98c868..b2e7310 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -109,7 +109,8 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = 0;
 
-	NLA_PUT_STRING(skb, NFACCT_NAME, acct->name);
+	if (nla_put_string(skb, NFACCT_NAME, acct->name))
+		goto nla_put_failure;
 
 	if (type == NFNL_MSG_ACCT_GET_CTRZERO) {
 		pkts = atomic64_xchg(&acct->pkts, 0);
@@ -118,9 +119,10 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 		pkts = atomic64_read(&acct->pkts);
 		bytes = atomic64_read(&acct->bytes);
 	}
-	NLA_PUT_BE64(skb, NFACCT_PKTS, cpu_to_be64(pkts));
-	NLA_PUT_BE64(skb, NFACCT_BYTES, cpu_to_be64(bytes));
-	NLA_PUT_BE32(skb, NFACCT_USE, htonl(atomic_read(&acct->refcnt)));
+	if (nla_put_be64(skb, NFACCT_PKTS, cpu_to_be64(pkts)) ||
+	    nla_put_be64(skb, NFACCT_BYTES, cpu_to_be64(bytes)) ||
+	    nla_put_be32(skb, NFACCT_USE, htonl(atomic_read(&acct->refcnt))))
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return skb->len;
-- 
1.7.7.6
