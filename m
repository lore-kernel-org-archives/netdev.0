From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCHv2 net-next] net: filter: move load_pointer() into filter.h
Date: Thu,  3 Jul 2014 07:56:54 -0700
Message-ID: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

load_pointer() is already a static inline function.
Let's move it into filter.h so BPF JIT implementations can reuse this
function.

Since we're exporting this function, let's also rename it to
bpf_load_pointer() for clarity.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
v1->v2:
* Renamed to more specific name of bpf_load_pointer(), as suggested
  by Daniel.

This patch is based on discussion with Alexei in the context of
reusing load_pointer for upcoming arm64 BPF JIT compiler. [1]
Compile tested on x86_64 and arm64.

[1] https://lkml.org/lkml/2014/7/3/14

 include/linux/filter.h | 13 +++++++++++++
 net/core/filter.c      | 15 +++------------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index a7e3c48..b885dcb 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -6,6 +6,7 @@
 
 #include <linux/atomic.h>
 #include <linux/compat.h>
+#include <linux/skbuff.h>
 #include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
 
@@ -406,6 +407,18 @@ static inline u16 bpf_anc_helper(const struct sock_filter *ftest)
 	}
 }
 
+void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
+					   int k, unsigned int size);
+
+static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
+				     unsigned int size, void *buffer)
+{
+	if (k >= 0)
+		return skb_header_pointer(skb, k, size, buffer);
+
+	return bpf_internal_load_pointer_neg_helper(skb, k, size);
+}
+
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
diff --git a/net/core/filter.c b/net/core/filter.c
index 1dbf646..87af1e3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -84,15 +84,6 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 	return NULL;
 }
 
-static inline void *load_pointer(const struct sk_buff *skb, int k,
-				 unsigned int size, void *buffer)
-{
-	if (k >= 0)
-		return skb_header_pointer(skb, k, size, buffer);
-
-	return bpf_internal_load_pointer_neg_helper(skb, k, size);
-}
-
 /**
  *	sk_filter - run a packet through a socket filter
  *	@sk: sock associated with &sk_buff
@@ -537,7 +528,7 @@ load_word:
 		 *   BPF_R0 - 8/16/32-bit skb data converted to cpu endianness
 		 */
 
-		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 4, &tmp);
+		ptr = bpf_load_pointer((struct sk_buff *) (unsigned long) CTX, off, 4, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be32(ptr);
 			CONT;
@@ -547,7 +538,7 @@ load_word:
 	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + imm32)) */
 		off = IMM;
 load_half:
-		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 2, &tmp);
+		ptr = bpf_load_pointer((struct sk_buff *) (unsigned long) CTX, off, 2, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be16(ptr);
 			CONT;
@@ -557,7 +548,7 @@ load_half:
 	LD_ABS_B: /* BPF_R0 = *(u8 *) (skb->data + imm32) */
 		off = IMM;
 load_byte:
-		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 1, &tmp);
+		ptr = bpf_load_pointer((struct sk_buff *) (unsigned long) CTX, off, 1, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = *(u8 *)ptr;
 			CONT;
-- 
1.9.1
