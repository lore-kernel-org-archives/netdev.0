From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/47] netfilter: nf_tables: Attach process info to NFT_MSG_NEWGEN notifications
Date: Mon,  4 Sep 2017 00:25:46 +0200
Message-ID: <1504477589-12045-5-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50796 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753125AbdICW0l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:26:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 97547190F62
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 859FCB5027
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:14 +0200 (CEST)
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

This is helpful for 'nft monitor' to track which process caused a given
change to the ruleset.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h | 2 ++
 net/netfilter/nf_tables_api.c            | 5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 683f6f88fcac..6f0a950e21c3 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1221,6 +1221,8 @@ enum nft_objref_attributes {
 enum nft_gen_attributes {
 	NFTA_GEN_UNSPEC,
 	NFTA_GEN_ID,
+	NFTA_GEN_PROC_PID,
+	NFTA_GEN_PROC_NAME,
 	__NFTA_GEN_MAX
 };
 #define NFTA_GEN_MAX		(__NFTA_GEN_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7fbf0070aba1..b77ad0813564 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4657,6 +4657,7 @@ static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
+	char buf[TASK_COMM_LEN];
 	int event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, NFT_MSG_NEWGEN);
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg), 0);
@@ -4668,7 +4669,9 @@ static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 	nfmsg->version		= NFNETLINK_V0;
 	nfmsg->res_id		= htons(net->nft.base_seq & 0xffff);
 
-	if (nla_put_be32(skb, NFTA_GEN_ID, htonl(net->nft.base_seq)))
+	if (nla_put_be32(skb, NFTA_GEN_ID, htonl(net->nft.base_seq)) ||
+	    nla_put_be32(skb, NFTA_GEN_PROC_PID, htonl(task_pid_nr(current))) ||
+	    nla_put_string(skb, NFTA_GEN_PROC_NAME, get_task_comm(buf, current)))
 		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
-- 
2.1.4
