From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 16/31: ctnetlink: remove nowait parameter from *fill_info()
Date: Wed, 10 Jun 2009 21:46:41 +0200 (MEST)
Message-ID: <20090610194640.11112.88473.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8b0a231d4d6336baf10f13b6142fd5c1f628247e
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:03:34 2009 +0200

    netfilter: ctnetlink: remove nowait parameter from *fill_info()
    
    This patch is a cleanup, it removes the `nowait' parameter
    from all *fill_info() function since it is always set to one.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c523f0b..2d7d69f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -350,8 +350,7 @@ nla_put_failure:
 
 static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
-		    int event, int nowait,
-		    const struct nf_conn *ct)
+		    int event, const struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
@@ -362,7 +361,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	nlh    = NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
 	nfmsg  = NLMSG_DATA(nlh);
 
-	nlh->nlmsg_flags    = (nowait && pid) ? NLM_F_MULTI : 0;
+	nlh->nlmsg_flags    = pid ? NLM_F_MULTI : 0;
 	nfmsg->nfgen_family = nf_ct_l3num(ct);
 	nfmsg->version      = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
@@ -637,8 +636,7 @@ restart:
 			}
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
-						IPCTNL_MSG_CT_NEW,
-						1, ct) < 0) {
+						IPCTNL_MSG_CT_NEW, ct) < 0) {
 				cb->args[1] = (unsigned long)ct;
 				goto out;
 			}
@@ -880,7 +878,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	rcu_read_lock();
 	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq,
-				  IPCTNL_MSG_CT_NEW, 1, ct);
+				  IPCTNL_MSG_CT_NEW, ct);
 	rcu_read_unlock();
 	nf_ct_put(ct);
 	if (err <= 0)
@@ -1503,9 +1501,7 @@ nla_put_failure:
 
 static int
 ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
-		    int event,
-		    int nowait,
-		    const struct nf_conntrack_expect *exp)
+			int event, const struct nf_conntrack_expect *exp)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
@@ -1515,7 +1511,7 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	nlh    = NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
 	nfmsg  = NLMSG_DATA(nlh);
 
-	nlh->nlmsg_flags    = (nowait && pid) ? NLM_F_MULTI : 0;
+	nlh->nlmsg_flags    = pid ? NLM_F_MULTI : 0;
 	nfmsg->nfgen_family = exp->tuple.src.l3num;
 	nfmsg->version	    = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
@@ -1617,10 +1613,11 @@ restart:
 					continue;
 				cb->args[1] = 0;
 			}
-			if (ctnetlink_exp_fill_info(skb, NETLINK_CB(cb->skb).pid,
+			if (ctnetlink_exp_fill_info(skb,
+						    NETLINK_CB(cb->skb).pid,
 						    cb->nlh->nlmsg_seq,
 						    IPCTNL_MSG_EXP_NEW,
-						    1, exp) < 0) {
+						    exp) < 0) {
 				if (!atomic_inc_not_zero(&exp->use))
 					continue;
 				cb->args[1] = (unsigned long)exp;
@@ -1689,8 +1686,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 
 	rcu_read_lock();
 	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid,
-				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW,
-				      1, exp);
+				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW, exp);
 	rcu_read_unlock();
 	if (err <= 0)
 		goto free;
