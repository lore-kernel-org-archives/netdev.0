From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/27] xtables: use match, target and data copy_to_user helpers in compat
Date: Fri,  3 Feb 2017 13:25:24 +0100
Message-ID: <1486124738-3013-14-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

Convert compat to copying entries, matches and targets one by one,
using the xt_match_to_user and xt_target_to_user helper functions.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index feccf527abdd..016db6be94b9 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -619,17 +619,14 @@ int xt_compat_match_to_user(const struct xt_entry_match *m,
 	int off = xt_compat_match_offset(match);
 	u_int16_t msize = m->u.user.match_size - off;
 
-	if (copy_to_user(cm, m, sizeof(*cm)) ||
-	    put_user(msize, &cm->u.user.match_size) ||
-	    copy_to_user(cm->u.user.name, m->u.kernel.match->name,
-			 strlen(m->u.kernel.match->name) + 1))
+	if (XT_OBJ_TO_USER(cm, m, match, msize))
 		return -EFAULT;
 
 	if (match->compat_to_user) {
 		if (match->compat_to_user((void __user *)cm->data, m->data))
 			return -EFAULT;
 	} else {
-		if (copy_to_user(cm->data, m->data, msize - sizeof(*cm)))
+		if (XT_DATA_TO_USER(cm, m, match, msize - sizeof(*cm)))
 			return -EFAULT;
 	}
 
@@ -977,17 +974,14 @@ int xt_compat_target_to_user(const struct xt_entry_target *t,
 	int off = xt_compat_target_offset(target);
 	u_int16_t tsize = t->u.user.target_size - off;
 
-	if (copy_to_user(ct, t, sizeof(*ct)) ||
-	    put_user(tsize, &ct->u.user.target_size) ||
-	    copy_to_user(ct->u.user.name, t->u.kernel.target->name,
-			 strlen(t->u.kernel.target->name) + 1))
+	if (XT_OBJ_TO_USER(ct, t, target, tsize))
 		return -EFAULT;
 
 	if (target->compat_to_user) {
 		if (target->compat_to_user((void __user *)ct->data, t->data))
 			return -EFAULT;
 	} else {
-		if (copy_to_user(ct->data, t->data, tsize - sizeof(*ct)))
+		if (XT_DATA_TO_USER(ct, t, target, tsize - sizeof(*ct)))
 			return -EFAULT;
 	}
 
-- 
2.1.4

