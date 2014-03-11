From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 3/9] net: filter: generalise sk_filter_release
Date: Tue, 11 Mar 2014 10:19:14 +0100
Message-ID: <1394529560-3490-4-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds generic a new callback function to release bytecode
area which depends on the socket filter type. This change prepares
the implementation of new socket filtering approaches.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/filter.h |    1 +
 include/net/sock.h     |    4 +---
 net/core/filter.c      |    4 ++--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index ab37714..7cba4c2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -28,6 +28,7 @@ struct sk_filter {
 	struct rcu_head		rcu;
 	unsigned int		(*run_filter)(const struct sk_buff *skb,
 					      const struct sock_filter *filter);
+	void			(*release_rcu)(struct rcu_head *rcu);
 	union {
 		struct sock_filter     	insns[0];
 		struct work_struct	work;
diff --git a/include/net/sock.h b/include/net/sock.h
index 7b9723c..9f9acbf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1616,8 +1616,6 @@ void sk_common_release(struct sock *sk);
 /* Initialise core socket variables */
 void sock_init_data(struct socket *sock, struct sock *sk);
 
-void sk_filter_release_rcu(struct rcu_head *rcu);
-
 /**
  *	sk_filter_release - release a socket filter
  *	@fp: filter to remove
@@ -1628,7 +1626,7 @@ void sk_filter_release_rcu(struct rcu_head *rcu);
 static inline void sk_filter_release(struct sk_filter *fp)
 {
 	if (atomic_dec_and_test(&fp->refcnt))
-		call_rcu(&fp->rcu, sk_filter_release_rcu);
+		call_rcu(&fp->rcu, fp->release_rcu);
 }
 
 static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index 3ea0e7f..826ca63 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -633,19 +633,19 @@ EXPORT_SYMBOL(sk_chk_filter);
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
  */
-void sk_filter_release_rcu(struct rcu_head *rcu)
+static void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
 	bpf_jit_free(fp);
 }
-EXPORT_SYMBOL(sk_filter_release_rcu);
 
 static int __sk_prepare_filter(struct sk_filter *fp)
 {
 	int err;
 
 	fp->run_filter = sk_run_filter;
+	fp->release_rcu = sk_filter_release_rcu;
 
 	err = sk_chk_filter(fp->insns, sk_bpf_flen(fp));
 	if (err)
-- 
1.7.10.4

