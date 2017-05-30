From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net] samples/bpf: bpf_load.c order of prog_fd[] should
 correspond with ELF order
Date: Tue, 30 May 2017 14:37:51 +0200
Message-ID: <149614787132.15375.2590780903240304298.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40512 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdE3Mhz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 08:37:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An eBPF ELF file generated with LLVM can contain several program
section, which can be used for bpf tail calls.  The bpf prog file
descriptors are accessible via array prog_fd[].

At-least XDP samples assume ordering, and uses prog_fd[0] is the main
XDP program to attach.  The actual order of array prog_fd[] depend on
whether or not a bpf program section is referencing any maps or not.
Not using a map result in being loaded/processed after all other
prog section.  Thus, this can lead to some very strange and hard to
debug situation, as the user can only see a FD and cannot correlated
that with the ELF section name.

The fix is rather simple, and even removes duplicate memcmp code.
Simply load program sections as the last step, instead of
load_and_attach while processing the relocation section.

When working with tail calls, it become even more essential that the
order of prog_fd[] is consistant, like the current dependency of the
map_fd[] order.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/bpf_load.c |   19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 74456b3eb89a..a91c57dd8571 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -516,16 +516,18 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 		processed_sec[maps_shndx] = true;
 	}
 
-	/* load programs that need map fixup (relocations) */
+	/* process all relo sections, and rewrite bpf insns for maps */
 	for (i = 1; i < ehdr.e_shnum; i++) {
 		if (processed_sec[i])
 			continue;
 
 		if (get_sec(elf, i, &ehdr, &shname, &shdr, &data))
 			continue;
+
 		if (shdr.sh_type == SHT_REL) {
 			struct bpf_insn *insns;
 
+			/* locate prog sec that need map fixup (relocations) */
 			if (get_sec(elf, shdr.sh_info, &ehdr, &shname_prog,
 				    &shdr_prog, &data_prog))
 				continue;
@@ -535,26 +537,15 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 				continue;
 
 			insns = (struct bpf_insn *) data_prog->d_buf;
-
-			processed_sec[shdr.sh_info] = true;
-			processed_sec[i] = true;
+			processed_sec[i] = true; /* relo section */
 
 			if (parse_relo_and_apply(data, symbols, &shdr, insns,
 						 map_data, nr_maps))
 				continue;
-
-			if (memcmp(shname_prog, "kprobe/", 7) == 0 ||
-			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
-			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
-			    memcmp(shname_prog, "xdp", 3) == 0 ||
-			    memcmp(shname_prog, "perf_event", 10) == 0 ||
-			    memcmp(shname_prog, "socket", 6) == 0 ||
-			    memcmp(shname_prog, "cgroup/", 7) == 0)
-				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
 	}
 
-	/* load programs that don't use maps */
+	/* load programs */
 	for (i = 1; i < ehdr.e_shnum; i++) {
 
 		if (processed_sec[i])
