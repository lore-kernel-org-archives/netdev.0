From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: nfnetlink: deliver netlink errors on batch completion
Date: Tue, 23 Sep 2014 11:24:47 +0200
Message-ID: <1411464288-18069-5-git-send-email-pablo@netfilter.org>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53476 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754381AbaIWJXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 05:23:51 -0400
In-Reply-To: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to wait until the full batch has been processed to deliver the
netlink error messages to userspace. Otherwise, we may deliver
duplicated errors to userspace in case that we need to abort and replay
the transaction if any of the required modules needs to be autoloaded.

A simple way to reproduce this (assumming nft_meta is not loaded) with
the following test file:

 add table filter
 add chain filter test
 add chain bad test                 # intentional wrong unexistent table
 add rule filter test meta mark 0

Then, when trying to load the batch:

 # nft -f test
 test:4:1-19: Error: Could not process rule: No such file or directory
 add chain bad test
 ^^^^^^^^^^^^^^^^^^^
 test:4:1-19: Error: Could not process rule: No such file or directory
 add chain bad test
 ^^^^^^^^^^^^^^^^^^^

The error is reported twice, once when the batch is aborted due to
missing nft_meta and another when it is fully processed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |   64 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 63 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index c138b8f..f37f071 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -222,6 +222,51 @@ replay:
 	}
 }
 
+struct nfnl_err {
+	struct list_head	head;
+	struct nlmsghdr		*nlh;
+	int			err;
+};
+
+static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err)
+{
+	struct nfnl_err *nfnl_err;
+
+	nfnl_err = kmalloc(sizeof(struct nfnl_err), GFP_KERNEL);
+	if (nfnl_err == NULL)
+		return -ENOMEM;
+
+	nfnl_err->nlh = nlh;
+	nfnl_err->err = err;
+	list_add_tail(&nfnl_err->head, list);
+
+	return 0;
+}
+
+static void nfnl_err_del(struct nfnl_err *nfnl_err)
+{
+	list_del(&nfnl_err->head);
+	kfree(nfnl_err);
+}
+
+static void nfnl_err_reset(struct list_head *err_list)
+{
+	struct nfnl_err *nfnl_err, *next;
+
+	list_for_each_entry_safe(nfnl_err, next, err_list, head)
+		nfnl_err_del(nfnl_err);
+}
+
+static void nfnl_err_deliver(struct list_head *err_list, struct sk_buff *skb)
+{
+	struct nfnl_err *nfnl_err, *next;
+
+	list_for_each_entry_safe(nfnl_err, next, err_list, head) {
+		netlink_ack(skb, nfnl_err->nlh, nfnl_err->err);
+		nfnl_err_del(nfnl_err);
+	}
+}
+
 static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 				u_int16_t subsys_id)
 {
@@ -230,6 +275,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	const struct nfnetlink_subsystem *ss;
 	const struct nfnl_callback *nc;
 	bool success = true, done = false;
+	static LIST_HEAD(err_list);
 	int err;
 
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
@@ -287,6 +333,7 @@ replay:
 		type = nlh->nlmsg_type;
 		if (type == NFNL_MSG_BATCH_BEGIN) {
 			/* Malformed: Batch begin twice */
+			nfnl_err_reset(&err_list);
 			success = false;
 			goto done;
 		} else if (type == NFNL_MSG_BATCH_END) {
@@ -333,6 +380,7 @@ replay:
 			 * original skb.
 			 */
 			if (err == -EAGAIN) {
+				nfnl_err_reset(&err_list);
 				ss->abort(skb);
 				nfnl_unlock(subsys_id);
 				kfree_skb(nskb);
@@ -341,11 +389,24 @@ replay:
 		}
 ack:
 		if (nlh->nlmsg_flags & NLM_F_ACK || err) {
+			/* Errors are delivered once the full batch has been
+			 * processed, this avoids that the same error is
+			 * reported several times when replaying the batch.
+			 */
+			if (nfnl_err_add(&err_list, nlh, err) < 0) {
+				/* We failed to enqueue an error, reset the
+				 * list of errors and send OOM to userspace
+				 * pointing to the batch header.
+				 */
+				nfnl_err_reset(&err_list);
+				netlink_ack(skb, nlmsg_hdr(oskb), -ENOMEM);
+				success = false;
+				goto done;
+			}
 			/* We don't stop processing the batch on errors, thus,
 			 * userspace gets all the errors that the batch
 			 * triggers.
 			 */
-			netlink_ack(skb, nlh, err);
 			if (err)
 				success = false;
 		}
@@ -361,6 +422,7 @@ done:
 	else
 		ss->abort(skb);
 
+	nfnl_err_deliver(&err_list, oskb);
 	nfnl_unlock(subsys_id);
 	kfree_skb(nskb);
 }
-- 
1.7.10.4
