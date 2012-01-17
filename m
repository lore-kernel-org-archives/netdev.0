From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: revert user-space expectation helper support
Date: Tue, 17 Jan 2012 12:04:47 +0100
Message-ID: <1326798289-11592-3-git-send-email-pablo@netfilter.org>
References: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch partially reverts:
3d058d7 netfilter: rework user-space expectation helper support
that was applied during the 3.2 development cycle.

After this patch, the tree remains just like before patch bc01bef,
that initially added the preliminary infrastructure.

I decided to partially revert this patch because the approach
that I proposed to resolve this problem is broken in NAT setups.
Moreover, a new infrastructure will be submitted for the 3.3.x
development cycle that resolve the existing issues while
providing a neat solution.

Since nobody has been seriously using this infrastructure in
user-space, the removal of this feature should affect any know
FOSS project (to my knowledge).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_common.h |    4 ----
 include/linux/netfilter/xt_CT.h               |    3 +--
 net/netfilter/nf_conntrack_helper.c           |   12 ------------
 net/netfilter/nf_conntrack_netlink.c          |    4 ----
 net/netfilter/xt_CT.c                         |    8 +++-----
 5 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 9e3a283..0d3dd66 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -83,10 +83,6 @@ enum ip_conntrack_status {
 	/* Conntrack is a fake untracked entry */
 	IPS_UNTRACKED_BIT = 12,
 	IPS_UNTRACKED = (1 << IPS_UNTRACKED_BIT),
-
-	/* Conntrack has a userspace helper. */
-	IPS_USERSPACE_HELPER_BIT = 13,
-	IPS_USERSPACE_HELPER = (1 << IPS_USERSPACE_HELPER_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
index 6390f09..b56e768 100644
--- a/include/linux/netfilter/xt_CT.h
+++ b/include/linux/netfilter/xt_CT.h
@@ -3,8 +3,7 @@
 
 #include <linux/types.h>
 
-#define XT_CT_NOTRACK		0x1
-#define XT_CT_USERSPACE_HELPER	0x2
+#define XT_CT_NOTRACK	0x1
 
 struct xt_ct_target_info {
 	__u16 flags;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 299fec9..bbe23ba 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -121,18 +121,6 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	int ret = 0;
 
 	if (tmpl != NULL) {
-		/* we've got a userspace helper. */
-		if (tmpl->status & IPS_USERSPACE_HELPER) {
-			help = nf_ct_helper_ext_add(ct, flags);
-			if (help == NULL) {
-				ret = -ENOMEM;
-				goto out;
-			}
-			rcu_assign_pointer(help->helper, NULL);
-			__set_bit(IPS_USERSPACE_HELPER_BIT, &ct->status);
-			ret = 0;
-			goto out;
-		}
 		help = nfct_help(tmpl);
 		if (help != NULL)
 			helper = help->helper;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2a4834b..9307b03 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2042,10 +2042,6 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	}
 	help = nfct_help(ct);
 	if (!help) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-	if (test_bit(IPS_USERSPACE_HELPER_BIT, &ct->status)) {
 		if (!cda[CTA_EXPECT_TIMEOUT]) {
 			err = -EINVAL;
 			goto out;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 8e87123..0221d10 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -62,8 +62,8 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 	int ret = 0;
 	u8 proto;
 
-	if (info->flags & ~(XT_CT_NOTRACK | XT_CT_USERSPACE_HELPER))
-		return -EOPNOTSUPP;
+	if (info->flags & ~XT_CT_NOTRACK)
+		return -EINVAL;
 
 	if (info->flags & XT_CT_NOTRACK) {
 		ct = nf_ct_untracked_get();
@@ -92,9 +92,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 				  GFP_KERNEL))
 		goto err3;
 
-	if (info->flags & XT_CT_USERSPACE_HELPER) {
-		__set_bit(IPS_USERSPACE_HELPER_BIT, &ct->status);
-	} else if (info->helper[0]) {
+	if (info->helper[0]) {
 		ret = -ENOENT;
 		proto = xt_ct_find_proto(par);
 		if (!proto) {
-- 
1.7.7.3

