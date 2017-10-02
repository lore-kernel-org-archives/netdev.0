From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] socket, bpf: fix possible use after free
Date: Mon, 02 Oct 2017 12:20:51 -0700
Message-ID: <1506972051.8061.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36975 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751819AbdJBTUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 15:20:53 -0400
Received: by mail-pf0-f194.google.com with SMTP id e69so6599267pfg.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 12:20:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Starting from linux-4.4, 3WHS no longer takes the listener lock.

Since this time, we might hit a use-after-free in sk_filter_charge(),
if the filter we got in the memcpy() of the listener content
just happened to be replaced by a thread changing listener BPF filter.

To fix this, we need to make sure the filter refcount is not already
zero before incrementing it again.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/filter.c |   12 ++++++++----
 net/core/sock.c   |    5 ++++-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 82edad58d066857aeee562661098effa3b3e6961..74b8c91fb5f4461da58c73568976bc9834c4612b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -989,10 +989,14 @@ static bool __sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 
 bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
-	bool ret = __sk_filter_charge(sk, fp);
-	if (ret)
-		refcount_inc(&fp->refcnt);
-	return ret;
+	if (!refcount_inc_not_zero(&fp->refcnt))
+		return false;
+
+	if (!__sk_filter_charge(sk, fp)) {
+		sk_filter_release(fp);
+		return false;
+	}
+	return true;
 }
 
 static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
diff --git a/net/core/sock.c b/net/core/sock.c
index 7d55c05f449d306b43fd850a61ce8ffd44174f7f..23953b741a41fbcf4a6ffb0dd5bf05bd5266b99d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1684,13 +1684,16 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 		sock_reset_flag(newsk, SOCK_DONE);
 
-		filter = rcu_dereference_protected(newsk->sk_filter, 1);
+		rcu_read_lock();
+		filter = rcu_dereference(sk->sk_filter);
 		if (filter != NULL)
 			/* though it's an empty new sock, the charging may fail
 			 * if sysctl_optmem_max was changed between creation of
 			 * original socket and cloning
 			 */
 			is_charged = sk_filter_charge(newsk, filter);
+		RCU_INIT_POINTER(newsk->sk_filter, filter);
+		rcu_read_unlock();
 
 		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk, sk))) {
 			/* We need to make sure that we don't uncharge the new
