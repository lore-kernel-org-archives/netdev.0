From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/7] bpf: export whether tail call has jited owner
Date: Sun,  2 Jul 2017 02:13:28 +0200
Message-ID: <24e20a662e8c5fe3fb6acaedea518df4d090f6ab.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57540 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbdGBANp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:45 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do export through fdinfo already whether a prog is JITed or not,
given a program load can fail in case of either prog or tail call map
has JITed property, but neither both are JITed or not JITed, we can
facilitate error reporting in loaders like iproute2 through exporting
owner_jited of tail call map. We already do export owner_prog_type
through this facility, so parser can pick up both for comparison.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d4d47de..1898047 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -216,10 +216,12 @@ static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
 	const struct bpf_map *map = filp->private_data;
 	const struct bpf_array *array;
 	u32 owner_prog_type = 0;
+	u32 owner_jited = 0;
 
 	if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY) {
 		array = container_of(map, struct bpf_array, map);
 		owner_prog_type = array->owner_prog_type;
+		owner_jited = array->owner_jited;
 	}
 
 	seq_printf(m,
@@ -236,9 +238,12 @@ static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
 		   map->map_flags,
 		   map->pages * 1ULL << PAGE_SHIFT);
 
-	if (owner_prog_type)
+	if (owner_prog_type) {
 		seq_printf(m, "owner_prog_type:\t%u\n",
 			   owner_prog_type);
+		seq_printf(m, "owner_jited:\t%u\n",
+			   owner_jited);
+	}
 }
 #endif
 
-- 
1.9.3
