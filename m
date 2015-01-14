From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: nfnetlink: remove redundant variable nskb
Date: Wed, 14 Jan 2015 21:34:45 +0100
Message-ID: <1421267689-24894-5-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49654 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbbANUcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 15:32:03 -0500
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Actually after netlink_skb_clone() is called, the nskb and
skb will point to the same thing, but they are used just like
they are different, sometimes this is confusing, so i think
there is no necessary to keep nskb anymore.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@soleta.eu>
---
 net/netfilter/nfnetlink.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 13c2e17..a7a7e82 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -272,7 +272,7 @@ static void nfnl_err_deliver(struct list_head *err_list, struct sk_buff *skb)
 static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 				u_int16_t subsys_id)
 {
-	struct sk_buff *nskb, *oskb = skb;
+	struct sk_buff *oskb = skb;
 	struct net *net = sock_net(skb->sk);
 	const struct nfnetlink_subsystem *ss;
 	const struct nfnl_callback *nc;
@@ -283,12 +283,11 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
 		return netlink_ack(skb, nlh, -EINVAL);
 replay:
-	nskb = netlink_skb_clone(oskb, GFP_KERNEL);
-	if (!nskb)
+	skb = netlink_skb_clone(oskb, GFP_KERNEL);
+	if (!skb)
 		return netlink_ack(oskb, nlh, -ENOMEM);
 
-	nskb->sk = oskb->sk;
-	skb = nskb;
+	skb->sk = oskb->sk;
 
 	nfnl_lock(subsys_id);
 	ss = rcu_dereference_protected(table[subsys_id].subsys,
@@ -305,7 +304,7 @@ replay:
 		{
 			nfnl_unlock(subsys_id);
 			netlink_ack(skb, nlh, -EOPNOTSUPP);
-			return kfree_skb(nskb);
+			return kfree_skb(skb);
 		}
 	}
 
@@ -385,7 +384,7 @@ replay:
 				nfnl_err_reset(&err_list);
 				ss->abort(oskb);
 				nfnl_unlock(subsys_id);
-				kfree_skb(nskb);
+				kfree_skb(skb);
 				goto replay;
 			}
 		}
@@ -426,7 +425,7 @@ done:
 
 	nfnl_err_deliver(&err_list, oskb);
 	nfnl_unlock(subsys_id);
-	kfree_skb(nskb);
+	kfree_skb(skb);
 }
 
 static void nfnetlink_rcv(struct sk_buff *skb)
-- 
1.7.10.4
