From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: use-after-free in sock_wake_async
Date: Thu, 26 Nov 2015 14:32:40 +0100
Message-ID: <87r3jcx4w7.fsf@stressinduktion.org>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
 <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
 <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
 <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
 <1448473891.24696.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <87610q3pjg.fsf@doppelsaurus.mobileactivedefense.com>
 <1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <87y4dl3m5c.fsf@doppelsaurus.mobileactivedefense.com>
 <1448481002.24696.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <87two93ig8.fsf@doppelsaurus.mobileactivedefense.com>
 <1448489350.24696.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448490732.1842763.450231537.5358AF37@webmail.messagingengine.com>
 <1448491414.24696.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448491950.1848115.450243417.726E2DCB@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448491950.1848115.450243417.726E2DCB@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:


> I have seen filesystems already doing so in .destroy_inode, that's why I
> am asking. The allocation happens the same way as we do with sock_alloc,
> e.g. shmem. I actually thought that struct inode already provides an
> rcu_head for exactly that reason.

E.g.:

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 54036ae..e15c49f 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -35,7 +35,6 @@
 struct macvtap_queue {
 	struct sock sk;
 	struct socket sock;
-	struct socket_wq wq;
 	int vnet_hdr_sz;
 	struct macvlan_dev __rcu *vlan;
 	struct file *file;
@@ -529,8 +528,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	if (!q)
 		goto out;
 
-	RCU_INIT_POINTER(q->sock.wq, &q->wq);
-	init_waitqueue_head(&q->wq.wait);
+	init_waitqueue_head(&q->sock.wq.wait);
 	q->sock.type = SOCK_RAW;
 	q->sock.state = SS_CONNECTED;
 	q->sock.file = file;
@@ -579,7 +577,7 @@ static unsigned int macvtap_poll(struct file *file, poll_table * wait)
 		goto out;
 
 	mask = 0;
-	poll_wait(file, &q->wq.wait, wait);
+	poll_wait(file, &q->sock.wq.wait, wait);
 
 	if (!skb_queue_empty(&q->sk.sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b1878fa..20c5d34 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -145,7 +145,6 @@ struct tap_filter {
 struct tun_file {
 	struct sock sk;
 	struct socket socket;
-	struct socket_wq wq;
 	struct tun_struct __rcu *tun;
 	struct fasync_struct *fasync;
 	/* only used for fasnyc */
@@ -2219,8 +2218,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile->flags = 0;
 	tfile->ifindex = 0;
 
-	init_waitqueue_head(&tfile->wq.wait);
-	RCU_INIT_POINTER(tfile->socket.wq, &tfile->wq);
+	init_waitqueue_head(&tfile->socket.wq.wait);
 
 	tfile->socket.file = file;
 	tfile->socket.ops = &tun_socket_ops;
diff --git a/include/linux/net.h b/include/linux/net.h
index 70ac5e2..3a7a4d1 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -89,8 +89,7 @@ struct socket_wq {
 	/* Note: wait MUST be first field of socket_wq */
 	wait_queue_head_t	wait;
 	struct fasync_struct	*fasync_list;
-	struct rcu_head		rcu;
-} ____cacheline_aligned_in_smp;
+};
 
 /**
  *  struct socket - general BSD socket
@@ -111,7 +110,7 @@ struct socket {
 
 	unsigned long		flags;
 
-	struct socket_wq __rcu	*wq;
+	struct socket_wq	wq;
 
 	struct file		*file;
 	struct sock		*sk;
diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4b..ae34da1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1674,7 +1674,7 @@ static inline void sock_orphan(struct sock *sk)
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
 	write_lock_bh(&sk->sk_callback_lock);
-	sk->sk_wq = parent->wq;
+	sk->sk_wq = &parent->wq;
 	parent->sk = sk;
 	sk_set_socket(sk, parent);
 	security_sock_graft(sk, parent);
diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 630c197..c125881 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -657,7 +657,7 @@ static void rcu_preempt_do_callbacks(void)
 /*
  * Queue a preemptible-RCU callback for invocation after a grace period.
  */
-void call_rcu(struct rcu_head *head, rcu_callback_t func)
+static void call_rcu(struct rcu_head *head, rcu_callback_t func)
 {
 	__call_rcu(head, func, rcu_state_p, -1, 0);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54..314ab6a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2383,7 +2383,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	if (sock) {
 		sk->sk_type	=	sock->type;
-		sk->sk_wq	=	sock->wq;
+		sk->sk_wq	=	&sock->wq;
 		sock->sk	=	sk;
 	} else
 		sk->sk_wq	=	NULL;
diff --git a/net/socket.c b/net/socket.c
index dd2c247..495485e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -245,19 +245,12 @@ static struct kmem_cache *sock_inode_cachep __read_mostly;
 static struct inode *sock_alloc_inode(struct super_block *sb)
 {
 	struct socket_alloc *ei;
-	struct socket_wq *wq;
 
 	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
-	wq = kmalloc(sizeof(*wq), GFP_KERNEL);
-	if (!wq) {
-		kmem_cache_free(sock_inode_cachep, ei);
-		return NULL;
-	}
-	init_waitqueue_head(&wq->wait);
-	wq->fasync_list = NULL;
-	RCU_INIT_POINTER(ei->socket.wq, wq);
+	init_waitqueue_head(&ei->socket.wq.wait);
+	ei->socket.wq.fasync_list = NULL;
 
 	ei->socket.state = SS_UNCONNECTED;
 	ei->socket.flags = 0;
@@ -268,17 +261,18 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 	return &ei->vfs_inode;
 }
 
-static void sock_destroy_inode(struct inode *inode)
+static void sock_cache_free_rcu(struct rcu_head *rcu)
 {
-	struct socket_alloc *ei;
-	struct socket_wq *wq;
-
-	ei = container_of(inode, struct socket_alloc, vfs_inode);
-	wq = rcu_dereference_protected(ei->socket.wq, 1);
-	kfree_rcu(wq, rcu);
+	struct socket_alloc *ei =
+		container_of(rcu, struct socket_alloc, vfs_inode.i_rcu);
 	kmem_cache_free(sock_inode_cachep, ei);
 }
 
+static void sock_destroy_inode(struct inode *inode)
+{
+	call_rcu(&inode->i_rcu, sock_cache_free_rcu);
+}
+
 static void init_once(void *foo)
 {
 	struct socket_alloc *ei = (struct socket_alloc *)foo;
@@ -573,7 +567,7 @@ void sock_release(struct socket *sock)
 		module_put(owner);
 	}
 
-	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
+	if (sock->wq.fasync_list)
 		pr_err("%s: fasync list not empty!\n", __func__);
 
 	this_cpu_sub(sockets_in_use, 1);
@@ -1044,7 +1038,7 @@ static int sock_fasync(int fd, struct file *filp, int on)
 		return -EINVAL;
 
 	lock_sock(sk);
-	wq = rcu_dereference_protected(sock->wq, sock_owned_by_user(sk));
+	wq = &sock->wq;
 	fasync_helper(fd, filp, on, &wq->fasync_list);
 
 	if (!wq->fasync_list)
@@ -1065,7 +1059,7 @@ int sock_wake_async(struct socket *sock, int how, int band)
 	if (!sock)
 		return -1;
 	rcu_read_lock();
-	wq = rcu_dereference(sock->wq);
+	wq = &sock->wq;
 	if (!wq || !wq->fasync_list) {
 		rcu_read_unlock();
 		return -1;
