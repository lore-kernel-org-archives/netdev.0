From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 1/4] tc, bpf, examples: further bpf_api improvements
Date: Tue,  2 Feb 2016 01:12:26 +0100
Message-ID: <de6a20f051ae612cfa23396eab591726b688f24b.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41818 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbcBBAMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:12:45 -0500
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a couple of improvements to tc's BPF api, that facilitate program
development.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 examples/bpf/bpf_cyclic.c   |  4 +---
 examples/bpf/bpf_graft.c    | 13 +++--------
 examples/bpf/bpf_prog.c     | 26 ++++++++++-----------
 examples/bpf/bpf_shared.c   |  3 +--
 examples/bpf/bpf_tailcall.c | 12 ++++------
 include/bpf_api.h           | 56 ++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 70 insertions(+), 44 deletions(-)

diff --git a/examples/bpf/bpf_cyclic.c b/examples/bpf/bpf_cyclic.c
index c66cbec..36745a3 100644
--- a/examples/bpf/bpf_cyclic.c
+++ b/examples/bpf/bpf_cyclic.c
@@ -11,9 +11,7 @@ BPF_PROG_ARRAY(jmp_tc, JMP_MAP_ID, PIN_OBJECT_NS, 1);
 __section_tail(JMP_MAP_ID, 0)
 int cls_loop(struct __sk_buff *skb)
 {
-	char fmt[] = "cb: %u\n";
-
-	trace_printk(fmt, sizeof(fmt), skb->cb[0]++);
+	printt("cb: %u\n", skb->cb[0]++);
 	tail_call(skb, &jmp_tc, 0);
 
 	skb->tc_classid = TC_H_MAKE(1, 42);
diff --git a/examples/bpf/bpf_graft.c b/examples/bpf/bpf_graft.c
index f48fd02..20784ff 100644
--- a/examples/bpf/bpf_graft.c
+++ b/examples/bpf/bpf_graft.c
@@ -38,29 +38,22 @@ BPF_PROG_ARRAY(jmp_tc, 0, PIN_GLOBAL_NS, 1);
 __section("aaa")
 int cls_aaa(struct __sk_buff *skb)
 {
-	char fmt[] = "aaa\n";
-
-	trace_printk(fmt, sizeof(fmt));
+	printt("aaa\n");
 	return TC_H_MAKE(1, 42);
 }
 
 __section("bbb")
 int cls_bbb(struct __sk_buff *skb)
 {
-	char fmt[] = "bbb\n";
-
-	trace_printk(fmt, sizeof(fmt));
+	printt("bbb\n");
 	return TC_H_MAKE(1, 43);
 }
 
 __section_cls_entry
 int cls_entry(struct __sk_buff *skb)
 {
-	char fmt[] = "fallthrough\n";
-
 	tail_call(skb, &jmp_tc, 0);
-	trace_printk(fmt, sizeof(fmt));
-
+	printt("fallthrough\n");
 	return BPF_H_DEFAULT;
 }
 
diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
index 4728049..f15e876 100644
--- a/examples/bpf/bpf_prog.c
+++ b/examples/bpf/bpf_prog.c
@@ -233,7 +233,7 @@ struct flow_keys {
 	__u8 ip_proto;
 };
 
-static inline int flow_ports_offset(__u8 ip_proto)
+static __inline__ int flow_ports_offset(__u8 ip_proto)
 {
 	switch (ip_proto) {
 	case IPPROTO_TCP:
@@ -249,14 +249,14 @@ static inline int flow_ports_offset(__u8 ip_proto)
 	}
 }
 
-static inline bool flow_is_frag(struct __sk_buff *skb, int nh_off)
+static __inline__ bool flow_is_frag(struct __sk_buff *skb, int nh_off)
 {
 	return !!(load_half(skb, nh_off + offsetof(struct iphdr, frag_off)) &
 		  (IP_MF | IP_OFFSET));
 }
 
-static inline int flow_parse_ipv4(struct __sk_buff *skb, int nh_off,
-				  __u8 *ip_proto, struct flow_keys *flow)
+static __inline__ int flow_parse_ipv4(struct __sk_buff *skb, int nh_off,
+				      __u8 *ip_proto, struct flow_keys *flow)
 {
 	__u8 ip_ver_len;
 
@@ -279,7 +279,7 @@ static inline int flow_parse_ipv4(struct __sk_buff *skb, int nh_off,
 	return nh_off;
 }
 
-static inline __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, int off)
+static __inline__ __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, int off)
 {
 	__u32 w0 = load_word(skb, off);
 	__u32 w1 = load_word(skb, off + sizeof(w0));
@@ -289,8 +289,8 @@ static inline __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, int off)
 	return w0 ^ w1 ^ w2 ^ w3;
 }
 
-static inline int flow_parse_ipv6(struct __sk_buff *skb, int nh_off,
-				  __u8 *ip_proto, struct flow_keys *flow)
+static __inline__ int flow_parse_ipv6(struct __sk_buff *skb, int nh_off,
+				      __u8 *ip_proto, struct flow_keys *flow)
 {
 	*ip_proto = load_byte(skb, nh_off + offsetof(struct ipv6hdr, nexthdr));
 
@@ -300,8 +300,8 @@ static inline int flow_parse_ipv6(struct __sk_buff *skb, int nh_off,
 	return nh_off + sizeof(struct ipv6hdr);
 }
 
-static inline bool flow_dissector(struct __sk_buff *skb,
-				  struct flow_keys *flow)
+static __inline__ bool flow_dissector(struct __sk_buff *skb,
+				      struct flow_keys *flow)
 {
 	int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
 	__be16 proto = skb->protocol;
@@ -381,8 +381,8 @@ static inline bool flow_dissector(struct __sk_buff *skb,
 	return true;
 }
 
-static inline void cls_update_proto_map(const struct __sk_buff *skb,
-					const struct flow_keys *flow)
+static __inline__ void cls_update_proto_map(const struct __sk_buff *skb,
+					    const struct flow_keys *flow)
 {
 	uint8_t proto = flow->ip_proto;
 	struct count_tuple *ct, _ct;
@@ -401,7 +401,7 @@ static inline void cls_update_proto_map(const struct __sk_buff *skb,
 	map_update_elem(&map_proto, &proto, &_ct, BPF_ANY);
 }
 
-static inline void cls_update_queue_map(const struct __sk_buff *skb)
+static __inline__ void cls_update_queue_map(const struct __sk_buff *skb)
 {
 	uint32_t queue = skb->queue_mapping;
 	struct count_queue *cq, _cq;
@@ -453,7 +453,7 @@ int cls_main(struct __sk_buff *skb)
 	return flow.ip_proto;
 }
 
-static inline void act_update_drop_map(void)
+static __inline__ void act_update_drop_map(void)
 {
 	uint32_t *count, cpu = get_smp_processor_id();
 
diff --git a/examples/bpf/bpf_shared.c b/examples/bpf/bpf_shared.c
index accc0ad..7fe9ef3 100644
--- a/examples/bpf/bpf_shared.c
+++ b/examples/bpf/bpf_shared.c
@@ -35,12 +35,11 @@ int emain(struct __sk_buff *skb)
 __section("ingress")
 int imain(struct __sk_buff *skb)
 {
-	char fmt[] = "map val: %d\n";
 	int key = 0, *val;
 
 	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		trace_printk(fmt, sizeof(fmt), *val);
+		printt("map val: %d\n", *val);
 
 	return BPF_H_DEFAULT;
 }
diff --git a/examples/bpf/bpf_tailcall.c b/examples/bpf/bpf_tailcall.c
index 040790d..f545430 100644
--- a/examples/bpf/bpf_tailcall.c
+++ b/examples/bpf/bpf_tailcall.c
@@ -34,12 +34,11 @@ BPF_ARRAY4(map_sh, 0, PIN_OBJECT_NS, 1);
 __section_tail(FOO, ENTRY_0)
 int cls_case1(struct __sk_buff *skb)
 {
-	char fmt[] = "case1: map-val: %d from:%u\n";
 	int key = 0, *val;
 
 	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		printt("case1: map-val: %d from:%u\n", *val, skb->cb[0]);
 
 	skb->cb[0] = ENTRY_0;
 	tail_call(skb, &jmp_ex, ENTRY_0);
@@ -50,12 +49,11 @@ int cls_case1(struct __sk_buff *skb)
 __section_tail(FOO, ENTRY_1)
 int cls_case2(struct __sk_buff *skb)
 {
-	char fmt[] = "case2: map-val: %d from:%u\n";
 	int key = 0, *val;
 
 	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		printt("case2: map-val: %d from:%u\n", *val, skb->cb[0]);
 
 	skb->cb[0] = ENTRY_1;
 	tail_call(skb, &jmp_tc, ENTRY_0);
@@ -66,12 +64,11 @@ int cls_case2(struct __sk_buff *skb)
 __section_tail(BAR, ENTRY_0)
 int cls_exit(struct __sk_buff *skb)
 {
-	char fmt[] = "exit: map-val: %d from:%u\n";
 	int key = 0, *val;
 
 	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		printt("exit: map-val: %d from:%u\n", *val, skb->cb[0]);
 
 	/* Termination point. */
 	return BPF_H_DEFAULT;
@@ -80,7 +77,6 @@ int cls_exit(struct __sk_buff *skb)
 __section_cls_entry
 int cls_entry(struct __sk_buff *skb)
 {
-	char fmt[] = "fallthrough\n";
 	int key = 0, *val;
 
 	/* For transferring state, we can use skb->cb[0] ... skb->cb[4]. */
@@ -92,7 +88,7 @@ int cls_entry(struct __sk_buff *skb)
 		tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));
 	}
 
-	trace_printk(fmt, sizeof(fmt));
+	printt("fallthrough\n");
 	return BPF_H_DEFAULT;
 }
 
diff --git a/include/bpf_api.h b/include/bpf_api.h
index 0666a31..4b16d25 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -56,6 +56,10 @@
 # define ntohl(X)		__constant_ntohl((X))
 #endif
 
+#ifndef __inline__
+# define __inline__		__attribute__((always_inline))
+#endif
+
 /** Section helper macros. */
 
 #ifndef __section
@@ -146,7 +150,7 @@
 # define BPF_H_DEFAULT	-1
 #endif
 
-/** BPF helper functions for tc. */
+/** BPF helper functions for tc. Individual flags are in linux/bpf.h */
 
 #ifndef BPF_FUNC
 # define BPF_FUNC(NAME, ...)						\
@@ -163,8 +167,22 @@ static int BPF_FUNC(map_delete_elem, void *map, const void *key);
 static uint64_t BPF_FUNC(ktime_get_ns);
 
 /* Debugging */
+
+/* FIXME: __attribute__ ((format(printf, 1, 3))) not possible unless
+ * llvm bug https://llvm.org/bugs/show_bug.cgi?id=26243 gets resolved.
+ * It would require ____fmt to be made const, which generates a reloc
+ * entry (non-map).
+ */
 static void BPF_FUNC(trace_printk, const char *fmt, int fmt_size, ...);
 
+#ifndef printt
+# define printt(fmt, ...)						\
+	({								\
+		char ____fmt[] = fmt;					\
+		trace_printk(____fmt, sizeof(____fmt), ##__VA_ARGS__);	\
+	})
+#endif
+
 /* Random numbers */
 static uint32_t BPF_FUNC(get_prandom_u32);
 
@@ -185,12 +203,11 @@ static int BPF_FUNC(clone_redirect, struct __sk_buff *skb, int ifindex,
 		    uint32_t flags);
 
 /* Packet manipulation */
-#define BPF_PSEUDO_HDR			0x10
-#define BPF_HAS_PSEUDO_HDR(flags)	((flags) & BPF_PSEUDO_HDR)
-#define BPF_HDR_FIELD_SIZE(flags)	((flags) & 0x0f)
-
+static int BPF_FUNC(skb_load_bytes, struct __sk_buff *skb, uint32_t off,
+		    void *to, uint32_t len);
 static int BPF_FUNC(skb_store_bytes, struct __sk_buff *skb, uint32_t off,
-		    void *from, uint32_t len, uint32_t flags);
+		    const void *from, uint32_t len, uint32_t flags);
+
 static int BPF_FUNC(l3_csum_replace, struct __sk_buff *skb, uint32_t off,
 		    uint32_t from, uint32_t to, uint32_t flags);
 static int BPF_FUNC(l4_csum_replace, struct __sk_buff *skb, uint32_t off,
@@ -205,14 +222,37 @@ static int BPF_FUNC(skb_vlan_pop, struct __sk_buff *skb);
 static int BPF_FUNC(skb_get_tunnel_key, struct __sk_buff *skb,
 		    struct bpf_tunnel_key *to, uint32_t size, uint32_t flags);
 static int BPF_FUNC(skb_set_tunnel_key, struct __sk_buff *skb,
-		    struct bpf_tunnel_key *from, uint32_t size, uint32_t flags);
+		    const struct bpf_tunnel_key *from, uint32_t size,
+		    uint32_t flags);
 
-/** LLVM built-ins */
+/** LLVM built-ins, mem*() routines work for constant size */
 
 #ifndef lock_xadd
 # define lock_xadd(ptr, val)	((void) __sync_fetch_and_add(ptr, val))
 #endif
 
+#ifndef memset
+# define memset(s, c, n)	__builtin_memset((s), (c), (n))
+#endif
+
+#ifndef memcpy
+# define memcpy(d, s, n)	__builtin_memcpy((d), (s), (n))
+#endif
+
+#ifndef memmove
+# define memmove(d, s, n)	__builtin_memmove((d), (s), (n))
+#endif
+
+/* FIXME: __builtin_memcmp() is not yet fully useable unless llvm bug
+ * https://llvm.org/bugs/show_bug.cgi?id=26218 gets resolved. Also
+ * this one would generate a reloc entry (non-map), otherwise.
+ */
+#if 0
+#ifndef memcmp
+# define memcmp(a, b, n)	__builtin_memcmp((a), (b), (n))
+#endif
+#endif
+
 unsigned long long load_byte(void *skb, unsigned long long off)
 	asm ("llvm.bpf.load.byte");
 
-- 
1.9.3
