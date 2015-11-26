From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: use-after-free in sock_wake_async
Date: Thu, 26 Nov 2015 15:31:33 +0100
Message-ID: <1448548293.879369.450777185.798D081C@webmail.messagingengine.com>
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
 <87r3jcx4w7.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
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
In-Reply-To: <87r3jcx4w7.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, Nov 26, 2015, at 14:32, Hannes Frederic Sowa wrote:
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7f89e4b..ae34da1 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1674,7 +1674,7 @@ static inline void sock_orphan(struct sock *sk)
>  static inline void sock_graft(struct sock *sk, struct socket *parent)
>  {
>  	write_lock_bh(&sk->sk_callback_lock);
> -       sk->sk_wq = parent->wq;
> +       sk->sk_wq = &parent->wq;

RCU_INIT_POINTER(sk->sk_wq, &parent->wq);

>  	parent->sk = sk;
>  	sk_set_socket(sk, parent);
>  	security_sock_graft(sk, parent);
> diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
> index 630c197..c125881 100644
> --- a/kernel/rcu/tree_plugin.h
> +++ b/kernel/rcu/tree_plugin.h
> @@ -657,7 +657,7 @@ static void rcu_preempt_do_callbacks(void)
>  /*
>   * Queue a preemptible-RCU callback for invocation after a grace period.
>   */
> -void call_rcu(struct rcu_head *head, rcu_callback_t func)
> +static void call_rcu(struct rcu_head *head, rcu_callback_t func)
>  {
>  	__call_rcu(head, func, rcu_state_p, -1, 0);
>  }
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 1e4dd54..314ab6a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2383,7 +2383,7 @@ void sock_init_data(struct socket *sock, struct
> sock *sk)
>  
>  	if (sock) {
>  		sk->sk_type	=	sock->type;
> -               sk->sk_wq       =       sock->wq;
> +               sk->sk_wq       =       &sock->wq;

RCU_INIT_POINTER()

>  		sock->sk	=	sk;
>  	} else
>  		sk->sk_wq	=	NULL;
> diff --git a/net/socket.c b/net/socket.c
> index dd2c247..495485e 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -245,19 +245,12 @@ static struct kmem_cache *sock_inode_cachep
> __read_mostly;
>  static struct inode *sock_alloc_inode(struct super_block *sb)
>  {
>  	struct socket_alloc *ei;
> -       struct socket_wq *wq;
>  
>  	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
>  	if (!ei)
>  		return NULL;
> -       wq = kmalloc(sizeof(*wq), GFP_KERNEL);
> -       if (!wq) {
> -               kmem_cache_free(sock_inode_cachep, ei);
> -               return NULL;
> -       }
> -       init_waitqueue_head(&wq->wait);
> -       wq->fasync_list = NULL;
> -       RCU_INIT_POINTER(ei->socket.wq, wq);
> +       init_waitqueue_head(&ei->socket.wq.wait);
> +       ei->socket.wq.fasync_list = NULL;
>  
>  	ei->socket.state = SS_UNCONNECTED;
>  	ei->socket.flags = 0;
> @@ -268,17 +261,18 @@ static struct inode *sock_alloc_inode(struct
> super_block *sb)
>  	return &ei->vfs_inode;
>  }
>  
> -static void sock_destroy_inode(struct inode *inode)
> +static void sock_cache_free_rcu(struct rcu_head *rcu)
>  {
> -       struct socket_alloc *ei;
> -       struct socket_wq *wq;
> -
> -       ei = container_of(inode, struct socket_alloc, vfs_inode);
> -       wq = rcu_dereference_protected(ei->socket.wq, 1);
> -       kfree_rcu(wq, rcu);
> +       struct socket_alloc *ei =
> +               container_of(rcu, struct socket_alloc, vfs_inode.i_rcu);
>  	kmem_cache_free(sock_inode_cachep, ei);
>  }
>  
> +static void sock_destroy_inode(struct inode *inode)
> +{
> +       call_rcu(&inode->i_rcu, sock_cache_free_rcu);
> +}
> +
>  static void init_once(void *foo)
>  {
>  	struct socket_alloc *ei = (struct socket_alloc *)foo;
> @@ -573,7 +567,7 @@ void sock_release(struct socket *sock)
>  		module_put(owner);
>  	}
>  
> -       if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
> +       if (sock->wq.fasync_list)
>  		pr_err("%s: fasync list not empty!\n", __func__);
>  
>  	this_cpu_sub(sockets_in_use, 1);
> @@ -1044,7 +1038,7 @@ static int sock_fasync(int fd, struct file *filp,
> int on)
>  		return -EINVAL;
>  
>  	lock_sock(sk);
> -       wq = rcu_dereference_protected(sock->wq, sock_owned_by_user(sk));
> +       wq = &sock->wq;
>  	fasync_helper(fd, filp, on, &wq->fasync_list);
>  
>  	if (!wq->fasync_list)
> @@ -1065,7 +1059,7 @@ int sock_wake_async(struct socket *sock, int how,
> int band)
>  	if (!sock)
>  		return -1;
>  	rcu_read_lock();
> -       wq = rcu_dereference(sock->wq);
> +       wq = &sock->wq;
>  	if (!wq || !wq->fasync_list) {
>  		rcu_read_unlock();
>  		return -1;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
