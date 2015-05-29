From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] tc: {f,m}_bpf: add tail call support for parser
Date: Fri, 29 May 2015 15:15:44 +0200
Message-ID: <bce7420af8f7210e1848b8db1d34ca42af6417c6.1432904654.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57750 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbbE2NPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 09:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel commit 04fd61ab36ec ("bpf: allow bpf programs to tail-call other
bpf programs") added support for tail calls, this patch here adds tc
front end parts for the object parser to prepopulate a given eBPF prog
array before the root prog is pushed down for classifier creation. The
prepopulation works with any number of prog arrays in any dependencies,
e.g. prog or normal maps could also be used from progs that are
tail-called themself, etc.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ doc will follow later some time after -next branch has man page again. ]

 tc/tc_bpf.c | 139 ++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 111 insertions(+), 28 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 59493df..276871a 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -16,6 +16,7 @@
 #include <unistd.h>
 #include <string.h>
 #include <stdbool.h>
+#include <stdint.h>
 #include <errno.h>
 #include <fcntl.h>
 #include <stdarg.h>
@@ -266,6 +267,19 @@ static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
+static int bpf_update_map(int fd, const void *key, const void *value,
+			  uint64_t flags)
+{
+	union bpf_attr attr = {
+		.map_fd		= fd,
+		.key		= bpf_ptr_to_u64(key),
+		.value		= bpf_ptr_to_u64(value),
+		.flags		= flags,
+	};
+
+	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+}
+
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 			 unsigned int len, const char *license)
 {
@@ -282,15 +296,17 @@ static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-static int bpf_prog_attach(enum bpf_prog_type type, const struct bpf_insn *insns,
-			   unsigned int size, const char *license)
+static int bpf_prog_attach(enum bpf_prog_type type, const char *sec,
+			   const struct bpf_insn *insns, unsigned int size,
+			   const char *license)
 {
 	int prog_fd = bpf_prog_load(type, insns, size, license);
 
 	if (prog_fd < 0 || bpf_verbose) {
-		bpf_dump_error("%s: %s\n", prog_fd < 0 ?
+		bpf_dump_error("%s (section \'%s\'): %s\n", prog_fd < 0 ?
 			       "BPF program rejected" :
-			       "BPF program verification", strerror(errno));
+			       "BPF program verification",
+			       sec, strerror(errno));
 	}
 
 	return prog_fd;
@@ -436,7 +452,7 @@ static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
 }
 
 static int bpf_fetch_ancillary(int file_fd, Elf *elf_fd, GElf_Ehdr *elf_hdr,
-			       bool *sec_seen, char *license, unsigned int lic_len,
+			       bool *sec_done, char *license, unsigned int lic_len,
 			       Elf_Data **sym_tab)
 {
 	int sec_index, ret = -1;
@@ -462,23 +478,24 @@ static int bpf_fetch_ancillary(int file_fd, Elf *elf_fd, GElf_Ehdr *elf_hdr,
 			maps_num = data_anc.sec_data->d_size / sizeof(*maps);
 			memcpy(map_ent, maps, data_anc.sec_data->d_size);
 
-			sec_seen[sec_index] = true;
 			ret = bpf_maps_attach(maps, maps_num);
 			if (ret < 0)
 				return ret;
+
+			sec_done[sec_index] = true;
 		}
 		/* Extract eBPF license. */
 		else if (!strcmp(data_anc.sec_name, ELF_SECTION_LICENSE)) {
 			if (data_anc.sec_data->d_size > lic_len)
 				return -ENOMEM;
 
-			sec_seen[sec_index] = true;
+			sec_done[sec_index] = true;
 			memcpy(license, data_anc.sec_data->d_buf,
 			       data_anc.sec_data->d_size);
 		}
 		/* Extract symbol table for relocations (map fd fixups). */
 		else if (data_anc.sec_hdr.sh_type == SHT_SYMTAB) {
-			sec_seen[sec_index] = true;
+			sec_done[sec_index] = true;
 			*sym_tab = data_anc.sec_data;
 		}
 	}
@@ -486,7 +503,7 @@ static int bpf_fetch_ancillary(int file_fd, Elf *elf_fd, GElf_Ehdr *elf_hdr,
 	return ret;
 }
 
-static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
+static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
 			       enum bpf_prog_type type, const char *sec,
 			       const char *license, Elf_Data *sym_tab)
 {
@@ -511,25 +528,24 @@ static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 		if (strcmp(data_insn.sec_name, sec))
 			continue;
 
-		sec_seen[sec_index] = true;
-		sec_seen[ins_index] = true;
-
 		ret = bpf_apply_relo_data(&data_relo, &data_insn, sym_tab);
 		if (ret < 0)
 			continue;
 
-		prog_fd = bpf_prog_attach(type, data_insn.sec_data->d_buf,
+		prog_fd = bpf_prog_attach(type, sec, data_insn.sec_data->d_buf,
 					  data_insn.sec_data->d_size, license);
 		if (prog_fd < 0)
 			continue;
 
+		sec_done[sec_index] = true;
+		sec_done[ins_index] = true;
 		break;
 	}
 
 	return prog_fd;
 }
 
-static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
+static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
 			  enum bpf_prog_type type, const char *sec,
 			  const char *license)
 {
@@ -540,7 +556,7 @@ static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 		int ret;
 
 		/* Attach eBPF programs without relocation data. */
-		if (sec_seen[sec_index])
+		if (sec_done[sec_index])
 			continue;
 
 		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
@@ -550,17 +566,78 @@ static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 		if (strcmp(data_insn.sec_name, sec))
 			continue;
 
-		prog_fd = bpf_prog_attach(type, data_insn.sec_data->d_buf,
+		prog_fd = bpf_prog_attach(type, sec, data_insn.sec_data->d_buf,
 					  data_insn.sec_data->d_size, license);
 		if (prog_fd < 0)
 			continue;
 
+		sec_done[sec_index] = true;
 		break;
 	}
 
 	return prog_fd;
 }
 
+static int bpf_fetch_prog_sec(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
+			      enum bpf_prog_type type, const char *sec,
+			      const char *license, Elf_Data *sym_tab)
+{
+	int ret = -1;
+
+	if (sym_tab)
+		ret = bpf_fetch_prog_relo(elf_fd, elf_hdr, sec_done, type,
+					  sec, license, sym_tab);
+	if (ret < 0)
+		ret = bpf_fetch_prog(elf_fd, elf_hdr, sec_done, type, sec,
+				     license);
+	return ret;
+}
+
+static int bpf_fill_prog_arrays(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_done,
+				enum bpf_prog_type type, const char *license,
+				Elf_Data *sym_tab)
+{
+	int sec_index;
+
+	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
+		struct bpf_elf_sec_data data_insn;
+		int ret, map_id, key_id, prog_fd;
+
+		if (sec_done[sec_index])
+			continue;
+
+		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
+					    &data_insn);
+		if (ret < 0)
+			continue;
+
+		ret = sscanf(data_insn.sec_name, "%i/%i", &map_id, &key_id);
+		if (ret != 2)
+			continue;
+
+		if (map_id >= ARRAY_SIZE(map_fds) || map_fds[map_id] < 0)
+			return -ENOENT;
+		if (map_ent[map_id].type != BPF_MAP_TYPE_PROG_ARRAY ||
+		    map_ent[map_id].max_elem <= key_id)
+			return -EINVAL;
+
+		prog_fd = bpf_fetch_prog_sec(elf_fd, elf_hdr, sec_done,
+					     type, data_insn.sec_name,
+					     license, sym_tab);
+		if (prog_fd < 0)
+			return -EIO;
+
+		ret = bpf_update_map(map_fds[map_id], &key_id, &prog_fd,
+				     BPF_ANY);
+		if (ret < 0)
+			return -ENOENT;
+
+		sec_done[sec_index] = true;
+	}
+
+	return 0;
+}
+
 int bpf_open_object(const char *path, enum bpf_prog_type type,
 		    const char *sec, bool verbose)
 {
@@ -568,7 +645,7 @@ int bpf_open_object(const char *path, enum bpf_prog_type type,
 	int file_fd, prog_fd = -1, ret;
 	Elf_Data *sym_tab = NULL;
 	GElf_Ehdr elf_hdr;
-	bool *sec_seen;
+	bool *sec_done;
 	Elf *elf_fd;
 
 	if (elf_version(EV_CURRENT) == EV_NONE)
@@ -589,8 +666,8 @@ int bpf_open_object(const char *path, enum bpf_prog_type type,
 		goto out_elf;
 	}
 
-	sec_seen = calloc(elf_hdr.e_shnum, sizeof(*sec_seen));
-	if (!sec_seen) {
+	sec_done = calloc(elf_hdr.e_shnum, sizeof(*sec_done));
+	if (!sec_done) {
 		ret = -ENOMEM;
 		goto out_elf;
 	}
@@ -601,31 +678,37 @@ int bpf_open_object(const char *path, enum bpf_prog_type type,
 	if (!bpf_may_skip_map_creation(file_fd))
 		bpf_maps_init();
 
-	ret = bpf_fetch_ancillary(file_fd, elf_fd, &elf_hdr, sec_seen,
+	ret = bpf_fetch_ancillary(file_fd, elf_fd, &elf_hdr, sec_done,
 				  license, sizeof(license), &sym_tab);
 	if (ret < 0)
 		goto out_maps;
-	if (sym_tab)
-		prog_fd = bpf_fetch_prog_relo(elf_fd, &elf_hdr, sec_seen, type,
-					      sec, license, sym_tab);
-	if (prog_fd < 0)
-		prog_fd = bpf_fetch_prog(elf_fd, &elf_hdr, sec_seen, type, sec,
-					 license);
+
+	prog_fd = bpf_fetch_prog_sec(elf_fd, &elf_hdr, sec_done, type,
+				     sec, license, sym_tab);
 	if (prog_fd < 0)
 		goto out_maps;
 
+	if (!bpf_may_skip_map_creation(file_fd)) {
+		ret = bpf_fill_prog_arrays(elf_fd, &elf_hdr, sec_done,
+					   type, license, sym_tab);
+		if (ret < 0)
+			goto out_prog;
+	}
+
 	bpf_save_finfo(file_fd);
 
-	free(sec_seen);
+	free(sec_done);
 
 	elf_end(elf_fd);
 	close(file_fd);
 
 	return prog_fd;
 
+out_prog:
+	close(prog_fd);
 out_maps:
 	bpf_maps_destroy();
-	free(sec_seen);
+	free(sec_done);
 out_elf:
 	elf_end(elf_fd);
 out:
-- 
1.9.3
