From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Wed, 11 Nov 2015 12:35:37 -0500
Message-ID: <56437C69.6090009@akamai.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
 <20151012120249.GB16370@unicorn.suse.cz>
 <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
 <CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
 <563CC002.5050307@akamai.com>
 <87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
 <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
 <877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:39736 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752479AbbKKRfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 12:35:38 -0500
In-Reply-To: <877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rainer,

> +
> +/* Needs sk unix state lock. After recv_ready indicated not ready,
> + * establish peer_wait connection if still needed.
> + */
> +static int unix_dgram_peer_wake_me(struct sock *sk, struct sock *other)
> +{
> +	int connected;
> +
> +	connected = unix_dgram_peer_wake_connect(sk, other);
> +
> +	if (unix_recvq_full(other))
> +		return 1;
> +
> +	if (connected)
> +		unix_dgram_peer_wake_disconnect(sk, other);
> +
> +	return 0;
> +}
> +

So the comment above this function says 'needs unix state lock', however
the usage in unix_dgram_sendmsg() has the 'other' lock, while the usage
in unix_dgram_poll() has the 'sk' lock. So this looks racy.

Also, another tweak on this scheme: Instead of calling
'__remove_wait_queue()' in unix_dgram_peer_wake_relay(). We could
instead simply mark each item in the queue as 'WQ_FLAG_EXCLUSIVE'. Then,
since 'unix_dgram_recvmsg()' does an exclusive wakeup the queue has
effectively been disabled (minus the first exlusive item in the list
which can just return if its marked exclusive). This means that in
dgram_poll(), we add to the list if we have not yet been added, and if
we are on the list, we do a remove and then add removing the exclusive
flag. Thus, all the waiters that need a wakeup are at the beginning of
the queue, and the disabled ones are at the end with the
'WQ_FLAG_EXCLUSIVE' flag set.

This does make the list potentially long, but if we only walk it to the
point we are doing the wakeup, it has no impact. I like the fact that in
this scheme the wakeup doesn't have to call remove against a long of
waiters - its just setting the exclusive flag.

Thanks,

-Jason





>  static inline int unix_writable(struct sock *sk)
>  {
>  	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
> @@ -430,6 +546,8 @@ static void unix_release_sock(struct sock *sk, int embrion)
>  			skpair->sk_state_change(skpair);
>  			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
>  		}
> +
> +		unix_dgram_peer_wake_disconnect(sk, skpair);
>  		sock_put(skpair); /* It may now die */
>  		unix_peer(sk) = NULL;
>  	}
> @@ -664,6 +782,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
>  	INIT_LIST_HEAD(&u->link);
>  	mutex_init(&u->readlock); /* single task reading lock */
>  	init_waitqueue_head(&u->peer_wait);
> +	init_waitqueue_func_entry(&u->peer_wake, unix_dgram_peer_wake_relay);
>  	unix_insert_socket(unix_sockets_unbound(sk), sk);
>  out:
>  	if (sk == NULL)
> @@ -1031,6 +1150,13 @@ restart:
>  	if (unix_peer(sk)) {
>  		struct sock *old_peer = unix_peer(sk);
>  		unix_peer(sk) = other;
> +
> +		if (unix_dgram_peer_wake_disconnect(sk, other))
> +			wake_up_interruptible_poll(sk_sleep(sk),
> +						   POLLOUT |
> +						   POLLWRNORM |
> +						   POLLWRBAND);
> +
>  		unix_state_double_unlock(sk, other);
>  
>  		if (other != old_peer)
> @@ -1565,6 +1691,13 @@ restart:
>  		unix_state_lock(sk);
>  		if (unix_peer(sk) == other) {
>  			unix_peer(sk) = NULL;
> +
> +			if (unix_dgram_peer_wake_disconnect(sk, other))
> +				wake_up_interruptible_poll(sk_sleep(sk),
> +							   POLLOUT |
> +							   POLLWRNORM |
> +							   POLLWRBAND);
> +
>  			unix_state_unlock(sk);
>  
>  			unix_dgram_disconnected(sk, other);
> @@ -1590,19 +1723,21 @@ restart:
>  			goto out_unlock;
>  	}
>  
> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
> -		if (!timeo) {
> -			err = -EAGAIN;
> -			goto out_unlock;
> -		}
> +	if (!unix_dgram_peer_recv_ready(sk, other)) {
> +		if (timeo) {
> +			timeo = unix_wait_for_peer(other, timeo);
>  
> -		timeo = unix_wait_for_peer(other, timeo);
> +			err = sock_intr_errno(timeo);
> +			if (signal_pending(current))
> +				goto out_free;
>  
> -		err = sock_intr_errno(timeo);
> -		if (signal_pending(current))
> -			goto out_free;
> +			goto restart;
> +		}
>  
> -		goto restart;
> +		if (unix_dgram_peer_wake_me(sk, other)) {
> +			err = -EAGAIN;
> +			goto out_unlock;
> +		}
>  	}
>  
>  	if (sock_flag(other, SOCK_RCVTSTAMP))
> @@ -2453,14 +2588,16 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  		return mask;
>  
>  	writable = unix_writable(sk);
> -	other = unix_peer_get(sk);
> -	if (other) {
> -		if (unix_peer(other) != sk) {
> -			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
> -			if (unix_recvq_full(other))
> -				writable = 0;
> -		}
> -		sock_put(other);
> +	if (writable) {
> +		unix_state_lock(sk);
> +
> +		other = unix_peer(sk);
> +		if (other &&
> +		    !unix_dgram_peer_recv_ready(sk, other) &&
> +		    unix_dgram_peer_wake_me(sk, other))
> +			writable = 0;
> +
> +		unix_state_unlock(sk);
>  	}
>  
>  	if (writable)
> 
