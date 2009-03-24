From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 28/41: ctnetlink: cleanup conntrack update preliminary checkings
Date: Tue, 24 Mar 2009 15:03:44 +0100 (MET)
Message-ID: <20090324140340.31401.72133.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e098360f159b3358f085543eb6dc2eb500d6667c
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:27:22 2009 +0100

    netfilter: ctnetlink: cleanup conntrack update preliminary checkings
    
    This patch moves the preliminary checkings that must be fulfilled
    to update a conntrack, which are the following:
    
     * NAT manglings cannot be updated
     * Changing the master conntrack is not allowed.
    
    This patch is a cleanup.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cca22d5..b67db69 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1062,6 +1062,10 @@ ctnetlink_change_conntrack(struct nf_conn *ct, struct nlattr *cda[])
 {
 	int err;
 
+	/* only allow NAT changes and master assignation for new conntracks */
+	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST] || cda[CTA_TUPLE_MASTER])
+		return -EOPNOTSUPP;
+
 	if (cda[CTA_HELP]) {
 		err = ctnetlink_change_helper(ct, cda);
 		if (err < 0)
@@ -1323,17 +1327,6 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
 		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
 
-		/* we only allow nat config for new conntracks */
-		if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
-			err = -EOPNOTSUPP;
-			goto out_unlock;
-		}
-		/* can't link an existing conntrack to a master */
-		if (cda[CTA_TUPLE_MASTER]) {
-			err = -EOPNOTSUPP;
-			goto out_unlock;
-		}
-
 		err = ctnetlink_change_conntrack(ct, cda);
 		if (err == 0) {
 			nf_conntrack_get(&ct->ct_general);
