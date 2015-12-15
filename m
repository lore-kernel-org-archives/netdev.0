From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 6/6] bpf: hash: reorganize 'struct htab_elem'
Date: Tue, 15 Dec 2015 19:21:04 +0800
Message-ID: <1450178464-27721-7-git-send-email-tom.leiming@gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lifetime for hash fields and liftime for kfree_rcu fields
can't be overlapped, so re-organizing them for better
readabilty.

Also one sizeof(void *) should be saved with this change,
and cache footprint can got improved too.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index c1600c3..5476545 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -17,15 +17,20 @@
 
 /* each htab element is struct htab_elem + key + value */
 struct htab_elem {
+	u32 tag;
 	union {
-		struct hlist_node hash_node;
-
-		/* used after deleted from hash */
-		struct bpf_htab *htab;
+		/* won't be used after being removed from hash */
+		struct {
+			u32 hash;
+			struct hlist_node hash_node;
+		};
+
+		/* set after being deleted from hash */
+		struct {
+			struct bpf_htab *htab;
+			struct rcu_head rcu;
+		};
 	};
-	struct rcu_head rcu;
-	u32 hash;
-	u32 tag;
 	char key[0] __aligned(8);
 };
 
-- 
1.9.1
