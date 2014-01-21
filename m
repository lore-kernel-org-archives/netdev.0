From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/7] sctp: remove macros sctp_spin_[un]lock
Date: Tue, 21 Jan 2014 15:44:08 +0800
Message-ID: <1390290252-16080-4-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:23174 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaAUHtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:49:23 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined spin_[un]lock to sctp_spin_[un]lock for user space friendly
code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h |  6 ++----
 net/sctp/socket.c       | 16 ++++++++--------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index c17121a..4f77e98 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -171,8 +171,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  */
 
 /* spin lock wrappers. */
-#define sctp_spin_lock(lock)    spin_lock(lock)
-#define sctp_spin_unlock(lock)  spin_unlock(lock)
 #define sctp_write_lock(lock)   write_lock(lock)
 #define sctp_write_unlock(lock) write_unlock(lock)
 #define sctp_read_lock(lock)    read_lock(lock)
@@ -349,11 +347,11 @@ static inline void sctp_skb_list_tail(struct sk_buff_head *list,
 	unsigned long flags;
 
 	spin_lock_irqsave(&head->lock, flags);
-	sctp_spin_lock(&list->lock);
+	spin_lock(&list->lock);
 
 	skb_queue_splice_tail_init(list, head);
 
-	sctp_spin_unlock(&list->lock);
+	spin_unlock(&list->lock);
 	spin_unlock_irqrestore(&head->lock, flags);
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f2e0005..98532cb 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5937,14 +5937,14 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 				continue;
 			index = sctp_phashfn(sock_net(sk), rover);
 			head = &sctp_port_hashtable[index];
-			sctp_spin_lock(&head->lock);
+			spin_lock(&head->lock);
 			sctp_for_each_hentry(pp, &head->chain)
 				if ((pp->port == rover) &&
 				    net_eq(sock_net(sk), pp->net))
 					goto next;
 			break;
 		next:
-			sctp_spin_unlock(&head->lock);
+			spin_unlock(&head->lock);
 		} while (--remaining > 0);
 
 		/* Exhausted local port range during search? */
@@ -5965,7 +5965,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		 * port iterator, pp being NULL.
 		 */
 		head = &sctp_port_hashtable[sctp_phashfn(sock_net(sk), snum)];
-		sctp_spin_lock(&head->lock);
+		spin_lock(&head->lock);
 		sctp_for_each_hentry(pp, &head->chain) {
 			if ((pp->port == snum) && net_eq(pp->net, sock_net(sk)))
 				goto pp_found;
@@ -6049,7 +6049,7 @@ success:
 	ret = 0;
 
 fail_unlock:
-	sctp_spin_unlock(&head->lock);
+	spin_unlock(&head->lock);
 
 fail:
 	local_bh_enable();
@@ -6286,13 +6286,13 @@ static inline void __sctp_put_port(struct sock *sk)
 						  inet_sk(sk)->inet_num)];
 	struct sctp_bind_bucket *pp;
 
-	sctp_spin_lock(&head->lock);
+	spin_lock(&head->lock);
 	pp = sctp_sk(sk)->bind_hash;
 	__sk_del_bind_node(sk);
 	sctp_sk(sk)->bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
 	sctp_bucket_destroy(pp);
-	sctp_spin_unlock(&head->lock);
+	spin_unlock(&head->lock);
 }
 
 void sctp_put_port(struct sock *sk)
@@ -6951,12 +6951,12 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	head = &sctp_port_hashtable[sctp_phashfn(sock_net(oldsk),
 						 inet_sk(oldsk)->inet_num)];
 	local_bh_disable();
-	sctp_spin_lock(&head->lock);
+	spin_lock(&head->lock);
 	pp = sctp_sk(oldsk)->bind_hash;
 	sk_add_bind_node(newsk, &pp->owner);
 	sctp_sk(newsk)->bind_hash = pp;
 	inet_sk(newsk)->inet_num = inet_sk(oldsk)->inet_num;
-	sctp_spin_unlock(&head->lock);
+	spin_unlock(&head->lock);
 	local_bh_enable();
 
 	/* Copy the bind_addr list from the original endpoint to the new
-- 
1.7.12
