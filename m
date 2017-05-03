From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/16] netfilter: ctnetlink: drop the incorrect cthelper module request
Date: Wed,  3 May 2017 11:32:00 +0200
Message-ID: <1493803931-2837-6-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

First, when creating a new ct, we will invoke request_module to try to
load the related inkernel cthelper. So there's no need to call the
request_module again when updating the ct helpinfo.

Second, ctnetlink_change_helper may be called with rcu_read_lock held,
i.e. rcu_read_lock -> nfqnl_recv_verdict -> nfqnl_ct_parse ->
ctnetlink_glue_parse -> ctnetlink_glue_parse_ct ->
ctnetlink_change_helper. But the request_module invocation may sleep,
so we can't call it with the rcu_read_lock held.

Remove it now.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dc7dfd68fafe..48c184552de0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1512,23 +1512,8 @@ static int ctnetlink_change_helper(struct nf_conn *ct,
 
 	helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
 					    nf_ct_protonum(ct));
-	if (helper == NULL) {
-#ifdef CONFIG_MODULES
-		spin_unlock_bh(&nf_conntrack_expect_lock);
-
-		if (request_module("nfct-helper-%s", helpname) < 0) {
-			spin_lock_bh(&nf_conntrack_expect_lock);
-			return -EOPNOTSUPP;
-		}
-
-		spin_lock_bh(&nf_conntrack_expect_lock);
-		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
-						    nf_ct_protonum(ct));
-		if (helper)
-			return -EAGAIN;
-#endif
+	if (helper == NULL)
 		return -EOPNOTSUPP;
-	}
 
 	if (help) {
 		if (help->helper == helper) {
-- 
2.1.4

