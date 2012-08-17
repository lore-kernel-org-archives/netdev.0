From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: ctnetlink: fix missing locking while changing conntrack from nfqueue
Date: Fri, 17 Aug 2012 16:09:32 +0200
Message-ID: <1345212573-3076-5-git-send-email-pablo@netfilter.org>
References: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Since 9cb017665 netfilter: add glue code to integrate nfnetlink_queue and
ctnetlink, we can modify the conntrack entry via nfnl_queue. However, the
change of the conntrack entry via nfnetlink_queue requires appropriate
locking to avoid concurrent updates.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 14f67a2..da4fc37 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1896,10 +1896,15 @@ static int
 ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 {
 	struct nlattr *cda[CTA_MAX+1];
+	int ret;
 
 	nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
 
-	return ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
+	spin_lock_bh(&nf_conntrack_lock);
+	ret = ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
+	spin_unlock_bh(&nf_conntrack_lock);
+
+	return ret;
 }
 
 static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
-- 
1.7.10.4

