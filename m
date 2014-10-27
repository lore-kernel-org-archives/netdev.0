From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_log: release skbuff on nlmsg put failure
Date: Mon, 27 Oct 2014 22:38:06 +0100
Message-ID: <1414445887-5108-8-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35989 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668AbaJ0Vgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 17:36:42 -0400
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Houcheng Lin <houcheng@gmail.com>

The kernel should reserve enough room in the skb so that the DONE
message can always be appended.  However, in case of e.g. new attribute
erronously not being size-accounted for, __nfulnl_send() will still
try to put next nlmsg into this full skbuf, causing the skb to be stuck
forever and blocking delivery of further messages.

Fix issue by releasing skb immediately after nlmsg_put error and
WARN() so we can track down the cause of such size mismatch.

[ fw@strlen.de: add tailroom/len info to WARN ]

Signed-off-by: Houcheng Lin <houcheng@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 2d02eac3..5f1be5b 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -346,26 +346,25 @@ nfulnl_alloc_skb(struct net *net, u32 peer_portid, unsigned int inst_size,
 	return skb;
 }
 
-static int
+static void
 __nfulnl_send(struct nfulnl_instance *inst)
 {
-	int status = -1;
-
 	if (inst->qlen > 1) {
 		struct nlmsghdr *nlh = nlmsg_put(inst->skb, 0, 0,
 						 NLMSG_DONE,
 						 sizeof(struct nfgenmsg),
 						 0);
-		if (!nlh)
+		if (WARN_ONCE(!nlh, "bad nlskb size: %u, tailroom %d\n",
+			      inst->skb->len, skb_tailroom(inst->skb))) {
+			kfree_skb(inst->skb);
 			goto out;
+		}
 	}
-	status = nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid,
-				   MSG_DONTWAIT);
-
+	nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid,
+			  MSG_DONTWAIT);
+out:
 	inst->qlen = 0;
 	inst->skb = NULL;
-out:
-	return status;
 }
 
 static void
-- 
1.7.10.4
