From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net] net: sk_clone_lock() should only do get_net() if the
 parent is not a kernel socket
Date: Thu, 30 Jul 2015 15:50:36 +0200
Message-ID: <20150730135036.GA17366@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, willemb@google.com,
	ebiederm@xmission.com, alexander.h.duyck@intel.com,
	ast@plumgrid.com, hannes@stressinduktion.org, dborkman@redhat.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



The newsk returned by sk_clone_lock should hold a get_net()
reference if, and only if, the parent is not a kernel socket
(making this similar to sk_alloc()).

E.g,. for the SYN_RECV path, tcp_v4_syn_recv_sock->..inet_csk_clone_lock
sets up the syn_recv newsk from sk_clone_lock. When the parent (listen)
socket is a kernel socket (defined in sk_alloc() as having
sk_net_refcnt == 0), then the newsk should also have a 0 sk_net_refcnt
and should not hold a get_net() reference.

Fixes: 26abe14379f8 ("net: Modify sk_alloc to not reference count the
      netns of kernel sockets.")
Acked-by: Eric Dumazet <edumazet@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: pulled patch #3 out of the RFC patch-set for RDS-TCP netns fixes; 
    Added Fixes, Acked-by, Cc fields based on mailing list feedback
    from Eric Dumazet.

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
