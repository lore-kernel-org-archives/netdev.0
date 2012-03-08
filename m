From: pablo@netfilter.org
Subject: [PATCH 07/23] netfilter: ctnetlink: allow to set expectation class
Date: Thu,  8 Mar 2012 02:00:56 +0100
Message-ID: <1331168472-5820-8-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows you to set the expectation class.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/netfilter/nf_conntrack_netlink.c          |   12 +++++++++++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index d498a44..557a0cf 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -173,6 +173,7 @@ enum ctattr_expect {
 	CTA_EXPECT_HELP_NAME,
 	CTA_EXPECT_ZONE,
 	CTA_EXPECT_FLAGS,
+	CTA_EXPECT_CLASS,
 	__CTA_EXPECT_MAX
 };
 #define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1b0aea6..b6ea397 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1691,6 +1691,7 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 	NLA_PUT_BE32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout));
 	NLA_PUT_BE32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp));
 	NLA_PUT_BE32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags));
+	NLA_PUT_BE32(skb, CTA_EXPECT_CLASS, htonl(exp->class));
 	help = nfct_help(master);
 	if (help) {
 		struct nf_conntrack_helper *helper;
@@ -1856,6 +1857,7 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING },
 	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
 	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
+	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
 };
 
 static int
@@ -2043,6 +2045,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper = NULL;
+	u_int32_t class = 0;
 	int err = 0;
 
 	/* caller guarantees that those three CTA_EXPECT_* exist */
@@ -2088,6 +2091,13 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 		}
 	}
 
+	if (cda[CTA_EXPECT_CLASS] && helper) {
+		class = ntohl(nla_get_be32(cda[CTA_EXPECT_CLASS]));
+		if (class > helper->expect_class_max) {
+			err = -EINVAL;
+			goto out;
+		}
+	}
 	exp = nf_ct_expect_alloc(ct);
 	if (!exp) {
 		err = -ENOMEM;
@@ -2115,7 +2125,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 			exp->flags = 0;
 	}
 
-	exp->class = 0;
+	exp->class = class;
 	exp->expectfn = NULL;
 	exp->master = ct;
 	exp->helper = helper;
-- 
1.7.7.3

