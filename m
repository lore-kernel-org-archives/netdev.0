From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] socket, bpf: fix sk_filter use after free in sk_clone_lock
Date: Wed, 22 Mar 2017 13:08:08 +0100
Message-ID: <3016fb20a3666f0db138b85049f9000ecd33a1f6.1490184193.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33220 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759013AbdCVM02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 08:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sk_clone_lock(), we create a new socket and inherit most of the
parent's members via sock_copy() which memcpy()'s various sections.
Now, in case the parent socket had a BPF socket filter attached,
then newsk->sk_filter points to the same instance as the original
sk->sk_filter.

sk_filter_charge() is then called on the newsk->sk_filter to take a
reference and should that fail due to hitting max optmem, we bail
out and release the newsk instance.

The issue is that commit 278571baca2a ("net: filter: simplify socket
charging") wrongly combined the dismantle path with the failure path
of xfrm_sk_clone_policy(). This means, even when charging failed, we
call sk_free_unlock_clone() on the newsk, which then still points to
the same sk_filter as the original sk.

Thus, sk_free_unlock_clone() calls into __sk_destruct() eventually
where it tests for present sk_filter and calls sk_filter_uncharge()
on it, which potentially lets sk_omem_alloc wrap around and releases
the eBPF prog and sk_filter structure from the (still intact) parent.

Fix it by making sure that when sk_filter_charge() failed, we reset
newsk->sk_filter back to NULL before passing to sk_free_unlock_clone(),
so that we don't mess with the parents sk_filter.

Only if xfrm_sk_clone_policy() fails, we did reach the point where
either the parent's filter was NULL and as a result newsk's as well
or where we previously had a successful sk_filter_charge(), thus for
that case, we do need sk_filter_uncharge() to release the prior taken
reference on sk_filter.

Fixes: 278571baca2a ("net: filter: simplify socket charging")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/sock.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index acb0d41..2c4f574 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1544,6 +1544,12 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 			is_charged = sk_filter_charge(newsk, filter);
 
 		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk, sk))) {
+			/* We need to make sure that we don't uncharge the new
+			 * socket if we couldn't charge it in the first place
+			 * as otherwise we uncharge the parent's filter.
+			 */
+			if (!is_charged)
+				RCU_INIT_POINTER(newsk->sk_filter, NULL);
 			sk_free_unlock_clone(newsk);
 			newsk = NULL;
 			goto out;
-- 
1.9.3
