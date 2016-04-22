From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/23] netfilter: x_tables: check standard target size too
Date: Fri, 22 Apr 2016 15:39:38 +0200
Message-ID: <1461332394-3994-8-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We have targets and standard targets -- the latter carries a verdict.

The ip/ip6tables validation functions will access t->verdict for the
standard targets to fetch the jump offset or verdict for chainloop
detection, but this happens before the targets get checked/validated.

Thus we also need to check for verdict presence here, else t->verdict
can point right after a blob.

Spotted with UBSAN while testing malformed blobs.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index fa206ce..1cb7a27 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -540,6 +540,13 @@ int xt_compat_match_to_user(const struct xt_entry_match *m,
 }
 EXPORT_SYMBOL_GPL(xt_compat_match_to_user);
 
+/* non-compat version may have padding after verdict */
+struct compat_xt_standard_target {
+	struct compat_xt_entry_target t;
+	compat_uint_t verdict;
+};
+
+/* see xt_check_entry_offsets */
 int xt_compat_check_entry_offsets(const void *base,
 				  unsigned int target_offset,
 				  unsigned int next_offset)
@@ -557,6 +564,10 @@ int xt_compat_check_entry_offsets(const void *base,
 	if (target_offset + t->u.target_size > next_offset)
 		return -EINVAL;
 
+	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) == 0 &&
+	    target_offset + sizeof(struct compat_xt_standard_target) != next_offset)
+		return -EINVAL;
+
 	return 0;
 }
 EXPORT_SYMBOL(xt_compat_check_entry_offsets);
@@ -596,6 +607,10 @@ int xt_check_entry_offsets(const void *base,
 	if (target_offset + t->u.target_size > next_offset)
 		return -EINVAL;
 
+	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) == 0 &&
+	    target_offset + sizeof(struct xt_standard_target) != next_offset)
+		return -EINVAL;
+
 	return 0;
 }
 EXPORT_SYMBOL(xt_check_entry_offsets);
-- 
2.1.4

