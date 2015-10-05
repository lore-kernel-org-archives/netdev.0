From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 05 Oct 2015 13:55:53 -0400
Message-ID: <5612B9A9.8050301@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com> <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-179.deploy.static.akamaitechnologies.com ([23.79.238.179]:33864
	"EHLO prod-mail-xrelay05.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750738AbbJERzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:55:55 -0400
In-Reply-To: <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2015 12:31 PM, Rainer Weikusat wrote:
> Jason Baron <jbaron@akamai.com> writes:
>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>> queue associated with the socket s that we are poll'ing against, but also calls
>> sock_poll_wait() for a remote peer socket p, if it is connected. Thus,
>> if we call poll()/select()/epoll() for the socket s, there are then
>> a couple of code paths in which the remote peer socket p and its associated
>> peer_wait queue can be freed before poll()/select()/epoll() have a chance
>> to remove themselves from the remote peer socket.
>>
>> The way that remote peer socket can be freed are:
>>
>> 1. If s calls connect() to a connect to a new socket other than p, it will
>> drop its reference on p, and thus a close() on p will free it.
>>
>> 2. If we call close on p(), then a subsequent sendmsg() from s, will drop
>> the final reference to p, allowing it to be freed.
> 
> Here's a more simple idea which _might_ work. The underlying problem
> seems to be that the second sock_poll_wait introduces a covert reference
> to the peer socket which isn't accounted for. The basic idea behind this
> is to execute an additional sock_hold for the peer whenever the
> sock_poll_wait is called for it and store it (the struct sock *) in a
> new struct unix_sock member. Upon entering unix_dgram_poll, if the
> member is not NULL, it's cleared and a sock_put for its former value is
> done. The 'poll peer not NULL -> sock_put it' code is also added to the
> destructor, although I'm unsure if this is really necessary. The patch
> below also includes the additional SOCK_DEAD test suggested by Martin as
> that seems generally sensible to me.
> 
> NB: This has survived both Martin's and my test programs for a number
> of executions/ longer periods of time than was common before without
> generating list corruption warnings. The patch below is against 'my'
> 3.2.54 and is here provided as a suggestion in the hope that it will be
> useful for someting, not as patch submission, as I spent less time
> thinking through this than I should ideally have but despite of this,
> it's another 2.5 hours of my life spent on something completely
> different than what I should be working on at the moment.
> 
> --------------
> diff -pru linux-2-6/include/net/af_unix.h linux-2-6.p/include/net/af_unix.h
> --- linux-2-6/include/net/af_unix.h	2014-01-20 21:52:53.000000000 +0000
> +++ linux-2-6.p/include/net/af_unix.h	2015-10-05 15:11:20.270958297 +0100
> @@ -50,6 +50,7 @@ struct unix_sock {
>  	struct vfsmount		*mnt;
>  	struct mutex		readlock;
>  	struct sock		*peer;
> +	struct sock		*poll_peer;
>  	struct sock		*other;
>  	struct list_head	link;
>  	atomic_long_t		inflight;
> diff -pru linux-2-6/net/unix/af_unix.c linux-2-6.p/net/unix/af_unix.c
> --- linux-2-6/net/unix/af_unix.c	2014-01-22 16:51:52.000000000 +0000
> +++ linux-2-6.p/net/unix/af_unix.c	2015-10-05 17:05:28.358273567 +0100
> @@ -361,6 +361,9 @@ static void unix_sock_destructor(struct
>  	if (u->addr)
>  		unix_release_addr(u->addr);
>  
> +	if (u->poll_peer)
> +		sock_put(u->poll_peer);
> +
>  	atomic_long_dec(&unix_nr_socks);
>  	local_bh_disable();
>  	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> @@ -625,6 +628,7 @@ static struct sock *unix_create1(struct
>  	u	  = unix_sk(sk);
>  	u->dentry = NULL;
>  	u->mnt	  = NULL;
> +	u->poll_peer = NULL;
>  	spin_lock_init(&u->lock);
>  	atomic_long_set(&u->inflight, 0);
>  	INIT_LIST_HEAD(&u->link);
> @@ -2135,8 +2139,16 @@ static unsigned int unix_poll(struct fil
>  static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  				    poll_table *wait)
>  {
> -	struct sock *sk = sock->sk, *other;
> -	unsigned int mask, writable;
> +	struct sock *sk = sock->sk, *other, *pp;
> +	struct unix_sock *u;
> +	unsigned int mask, writable, dead;
> +
> +	u = unix_sk(sk);
> +	pp = u->poll_peer;
> +	if (pp) {
> +		u->poll_peer = NULL;
> +		sock_put(pp);
> +	}
>  
>  	sock_poll_wait(file, sk_sleep(sk), wait);
>  	mask = 0;
> @@ -2170,7 +2182,20 @@ static unsigned int unix_dgram_poll(stru
>  	other = unix_peer_get(sk);
>  	if (other) {
>  		if (unix_peer(other) != sk) {
> -			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
> +			unix_state_lock(other);
> +
> +			dead = sock_flag(other, SOCK_DEAD);
> +			if (!dead)
> +				sock_poll_wait(file, &unix_sk(other)->peer_wait,
> +					       wait);
> +
> +			unix_state_unlock(other);
> +
> +			if (!dead) {
> +				u->poll_peer = other;
> +				sock_hold(other);
> +			}
> +
>  			if (unix_recvq_full(other))
>  				writable = 0;
>  		}
> 


Interesting - will this work for the test case you supplied where we are in
epoll_wait() and another thread does a connect() to a new target? In that
case, even if we issue a wakeup to the epoll thread, its not going to have
a non-NULL poll_table, so it wouldn't be added to the new target. IE
the first test case here:

https://lkml.org/lkml/2015/10/4/154

Only a re-add or modify using epoll_ctl() will re-register with a non-NULL
poll_table.

Thanks,

-Jason
