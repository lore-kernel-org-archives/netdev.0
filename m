From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v4 1/3] net: unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 12 Oct 2015 15:41:55 -0400
Message-ID: <561C0D03.60607@akamai.com>
References: <cover.1444363559.git.jbaron@akamai.com> <8f8dfc6fdb8015091b58509044b15489df261461.1444363559.git.jbaron@akamai.com> <87io6gayze.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87io6gayze.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/09/2015 10:38 AM, Hannes Frederic Sowa wrote:
> Hi,
> 
> Jason Baron <jbaron@akamai.com> writes:
> 
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
>>
>> Address this issue, by reverting unix_dgram_poll() to only register with
>> the wait queue associated with s and register a callback with the remote peer
>> socket on connect() that will wake up the wait queue associated with s. If
>> scenarios 1 or 2 occur above we then simply remove the callback from the
>> remote peer. This then presents the expected semantics to poll()/select()/
>> epoll().
>>
>> I've implemented this for sock-type, SOCK_RAW, SOCK_DGRAM, and SOCK_SEQPACKET
>> but not for SOCK_STREAM, since SOCK_STREAM does not use unix_dgram_poll().
>>
>> Introduced in commit ec0d215f9420 ("af_unix: fix 'poll for write'/connected
>> DGRAM sockets").
>>
>> Tested-by: Mathias Krause <minipli@googlemail.com>
>> Signed-off-by: Jason Baron <jbaron@akamai.com>
> 
> While I think this approach works, I haven't seen where the current code
> leaks a reference. Assignment to unix_peer(sk) in general take spin_lock
> and increment refcount. Are there bugs at the two places you referred
> to?
> 
> Is an easier fix just to use atomic_inc_not_zero(&sk->sk_refcnt) in
> unix_peer_get() which could also help other places?
> 

Hi,

So we could potentially inc the refcnt on the remote peer such that the
remote peer does not free before the socket that has connected to it.
However, then the socket that has taken the reference against the peer
socket has to potentially record a number of remote sockets (all the ones
that it has connected to over its lifetime), and then drop all of their
refcnt's when it finally closes.

The reason for this is that with the current code when we do
poll()/select()/epoll() on a socket with a peer socket, those calls
take reference on the peer socket. Specifically, they record the remote
peer whead, such that they can remove their callbacks when they return.
So its not safe to just drop a reference on the remote peer when it
closes because their might be outstanding poll()/select()/epoll()
references pending.

Normally, poll()/select()/epoll() are waiting on a whead associated
directly with the fd/file that they are waiting for.

The other point here is that the way this patch structures things is
that when the socket connects to a new remote and hence disconnects from
an existing remote, POLLOUT events will continue to be correctly
delivered. That was not possible with the current structure of things
b/c there was no way to inform poll to re-register with the remote peer
whead. So, that means that the first test case here now works:

https://lkml.org/lkml/2015/10/4/154

Whereas with the old code test case would just hang for ever.

So yes there is a bit of code churn here, but I think it moves the
code-base in a direction that not only solves this issue, but corrects
additional poll() behaviors as well.

Thanks,

-Jason
