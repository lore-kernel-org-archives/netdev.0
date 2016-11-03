From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix map not being uncharged during map creation failure
Date: Fri,  4 Nov 2016 00:56:31 +0100
Message-ID: <89c1a3a48ca9940a0fdc1298e11c03c4074a1c59.1478216947.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48259 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758726AbcKCX4q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In map_create(), we first find and create the map, then once that
suceeded, we charge it to the user's RLIMIT_MEMLOCK, and then fetch
a new anon fd through anon_inode_getfd(). The problem is, once the
latter fails f.e. due to RLIMIT_NOFILE limit, then we only destruct
the map via map->ops->map_free(), but without uncharging the previously
locked memory first. That means that the user_struct allocation is
leaked as well as the accounted RLIMIT_MEMLOCK memory not released.
Make the label names in the fix consistent with bpf_prog_load().

Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..237f3d6 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -194,7 +194,7 @@ static int map_create(union bpf_attr *attr)
 
 	err = bpf_map_charge_memlock(map);
 	if (err)
-		goto free_map;
+		goto free_map_nouncharge;
 
 	err = bpf_map_new_fd(map);
 	if (err < 0)
@@ -204,6 +204,8 @@ static int map_create(union bpf_attr *attr)
 	return err;
 
 free_map:
+	bpf_map_uncharge_memlock(map);
+free_map_nouncharge:
 	map->ops->map_free(map);
 	return err;
 }
-- 
1.9.3
