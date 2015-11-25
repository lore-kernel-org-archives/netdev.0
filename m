From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Tue, 24 Nov 2015 21:43:30 -0800
Message-ID: <1448430210.22599.322.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <1448418495.22599.320.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
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
To: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34117 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbbKYFnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 00:43:33 -0500
In-Reply-To: <1448418495.22599.320.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-24 at 18:28 -0800, Eric Dumazet wrote:
> Dmitry, could you test following patch with your setup ?
> 
> ( I tried to reproduce the error you reported but could not )
> 
> Inode can be freed (without RCU grace period), but not the socket or
> sk_wq
> 
> By using sk_wq in the critical paths, we do not dereference the inode,
> 
> 

I finally was able to reproduce the warning (with more instances running
in parallel), and apparently this patch solves the problem.

> 
> Thanks !
> 
>  include/linux/net.h |    2 +-
>  include/net/sock.h  |    8 ++++++--
>  net/core/stream.c   |    2 +-
>  net/sctp/socket.c   |    6 +++++-
>  net/socket.c        |   16 +++++-----------
>  5 files changed, 18 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 70ac5e28e6b7..6b93ec234ce8 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -202,7 +202,7 @@ enum {
>  	SOCK_WAKE_URG,
>  };
>  
> -int sock_wake_async(struct socket *sk, int how, int band);
> +int sock_wake_async(struct socket *sock, struct socket_wq *wq, int how, int band);
>  int sock_register(const struct net_proto_family *fam);
>  void sock_unregister(int family);
>  int __sock_create(struct net *net, int family, int type, int proto,
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7f89e4ba18d1..af78f9e7a218 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2007,8 +2007,12 @@ static inline unsigned long sock_wspace(struct sock *sk)
>  
>  static inline void sk_wake_async(struct sock *sk, int how, int band)
>  {
> -	if (sock_flag(sk, SOCK_FASYNC))
> -		sock_wake_async(sk->sk_socket, how, band);
> +	if (sock_flag(sk, SOCK_FASYNC)) {
> +		rcu_read_lock();
> +		sock_wake_async(sk->sk_socket, rcu_dereference(sk->sk_wq),
> +				how, band);
> +		rcu_read_unlock();
> +	}
>  }
>  
>  /* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
> diff --git a/net/core/stream.c b/net/core/stream.c
> index d70f77a0c889..92682228919d 100644
> --- a/net/core/stream.c
> +++ b/net/core/stream.c
> @@ -39,7 +39,7 @@ void sk_stream_write_space(struct sock *sk)
>  			wake_up_interruptible_poll(&wq->wait, POLLOUT |
>  						POLLWRNORM | POLLWRBAND);
>  		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
> -			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
> +			sock_wake_async(sock, wq, SOCK_WAKE_SPACE, POLL_OUT);
>  		rcu_read_unlock();
>  	}
>  }
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 897c01c029ca..6ab04866a1e7 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6817,9 +6817,13 @@ static void __sctp_write_space(struct sctp_association *asoc)
>  			 * here by modeling from the current TCP/UDP code.
>  			 * We have not tested with it yet.
>  			 */
> -			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
> +			if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
> +				rcu_read_lock();
>  				sock_wake_async(sock,
> +						rcu_dereference(sk->sk_wq),
>  						SOCK_WAKE_SPACE, POLL_OUT);
> +				rcu_read_unlock();
> +			}
>  		}
>  	}
>  }
> diff --git a/net/socket.c b/net/socket.c
> index dd2c247c99e3..8df62c8bef90 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1058,18 +1058,12 @@ static int sock_fasync(int fd, struct file *filp, int on)
>  
>  /* This function may be called only under socket lock or callback_lock or rcu_lock */
>  
> -int sock_wake_async(struct socket *sock, int how, int band)
> +int sock_wake_async(struct socket *sock, struct socket_wq *wq,
> +		    int how, int band)
>  {
> -	struct socket_wq *wq;
> -
> -	if (!sock)
> -		return -1;
> -	rcu_read_lock();
> -	wq = rcu_dereference(sock->wq);
> -	if (!wq || !wq->fasync_list) {
> -		rcu_read_unlock();
> +	if (!sock || !wq || !wq->fasync_list)
>  		return -1;
> -	}
> +
>  	switch (how) {
>  	case SOCK_WAKE_WAITD:
>  		if (test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
> @@ -1086,7 +1080,7 @@ call_kill:
>  	case SOCK_WAKE_URG:
>  		kill_fasync(&wq->fasync_list, SIGURG, band);
>  	}
> -	rcu_read_unlock();
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(sock_wake_async);
> 
