From: kaber@trash.net
Subject: [PATCH 13/72] netfilter: ctnetlink: allow to specify the expectation flags
Date: Thu, 21 Oct 2010 17:19:00 +0200
Message-ID: <1287674399-31455-14-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab0JUPUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:04 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

With this patch, you can specify the expectation flags for user-space
created expectations.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_common.h |    4 ++++
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/net/netfilter/nf_conntrack_expect.h   |    3 ---
 net/netfilter/nf_conntrack_netlink.c          |    8 +++++++-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 1afd18c..fdc50ca 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -100,6 +100,10 @@ enum ip_conntrack_expect_events {
 	IPEXP_NEW,		/* new expectation */
 };
 
+/* expectation flags */
+#define NF_CT_EXPECT_PERMANENT		0x1
+#define NF_CT_EXPECT_INACTIVE		0x2
+
 #ifdef __KERNEL__
 struct ip_conntrack_stat {
 	unsigned int searched;
diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 9ed534c..455f0ce 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -161,6 +161,7 @@ enum ctattr_expect {
 	CTA_EXPECT_ID,
 	CTA_EXPECT_HELP_NAME,
 	CTA_EXPECT_ZONE,
+	CTA_EXPECT_FLAGS,
 	__CTA_EXPECT_MAX
 };
 #define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 11e8150..96bb42a 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -67,9 +67,6 @@ struct nf_conntrack_expect_policy {
 
 #define NF_CT_EXPECT_CLASS_DEFAULT	0
 
-#define NF_CT_EXPECT_PERMANENT	0x1
-#define NF_CT_EXPECT_INACTIVE	0x2
-
 int nf_conntrack_expect_init(struct net *net);
 void nf_conntrack_expect_fini(struct net *net);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 37533a3..0804e0e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1577,6 +1577,7 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 
 	NLA_PUT_BE32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout));
 	NLA_PUT_BE32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp));
+	NLA_PUT_BE32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags));
 	helper = rcu_dereference(nfct_help(master)->helper);
 	if (helper)
 		NLA_PUT_STRING(skb, CTA_EXPECT_HELP_NAME, helper->name);
@@ -1734,6 +1735,7 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
 	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING },
 	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
+	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
 };
 
 static int
@@ -1933,9 +1935,13 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 		goto out;
 	}
 
+	if (cda[CTA_EXPECT_FLAGS])
+		exp->flags = ntohl(nla_get_be32(cda[CTA_EXPECT_FLAGS]));
+	else
+		exp->flags = 0;
+
 	exp->class = 0;
 	exp->expectfn = NULL;
-	exp->flags = 0;
 	exp->master = ct;
 	exp->helper = NULL;
 	memcpy(&exp->tuple, &tuple, sizeof(struct nf_conntrack_tuple));
-- 
1.7.1

