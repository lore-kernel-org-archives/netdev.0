From: NeilBrown <neilb@suse.de>
Subject: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
Date: Wed, 16 Apr 2014 14:03:36 +1000
Message-ID: <20140416040336.10604.96000.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xfs@oss.sgi.com
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
Cc: netdev@vger.kernel.org
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

sk_lock can be taken while reclaiming memory (in nfsd for loop-back
NFS mounts, and presumably in nfs), and memory can be allocated while
holding sk_lock, at least via:

 inet_listen -> inet_csk_listen_start ->reqsk_queue_alloc

So to avoid deadlocks, always set PF_FSTRANS while holding sk_lock.

This deadlock was found by lockdep.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/net/sock.h |    1 +
 net/core/sock.c    |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index b9586a137cad..27c355637e44 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -324,6 +324,7 @@ struct sock {
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 
 	socket_lock_t		sk_lock;
+	unsigned int		sk_pflags; /* process flags before taking lock */
 	struct sk_buff_head	sk_receive_queue;
 	/*
 	 * The backlog queue is special, it is always used with
diff --git a/net/core/sock.c b/net/core/sock.c
index cf9bd24e4099..8bc677ef072e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2341,6 +2341,7 @@ void lock_sock_nested(struct sock *sk, int subclass)
 	/*
 	 * The sk_lock has mutex_lock() semantics here:
 	 */
+	current_set_flags_nested(&sk->sk_pflags, PF_FSTRANS);
 	mutex_acquire(&sk->sk_lock.dep_map, subclass, 0, _RET_IP_);
 	local_bh_enable();
 }
@@ -2352,6 +2353,7 @@ void release_sock(struct sock *sk)
 	 * The sk_lock has mutex_unlock() semantics:
 	 */
 	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
+	current_restore_flags_nested(&sk->sk_pflags, PF_FSTRANS);
 
 	spin_lock_bh(&sk->sk_lock.slock);
 	if (sk->sk_backlog.tail)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
