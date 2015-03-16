From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2 2/2] tc: add eBPF support to f_bpf
Date: Mon, 16 Mar 2015 19:37:41 +0100
Message-ID: <e6ccd2548197c60c0686dca78ae02fc604fde065.1426530729.git.daniel@iogearbox.net>
References: <cover.1426530729.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, jiri@resnulli.us, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43560 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756903AbbCPShr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 14:37:47 -0400
In-Reply-To: <cover.1426530729.git.daniel@iogearbox.net>
In-Reply-To: <cover.1426530729.git.daniel@iogearbox.net>
References: <cover.1426530729.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds the tc frontend for kernel commit e2e9b6541dd4 ("cls_bpf:
add initial eBPF support for programmable classifiers").

A C-like classifier program (f.e. see e2e9b6541dd4) is being compiled via
LLVM's eBPF backend into an ELF file, that is then being passed to tc. tc
then loads, if any, eBPF maps and eBPF opcodes (with fixed-up eBPF map file
descriptors) out of its dedicated sections, and via bpf(2) into the kernel
and then the resulting fd via netlink down to cls_bpf. cls_bpf allows for
annotations, currently, I've used the file name for that, so that the user
can easily identify his filter when dumping configurations back.

Example usage:

  clang -O2 -emit-llvm -c cls.c -o - | llc -march=bpf -filetype=obj -o cls.o
  tc filter add dev em1 parent 1: bpf run object-file cls.o classid x:y

  tc filter show dev em1 [...]
  filter parent 1: protocol all pref 49152 bpf handle 0x1 flowid x:y cls.o

I placed the parser bits derived from Alexei's kernel sample, into tc_bpf.c
as my next step is to also add the same support for BPF action, so we can
have a fully fledged eBPF classifier and action in tc.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 configure       |  26 ++++
 include/utils.h |   5 +
 tc/Makefile     |   5 +
 tc/f_bpf.c      |  36 ++++--
 tc/tc_bpf.c     | 392 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_bpf.h     |  58 ++++++++-
 6 files changed, 511 insertions(+), 11 deletions(-)

diff --git a/configure b/configure
index 631938e..7bec8a9 100755
--- a/configure
+++ b/configure
@@ -266,6 +266,29 @@ EOF
     rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
 }
 
+check_elf()
+{
+    cat >$TMPDIR/elftest.c <<EOF
+#include <libelf.h>
+#include <gelf.h>
+int main(void)
+{
+	Elf_Scn *scn;
+	GElf_Shdr shdr;
+	return elf_version(EV_CURRENT);
+}
+EOF
+
+    if $CC -I$INCLUDE -o $TMPDIR/elftest $TMPDIR/elftest.c -lelf >/dev/null 2>&1
+    then
+	echo "TC_CONFIG_ELF:=y" >>Config
+	echo "yes"
+    else
+	echo "no"
+    fi
+    rm -f $TMPDIR/elftest.c $TMPDIR/elftest
+}
+
 check_selinux()
 # SELinux is a compile time option in the ss utility
 {
@@ -306,5 +329,8 @@ check_netnsid
 echo -n "SELinux support: "
 check_selinux
 
+echo -n "ELF support: "
+check_elf
+
 echo -e "\nDocs"
 check_docs
diff --git a/include/utils.h b/include/utils.h
index 9151c4f..59b2280 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -157,6 +157,11 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
+#ifndef __check_format_string
+# define __check_format_string(pos_str, pos_args) \
+	__attribute__ ((format (printf, (pos_str), (pos_args))))
+#endif
+
 extern int cmdlineno;
 extern ssize_t getcmdline(char **line, size_t *len, FILE *in);
 extern int makeargs(char *line, char *argv[], int maxargs);
diff --git a/tc/Makefile b/tc/Makefile
index d831a15..2eff082 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -89,6 +89,11 @@ else
   endif
 endif
 
+ifeq ($(TC_CONFIG_ELF),y)
+  CFLAGS += -DHAVE_ELF
+  LDLIBS += -lelf
+endif
+
 TCOBJ += $(TCMODULES)
 LDLIBS += -L. -ltc -lm
 
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index e2af94e..6d76580 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -34,13 +34,15 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
 	fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
+	fprintf(stderr, " [from file]:  run object-file FILE\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "               [ action ACTION_SPEC ]\n");
 	fprintf(stderr, "               [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
 	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
-	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
+	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string,\n");
+	fprintf(stderr, "or an ELF file containing eBPF map definitions and bytecode.\n");
 	fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
 }
@@ -71,31 +73,40 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
-			bool from_file;
+			bool from_file = true, ebpf;
 			struct sock_filter bpf_ops[BPF_MAXINSNS];
-			__u16 bpf_len;
 			int ret;
 
 			NEXT_ARG();
 			if (strcmp(*argv, "bytecode-file") == 0) {
-				from_file = true;
+				ebpf = false;
 			} else if (strcmp(*argv, "bytecode") == 0) {
 				from_file = false;
+				ebpf = false;
+			} else if (strcmp(*argv, "object-file") == 0) {
+				ebpf = true;
 			} else {
 				fprintf(stderr, "What is \"%s\"?\n", *argv);
 				explain();
 				return -1;
 			}
 			NEXT_ARG();
-			ret = bpf_parse_ops(argc, argv, bpf_ops, from_file);
+			ret = ebpf ? bpf_open_object(*argv, BPF_PROG_TYPE_SCHED_CLS) :
+			             bpf_parse_ops(argc, argv, bpf_ops, from_file);
 			if (ret < 0) {
-				fprintf(stderr, "Illegal \"bytecode\"\n");
+				fprintf(stderr, "%s\n", ebpf ?
+					"Could not load object" :
+					"Illegal \"bytecode\"");
 				return -1;
 			}
-			bpf_len = ret;
-			addattr16(n, MAX_MSG, TCA_BPF_OPS_LEN, bpf_len);
-			addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
-				  bpf_len * sizeof(struct sock_filter));
+			if (ebpf) {
+				addattr32(n, MAX_MSG, TCA_BPF_FD, ret);
+				addattrstrz(n, MAX_MSG, TCA_BPF_NAME, *argv);
+			} else {
+				addattr16(n, MAX_MSG, TCA_BPF_OPS_LEN, ret);
+				addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
+					  ret * sizeof(struct sock_filter));
+			}
 		} else if (matches(*argv, "classid") == 0 ||
 			   strcmp(*argv, "flowid") == 0) {
 			unsigned handle;
@@ -153,6 +164,11 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 			sprint_tc_classid(rta_getattr_u32(tb[TCA_BPF_CLASSID]), b1));
 	}
 
+	if (tb[TCA_BPF_NAME])
+		fprintf(f, "%s ", rta_getattr_str(tb[TCA_BPF_NAME]));
+	else if (tb[TCA_BPF_FD])
+		fprintf(f, "pfd %u ", rta_getattr_u32(tb[TCA_BPF_FD]));
+
 	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN])
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index c6901d6..3778d6b 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -8,6 +8,7 @@
  *
  * Authors:	Daniel Borkmann <dborkman@redhat.com>
  *		Jiri Pirko <jiri@resnulli.us>
+ *		Alexei Starovoitov <ast@plumgrid.com>
  */
 
 #include <stdio.h>
@@ -16,10 +17,19 @@
 #include <string.h>
 #include <stdbool.h>
 #include <errno.h>
+#include <fcntl.h>
+#include <stdarg.h>
+#include <sys/types.h>
+#include <sys/stat.h>
 #include <linux/filter.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
 
+#ifdef HAVE_ELF
+#include <libelf.h>
+#include <gelf.h>
+#endif
+
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_bpf.h"
@@ -144,3 +154,385 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 	fprintf(f, "%hu %hhu %hhu %u\'\n", ops[i].code, ops[i].jt,
 		ops[i].jf, ops[i].k);
 }
+
+#ifdef HAVE_ELF
+struct bpf_elf_sec_data {
+	GElf_Shdr	sec_hdr;
+	char		*sec_name;
+	Elf_Data	*sec_data;
+};
+
+static char bpf_log_buf[8192];
+
+static const char *prog_type_section(enum bpf_prog_type type)
+{
+	switch (type) {
+	case BPF_PROG_TYPE_SCHED_CLS:
+		return ELF_SECTION_CLASSIFIER;
+	/* case BPF_PROG_TYPE_SCHED_ACT:   */
+	/*	return ELF_SECTION_ACTION; */
+	default:
+		return NULL;
+	}
+}
+
+static void bpf_dump_error(const char *format, ...)  __check_format_string(1, 2);
+static void bpf_dump_error(const char *format, ...)
+{
+	va_list vl;
+
+	va_start(vl, format);
+	vfprintf(stderr, format, vl);
+	va_end(vl);
+
+	fprintf(stderr, "%s", bpf_log_buf);
+	memset(bpf_log_buf, 0, sizeof(bpf_log_buf));
+}
+
+static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
+			  unsigned int size_value, unsigned int max_elem)
+{
+	union bpf_attr attr = {
+		.map_type	= type,
+		.key_size	= size_key,
+		.value_size	= size_value,
+		.max_entries	= max_elem,
+	};
+
+	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
+}
+
+static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
+			 unsigned int len, const char *license)
+{
+	union bpf_attr attr = {
+		.prog_type	= type,
+		.insns		= bpf_ptr_to_u64(insns),
+		.insn_cnt	= len / sizeof(struct bpf_insn),
+		.license	= bpf_ptr_to_u64(license),
+		.log_buf	= bpf_ptr_to_u64(bpf_log_buf),
+		.log_size	= sizeof(bpf_log_buf),
+		.log_level	= 1,
+	};
+
+	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
+static int bpf_prog_attach(enum bpf_prog_type type, const struct bpf_insn *insns,
+			   unsigned int size, const char *license)
+{
+	int prog_fd = bpf_prog_load(type, insns, size, license);
+
+	if (prog_fd < 0)
+		bpf_dump_error("BPF program rejected: %s\n", strerror(errno));
+
+	return prog_fd;
+}
+
+static int bpf_map_attach(enum bpf_map_type type, unsigned int size_key,
+			  unsigned int size_value, unsigned int max_elem)
+{
+	int map_fd = bpf_create_map(type, size_key, size_value, max_elem);
+
+	if (map_fd < 0)
+		bpf_dump_error("BPF map rejected: %s\n", strerror(errno));
+
+	return map_fd;
+}
+
+static void bpf_maps_init(int *map_fds, unsigned int max_fds)
+{
+	int i;
+
+	for (i = 0; i < max_fds; i++)
+		map_fds[i] = -1;
+}
+
+static void bpf_maps_destroy(const int *map_fds, unsigned int max_fds)
+{
+	int i;
+
+	for (i = 0; i < max_fds; i++) {
+		if (map_fds[i] >= 0)
+			close(map_fds[i]);
+	}
+}
+
+static int bpf_maps_attach(struct bpf_elf_map *maps, unsigned int num_maps,
+			   int *map_fds, unsigned int max_fds)
+{
+	int i, ret;
+
+	for (i = 0; i < num_maps && num_maps <= max_fds; i++) {
+		struct bpf_elf_map *map = &maps[i];
+
+		ret = bpf_map_attach(map->type, map->size_key,
+				     map->size_value, map->max_elem);
+		if (ret < 0)
+			goto err_unwind;
+
+		map_fds[i] = ret;
+	}
+
+	return 0;
+
+err_unwind:
+	bpf_maps_destroy(map_fds, i);
+	return ret;
+}
+
+static int bpf_fill_section_data(Elf *elf_fd, GElf_Ehdr *elf_hdr, int sec_index,
+				 struct bpf_elf_sec_data *sec_data)
+{
+	GElf_Shdr sec_hdr;
+	Elf_Scn *sec_fd;
+	Elf_Data *sec_edata;
+	char *sec_name;
+
+	memset(sec_data, 0, sizeof(*sec_data));
+
+	sec_fd = elf_getscn(elf_fd, sec_index);
+	if (!sec_fd)
+		return -EINVAL;
+
+	if (gelf_getshdr(sec_fd, &sec_hdr) != &sec_hdr)
+		return -EIO;
+
+	sec_name = elf_strptr(elf_fd, elf_hdr->e_shstrndx,
+			      sec_hdr.sh_name);
+	if (!sec_name || !sec_hdr.sh_size)
+		return -ENOENT;
+
+	sec_edata = elf_getdata(sec_fd, NULL);
+	if (!sec_edata || elf_getdata(sec_fd, sec_edata))
+		return -EIO;
+
+	memcpy(&sec_data->sec_hdr, &sec_hdr, sizeof(sec_hdr));
+	sec_data->sec_name = sec_name;
+	sec_data->sec_data = sec_edata;
+
+	return 0;
+}
+
+static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
+			       struct bpf_elf_sec_data *data_insn,
+			       Elf_Data *sym_tab, int *map_fds, int max_fds)
+{
+	Elf_Data *idata = data_insn->sec_data;
+	GElf_Shdr *rhdr = &data_relo->sec_hdr;
+	int relo_ent, relo_num = rhdr->sh_size / rhdr->sh_entsize;
+	struct bpf_insn *insns = idata->d_buf;
+	unsigned int num_insns = idata->d_size / sizeof(*insns);
+
+	for (relo_ent = 0; relo_ent < relo_num; relo_ent++) {
+		unsigned int ioff, fnum;
+		GElf_Rel relo;
+		GElf_Sym sym;
+
+		if (gelf_getrel(data_relo->sec_data, relo_ent, &relo) != &relo)
+			return -EIO;
+
+		ioff = relo.r_offset / sizeof(struct bpf_insn);
+		if (ioff >= num_insns)
+			return -EINVAL;
+		if (insns[ioff].code != (BPF_LD | BPF_IMM | BPF_DW))
+			return -EINVAL;
+
+		if (gelf_getsym(sym_tab, GELF_R_SYM(relo.r_info), &sym) != &sym)
+			return -EIO;
+
+		fnum = sym.st_value / sizeof(struct bpf_elf_map);
+		if (fnum >= max_fds)
+			return -EINVAL;
+
+		insns[ioff].src_reg = BPF_PSEUDO_MAP_FD;
+		insns[ioff].imm = map_fds[fnum];
+	}
+
+	return 0;
+}
+
+static int bpf_fetch_ancillary(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
+			       int *map_fds, unsigned int max_fds,
+			       char *license, unsigned int lic_len,
+			       Elf_Data **sym_tab)
+{
+	int sec_index, ret = -1;
+
+	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
+		struct bpf_elf_sec_data data_anc;
+
+		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
+					    &data_anc);
+		if (ret < 0)
+			continue;
+
+		/* Extract and load eBPF map fds. */
+		if (!strcmp(data_anc.sec_name, ELF_SECTION_MAPS)) {
+			struct bpf_elf_map *maps = data_anc.sec_data->d_buf;
+			unsigned int maps_num = data_anc.sec_data->d_size /
+						sizeof(*maps);
+
+			sec_seen[sec_index] = true;
+			ret = bpf_maps_attach(maps, maps_num, map_fds,
+					      max_fds);
+			if (ret < 0)
+				return ret;
+		}
+		/* Extract eBPF license. */
+		else if (!strcmp(data_anc.sec_name, ELF_SECTION_LICENSE)) {
+			if (data_anc.sec_data->d_size > lic_len)
+				return -ENOMEM;
+
+			sec_seen[sec_index] = true;
+			memcpy(license, data_anc.sec_data->d_buf,
+			       data_anc.sec_data->d_size);
+		}
+		/* Extract symbol table for relocations (map fd fixups). */
+		else if (data_anc.sec_hdr.sh_type == SHT_SYMTAB) {
+			sec_seen[sec_index] = true;
+			*sym_tab = data_anc.sec_data;
+		}
+	}
+
+	return ret;
+}
+
+static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
+			       enum bpf_prog_type type, char *license,
+			       Elf_Data *sym_tab, int *map_fds, unsigned int max_fds)
+{
+	int sec_index, prog_fd = -1;
+
+	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
+		struct bpf_elf_sec_data data_relo, data_insn;
+		int ins_index, ret;
+
+		/* Attach eBPF programs with relocation data (maps). */
+		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
+					    &data_relo);
+		if (ret < 0 || data_relo.sec_hdr.sh_type != SHT_REL)
+			continue;
+
+		ins_index = data_relo.sec_hdr.sh_info;
+
+		ret = bpf_fill_section_data(elf_fd, elf_hdr, ins_index,
+					    &data_insn);
+		if (ret < 0)
+			continue;
+		if (strcmp(data_insn.sec_name, prog_type_section(type)))
+			continue;
+
+		sec_seen[sec_index] = true;
+		sec_seen[ins_index] = true;
+
+		ret = bpf_apply_relo_data(&data_relo, &data_insn, sym_tab,
+					  map_fds, max_fds);
+		if (ret < 0)
+			continue;
+
+		prog_fd = bpf_prog_attach(type, data_insn.sec_data->d_buf,
+					  data_insn.sec_data->d_size, license);
+		if (prog_fd < 0)
+			continue;
+
+		break;
+	}
+
+	return prog_fd;
+}
+
+static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
+			  enum bpf_prog_type type, char *license)
+{
+	int sec_index, prog_fd = -1;
+
+	for (sec_index = 1; sec_index < elf_hdr->e_shnum; sec_index++) {
+		struct bpf_elf_sec_data data_insn;
+		int ret;
+
+		/* Attach eBPF programs without relocation data. */
+		if (sec_seen[sec_index])
+			continue;
+
+		ret = bpf_fill_section_data(elf_fd, elf_hdr, sec_index,
+					    &data_insn);
+		if (ret < 0)
+			continue;
+		if (strcmp(data_insn.sec_name, prog_type_section(type)))
+			continue;
+
+		prog_fd = bpf_prog_attach(type, data_insn.sec_data->d_buf,
+					  data_insn.sec_data->d_size, license);
+		if (prog_fd < 0)
+			continue;
+
+		break;
+	}
+
+	return prog_fd;
+}
+
+int bpf_open_object(const char *path, enum bpf_prog_type type)
+{
+	int map_fds[ELF_MAX_MAPS], max_fds = ARRAY_SIZE(map_fds);
+	char license[ELF_MAX_LICENSE_LEN];
+	int file_fd, prog_fd = -1, ret;
+	Elf_Data *sym_tab = NULL;
+	GElf_Ehdr elf_hdr;
+	bool *sec_seen;
+	Elf *elf_fd;
+
+	if (elf_version(EV_CURRENT) == EV_NONE)
+		return -EINVAL;
+
+	file_fd = open(path, O_RDONLY, 0);
+	if (file_fd < 0)
+		return -errno;
+
+	elf_fd = elf_begin(file_fd, ELF_C_READ, NULL);
+	if (!elf_fd) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (gelf_getehdr(elf_fd, &elf_hdr) != &elf_hdr) {
+		ret = -EIO;
+		goto out_elf;
+	}
+
+	sec_seen = calloc(elf_hdr.e_shnum, sizeof(*sec_seen));
+	if (!sec_seen) {
+		ret = -ENOMEM;
+		goto out_elf;
+	}
+
+	memset(license, 0, sizeof(license));
+	bpf_maps_init(map_fds, max_fds);
+
+	ret = bpf_fetch_ancillary(elf_fd, &elf_hdr, sec_seen, map_fds, max_fds,
+				  license, sizeof(license), &sym_tab);
+	if (ret < 0)
+		goto out_maps;
+	if (sym_tab)
+		prog_fd = bpf_fetch_prog_relo(elf_fd, &elf_hdr, sec_seen, type,
+					      license, sym_tab, map_fds, max_fds);
+	if (prog_fd < 0)
+		prog_fd = bpf_fetch_prog(elf_fd, &elf_hdr, sec_seen, type,
+					 license);
+	if (prog_fd < 0)
+		goto out_maps;
+out_sec:
+	free(sec_seen);
+out_elf:
+	elf_end(elf_fd);
+out:
+	close(file_fd);
+	return prog_fd;
+
+out_maps:
+	bpf_maps_destroy(map_fds, max_fds);
+	goto out_sec;
+}
+
+#endif /* HAVE_ELF */
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 08cca92..ce64747 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -13,10 +13,42 @@
 #ifndef _TC_BPF_H_
 #define _TC_BPF_H_ 1
 
-#include <stdio.h>
 #include <linux/filter.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/bpf.h>
+#include <sys/syscall.h>
+#include <errno.h>
+#include <stdio.h>
+#include <stdint.h>
+
+#include "utils.h"
+
+/* Note:
+ *
+ * Below ELF section names and bpf_elf_map structure definition
+ * are not (!) kernel ABI. It's rather a "contract" between the
+ * application and the BPF loader in tc. For compatibility, the
+ * section names should stay as-is. Introduction of aliases, if
+ * needed, are a possibility, though.
+ */
+
+/* ELF section names, etc */
+#define ELF_SECTION_LICENSE	"license"
+#define ELF_SECTION_MAPS	"maps"
+#define ELF_SECTION_CLASSIFIER	"classifier"
+#define ELF_SECTION_ACTION	"action"
+
+#define ELF_MAX_MAPS		64
+#define ELF_MAX_LICENSE_LEN	128
+
+/* ELF map definition */
+struct bpf_elf_map {
+	__u32 type;
+	__u32 size_key;
+	__u32 size_value;
+	__u32 max_elem;
+};
 
 int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		     char **bpf_string, bool *need_release,
@@ -25,4 +57,28 @@ int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
 		  bool from_file);
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
+static inline __u64 bpf_ptr_to_u64(const void *ptr)
+{
+	return (__u64) (unsigned long) ptr;
+}
+
+#ifdef HAVE_ELF
+int bpf_open_object(const char *path, enum bpf_prog_type type);
+
+static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
+{
+#ifdef __NR_bpf
+	return syscall(__NR_bpf, cmd, attr, size);
+#else
+	errno = ENOSYS;
+	return -1;
 #endif
+}
+#else
+static inline int bpf_open_object(const char *path, enum bpf_prog_type type)
+{
+	errno = ENOSYS;
+	return -1;
+}
+#endif /* HAVE_ELF */
+#endif /* _TC_BPF_H_ */
-- 
1.9.3
