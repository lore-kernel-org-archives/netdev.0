From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/6] bpf: try harder on clones when writing into skb
Date: Fri, 19 Feb 2016 23:05:25 +0100
Message-ID: <72f0f4b9010069aeb865c55b006c85bd5811de3c.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35341 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993093AbcBSWFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:39 -0500
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we're dealing with clones and the area is not writeable, try
harder and get a copy via pskb_expand_head(). Replace also other
occurences in tc actions with the new skb_try_make_writable().

Reported-by: Ashhad Sheikh <ashhadsheikh394@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/skbuff.h |  7 +++++++
 net/core/filter.c      | 19 ++++++++++---------
 net/sched/act_csum.c   |  8 ++------
 net/sched/act_nat.c    | 18 +++++-------------
 4 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 89b5367..6a57757 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2630,6 +2630,13 @@ static inline int skb_clone_writable(const struct sk_buff *skb, unsigned int len
 	       skb_headroom(skb) + len <= skb->hdr_len;
 }
 
+static inline int skb_try_make_writable(struct sk_buff *skb,
+					unsigned int write_len)
+{
+	return skb_cloned(skb) && !skb_clone_writable(skb, write_len) &&
+	       pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+}
+
 static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
 			    int cloned)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index ea391e6..f031b82 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1364,9 +1364,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	 */
 	if (unlikely((u32) offset > 0xffff || len > sizeof(sp->buff)))
 		return -EFAULT;
-
-	if (unlikely(skb_cloned(skb) &&
-		     !skb_clone_writable(skb, offset + len)))
+	if (unlikely(skb_try_make_writable(skb, offset + len)))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, len, sp->buff);
@@ -1439,9 +1437,7 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
-
-	if (unlikely(skb_cloned(skb) &&
-		     !skb_clone_writable(skb, offset + sizeof(sum))))
+	if (unlikely(skb_try_make_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1488,9 +1484,7 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
-
-	if (unlikely(skb_cloned(skb) &&
-		     !skb_clone_writable(skb, offset + sizeof(sum))))
+	if (unlikely(skb_try_make_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1734,6 +1728,13 @@ bool bpf_helper_changes_skb_data(void *func)
 		return true;
 	if (func == bpf_skb_vlan_pop)
 		return true;
+	if (func == bpf_skb_store_bytes)
+		return true;
+	if (func == bpf_l3_csum_replace)
+		return true;
+	if (func == bpf_l4_csum_replace)
+		return true;
+
 	return false;
 }
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index b07c535..eeb3eb3 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -105,9 +105,7 @@ static void *tcf_csum_skb_nextlayer(struct sk_buff *skb,
 	int hl = ihl + jhl;
 
 	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
-	    (skb_cloned(skb) &&
-	     !skb_clone_writable(skb, hl + ntkoff) &&
-	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+	    skb_try_make_writable(skb, hl + ntkoff))
 		return NULL;
 	else
 		return (void *)(skb_network_header(skb) + ihl);
@@ -365,9 +363,7 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
 	}
 
 	if (update_flags & TCA_CSUM_UPDATE_FLAG_IPV4HDR) {
-		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb, sizeof(*iph) + ntkoff) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		if (skb_try_make_writable(skb, sizeof(*iph) + ntkoff))
 			goto fail;
 
 		ip_send_check(ip_hdr(skb));
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index b7c4ead..27607b8 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -126,9 +126,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		addr = iph->daddr;
 
 	if (!((old_addr ^ addr) & mask)) {
-		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb, sizeof(*iph) + noff) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		if (skb_try_make_writable(skb, sizeof(*iph) + noff))
 			goto drop;
 
 		new_addr &= mask;
@@ -156,9 +154,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		struct tcphdr *tcph;
 
 		if (!pskb_may_pull(skb, ihl + sizeof(*tcph) + noff) ||
-		    (skb_cloned(skb) &&
-		     !skb_clone_writable(skb, ihl + sizeof(*tcph) + noff) &&
-		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		    skb_try_make_writable(skb, ihl + sizeof(*tcph) + noff))
 			goto drop;
 
 		tcph = (void *)(skb_network_header(skb) + ihl);
@@ -171,9 +167,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		struct udphdr *udph;
 
 		if (!pskb_may_pull(skb, ihl + sizeof(*udph) + noff) ||
-		    (skb_cloned(skb) &&
-		     !skb_clone_writable(skb, ihl + sizeof(*udph) + noff) &&
-		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		    skb_try_make_writable(skb, ihl + sizeof(*udph) + noff))
 			goto drop;
 
 		udph = (void *)(skb_network_header(skb) + ihl);
@@ -213,10 +207,8 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		if ((old_addr ^ addr) & mask)
 			break;
 
-		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb, ihl + sizeof(*icmph) +
-					     sizeof(*iph) + noff) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		if (skb_try_make_writable(skb, ihl + sizeof(*icmph) +
+					  sizeof(*iph) + noff))
 			goto drop;
 
 		icmph = (void *)(skb_network_header(skb) + ihl);
-- 
1.9.3
