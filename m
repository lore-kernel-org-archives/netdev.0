From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bpf: make bpf_stackmap_copy conditionally called
Date: Thu, 10 Mar 2016 02:43:42 +0100
Message-ID: <1457574245-2998842-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:61398 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934872AbcCJD1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 22:27:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the bpf syscall to use the new bpf_stackmap_copy() helper for
BPF_MAP_TYPE_STACK_TRACE causes a link error when CONFIG_PERF_EVENTS
is disabled:

kernel/built-in.o: In function `map_lookup_elem':
:(.text+0x7fca4): undefined reference to `bpf_stackmap_copy'

This patch simply avoids handling that case, which may or may not
be the correct answer here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 557c0c6e7df8 ("bpf: convert stackmap to pre-allocation")
---
 kernel/bpf/syscall.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2978d0d08869..b014b64b6116 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -290,7 +290,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		err = bpf_percpu_hash_copy(map, key, value);
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_copy(map, key, value);
-	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE) {
+	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE &&
+		   IS_ENABLED(CONFIG_PERF_EVENTS)) {
 		err = bpf_stackmap_copy(map, key, value);
 	} else {
 		rcu_read_lock();
-- 
2.7.0
