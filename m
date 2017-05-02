From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/4] samples/bpf: make bpf_load.c code compatible
 with ELF maps section changes
Date: Tue, 02 May 2017 14:31:56 +0200
Message-ID: <149372831600.22268.4042215094788332751.stgit@firesoul>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdEBMcB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:32:01 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does proper parsing of the ELF "maps" section, in-order to
be both backwards and forwards compatible with changes to the map
definition struct bpf_map_def, which gets compiled into the ELF file.

The assumption is that new features with value zero, means that they
are not in-use.  For backward compatibility where loading an ELF file
with a smaller struct bpf_map_def, only copy objects ELF size, leaving
rest of loaders struct zero.  For forward compatibility where ELF file
have a larger struct bpf_map_def, only copy loaders own struct size
and verify that rest of the larger struct is zero, assuming this means
the newer feature was not activated, thus it should be safe for this
older loader to load this newer ELF file.

Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
Fixes: 409526bea3c3 ("samples/bpf: bpf_load.c detect and abort if ELF maps section size is wrong")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/bpf_load.c |  224 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 155 insertions(+), 69 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 4221dc359453..fedec29c7817 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -39,6 +39,16 @@ int event_fd[MAX_PROGS];
 int prog_cnt;
 int prog_array_fd = -1;
 
+/* Keeping relevant info on maps */
+struct bpf_map_data {
+	int fd;
+	char *name;
+	size_t elf_offset;
+	struct bpf_map_def def;
+};
+struct bpf_map_data map_data[MAX_MAPS];
+int map_data_count = 0;
+
 static int populate_prog_array(const char *event, int prog_fd)
 {
 	int ind = atoi(event), err;
@@ -186,42 +196,39 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	return 0;
 }
 
-static int load_maps(struct bpf_map_def *maps, int nr_maps,
-		     const char **map_names, fixup_map_cb fixup_map)
+static int load_maps(struct bpf_map_data *maps, int nr_maps,
+		     fixup_map_cb fixup_map)
 {
 	int i;
-	/*
-	 * Warning: Using "maps" pointing to ELF data_maps->d_buf as
-	 * an array of struct bpf_map_def is a wrong assumption about
-	 * the ELF maps section format.
-	 */
+
 	for (i = 0; i < nr_maps; i++) {
 		if (fixup_map)
-			fixup_map(&maps[i], map_names[i], i);
+			fixup_map(&maps[i].def, maps[i].name, i);
 
-		if (maps[i].type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
-		    maps[i].type == BPF_MAP_TYPE_HASH_OF_MAPS) {
-			int inner_map_fd = map_fd[maps[i].inner_map_idx];
+		if (maps[i].def.type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
+		    maps[i].def.type == BPF_MAP_TYPE_HASH_OF_MAPS) {
+			int inner_map_fd = map_fd[maps[i].def.inner_map_idx];
 
-			map_fd[i] = bpf_create_map_in_map(maps[i].type,
-							  maps[i].key_size,
-							  inner_map_fd,
-							  maps[i].max_entries,
-							  maps[i].map_flags);
+			map_fd[i] = bpf_create_map_in_map(maps[i].def.type,
+							maps[i].def.key_size,
+							inner_map_fd,
+							maps[i].def.max_entries,
+							maps[i].def.map_flags);
 		} else {
-			map_fd[i] = bpf_create_map(maps[i].type,
-						   maps[i].key_size,
-						   maps[i].value_size,
-						   maps[i].max_entries,
-						   maps[i].map_flags);
+			map_fd[i] = bpf_create_map(maps[i].def.type,
+						   maps[i].def.key_size,
+						   maps[i].def.value_size,
+						   maps[i].def.max_entries,
+						   maps[i].def.map_flags);
 		}
 		if (map_fd[i] < 0) {
 			printf("failed to create a map: %d %s\n",
 			       errno, strerror(errno));
 			return 1;
 		}
+		maps[i].fd = map_fd[i];
 
-		if (maps[i].type == BPF_MAP_TYPE_PROG_ARRAY)
+		if (maps[i].def.type == BPF_MAP_TYPE_PROG_ARRAY)
 			prog_array_fd = map_fd[i];
 	}
 	return 0;
@@ -251,7 +258,8 @@ static int get_sec(Elf *elf, int i, GElf_Ehdr *ehdr, char **shname,
 }
 
 static int parse_relo_and_apply(Elf_Data *data, Elf_Data *symbols,
-				GElf_Shdr *shdr, struct bpf_insn *insn)
+				GElf_Shdr *shdr, struct bpf_insn *insn,
+				struct bpf_map_data *maps, int nr_maps)
 {
 	int i, nrels;
 
@@ -261,6 +269,8 @@ static int parse_relo_and_apply(Elf_Data *data, Elf_Data *symbols,
 		GElf_Sym sym;
 		GElf_Rel rel;
 		unsigned int insn_idx;
+		bool match = false;
+		int j, map_idx;
 
 		gelf_getrel(data, i, &rel);
 
@@ -274,11 +284,21 @@ static int parse_relo_and_apply(Elf_Data *data, Elf_Data *symbols,
 			return 1;
 		}
 		insn[insn_idx].src_reg = BPF_PSEUDO_MAP_FD;
-		/*
-		 * Warning: Using sizeof(struct bpf_map_def) here is a
-		 * wrong assumption about ELF maps section format
-		 */
-		insn[insn_idx].imm = map_fd[sym.st_value / sizeof(struct bpf_map_def)];
+
+		/* Match FD relocation against recorded map_data[] offset */
+		for (map_idx = 0; map_idx < nr_maps; map_idx++) {
+			if (maps[map_idx].elf_offset == sym.st_value) {
+				match = true;
+				break;
+			}
+		}
+		if (match) {
+			insn[insn_idx].imm = maps[map_idx].fd;
+		} else {
+			printf("invalid relo for insn[%d] no map_data match\n",
+			       insn_idx);
+			return 1;
+		}
 	}
 
 	return 0;
@@ -297,40 +317,112 @@ static int cmp_symbols(const void *l, const void *r)
 		return 0;
 }
 
-static int get_sorted_map_names(Elf *elf, Elf_Data *symbols, int maps_shndx,
-				int strtabidx, char **map_names)
+static int load_elf_maps_section(struct bpf_map_data *maps, int maps_shndx,
+				 Elf *elf, Elf_Data *symbols, int strtabidx)
 {
-	GElf_Sym map_symbols[MAX_MAPS];
-	int i, nr_maps = 0;
+	int map_sz_elf, map_sz_copy;
+	bool validate_zero = false;
+	Elf_Data *data_maps;
+	int i, nr_maps;
+	GElf_Sym *sym;
+	Elf_Scn *scn;
+	int copy_sz;
+
+	if (maps_shndx < 0)
+		return -EINVAL;
+	if (!symbols)
+		return -EINVAL;
+
+	/* Get data for maps section via elf index */
+	scn = elf_getscn(elf, maps_shndx);
+	if (scn)
+		data_maps = elf_getdata(scn, NULL);
+	if (!scn || !data_maps) {
+		printf("Failed to get Elf_Data from maps section %d\n",
+		       maps_shndx);
+		return -EINVAL;
+	}
 
-	for (i = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
-		assert(nr_maps < MAX_MAPS);
-		if (!gelf_getsym(symbols, i, &map_symbols[nr_maps]))
+	/* For each map get corrosponding symbol table entry */
+	sym = calloc(MAX_MAPS+1, sizeof(GElf_Sym));
+	for (i = 0, nr_maps = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
+		assert(nr_maps < MAX_MAPS+1);
+		if (!gelf_getsym(symbols, i, &sym[nr_maps]))
 			continue;
-		if (map_symbols[nr_maps].st_shndx != maps_shndx)
+		if (sym[nr_maps].st_shndx != maps_shndx)
 			continue;
+		/* Only increment iif maps section */
 		nr_maps++;
 	}
 
-	qsort(map_symbols, nr_maps, sizeof(GElf_Sym), cmp_symbols);
+	/* Align to map_fd[] order, via sort on offset in sym.st_value */
+	qsort(sym, nr_maps, sizeof(GElf_Sym), cmp_symbols);
+
+	/* Keeping compatible with ELF maps section changes
+	 * ------------------------------------------------
+	 * The program size of struct bpf_map_def is known by loader
+	 * code, but struct stored in ELF file can be different.
+	 *
+	 * Unfortunately sym[i].st_size is zero.  To calculate the
+	 * struct size stored in the ELF file, assume all struct have
+	 * the same size, and simply divide with number of map
+	 * symbols.
+	 */
+	map_sz_elf = data_maps->d_size / nr_maps;
+	map_sz_copy = sizeof(struct bpf_map_def);
+	if (map_sz_elf < map_sz_copy) {
+		/*
+		 * Backward compat, loading older ELF file with
+		 * smaller struct, keeping remaining bytes zero.
+		 */
+		map_sz_copy = map_sz_elf;
+	} else if (map_sz_elf > map_sz_copy) {
+		/*
+		 * Forward compat, loading newer ELF file with larger
+		 * struct with unknown features. Assume zero means
+		 * feature not used.  Thus, validate rest of struct
+		 * data is zero.
+		 */
+		validate_zero = true;
+	}
 
+	/* Memcpy relevant part of ELF maps data to loader maps */
 	for (i = 0; i < nr_maps; i++) {
-		char *map_name;
-
-		map_name = elf_strptr(elf, strtabidx, map_symbols[i].st_name);
-		if (!map_name) {
-			printf("cannot get map symbol\n");
-			return -1;
-		}
-
-		map_names[i] = strdup(map_name);
-		if (!map_names[i]) {
+		unsigned char *addr, *end;
+		struct bpf_map_def *def;
+		const char *map_name;
+		size_t offset;
+
+		map_name = elf_strptr(elf, strtabidx, sym[i].st_name);
+		maps[i].name = strdup(map_name);
+		if (!maps[i].name) {
 			printf("strdup(%s): %s(%d)\n", map_name,
 			       strerror(errno), errno);
-			return -1;
+			free(sym);
+			return -errno;
+		}
+
+		/* Symbol value is offset into ELF maps section data area */
+		offset = sym[i].st_value;
+		def = (struct bpf_map_def *)(data_maps->d_buf + offset);
+		maps[i].elf_offset = offset;
+		memset(&maps[i].def, 0, sizeof(struct bpf_map_def));
+		memcpy(&maps[i].def, def, map_sz_copy);
+
+		/* Verify no newer features were requested */
+		if (validate_zero) {
+			addr = (unsigned char*) def + map_sz_copy;
+			end  = (unsigned char*) def + map_sz_elf;
+			for (; addr < end; addr++) {
+				if (*addr != 0) {
+					free(sym);
+					return -EFBIG;
+				}
+			}
 		}
 	}
 
+	free(sym);
 	return nr_maps;
 }
 
@@ -341,7 +433,8 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 	GElf_Ehdr ehdr;
 	GElf_Shdr shdr, shdr_prog;
 	Elf_Data *data, *data_prog, *data_maps = NULL, *symbols = NULL;
-	char *shname, *shname_prog, *map_names[MAX_MAPS] = { NULL };
+	char *shname, *shname_prog;
+	int nr_maps = 0;
 
 	/* reset global variables */
 	kern_version = 0;
@@ -389,8 +482,12 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 			}
 			memcpy(&kern_version, data->d_buf, sizeof(int));
 		} else if (strcmp(shname, "maps") == 0) {
+			int j;
+
 			maps_shndx = i;
 			data_maps = data;
+			for (j = 0; j < MAX_MAPS; j++)
+				map_data[j].fd = -1;
 		} else if (shdr.sh_type == SHT_SYMTAB) {
 			strtabidx = shdr.sh_link;
 			symbols = data;
@@ -405,27 +502,17 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 	}
 
 	if (data_maps) {
-		int nr_maps;
-		int prog_elf_map_sz;
-
-		nr_maps = get_sorted_map_names(elf, symbols, maps_shndx,
-					       strtabidx, map_names);
-		if (nr_maps < 0)
-			goto done;
-
-		/* Deduce map struct size stored in ELF maps section */
-		prog_elf_map_sz = data_maps->d_size / nr_maps;
-		if (prog_elf_map_sz != sizeof(struct bpf_map_def)) {
-			printf("Error: ELF maps sec wrong size (%d/%lu),"
-			       " old kern.o file?\n",
-			       prog_elf_map_sz, sizeof(struct bpf_map_def));
+		nr_maps = load_elf_maps_section(map_data, maps_shndx,
+						elf, symbols, strtabidx);
+		if (nr_maps < 0) {
+			printf("Error: Failed loading ELF maps (errno:%d):%s\n",
+			       nr_maps, strerror(-nr_maps));
 			ret = 1;
 			goto done;
 		}
-
-		if (load_maps(data_maps->d_buf, nr_maps,
-			      (const char **)map_names, fixup_map))
+		if (load_maps(map_data, nr_maps, fixup_map))
 			goto done;
+		map_data_count = nr_maps;
 
 		processed_sec[maps_shndx] = true;
 	}
@@ -453,7 +540,8 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 			processed_sec[shdr.sh_info] = true;
 			processed_sec[i] = true;
 
-			if (parse_relo_and_apply(data, symbols, &shdr, insns))
+			if (parse_relo_and_apply(data, symbols, &shdr, insns,
+						 map_data, nr_maps))
 				continue;
 
 			if (memcmp(shname_prog, "kprobe/", 7) == 0 ||
@@ -488,8 +576,6 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 
 	ret = 0;
 done:
-	for (i = 0; i < MAX_MAPS; i++)
-		free(map_names[i]);
 	close(fd);
 	return ret;
 }
