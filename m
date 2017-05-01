From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/53] netfilter: ctnetlink: Expectations must have a conntrack helper area
Date: Mon,  1 May 2017 12:46:36 +0200
Message-ID: <1493635640-24325-10-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

The expect check function __nf_ct_expect_check() asks the master_help is
necessary. So it is unnecessary to go ahead in ctnetlink_alloc_expect
when there is no help.

Actually the commit bc01befdcf3e ("netfilter: ctnetlink: add support for
user-space expectation helpers") permits ctnetlink create one expect
even though there is no master help. But the latter commit 3d058d7bc2c5
("netfilter: rework user-space expectation helper support") disables it
again.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ecdc324c7785..cd0a6d270ebe 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -3038,6 +3038,10 @@ ctnetlink_alloc_expect(const struct nlattr * const cda[], struct nf_conn *ct,
 	struct nf_conn_help *help;
 	int err;
 
+	help = nfct_help(ct);
+	if (!help)
+		return ERR_PTR(-EOPNOTSUPP);
+
 	if (cda[CTA_EXPECT_CLASS] && helper) {
 		class = ntohl(nla_get_be32(cda[CTA_EXPECT_CLASS]));
 		if (class > helper->expect_class_max)
@@ -3047,26 +3051,11 @@ ctnetlink_alloc_expect(const struct nlattr * const cda[], struct nf_conn *ct,
 	if (!exp)
 		return ERR_PTR(-ENOMEM);
 
-	help = nfct_help(ct);
-	if (!help) {
-		if (!cda[CTA_EXPECT_TIMEOUT]) {
-			err = -EINVAL;
-			goto err_out;
-		}
-		exp->timeout.expires =
-		  jiffies + ntohl(nla_get_be32(cda[CTA_EXPECT_TIMEOUT])) * HZ;
-
-		exp->flags = NF_CT_EXPECT_USERSPACE;
-		if (cda[CTA_EXPECT_FLAGS]) {
-			exp->flags |=
-				ntohl(nla_get_be32(cda[CTA_EXPECT_FLAGS]));
-		}
+	if (cda[CTA_EXPECT_FLAGS]) {
+		exp->flags = ntohl(nla_get_be32(cda[CTA_EXPECT_FLAGS]));
+		exp->flags &= ~NF_CT_EXPECT_USERSPACE;
 	} else {
-		if (cda[CTA_EXPECT_FLAGS]) {
-			exp->flags = ntohl(nla_get_be32(cda[CTA_EXPECT_FLAGS]));
-			exp->flags &= ~NF_CT_EXPECT_USERSPACE;
-		} else
-			exp->flags = 0;
+		exp->flags = 0;
 	}
 	if (cda[CTA_EXPECT_FN]) {
 		const char *name = nla_data(cda[CTA_EXPECT_FN]);
-- 
2.1.4

