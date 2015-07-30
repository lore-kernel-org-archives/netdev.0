From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next 3/3] net/core/sock.c: sk_clone_lock() should only do get_net() if the parent is not a kernel socket
Date: Thu, 30 Jul 2015 04:55:47 -0400
Message-ID: <15334c31275787177fb1d12927604ee87d3938d4.1438245718.git.sowmini.varadhan@oracle.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
Cc: cwang@twopensource.com, ajaykumar.hotchandani@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32630 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999AbbG3I4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 04:56:22 -0400
In-Reply-To: <cover.1438245718.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1438245718.git.sowmini.varadhan@oracle.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newsk returned by sk_clone_lock should hold a get_net()
reference if, and only if, the parent is not a kernel socket
(making this similar to sk_alloc()).

E.g,. for the SYN_RECV call path, tcp_v4_syn_recv_sock->..inet_csk_clone_lock
sets up the syn_recv newsk from sk_clone_lock. When the parent (listen)
socket is a kernel socket (defined in sk_alloc() as having
sk_net_refcnt == 0), then the newsk should also have a 0 sk_net_refcnt
and should not hold a get_net() reference.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/core/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 08f16db..371d1b7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1497,7 +1497,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
-		get_net(sock_net(newsk));
+		if (likely(newsk->sk_net_refcnt))
+			get_net(sock_net(newsk));
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
-- 
1.7.1
