From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 14/23] tools lib bpf: Fix map offsets in relocation
Date: Wed, 25 Jan 2017 10:53:41 -0300
Message-ID: <20170125135350.22983-15-acme@kernel.org>
References: <20170125135350.22983-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Wang Nan <wangnan0@huawei.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170125135350.22983-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe@ovn.org>

Commit 4708bbda5cb2 ("tools lib bpf: Fix maps resolution") attempted to
fix map resolution by identifying the number of symbols that point to
maps, and using this number to resolve each of the maps.

However, during relocation the original definition of the map size was
still in use. For up to two maps, the calculation was correct if there
was a small difference in size between the map definition in libbpf and
the one that the client library uses. However if the difference was
large, particularly if more than two maps were used in the BPF program,
the relocation would fail.

For example, when using a map definition with size 28, with three maps,
map relocation would count:

    (sym_offset / sizeof(struct bpf_map_def) => map_idx)
    (0 / 16 => 0), ie map_idx = 0
    (28 / 16 => 1), ie map_idx = 1
    (56 / 16 => 3), ie map_idx = 3

So, libbpf reports:

    libbpf: bpf relocation: map_idx 3 large than 2

Fix map relocation by checking the exact offset of maps when doing
relocation.

Signed-off-by: Joe Stringer <joe@ovn.org>
[Allow different map size in an object]
Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org
Fixes: 4708bbda5cb2 ("tools lib bpf: Fix maps resolution")
Link: http://lkml.kernel.org/r/20170123011128.26534-2-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/bpf/libbpf.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 84e6b35da4bd..671d5ad07cf1 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -779,7 +779,7 @@ static int
 bpf_program__collect_reloc(struct bpf_program *prog,
 			   size_t nr_maps, GElf_Shdr *shdr,
 			   Elf_Data *data, Elf_Data *symbols,
-			   int maps_shndx)
+			   int maps_shndx, struct bpf_map *maps)
 {
 	int i, nrels;
 
@@ -829,7 +829,15 @@ bpf_program__collect_reloc(struct bpf_program *prog,
 			return -LIBBPF_ERRNO__RELOC;
 		}
 
-		map_idx = sym.st_value / sizeof(struct bpf_map_def);
+		/* TODO: 'maps' is sorted. We can use bsearch to make it faster. */
+		for (map_idx = 0; map_idx < nr_maps; map_idx++) {
+			if (maps[map_idx].offset == sym.st_value) {
+				pr_debug("relocation: find map %zd (%s) for insn %u\n",
+					 map_idx, maps[map_idx].name, insn_idx);
+				break;
+			}
+		}
+
 		if (map_idx >= nr_maps) {
 			pr_warning("bpf relocation: map_idx %d large than %d\n",
 				   (int)map_idx, (int)nr_maps - 1);
@@ -953,7 +961,8 @@ static int bpf_object__collect_reloc(struct bpf_object *obj)
 		err = bpf_program__collect_reloc(prog, nr_maps,
 						 shdr, data,
 						 obj->efile.symbols,
-						 obj->efile.maps_shndx);
+						 obj->efile.maps_shndx,
+						 obj->maps);
 		if (err)
 			return err;
 	}
-- 
2.9.3
