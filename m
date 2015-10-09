From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 1/3] net: unix: fix use-after-free in unix_dgram_poll()
Date: Fri, 09 Oct 2015 16:38:29 +0200
Message-ID: <87io6gayze.fsf@stressinduktion.org>
References: <cover.1444363559.git.jbaron@akamai.com> <8f8dfc6fdb8015091b58509044b15489df261461.1444363559.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: Jason Baron <jbaron@akamai.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8f8dfc6fdb8015091b58509044b15489df261461.1444363559.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jason Baron <jbaron@akamai.com> writes:

> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
> queue associated with the socket s that we are poll'ing against, but also calls
> sock_poll_wait() for a remote peer socket p, if it is connected. Thus,
> if we call poll()/select()/epoll() for the socket s, there are then
> a couple of code paths in which the remote peer socket p and its associated
> peer_wait queue can be freed before poll()/select()/epoll() have a chance
> to remove themselves from the remote peer socket.
>
> The way that remote peer socket can be freed are:
>
> 1. If s calls connect() to a connect to a new socket other than p, it will
> drop its reference on p, and thus a close() on p will free it.
>
> 2. If we call close on p(), then a subsequent sendmsg() from s, will drop
> the final reference to p, allowing it to be freed.
>
> Address this issue, by reverting unix_dgram_poll() to only register with
> the wait queue associated with s and register a callback with the remote peer
> socket on connect() that will wake up the wait queue associated with s. If
> scenarios 1 or 2 occur above we then simply remove the callback from the
> remote peer. This then presents the expected semantics to poll()/select()/
> epoll().
>
> I've implemented this for sock-type, SOCK_RAW, SOCK_DGRAM, and SOCK_SEQPACKET
> but not for SOCK_STREAM, since SOCK_STREAM does not use unix_dgram_poll().
>
> Introduced in commit ec0d215f9420 ("af_unix: fix 'poll for write'/connected
> DGRAM sockets").
>
> Tested-by: Mathias Krause <minipli@googlemail.com>
> Signed-off-by: Jason Baron <jbaron@akamai.com>

While I think this approach works, I haven't seen where the current code
leaks a reference. Assignment to unix_peer(sk) in general take spin_lock
and increment refcount. Are there bugs at the two places you referred
to?

Is an easier fix just to use atomic_inc_not_zero(&sk->sk_refcnt) in
unix_peer_get() which could also help other places?

Thanks,
Hannes
