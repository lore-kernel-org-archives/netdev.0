From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/13] af_unix: Export stuff required for diag module
Date: Thu, 15 Dec 2011 16:44:03 +0400
Message-ID: <4EE9EB93.10400@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32548 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:44:08 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/net/af_unix.h |    3 +++
 net/unix/af_unix.c    |    9 ++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 91ab5b0..63b1781 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -11,10 +11,13 @@ extern void unix_notinflight(struct file *fp);
 extern void unix_gc(void);
 extern void wait_for_unix_gc(void);
 extern struct sock *unix_get_socket(struct file *filp);
+extern struct sock *unix_peer_get(struct sock *);
 
 #define UNIX_HASH_SIZE	256
 
 extern unsigned int unix_tot_inflight;
+extern spinlock_t unix_table_lock;
+extern struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 
 struct unix_address {
 	atomic_t	refcnt;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index b595a3d..e1b9358 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -115,8 +115,10 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
-static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
-static DEFINE_SPINLOCK(unix_table_lock);
+struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
+EXPORT_SYMBOL_GPL(unix_socket_table);
+DEFINE_SPINLOCK(unix_table_lock);
+EXPORT_SYMBOL_GPL(unix_table_lock);
 static atomic_long_t unix_nr_socks;
 
 #define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
@@ -172,7 +174,7 @@ static inline int unix_recvq_full(struct sock const *sk)
 	return skb_queue_len(&sk->sk_receive_queue) > sk->sk_max_ack_backlog;
 }
 
-static struct sock *unix_peer_get(struct sock *s)
+struct sock *unix_peer_get(struct sock *s)
 {
 	struct sock *peer;
 
@@ -183,6 +185,7 @@ static struct sock *unix_peer_get(struct sock *s)
 	unix_state_unlock(s);
 	return peer;
 }
+EXPORT_SYMBOL_GPL(unix_peer_get);
 
 static inline void unix_release_addr(struct unix_address *addr)
 {
-- 
1.5.5.6
