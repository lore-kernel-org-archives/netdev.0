From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH] tools lib bpf: fix maps resolution
Date: Tue, 8 Nov 2016 21:57:34 +0000
Message-ID: <20161108215734.28905-1-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <pi3orama@huawei.com>, Wang Nan <wangnan0@huawei.com>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Li Zefan <lizefan@huawei.com>
To: <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:23695 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751725AbcKHV7S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:59:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

It is not correct to assimilate the elf data of the maps section
to an array of map definition. In fact the sizes differ. The
offset provided in the symbol section has to be used instead.

This patch fixes a bug causing a elf with two maps not to load
correctly.

Wang Nan added:

This patch requires a name for each BPF map, so array of BPF maps is
not allowed. This restriction is reasonable, because kernel verifier
forbid indexing BPF map from such array unless the index is a fixed
value, but if the index is fixed why not merging it into name?

For example:

Program like this:
  ...
  unsigned long cpu = get_smp_processor_id();
  int *pval = map_lookup_elem(&map_array[cpu], &key);
  ...

Generates bytecode like this:

0: (b7) r1 = 0
1: (63) *(u32 *)(r10 -4) = r1
2: (b7) r1 = 680997
3: (63) *(u32 *)(r10 -8) = r1
4: (85) call 8
5: (67) r0 <<= 4
6: (18) r1 = 0x112dd000
8: (0f) r0 += r1
9: (bf) r2 = r10
10: (07) r2 += -4
11: (bf) r1 = r0
12: (85) call 1

Where instruction 8 is the computation, 8 and 11 render r1 to an invalid
value for function map_lookup_elem, causes verifier report error.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
[Merge bpf_object__init_maps_name into bpf_object__init_maps
 Fix segfault for buggy BPF script
 Validate obj->maps
]
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>
---
 tools/lib/bpf/libbpf.c | 142 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 98 insertions(+), 44 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index b699aea..96a2b2f 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -185,6 +185,7 @@ struct bpf_program {
 struct bpf_map {
 	int fd;
 	char *name;
+	size_t offset;
 	struct bpf_map_def def;
 	void *priv;
 	bpf_map_clear_priv_t clear_priv;
@@ -513,57 +514,106 @@ bpf_object__init_kversion(struct bpf_object *obj,
 }
 
 static int
-bpf_object__init_maps(struct bpf_object *obj, void *data,
-		      size_t size)
+bpf_object__validate_maps(struct bpf_object *obj)
 {
-	size_t nr_maps;
 	int i;
 
-	nr_maps = size / sizeof(struct bpf_map_def);
-	if (!data || !nr_maps) {
-		pr_debug("%s doesn't need map definition\n",
-			 obj->path);
+	/*
+	 * If there's only 1 map, the only error case should have been
+	 * catched in bpf_object__init_maps().
+	 */
+	if (!obj->maps || !obj->nr_maps || (obj->nr_maps == 1))
 		return 0;
-	}
 
-	pr_debug("maps in %s: %zd bytes\n", obj->path, size);
+	for (i = 1; i < obj->nr_maps; i++) {
+		const struct bpf_map *a = &obj->maps[i - 1];
+		const struct bpf_map *b = &obj->maps[i];
 
-	obj->maps = calloc(nr_maps, sizeof(obj->maps[0]));
-	if (!obj->maps) {
-		pr_warning("alloc maps for object failed\n");
-		return -ENOMEM;
+		if (b->offset - a->offset < sizeof(struct bpf_map_def)) {
+			pr_warning("corrupted map section in %s: map \"%s\" too small\n",
+				   obj->path, a->name);
+			return -EINVAL;
+		}
 	}
-	obj->nr_maps = nr_maps;
-
-	for (i = 0; i < nr_maps; i++) {
-		struct bpf_map_def *def = &obj->maps[i].def;
+	return 0;
+}
 
-		/*
-		 * fill all fd with -1 so won't close incorrect
-		 * fd (fd=0 is stdin) when failure (zclose won't close
-		 * negative fd)).
-		 */
-		obj->maps[i].fd = -1;
+static int compare_bpf_map(const void *_a, const void *_b)
+{
+	const struct bpf_map *a = _a;
+	const struct bpf_map *b = _b;
 
-		/* Save map definition into obj->maps */
-		*def = ((struct bpf_map_def *)data)[i];
-	}
-	return 0;
+	return a->offset - b->offset;
 }
 
 static int
-bpf_object__init_maps_name(struct bpf_object *obj)
+bpf_object__init_maps(struct bpf_object *obj)
 {
-	int i;
+	int i, map_idx, nr_maps = 0;
+	Elf_Scn *scn;
+	Elf_Data *data;
 	Elf_Data *symbols = obj->efile.symbols;
 
-	if (!symbols || obj->efile.maps_shndx < 0)
+	if (obj->efile.maps_shndx < 0)
+		return -EINVAL;
+	if (!symbols)
+		return -EINVAL;
+
+	scn = elf_getscn(obj->efile.elf, obj->efile.maps_shndx);
+	if (scn)
+		data = elf_getdata(scn, NULL);
+	if (!scn || !data) {
+		pr_warning("failed to get Elf_Data from map section %d\n",
+			   obj->efile.maps_shndx);
 		return -EINVAL;
+	}
 
+	/*
+	 * Count number of maps. Each map has a name.
+	 * Array of maps is not supported: only the first element is
+	 * considered.
+	 *
+	 * TODO: Detect array of map and report error.
+	 */
 	for (i = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
 		GElf_Sym sym;
-		size_t map_idx;
+
+		if (!gelf_getsym(symbols, i, &sym))
+			continue;
+		if (sym.st_shndx != obj->efile.maps_shndx)
+			continue;
+		nr_maps++;
+	}
+
+	/* Alloc obj->maps and fill nr_maps. */
+	pr_debug("maps in %s: %d maps in %zd bytes\n", obj->path,
+		 nr_maps, data->d_size);
+
+	if (!nr_maps)
+		return 0;
+
+	obj->maps = calloc(nr_maps, sizeof(obj->maps[0]));
+	if (!obj->maps) {
+		pr_warning("alloc maps for object failed\n");
+		return -ENOMEM;
+	}
+	obj->nr_maps = nr_maps;
+
+	/*
+	 * fill all fd with -1 so won't close incorrect
+	 * fd (fd=0 is stdin) when failure (zclose won't close
+	 * negative fd)).
+	 */
+	for (i = 0; i < nr_maps; i++)
+		obj->maps[i].fd = -1;
+
+	/*
+	 * Fill obj->maps using data in "maps" section.
+	 */
+	for (i = 0, map_idx = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
+		GElf_Sym sym;
 		const char *map_name;
+		struct bpf_map_def *def;
 
 		if (!gelf_getsym(symbols, i, &sym))
 			continue;
@@ -573,21 +623,27 @@ bpf_object__init_maps_name(struct bpf_object *obj)
 		map_name = elf_strptr(obj->efile.elf,
 				      obj->efile.strtabidx,
 				      sym.st_name);
-		map_idx = sym.st_value / sizeof(struct bpf_map_def);
-		if (map_idx >= obj->nr_maps) {
-			pr_warning("index of map \"%s\" is buggy: %zu > %zu\n",
-				   map_name, map_idx, obj->nr_maps);
-			continue;
+		obj->maps[map_idx].offset = sym.st_value;
+		if (sym.st_value + sizeof(struct bpf_map_def) > data->d_size) {
+			pr_warning("corrupted maps section in %s: last map \"%s\" too small\n",
+				   obj->path, map_name);
+			return -EINVAL;
 		}
+
 		obj->maps[map_idx].name = strdup(map_name);
 		if (!obj->maps[map_idx].name) {
 			pr_warning("failed to alloc map name\n");
 			return -ENOMEM;
 		}
-		pr_debug("map %zu is \"%s\"\n", map_idx,
+		pr_debug("map %d is \"%s\"\n", map_idx,
 			 obj->maps[map_idx].name);
+		def = (struct bpf_map_def *)(data->d_buf + sym.st_value);
+		obj->maps[map_idx].def = *def;
+		map_idx++;
 	}
-	return 0;
+
+	qsort(obj->maps, obj->nr_maps, sizeof(obj->maps[0]), compare_bpf_map);
+	return bpf_object__validate_maps(obj);
 }
 
 static int bpf_object__elf_collect(struct bpf_object *obj)
@@ -645,11 +701,9 @@ static int bpf_object__elf_collect(struct bpf_object *obj)
 			err = bpf_object__init_kversion(obj,
 							data->d_buf,
 							data->d_size);
-		else if (strcmp(name, "maps") == 0) {
-			err = bpf_object__init_maps(obj, data->d_buf,
-						    data->d_size);
+		else if (strcmp(name, "maps") == 0)
 			obj->efile.maps_shndx = idx;
-		} else if (sh.sh_type == SHT_SYMTAB) {
+		else if (sh.sh_type == SHT_SYMTAB) {
 			if (obj->efile.symbols) {
 				pr_warning("bpf: multiple SYMTAB in %s\n",
 					   obj->path);
@@ -698,7 +752,7 @@ static int bpf_object__elf_collect(struct bpf_object *obj)
 		return LIBBPF_ERRNO__FORMAT;
 	}
 	if (obj->efile.maps_shndx >= 0)
-		err = bpf_object__init_maps_name(obj);
+		err = bpf_object__init_maps(obj);
 out:
 	return err;
 }
@@ -807,7 +861,7 @@ bpf_object__create_maps(struct bpf_object *obj)
 				zclose(obj->maps[j].fd);
 			return err;
 		}
-		pr_debug("create map: fd=%d\n", *pfd);
+		pr_debug("create map %s: fd=%d\n", obj->maps[i].name, *pfd);
 	}
 
 	return 0;
-- 
2.10.1
