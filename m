From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bpf: fix possible uninitialized access in inactive rotation
Date: Wed, 16 Nov 2016 15:38:21 +0100
Message-ID: <20161116143836.2448688-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Martin KaFai Lau <kafai@fb.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This newly added code causes a build warning:

kernel/bpf/bpf_lru_list.c: In function '__bpf_lru_list_rotate_inactive':
kernel/bpf/bpf_lru_list.c:201:28: error: 'next' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The warning is plausible from looking at the code, though there might
be non-obvious external constraints that ensure it always works.

Moving the assignment of ->next_inactive_rotation inside of the
loop makes it obvious to the reader and the compiler when we
actually want to update ->next.

Fixes: 3a08c2fd7634 ("bpf: LRU List")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 kernel/bpf/bpf_lru_list.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index bfebff010ba9..f462e5f09703 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -192,13 +192,14 @@ static void __bpf_lru_list_rotate_inactive(struct bpf_lru *lru,
 		next = cur->prev;
 		if (bpf_lru_node_is_ref(node))
 			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);
-		if (cur == last)
+		if (cur == last) {
+			l->next_inactive_rotation = next;
 			break;
+		}
 		cur = next;
 		i++;
 	}
 
-	l->next_inactive_rotation = next;
 }
 
 /* Shrink the inactive list.  It starts from the tail of the
-- 
2.9.0
