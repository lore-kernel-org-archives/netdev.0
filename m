From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 45/53] netfilter: pptp: attach nat extension when needed
Date: Mon,  1 May 2017 12:47:12 +0200
Message-ID: <1493635640-24325-46-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49724 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S379002AbdEAKtA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:49:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ACBA121057C
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9A0D6FF2D5
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7A84FA6C1
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:03 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

make sure nat extension gets added if the master conntrack is subject to
NAT.  This will be required once the nat core stops adding it by default.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_pptp.c  | 25 +++++++++++++++++++++----
 net/netfilter/nf_conntrack_pptp.c | 12 ++++++++++--
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 211fee5fe59d..8a69363b4884 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -49,9 +49,14 @@ static void pptp_nat_expected(struct nf_conn *ct,
 	const struct nf_ct_pptp_master *ct_pptp_info;
 	const struct nf_nat_pptp *nat_pptp_info;
 	struct nf_nat_range range;
+	struct nf_conn_nat *nat;
 
+	nat = nf_ct_nat_ext_add(ct);
+	if (WARN_ON_ONCE(!nat))
+		return;
+
+	nat_pptp_info = &nat->help.nat_pptp_info;
 	ct_pptp_info = nfct_help_data(master);
-	nat_pptp_info = &nfct_nat(master)->help.nat_pptp_info;
 
 	/* And here goes the grand finale of corrosion... */
 	if (exp->dir == IP_CT_DIR_ORIGINAL) {
@@ -120,13 +125,17 @@ pptp_outbound_pkt(struct sk_buff *skb,
 
 {
 	struct nf_ct_pptp_master *ct_pptp_info;
+	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_pptp *nat_pptp_info;
 	u_int16_t msg;
 	__be16 new_callid;
 	unsigned int cid_off;
 
+	if (WARN_ON_ONCE(!nat))
+		return NF_DROP;
+
+	nat_pptp_info = &nat->help.nat_pptp_info;
 	ct_pptp_info = nfct_help_data(ct);
-	nat_pptp_info = &nfct_nat(ct)->help.nat_pptp_info;
 
 	new_callid = ct_pptp_info->pns_call_id;
 
@@ -191,11 +200,15 @@ pptp_exp_gre(struct nf_conntrack_expect *expect_orig,
 	     struct nf_conntrack_expect *expect_reply)
 {
 	const struct nf_conn *ct = expect_orig->master;
+	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_ct_pptp_master *ct_pptp_info;
 	struct nf_nat_pptp *nat_pptp_info;
 
+	if (WARN_ON_ONCE(!nat))
+		return;
+
+	nat_pptp_info = &nat->help.nat_pptp_info;
 	ct_pptp_info = nfct_help_data(ct);
-	nat_pptp_info = &nfct_nat(ct)->help.nat_pptp_info;
 
 	/* save original PAC call ID in nat_info */
 	nat_pptp_info->pac_call_id = ct_pptp_info->pac_call_id;
@@ -223,11 +236,15 @@ pptp_inbound_pkt(struct sk_buff *skb,
 		 union pptp_ctrl_union *pptpReq)
 {
 	const struct nf_nat_pptp *nat_pptp_info;
+	struct nf_conn_nat *nat = nfct_nat(ct);
 	u_int16_t msg;
 	__be16 new_pcid;
 	unsigned int pcid_off;
 
-	nat_pptp_info = &nfct_nat(ct)->help.nat_pptp_info;
+	if (WARN_ON_ONCE(!nat))
+		return NF_DROP;
+
+	nat_pptp_info = &nat->help.nat_pptp_info;
 	new_pcid = nat_pptp_info->pns_call_id;
 
 	switch (msg = ntohs(ctlh->messageType)) {
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 126031909fc7..6959e93063d4 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -263,7 +263,7 @@ static int exp_gre(struct nf_conn *ct, __be16 callid, __be16 peer_callid)
 	goto out_put_both;
 }
 
-static inline int
+static int
 pptp_inbound_pkt(struct sk_buff *skb, unsigned int protoff,
 		 struct PptpControlHeader *ctlh,
 		 union pptp_ctrl_union *pptpReq,
@@ -391,7 +391,7 @@ pptp_inbound_pkt(struct sk_buff *skb, unsigned int protoff,
 	return NF_ACCEPT;
 }
 
-static inline int
+static int
 pptp_outbound_pkt(struct sk_buff *skb, unsigned int protoff,
 		  struct PptpControlHeader *ctlh,
 		  union pptp_ctrl_union *pptpReq,
@@ -523,6 +523,14 @@ conntrack_pptp_help(struct sk_buff *skb, unsigned int protoff,
 	int ret;
 	u_int16_t msg;
 
+#if IS_ENABLED(CONFIG_NF_NAT)
+	if (!nf_ct_is_confirmed(ct) && (ct->status & IPS_NAT_MASK)) {
+		struct nf_conn_nat *nat = nf_ct_ext_find(ct, NF_CT_EXT_NAT);
+
+		if (!nat && !nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC))
+			return NF_DROP;
+	}
+#endif
 	/* don't do any tracking before tcp handshake complete */
 	if (ctinfo != IP_CT_ESTABLISHED && ctinfo != IP_CT_ESTABLISHED_REPLY)
 		return NF_ACCEPT;
-- 
2.1.4
