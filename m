From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 3/3] net: filter: misc/various cleanups
Date: Thu,  1 May 2014 18:16:36 +0200
Message-ID: <1398960996-10469-4-git-send-email-dborkman@redhat.com>
References: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbaEAQQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 12:16:57 -0400
In-Reply-To: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This contains only some minor misc cleanpus. We can spare us the
extra variable declaration in __skb_get_pay_offset(), the cast in
__get_random_u32() is rather unnecessary and in __sk_migrate_realloc()
we can remove the memcpy() and do a direct assignment of the structs.
Latter was suggested by Fengguang Wu found with coccinelle. Also,
remaining pointer casts of long should be unsigned long instead.

Suggested-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index c93ca8d..36cfceb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -78,9 +78,9 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 		ptr = skb_network_header(skb) + k - SKF_NET_OFF;
 	else if (k >= SKF_LL_OFF)
 		ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
-
 	if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
 		return ptr;
+
 	return NULL;
 }
 
@@ -89,6 +89,7 @@ static inline void *load_pointer(const struct sk_buff *skb, int k,
 {
 	if (k >= 0)
 		return skb_header_pointer(skb, k, size, buffer);
+
 	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
@@ -598,14 +599,12 @@ static unsigned int pkt_type_offset(void)
 
 static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) ctx;
-
-	return __skb_get_poff(skb);
+	return __skb_get_poff((struct sk_buff *)(long unsigned) ctx);
 }
 
 static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) ctx;
+	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
 
 	if (skb_is_nonlinear(skb))
@@ -626,7 +625,7 @@ static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 
 static u64 __skb_get_nlattr_nest(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
-	struct sk_buff *skb = (struct sk_buff *)(long) ctx;
+	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
 	struct nlattr *nla;
 
 	if (skb_is_nonlinear(skb))
@@ -657,7 +656,7 @@ static u64 __get_raw_cpu_id(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 /* note that this only generates 32-bit random numbers */
 static u64 __get_random_u32(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
-	return (u64)prandom_u32();
+	return prandom_u32();
 }
 
 static bool convert_bpf_extensions(struct sock_filter *fp,
@@ -1475,7 +1474,7 @@ static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
 
 	fp_new = sock_kmalloc(sk, len, GFP_KERNEL);
 	if (fp_new) {
-		memcpy(fp_new, fp, sizeof(struct sk_filter));
+		*fp_new = *fp;
 		/* As we're kepping orig_prog in fp_new along,
 		 * we need to make sure we're not evicting it
 		 * from the old fp.
-- 
1.7.11.7
