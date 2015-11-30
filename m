From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, array: fix heap out-of-bounds access when updating elements
Date: Mon, 30 Nov 2015 13:02:56 +0100
Message-ID: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
References: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Cc: ast@kernel.org, dvyukov@google.com, kcc@google.com,
	glider@google.com, edumazet@google.com, sasha.levin@oracle.com,
	syzkaller@googlegroups.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36984 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbbK3MDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 07:03:02 -0500
In-Reply-To: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During own review but also reported by Dmitry's syzkaller [1] it has been
noticed that we trigger a heap out-of-bounds access on eBPF array maps
when updating elements. This happens with each map whose map->value_size
(specified during map creation time) is not multiple of 8 bytes.

In array_map_alloc(), elem_size is round_up(attr->value_size, 8) and
used to align array map slots for faster access. However, in function
array_map_update_elem(), we update the element as ...

memcpy(array->value + array->elem_size * index, value, array->elem_size);

... where we access 'value' out-of-bounds, since it was allocated from
map_update_elem() from syscall side as kmalloc(map->value_size, GFP_USER)
and later on copied through copy_from_user(value, uvalue, map->value_size).
Thus, up to 7 bytes, we can access out-of-bounds.

Same could happen from within an eBPF program, where in worst case we
access beyond an eBPF program's designated stack.

Since 1be7f75d1668 ("bpf: enable non-root eBPF programs") didn't hit an
official release yet, it only affects priviledged users.

In case of array_map_lookup_elem(), the verifier prevents eBPF programs
from accessing beyond map->value_size through check_map_access(). Also
from syscall side map_lookup_elem() only copies map->value_size back to
user, so nothing could leak.

  [1] http://github.com/google/syzkaller

Fixes: 28fbcfa08d8e ("bpf: add array type of eBPF maps")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/arraymap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 3f4c99e..4c67ce3 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -105,7 +105,7 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
 		/* all elements already exist */
 		return -EEXIST;
 
-	memcpy(array->value + array->elem_size * index, value, array->elem_size);
+	memcpy(array->value + array->elem_size * index, value, map->value_size);
 	return 0;
 }
 
-- 
1.9.3
