From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 2/2] net: Introduce sk_clone_lock() error path routine
Date: Wed,  1 Mar 2017 16:35:08 -0300
Message-ID: <20170301193508.25760-2-acme@kernel.org>
References: <20170301193508.25760-1-acme@kernel.org>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        Thomas Gleixner <tglx@linutronix.de>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:46826 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753140AbdCAVo0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 16:44:26 -0500
In-Reply-To: <20170301193508.25760-1-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

When handling problems in cloning a socket with the sk_clone_locked()
function we need to perform several steps that were open coded in it and
its callers, so introduce a routine to avoid this duplication:
sk_free_unlock_clone().

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/n/net-ui6laqkotycunhtmqryl9bfx@git.kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/sock.h   |  1 +
 net/core/sock.c      | 16 +++++++++++-----
 net/dccp/minisocks.c |  6 +-----
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c4f5e6fca17c..93d1160bcd32 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1520,6 +1520,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 void sk_free(struct sock *sk);
 void sk_destruct(struct sock *sk);
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
+void sk_free_unlock_clone(struct sock *sk);
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
diff --git a/net/core/sock.c b/net/core/sock.c
index 4eca27dc5c94..a3d9bb20f65d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1540,11 +1540,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 			is_charged = sk_filter_charge(newsk, filter);
 
 		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk, sk))) {
-			/* It is still raw copy of parent, so invalidate
-			 * destructor and make plain sk_free() */
-			newsk->sk_destruct = NULL;
-			bh_unlock_sock(newsk);
-			sk_free(newsk);
+			sk_free_unlock_clone(newsk);
 			newsk = NULL;
 			goto out;
 		}
@@ -1593,6 +1589,16 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 }
 EXPORT_SYMBOL_GPL(sk_clone_lock);
 
+void sk_free_unlock_clone(struct sock *sk)
+{
+	/* It is still raw copy of parent, so invalidate
+	 * destructor and make plain sk_free() */
+	sk->sk_destruct = NULL;
+	bh_unlock_sock(sk);
+	sk_free(sk);
+}
+EXPORT_SYMBOL_GPL(sk_free_unlock_clone);
+
 void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
 	u32 max_segs = 1;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index d20d948a98ed..e267e6f4c9a5 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -119,11 +119,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
 		 * Activate features: initialise CCIDs, sequence windows etc.
 		 */
 		if (dccp_feat_activate_values(newsk, &dreq->dreq_featneg)) {
-			/* It is still raw copy of parent, so invalidate
-			 * destructor and make plain sk_free() */
-			newsk->sk_destruct = NULL;
-			bh_unlock_sock(newsk);
-			sk_free(newsk);
+			sk_free_unlock_clone(newsk);
 			return NULL;
 		}
 		dccp_init_xmit_timers(newsk);
-- 
2.9.3
