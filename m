From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V1] samples/bpf: bpf_load.c detect and abort if ELF
 maps section size is wrong
Date: Fri, 28 Apr 2017 16:25:04 +0200
Message-ID: <149338948065.27354.8568861008673180957.stgit@firesoul>
References: <20170428082816.20a34395@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968236AbdD1OZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 10:25:10 -0400
In-Reply-To: <20170428082816.20a34395@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct bpf_map_def was extended in commit fb30d4b71214 ("bpf: Add tests
for map-in-map") with member unsigned int inner_map_idx.  This changed the size
of the maps section in the generated ELF _kern.o files.

Unfortunately the loader in bpf_load.c does not detect or handle this.  Thus,
older _kern.o files became incompatible, and caused hard-to-debug errors
where the syscall validation rejected BPF_MAP_CREATE request.

This patch only detect the situation and aborts load_bpf_file(). It also
add code comments warning people that read this loader for inspiration
for these pitfalls.

Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
Is it worth to implement proper backward-compat loading of older ELF objects
with this bpf-loader?

 samples/bpf/bpf_load.c |   40 +++++++++++++++++++++++++++++++---------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 0d449d8032d1..b84ac9dbff18 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -185,12 +185,16 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	return 0;
 }
 
-static int load_maps(struct bpf_map_def *maps, int len,
+static int load_maps(struct bpf_map_def *maps, int nr_maps,
 		     const char **map_names, fixup_map_cb fixup_map)
 {
 	int i;
-
-	for (i = 0; i < len / sizeof(struct bpf_map_def); i++) {
+	/*
+	 * Warning: Using "maps" pointing to ELF data_maps->d_buf as
+	 * an array of struct bpf_map_def is a wrong assumption about
+	 * the ELF maps section format.
+	 */
+	for (i = 0; i < nr_maps; i++) {
 		if (fixup_map)
 			fixup_map(&maps[i], map_names[i], i);
 
@@ -269,6 +273,10 @@ static int parse_relo_and_apply(Elf_Data *data, Elf_Data *symbols,
 			return 1;
 		}
 		insn[insn_idx].src_reg = BPF_PSEUDO_MAP_FD;
+		/*
+		 * Warning: Using sizeof(struct bpf_map_def) here is a
+		 * wrong assumption about ELF maps section format
+		 */
 		insn[insn_idx].imm = map_fd[sym.st_value / sizeof(struct bpf_map_def)];
 	}
 
@@ -311,18 +319,18 @@ static int get_sorted_map_names(Elf *elf, Elf_Data *symbols, int maps_shndx,
 		map_name = elf_strptr(elf, strtabidx, map_symbols[i].st_name);
 		if (!map_name) {
 			printf("cannot get map symbol\n");
-			return 1;
+			return -1;
 		}
 
 		map_names[i] = strdup(map_name);
 		if (!map_names[i]) {
 			printf("strdup(%s): %s(%d)\n", map_name,
 			       strerror(errno), errno);
-			return 1;
+			return -1;
 		}
 	}
 
-	return 0;
+	return nr_maps;
 }
 
 static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
@@ -396,11 +404,25 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 	}
 
 	if (data_maps) {
-		if (get_sorted_map_names(elf, symbols, maps_shndx, strtabidx,
-					 map_names))
+		int nr_maps;
+		int prog_elf_map_sz;
+
+		nr_maps = get_sorted_map_names(elf, symbols, maps_shndx,
+					       strtabidx, map_names);
+		if (nr_maps < 0)
 			goto done;
 
-		if (load_maps(data_maps->d_buf, data_maps->d_size,
+		/* Deduce map struct size stored in ELF maps section */
+		prog_elf_map_sz = data_maps->d_size / nr_maps;
+		if (prog_elf_map_sz != sizeof(struct bpf_map_def)) {
+			printf("Error: ELF maps sec wrong size (%d/%lu),"
+			       " old kern.o file?\n",
+			       prog_elf_map_sz, sizeof(struct bpf_map_def));
+			ret = 1;
+			goto done;
+		}
+
+		if (load_maps(data_maps->d_buf, nr_maps,
 			      (const char **)map_names, fixup_map))
 			goto done;
 
