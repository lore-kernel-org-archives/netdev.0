From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/18] netfilter: nfnetlink_queue_core: Move away from
 NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:26 -0700 (PDT)
Message-ID: <20120626.220226.1944256461415728480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab2F0FC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:26 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 4DDEA584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_queue_core.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index d36b95e..a0b6492 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -274,13 +274,17 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
-		goto nlmsg_failure;
+		return NULL;
 
 	old_tail = skb->tail;
-	nlh = NLMSG_PUT(skb, 0, 0,
+	nlh = nlmsg_put(skb, 0, 0,
 			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
-			sizeof(struct nfgenmsg));
-	nfmsg = NLMSG_DATA(nlh);
+			sizeof(struct nfgenmsg), 0);
+	if (!nlh) {
+		kfree_skb(skb);
+		return NULL;
+	}
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = entry->pf;
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(queue->queue_num);
@@ -383,7 +387,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 
 		if (skb_tailroom(skb) < nla_total_size(data_len)) {
 			printk(KERN_WARNING "nf_queue: no tailroom!\n");
-			goto nlmsg_failure;
+			kfree_skb(skb);
+			return NULL;
 		}
 
 		nla = (struct nlattr *)skb_put(skb, nla_total_size(data_len));
@@ -400,7 +405,6 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
 
-nlmsg_failure:
 nla_put_failure:
 	if (skb)
 		kfree_skb(skb);
@@ -686,7 +690,7 @@ nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
 		   const struct nlmsghdr *nlh,
 		   const struct nlattr * const nfqa[])
 {
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct nf_queue_entry *entry, *tmp;
 	unsigned int verdict, maxid;
 	struct nfqnl_msg_verdict_hdr *vhdr;
@@ -732,7 +736,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 		   const struct nlmsghdr *nlh,
 		   const struct nlattr * const nfqa[])
 {
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
 
 	struct nfqnl_msg_verdict_hdr *vhdr;
@@ -806,7 +810,7 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		  const struct nlmsghdr *nlh,
 		  const struct nlattr * const nfqa[])
 {
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
 	struct nfqnl_instance *queue;
 	struct nfqnl_msg_config_cmd *cmd = NULL;
-- 
1.7.10.2
