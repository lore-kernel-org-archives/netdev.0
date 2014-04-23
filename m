From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/5] net: filter: misc/various cleanups
Date: Wed, 23 Apr 2014 22:56:58 +0200
Message-ID: <1398286621-3591-3-git-send-email-dborkman@redhat.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932643AbaDWU5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 16:57:14 -0400
In-Reply-To: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This contains only some minor misc cleanpus. We can spare us the
extra variable declaration in __skb_get_pay_offset(), we can mark
some unexpected conditions in the fast-path as unlikely(), the
cast in __get_random_u32() is rather unnecessary and in
__sk_migrate_realloc() we can remove the memcpy() and do a direct
assignment of the structs. Latter was suggested by Fengguang Wu
found with coccinelle.

Suggested-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index a1784e9..2fd2293 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -57,9 +57,9 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 		ptr = skb_network_header(skb) + k - SKF_NET_OFF;
 	else if (k >= SKF_LL_OFF)
 		ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
-
 	if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
 		return ptr;
+
 	return NULL;
 }
 
@@ -68,6 +68,7 @@ static inline void *load_pointer(const struct sk_buff *skb, int k,
 {
 	if (k >= 0)
 		return skb_header_pointer(skb, k, size, buffer);
+
 	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
@@ -596,9 +597,7 @@ static unsigned int pkt_type_offset(void)
 
 static u64 __skb_get_pay_offset(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) ctx;
-
-	return __skb_get_poff(skb);
+	return __skb_get_poff((struct sk_buff *)(long) ctx);
 }
 
 static u64 __skb_get_nlattr(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
@@ -609,10 +608,10 @@ static u64 __skb_get_nlattr(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 	if (skb_is_nonlinear(skb))
 		return 0;
 
-	if (skb->len < sizeof(struct nlattr))
+	if (unlikely(skb->len < sizeof(struct nlattr)))
 		return 0;
 
-	if (A > skb->len - sizeof(struct nlattr))
+	if (unlikely(A > skb->len - sizeof(struct nlattr)))
 		return 0;
 
 	nla = nla_find((struct nlattr *) &skb->data[A], skb->len - A, X);
@@ -630,14 +629,14 @@ static u64 __skb_get_nlattr_nest(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 	if (skb_is_nonlinear(skb))
 		return 0;
 
-	if (skb->len < sizeof(struct nlattr))
+	if (unlikely(skb->len < sizeof(struct nlattr)))
 		return 0;
 
-	if (A > skb->len - sizeof(struct nlattr))
+	if (unlikely(A > skb->len - sizeof(struct nlattr)))
 		return 0;
 
 	nla = (struct nlattr *) &skb->data[A];
-	if (nla->nla_len > skb->len - A)
+	if (unlikely(nla->nla_len > skb->len - A))
 		return 0;
 
 	nla = nla_find_nested(nla, X);
@@ -655,7 +654,7 @@ static u64 __get_raw_cpu_id(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 /* note that this only generates 32-bit random numbers */
 static u64 __get_random_u32(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 {
-	return (u64)prandom_u32();
+	return prandom_u32();
 }
 
 static bool convert_bpf_extensions(struct sock_filter *fp,
@@ -1472,7 +1471,7 @@ static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
 
 	fp_new = sock_kmalloc(sk, len, GFP_KERNEL);
 	if (fp_new) {
-		memcpy(fp_new, fp, sizeof(struct sk_filter));
+		*fp_new = *fp;
 		/* As we're kepping orig_prog in fp_new along,
 		 * we need to make sure we're not evicting it
 		 * from the old fp.
-- 
1.7.11.7
