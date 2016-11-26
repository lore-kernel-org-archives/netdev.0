From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/6] bpf: add owner_prog_type and accounted mem to array map's fdinfo
Date: Sat, 26 Nov 2016 01:28:07 +0100
Message-ID: <3f8494503627c738d3bbf93949c9c346e86109a5.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42853 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow for checking the owner_prog_type of a program array map. In some
cases bpf(2) can return -EINVAL /after/ the verifier passed and did all
the rewrites of the bpf program.

The reason that lets us fail at this late stage is that program array
maps are incompatible. Allow users to inspect this earlier after they
got the map fd through BPF_OBJ_GET command. tc will get support for this.

Also, display how much we charged the map with regards to RLIMIT_MEMLOCK.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1090d16..4caa18e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -138,18 +138,31 @@ static int bpf_map_release(struct inode *inode, struct file *filp)
 static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
 {
 	const struct bpf_map *map = filp->private_data;
+	const struct bpf_array *array;
+	u32 owner_prog_type = 0;
+
+	if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY) {
+		array = container_of(map, struct bpf_array, map);
+		owner_prog_type = array->owner_prog_type;
+	}
 
 	seq_printf(m,
 		   "map_type:\t%u\n"
 		   "key_size:\t%u\n"
 		   "value_size:\t%u\n"
 		   "max_entries:\t%u\n"
-		   "map_flags:\t%#x\n",
+		   "map_flags:\t%#x\n"
+		   "memlock:\t%llu\n",
 		   map->map_type,
 		   map->key_size,
 		   map->value_size,
 		   map->max_entries,
-		   map->map_flags);
+		   map->map_flags,
+		   map->pages * 1ULL << PAGE_SHIFT);
+
+	if (owner_prog_type)
+		seq_printf(m, "owner_prog_type:\t%u\n",
+			   owner_prog_type);
 }
 #endif
 
-- 
1.9.3
