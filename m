From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nfnetlink: use original skbuff when acking batches
Date: Tue, 16 Feb 2016 18:02:33 +0100
Message-ID: <1455642157-6864-3-git-send-email-pablo@netfilter.org>
References: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52916 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143AbcBPRER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 12:04:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B433A6EF41
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A0B6091F5
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B491891F5
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:14 +0100 (CET)
In-Reply-To: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since bd678e09dc17 ("netfilter: nfnetlink: fix splat due to incorrect
socket memory accounting in skbuff clones"), we don't manually attach
the sk to the skbuff clone anymore, so we have to use the original
skbuff from netlink_ack() which needs to access the sk pointer.

Fixes: bd678e09dc17 ("netfilter: nfnetlink: fix splat due to incorrect socket memory accounting in skbuff clones")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index a7ba233..62e92af 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -311,14 +311,14 @@ replay:
 #endif
 		{
 			nfnl_unlock(subsys_id);
-			netlink_ack(skb, nlh, -EOPNOTSUPP);
+			netlink_ack(oskb, nlh, -EOPNOTSUPP);
 			return kfree_skb(skb);
 		}
 	}
 
 	if (!ss->commit || !ss->abort) {
 		nfnl_unlock(subsys_id);
-		netlink_ack(skb, nlh, -EOPNOTSUPP);
+		netlink_ack(oskb, nlh, -EOPNOTSUPP);
 		return kfree_skb(skb);
 	}
 
@@ -406,7 +406,7 @@ ack:
 				 * pointing to the batch header.
 				 */
 				nfnl_err_reset(&err_list);
-				netlink_ack(skb, nlmsg_hdr(oskb), -ENOMEM);
+				netlink_ack(oskb, nlmsg_hdr(oskb), -ENOMEM);
 				status |= NFNL_BATCH_FAILURE;
 				goto done;
 			}
-- 
2.1.4
