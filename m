From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/16] netfilter: ctnetlink: acquire ct->lock before operating nf_ct_seqadj
Date: Wed,  3 May 2017 11:32:03 +0200
Message-ID: <1493803931-2837-9-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45754 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752981AbdECJcf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 05:32:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C1B771C445F
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B149ADA90B
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 50637DA90B
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:23 +0200 (CEST)
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

We should acquire the ct->lock before accessing or modifying the
nf_ct_seqadj, as another CPU may modify the nf_ct_seqadj at the same
time during its packet proccessing.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 86deed6a8db4..78f8c9adbd3c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -417,8 +417,7 @@ dump_ct_seq_adj(struct sk_buff *skb, const struct nf_ct_seqadj *seq, int type)
 	return -1;
 }
 
-static int ctnetlink_dump_ct_seq_adj(struct sk_buff *skb,
-				     const struct nf_conn *ct)
+static int ctnetlink_dump_ct_seq_adj(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nf_conn_seqadj *seqadj = nfct_seqadj(ct);
 	struct nf_ct_seqadj *seq;
@@ -426,15 +425,20 @@ static int ctnetlink_dump_ct_seq_adj(struct sk_buff *skb,
 	if (!(ct->status & IPS_SEQ_ADJUST) || !seqadj)
 		return 0;
 
+	spin_lock_bh(&ct->lock);
 	seq = &seqadj->seq[IP_CT_DIR_ORIGINAL];
 	if (dump_ct_seq_adj(skb, seq, CTA_SEQ_ADJ_ORIG) == -1)
-		return -1;
+		goto err;
 
 	seq = &seqadj->seq[IP_CT_DIR_REPLY];
 	if (dump_ct_seq_adj(skb, seq, CTA_SEQ_ADJ_REPLY) == -1)
-		return -1;
+		goto err;
 
+	spin_unlock_bh(&ct->lock);
 	return 0;
+err:
+	spin_unlock_bh(&ct->lock);
+	return -1;
 }
 
 static int ctnetlink_dump_id(struct sk_buff *skb, const struct nf_conn *ct)
@@ -1637,11 +1641,12 @@ ctnetlink_change_seq_adj(struct nf_conn *ct,
 	if (!seqadj)
 		return 0;
 
+	spin_lock_bh(&ct->lock);
 	if (cda[CTA_SEQ_ADJ_ORIG]) {
 		ret = change_seq_adj(&seqadj->seq[IP_CT_DIR_ORIGINAL],
 				     cda[CTA_SEQ_ADJ_ORIG]);
 		if (ret < 0)
-			return ret;
+			goto err;
 
 		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 	}
@@ -1650,12 +1655,16 @@ ctnetlink_change_seq_adj(struct nf_conn *ct,
 		ret = change_seq_adj(&seqadj->seq[IP_CT_DIR_REPLY],
 				     cda[CTA_SEQ_ADJ_REPLY]);
 		if (ret < 0)
-			return ret;
+			goto err;
 
 		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 	}
 
+	spin_unlock_bh(&ct->lock);
 	return 0;
+err:
+	spin_unlock_bh(&ct->lock);
+	return ret;
 }
 
 static int
-- 
2.1.4
