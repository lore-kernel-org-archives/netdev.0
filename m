From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 3/3] tc, bpf: add support for map pre/allocation
Date: Sat,  9 Apr 2016 00:32:05 +0200
Message-ID: <b4d91dc38317a513ad6bbdab2be29c61db259c15.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39607 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbcDHWcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:32:19 -0400
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to kernel commit 6c9059817432 ("bpf: pre-allocate hash map
elements"). Add flags support, so that we can pass in BPF_F_NO_PREALLOC
flag for disallowing preallocation. Update examples accordingly and also
remove the BPF_* map helper macros from them as they were not very useful.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 examples/bpf/bpf_cyclic.c   |  9 ++++++++-
 examples/bpf/bpf_graft.c    |  8 +++++++-
 examples/bpf/bpf_prog.c     |  2 ++
 examples/bpf/bpf_shared.c   |  8 +++++++-
 examples/bpf/bpf_tailcall.c | 29 +++++++++++++++++++++++++----
 include/bpf_api.h           | 45 ---------------------------------------------
 include/bpf_elf.h           |  1 +
 tc/tc_bpf.c                 | 16 ++++++++++++----
 8 files changed, 62 insertions(+), 56 deletions(-)

diff --git a/examples/bpf/bpf_cyclic.c b/examples/bpf/bpf_cyclic.c
index 36745a3..11d1c06 100644
--- a/examples/bpf/bpf_cyclic.c
+++ b/examples/bpf/bpf_cyclic.c
@@ -6,7 +6,14 @@
  */
 #define JMP_MAP_ID	0xabccba
 
-BPF_PROG_ARRAY(jmp_tc, JMP_MAP_ID, PIN_OBJECT_NS, 1);
+struct bpf_elf_map __section_maps jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= JMP_MAP_ID,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
 
 __section_tail(JMP_MAP_ID, 0)
 int cls_loop(struct __sk_buff *skb)
diff --git a/examples/bpf/bpf_graft.c b/examples/bpf/bpf_graft.c
index 20784ff..07113d4 100644
--- a/examples/bpf/bpf_graft.c
+++ b/examples/bpf/bpf_graft.c
@@ -33,7 +33,13 @@
  *   [...]
  */
 
-BPF_PROG_ARRAY(jmp_tc, 0, PIN_GLOBAL_NS, 1);
+struct bpf_elf_map __section_maps jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_GLOBAL_NS,
+	.max_elem	= 1,
+};
 
 __section("aaa")
 int cls_aaa(struct __sk_buff *skb)
diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
index f15e876..d6caf37 100644
--- a/examples/bpf/bpf_prog.c
+++ b/examples/bpf/bpf_prog.c
@@ -192,6 +192,7 @@ struct bpf_elf_map __section("maps") map_proto = {
 	.size_key	=	sizeof(uint8_t),
 	.size_value	=	sizeof(struct count_tuple),
 	.max_elem	=	256,
+	.flags		=	BPF_F_NO_PREALLOC,
 };
 
 struct bpf_elf_map __section("maps") map_queue = {
@@ -200,6 +201,7 @@ struct bpf_elf_map __section("maps") map_queue = {
 	.size_key	=	sizeof(uint32_t),
 	.size_value	=	sizeof(struct count_queue),
 	.max_elem	=	1024,
+	.flags		=	BPF_F_NO_PREALLOC,
 };
 
 struct bpf_elf_map __section("maps") map_drops = {
diff --git a/examples/bpf/bpf_shared.c b/examples/bpf/bpf_shared.c
index 7fe9ef3..21fe6f1 100644
--- a/examples/bpf/bpf_shared.c
+++ b/examples/bpf/bpf_shared.c
@@ -18,7 +18,13 @@
  * instance is being created.
  */
 
-BPF_ARRAY4(map_sh, 0, PIN_OBJECT_NS, 1); /* or PIN_GLOBAL_NS, or PIN_NONE */
+struct bpf_elf_map __section_maps map_sh = {
+	.type		= BPF_MAP_TYPE_ARRAY,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_OBJECT_NS, /* or PIN_GLOBAL_NS, or PIN_NONE */
+	.max_elem	= 1,
+};
 
 __section("egress")
 int emain(struct __sk_buff *skb)
diff --git a/examples/bpf/bpf_tailcall.c b/examples/bpf/bpf_tailcall.c
index f545430..1a30426 100644
--- a/examples/bpf/bpf_tailcall.c
+++ b/examples/bpf/bpf_tailcall.c
@@ -26,10 +26,31 @@
  * classifier behaviour.
  */
 
-BPF_PROG_ARRAY(jmp_tc, FOO, PIN_OBJECT_NS, MAX_JMP_SIZE);
-BPF_PROG_ARRAY(jmp_ex, BAR, PIN_OBJECT_NS, 1);
-
-BPF_ARRAY4(map_sh, 0, PIN_OBJECT_NS, 1);
+struct bpf_elf_map __section_maps jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= FOO,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= MAX_JMP_SIZE,
+};
+
+struct bpf_elf_map __section_maps jmp_ex = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= BAR,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
+
+struct bpf_elf_map __section_maps map_sh = {
+	.type		= BPF_MAP_TYPE_ARRAY,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
 
 __section_tail(FOO, ENTRY_0)
 int cls_case1(struct __sk_buff *skb)
diff --git a/include/bpf_api.h b/include/bpf_api.h
index 0f278f0..1b250d2 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -99,51 +99,6 @@
 	char ____license[] __section_license = NAME
 #endif
 
-#ifndef __BPF_MAP
-# define __BPF_MAP(NAME, TYPE, ID, SIZE_KEY, SIZE_VALUE, PIN, MAX_ELEM)	\
-	struct bpf_elf_map __section_maps NAME = {			\
-		.type		= (TYPE),				\
-		.id		= (ID),					\
-		.size_key	= (SIZE_KEY),				\
-		.size_value	= (SIZE_VALUE),				\
-		.pinning	= (PIN),				\
-		.max_elem	= (MAX_ELEM),				\
-	}
-#endif
-
-#ifndef BPF_HASH
-# define BPF_HASH(NAME, ID, SIZE_KEY, SIZE_VALUE, PIN, MAX_ELEM)	\
-	__BPF_MAP(NAME, BPF_MAP_TYPE_HASH, ID, SIZE_KEY, SIZE_VALUE,	\
-		  PIN, MAX_ELEM)
-#endif
-
-#ifndef BPF_ARRAY
-# define BPF_ARRAY(NAME, ID, SIZE_VALUE, PIN, MAX_ELEM)			\
-	__BPF_MAP(NAME, BPF_MAP_TYPE_ARRAY, ID, sizeof(uint32_t), 	\
-		  SIZE_VALUE, PIN, MAX_ELEM)
-#endif
-
-#ifndef BPF_ARRAY2
-# define BPF_ARRAY2(NAME, ID, PIN, MAX_ELEM)				\
-	BPF_ARRAY(NAME, ID, sizeof(uint16_t), PIN, MAX_ELEM)
-#endif
-
-#ifndef BPF_ARRAY4
-# define BPF_ARRAY4(NAME, ID, PIN, MAX_ELEM)				\
-	BPF_ARRAY(NAME, ID, sizeof(uint32_t), PIN, MAX_ELEM)
-#endif
-
-#ifndef BPF_ARRAY8
-# define BPF_ARRAY8(NAME, ID, PIN, MAX_ELEM)				\
-	BPF_ARRAY(NAME, ID, sizeof(uint64_t), PIN, MAX_ELEM)
-#endif
-
-#ifndef BPF_PROG_ARRAY
-# define BPF_PROG_ARRAY(NAME, ID, PIN, MAX_ELEM)			\
-	__BPF_MAP(NAME, BPF_MAP_TYPE_PROG_ARRAY, ID, sizeof(uint32_t),	\
-		  sizeof(uint32_t), PIN, MAX_ELEM)
-#endif
-
 /** Classifier helper */
 
 #ifndef BPF_H_DEFAULT
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
index 31a8974..36cc988 100644
--- a/include/bpf_elf.h
+++ b/include/bpf_elf.h
@@ -32,6 +32,7 @@ struct bpf_elf_map {
 	__u32 size_key;
 	__u32 size_value;
 	__u32 max_elem;
+	__u32 flags;
 	__u32 id;
 	__u32 pinning;
 };
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 0c59427..fe927ac 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -231,6 +231,9 @@ static void bpf_map_pin_report(const struct bpf_elf_map *pin,
 	if (obj->max_elem != pin->max_elem)
 		fprintf(stderr, " - Max elems:    %u (obj) != %u (pin)\n",
 			obj->max_elem, pin->max_elem);
+	if (obj->flags != pin->flags)
+		fprintf(stderr, " - Flags:        %#x (obj) != %#x (pin)\n",
+			obj->flags, pin->flags);
 
 	fprintf(stderr, "\n");
 }
@@ -261,6 +264,8 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 			tmp.size_value = val;
 		else if (sscanf(buff, "max_entries:\t%u", &val) == 1)
 			tmp.max_elem = val;
+		else if (sscanf(buff, "map_flags:\t%i", &val) == 1)
+			tmp.flags = val;
 	}
 
 	fclose(fp);
@@ -796,8 +801,9 @@ static int bpf_log_realloc(struct bpf_elf_ctx *ctx)
 	return 0;
 }
 
-static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
-			  unsigned int size_value, unsigned int max_elem)
+static int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
+			  uint32_t size_value, uint32_t max_elem,
+			  uint32_t flags)
 {
 	union bpf_attr attr;
 
@@ -806,6 +812,7 @@ static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 	attr.key_size = size_key;
 	attr.value_size = size_value;
 	attr.max_entries = max_elem;
+	attr.map_flags = flags;
 
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
@@ -1147,7 +1154,8 @@ static void bpf_map_report(int fd, const char *name,
 	fprintf(stderr, " - Pinning:      %u\n", map->pinning);
 	fprintf(stderr, " - Size key:     %u\n", map->size_key);
 	fprintf(stderr, " - Size value:   %u\n", map->size_value);
-	fprintf(stderr, " - Max elems:    %u\n\n", map->max_elem);
+	fprintf(stderr, " - Max elems:    %u\n", map->max_elem);
+	fprintf(stderr, " - Flags:        %#x\n\n", map->flags);
 }
 
 static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
@@ -1174,7 +1182,7 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 
 	errno = 0;
 	fd = bpf_map_create(map->type, map->size_key, map->size_value,
-			    map->max_elem);
+			    map->max_elem, map->flags);
 	if (fd < 0 || ctx->verbose) {
 		bpf_map_report(fd, name, map, ctx);
 		if (fd < 0)
-- 
1.9.3
