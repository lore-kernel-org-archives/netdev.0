From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: nfnetlink_queue: fix memory leak when attach expectation successfully
Date: Wed, 10 Aug 2016 21:16:42 +0200
Message-ID: <1470856605-7903-7-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

User can use NFQA_EXP to attach expectations to conntracks, but we
forget to put back nf_conntrack_expect when it is inserted successfully,
i.e. in this normal case, expect's use refcnt will be 3. So even we
unlink it and put it back later, the use refcnt is still 1, then the
memory will be leaked forever.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 050bb34..b9bfe64 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2362,12 +2362,8 @@ ctnetlink_glue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
 		return PTR_ERR(exp);
 
 	err = nf_ct_expect_related_report(exp, portid, report);
-	if (err < 0) {
-		nf_ct_expect_put(exp);
-		return err;
-	}
-
-	return 0;
+	nf_ct_expect_put(exp);
+	return err;
 }
 
 static void ctnetlink_glue_seqadj(struct sk_buff *skb, struct nf_conn *ct,
-- 
2.1.4

