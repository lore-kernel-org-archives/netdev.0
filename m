From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rcu tree with the net tree
Date: Tue, 3 May 2011 14:24:19 +1000
Message-ID: <20110503142419.2b7d5e23.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

Today's linux-next merge of the rcu tree got a conflict in
net/core/filter.c between commit 0a14842f5a3c ("net: filter: Just In Time
compiler for x86-64") from the net tree and commit 10cde158c259
("net,rcu: convert call_rcu(sk_filter_release_rcu) to kfree_rcu") from
the rcu tree.

The former adds another operation into sk_filter_release_rcu(), so I have
effectively reverted the rcu tree change for now (by applying the patch
below as a merge fixup).
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 3 May 2011 14:06:50 +1000
Subject: [PATCH] Revert "net,rcu: convert call_rcu(sk_filter_release_rcu) to
 kfree_rcu"

This reverts commit 10cde158c2591422a2b32a2f560f406b8e69bee6.
---
 include/net/sock.h |    4 +++-
 net/core/filter.c  |   13 +++++++++++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1a2f255..f2046e4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1180,6 +1180,8 @@ extern void sk_common_release(struct sock *sk);
 /* Initialise core socket variables */
 extern void sock_init_data(struct socket *sock, struct sock *sk);
 
+extern void sk_filter_release_rcu(struct rcu_head *rcu);
+
 /**
  *	sk_filter_release - release a socket filter
  *	@fp: filter to remove
@@ -1190,7 +1192,7 @@ extern void sock_init_data(struct socket *sock, struct sock *sk);
 static inline void sk_filter_release(struct sk_filter *fp)
 {
 	if (atomic_dec_and_test(&fp->refcnt))
-		kfree_rcu(fp, rcu);
+		call_rcu(&fp->rcu, sk_filter_release_rcu);
 }
 
 static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index 66d403d..0eb8c44 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -572,6 +572,19 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 EXPORT_SYMBOL(sk_chk_filter);
 
 /**
+ * 	sk_filter_release_rcu - Release a socket filter by rcu_head
+ *	@rcu: rcu_head that contains the sk_filter to free
+ */
+void sk_filter_release_rcu(struct rcu_head *rcu)
+{
+	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
+
+	bpf_jit_free(fp);
+	kfree(fp);
+}
+EXPORT_SYMBOL(sk_filter_release_rcu);
+
+/**
  *	sk_attach_filter - attach a socket filter
  *	@fprog: the filter program
  *	@sk: the socket to use
-- 
1.7.4.4
