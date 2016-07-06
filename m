From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/26] netfilter: Allow xt_owner in any user namespace
Date: Wed,  6 Jul 2016 16:23:52 +0200
Message-ID: <1467815048-2240-11-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

Making this work is a little tricky as it really isn't kosher to
change the xt_owner_match_info in a check function.

Without changing xt_owner_match_info we need to know the user
namespace the uids and gids are specified in.  In the common case
net->user_ns == current_user_ns().  Verify net->user_ns ==
current_user_ns() in owner_check so we can later assume it in
owner_mt.

In owner_check also verify that all of the uids and gids specified are
in net->user_ns and that the expected min/max relationship exists
between the uids and gids in xt_owner_match_info.

In owner_mt get the network namespace from the outgoing socket, as this
must be the same network namespace as the netfilter rules, and use that
network namespace to find the user namespace the uids and gids in
xt_match_owner_info are encoded in.  Then convert from their encoded
from into the kernel internal format for uids and gids and perform the
owner match.

Similar to ping_group_range, this code does not try to detect
noncontiguous UID/GID ranges.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_owner.c | 41 +++++++++++++++++++++++++++++++++++------
 1 file changed, 35 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index 1302b47..a20e731 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -21,11 +21,39 @@
 static int owner_check(const struct xt_mtchk_param *par)
 {
 	struct xt_owner_match_info *info = par->matchinfo;
+	struct net *net = par->net;
 
-	/* For now only allow adding matches from the initial user namespace */
+	/* Only allow the common case where the userns of the writer
+	 * matches the userns of the network namespace.
+	 */
 	if ((info->match & (XT_OWNER_UID|XT_OWNER_GID)) &&
-	    (current_user_ns() != &init_user_ns))
+	    (current_user_ns() != net->user_ns))
 		return -EINVAL;
+
+	/* Ensure the uids are valid */
+	if (info->match & XT_OWNER_UID) {
+		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
+		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
+
+		if (!uid_valid(uid_min) || !uid_valid(uid_max) ||
+		    (info->uid_max < info->uid_min) ||
+		    uid_lt(uid_max, uid_min)) {
+			return -EINVAL;
+		}
+	}
+
+	/* Ensure the gids are valid */
+	if (info->match & XT_OWNER_GID) {
+		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
+		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
+
+		if (!gid_valid(gid_min) || !gid_valid(gid_max) ||
+		    (info->gid_max < info->gid_min) ||
+		    gid_lt(gid_max, gid_min)) {
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
@@ -35,6 +63,7 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
 	struct sock *sk = skb_to_full_sk(skb);
+	struct net *net = par->net;
 
 	if (sk == NULL || sk->sk_socket == NULL)
 		return (info->match ^ info->invert) == 0;
@@ -51,8 +80,8 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
 
 	if (info->match & XT_OWNER_UID) {
-		kuid_t uid_min = make_kuid(&init_user_ns, info->uid_min);
-		kuid_t uid_max = make_kuid(&init_user_ns, info->uid_max);
+		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
+		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
 		if ((uid_gte(filp->f_cred->fsuid, uid_min) &&
 		     uid_lte(filp->f_cred->fsuid, uid_max)) ^
 		    !(info->invert & XT_OWNER_UID))
@@ -60,8 +89,8 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	if (info->match & XT_OWNER_GID) {
-		kgid_t gid_min = make_kgid(&init_user_ns, info->gid_min);
-		kgid_t gid_max = make_kgid(&init_user_ns, info->gid_max);
+		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
+		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
 		if ((gid_gte(filp->f_cred->fsgid, gid_min) &&
 		     gid_lte(filp->f_cred->fsgid, gid_max)) ^
 		    !(info->invert & XT_OWNER_GID))
-- 
2.1.4

