From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/18] netfilter: nfnetlink_log: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:23 -0700 (PDT)
Message-ID: <20120626.220223.1090653207727010874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2F0FCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:24 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8564C584190
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_log.c |   29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3c3cfc0..169ab59 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -326,18 +326,20 @@ __nfulnl_send(struct nfulnl_instance *inst)
 {
 	int status = -1;
 
-	if (inst->qlen > 1)
-		NLMSG_PUT(inst->skb, 0, 0,
-			  NLMSG_DONE,
-			  sizeof(struct nfgenmsg));
-
+	if (inst->qlen > 1) {
+		struct nlmsghdr *nlh = nlmsg_put(inst->skb, 0, 0,
+						 NLMSG_DONE,
+						 sizeof(struct nfgenmsg),
+						 0);
+		if (!nlh)
+			goto out;
+	}
 	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_pid,
 				   MSG_DONTWAIT);
 
 	inst->qlen = 0;
 	inst->skb = NULL;
-
-nlmsg_failure:
+out:
 	return status;
 }
 
@@ -380,10 +382,12 @@ __build_packet_message(struct nfulnl_instance *inst,
 	struct nfgenmsg *nfmsg;
 	sk_buff_data_t old_tail = inst->skb->tail;
 
-	nlh = NLMSG_PUT(inst->skb, 0, 0,
+	nlh = nlmsg_put(inst->skb, 0, 0,
 			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
-			sizeof(struct nfgenmsg));
-	nfmsg = NLMSG_DATA(nlh);
+			sizeof(struct nfgenmsg), 0);
+	if (!nlh)
+		return -1;
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = pf;
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(inst->group_num);
@@ -526,7 +530,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 
 		if (skb_tailroom(inst->skb) < nla_total_size(data_len)) {
 			printk(KERN_WARNING "nfnetlink_log: no tailroom!\n");
-			goto nlmsg_failure;
+			return -1;
 		}
 
 		nla = (struct nlattr *)skb_put(inst->skb, nla_total_size(data_len));
@@ -540,7 +544,6 @@ __build_packet_message(struct nfulnl_instance *inst,
 	nlh->nlmsg_len = inst->skb->tail - old_tail;
 	return 0;
 
-nlmsg_failure:
 nla_put_failure:
 	PRINTR(KERN_ERR "nfnetlink_log: error creating log nlmsg\n");
 	return -1;
@@ -745,7 +748,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		   const struct nlmsghdr *nlh,
 		   const struct nlattr * const nfula[])
 {
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t group_num = ntohs(nfmsg->res_id);
 	struct nfulnl_instance *inst;
 	struct nfulnl_msg_config_cmd *cmd = NULL;
-- 
1.7.10.2
