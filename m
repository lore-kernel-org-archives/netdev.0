From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: nfnetlink: keep going batch handling on missing modules
Date: Wed,  8 Jul 2015 11:48:18 +0200
Message-ID: <1436348900-13130-6-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a fresh boot with no modules in place at all and a large rulesets, the
existing nfnetlink_rcv_batch() funcion can take long time to commit the ruleset
due to the many abort path. This is specifically a problem for the existing
client of this code, ie. nf_tables, since it results in several
synchronize_rcu() call in a row.

This patch changes the policy to keep full batch processing on missing modules
errors so we abort only once.

Reported-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |   38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 8b117c9..0c0e8ec 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -269,6 +269,12 @@ static void nfnl_err_deliver(struct list_head *err_list, struct sk_buff *skb)
 	}
 }
 
+enum {
+	NFNL_BATCH_FAILURE	= (1 << 0),
+	NFNL_BATCH_DONE		= (1 << 1),
+	NFNL_BATCH_REPLAY	= (1 << 2),
+};
+
 static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 				u_int16_t subsys_id)
 {
@@ -276,13 +282,15 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	const struct nfnetlink_subsystem *ss;
 	const struct nfnl_callback *nc;
-	bool success = true, done = false;
 	static LIST_HEAD(err_list);
+	u32 status;
 	int err;
 
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
 		return netlink_ack(skb, nlh, -EINVAL);
 replay:
+	status = 0;
+
 	skb = netlink_skb_clone(oskb, GFP_KERNEL);
 	if (!skb)
 		return netlink_ack(oskb, nlh, -ENOMEM);
@@ -336,10 +344,10 @@ replay:
 		if (type == NFNL_MSG_BATCH_BEGIN) {
 			/* Malformed: Batch begin twice */
 			nfnl_err_reset(&err_list);
-			success = false;
+			status |= NFNL_BATCH_FAILURE;
 			goto done;
 		} else if (type == NFNL_MSG_BATCH_END) {
-			done = true;
+			status |= NFNL_BATCH_DONE;
 			goto done;
 		} else if (type < NLMSG_MIN_TYPE) {
 			err = -EINVAL;
@@ -382,11 +390,8 @@ replay:
 			 * original skb.
 			 */
 			if (err == -EAGAIN) {
-				nfnl_err_reset(&err_list);
-				ss->abort(oskb);
-				nfnl_unlock(subsys_id);
-				kfree_skb(skb);
-				goto replay;
+				status |= NFNL_BATCH_REPLAY;
+				goto next;
 			}
 		}
 ack:
@@ -402,7 +407,7 @@ ack:
 				 */
 				nfnl_err_reset(&err_list);
 				netlink_ack(skb, nlmsg_hdr(oskb), -ENOMEM);
-				success = false;
+				status |= NFNL_BATCH_FAILURE;
 				goto done;
 			}
 			/* We don't stop processing the batch on errors, thus,
@@ -410,19 +415,26 @@ ack:
 			 * triggers.
 			 */
 			if (err)
-				success = false;
+				status |= NFNL_BATCH_FAILURE;
 		}
-
+next:
 		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 		if (msglen > skb->len)
 			msglen = skb->len;
 		skb_pull(skb, msglen);
 	}
 done:
-	if (success && done)
+	if (status & NFNL_BATCH_REPLAY) {
+		ss->abort(oskb);
+		nfnl_err_reset(&err_list);
+		nfnl_unlock(subsys_id);
+		kfree_skb(skb);
+		goto replay;
+	} else if (status == NFNL_BATCH_DONE) {
 		ss->commit(oskb);
-	else
+	} else {
 		ss->abort(oskb);
+	}
 
 	nfnl_err_deliver(&err_list, oskb);
 	nfnl_unlock(subsys_id);
-- 
1.7.10.4

