From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 8/8] af_unix: charge buffers to kmemcg
Date: Tue, 24 May 2016 11:49:30 +0300
Message-ID: <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, Johannes Weiner
	<hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, <linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>, <x86@kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Unix sockets can consume a significant amount of system memory, hence
they should be accounted to kmemcg.

Since unix socket buffers are always allocated from process context,
all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
sock->sk_allocation mask.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/unix/af_unix.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 80aa6a3e6817..022bdd3ab7d9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -769,6 +769,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	lockdep_set_class(&sk->sk_receive_queue.lock,
 				&af_unix_sk_receive_queue_lock_key);
 
+	sk->sk_allocation	= GFP_KERNEL_ACCOUNT;
 	sk->sk_write_space	= unix_write_space;
 	sk->sk_max_ack_backlog	= net->unx.sysctl_max_dgram_qlen;
 	sk->sk_destruct		= unix_sock_destructor;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
