From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 3/3] af_unix: optimize the unix_dgram_recvmsg()
Date: Mon, 05 Oct 2015 13:13:43 -0400
Message-ID: <5612AFC7.5090900@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com> <ba2b4c5c1d6fd3d99cd4b1286edace56c0f84a0d.1443817522.git.jbaron@akamai.com> <20151005074151.GD2903@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	rweikusat@mobileactivedefense.com, viro@zeniv.linux.org.uk,
	davidel@xmailserver.org, dave@stgolabs.net, olivier@mauras.ch,
	pageexec@freemail.hu, torvalds@linux-foundation.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151005074151.GD2903@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/2015 03:41 AM, Peter Zijlstra wrote:
> On Fri, Oct 02, 2015 at 08:44:02PM +0000, Jason Baron wrote:
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index f789423..b8ed1bc 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
> 
>> @@ -1079,6 +1079,9 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
>>  
>>  	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
>>  
>> +	set_bit(UNIX_NOSPACE, &u->flags);
>> +	/* pairs with mb in unix_dgram_recv */
>> +	smp_mb__after_atomic();
>>  	sched = !sock_flag(other, SOCK_DEAD) &&
>>  		!(other->sk_shutdown & RCV_SHUTDOWN) &&
>>  		unix_recvq_full(other);
>> @@ -1623,17 +1626,22 @@ restart:
>>  
>>  	if (unix_peer(other) != sk && unix_recvq_full(other)) {
>>  		if (!timeo) {
>> +			set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
>> +			/* pairs with mb in unix_dgram_recv */
>> +			smp_mb__after_atomic();
>> +			if (unix_recvq_full(other)) {
>> +				err = -EAGAIN;
>> +				goto out_unlock;
>> +			}
>> +		} else {
> 
>> @@ -1939,8 +1947,14 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
>>  		goto out_unlock;
>>  	}
>>  
>> +	/* pairs with unix_dgram_poll() and wait_for_peer() */
>> +	smp_mb();
>> +	if (test_bit(UNIX_NOSPACE, &u->flags)) {
>> +		clear_bit(UNIX_NOSPACE, &u->flags);
>> +		wake_up_interruptible_sync_poll(&u->peer_wait,
>> +						POLLOUT | POLLWRNORM |
>> +						POLLWRBAND);
>> +	}
>>  
>>  	if (msg->msg_name)
>>  		unix_copy_addr(msg, skb->sk);
>> @@ -2468,20 +2493,19 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>>  	if (!(poll_requested_events(wait) & (POLLWRBAND|POLLWRNORM|POLLOUT)))
>>  		return mask;
>>  
>>  	other = unix_peer_get(sk);
>> +	if (unix_dgram_writable(sk, other)) {
>>  		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
>> +	} else {
>>  		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
>> +		set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
>> +		/* pairs with mb in unix_dgram_recv */
>> +		smp_mb__after_atomic();
>> +		if (unix_dgram_writable(sk, other))
>> +			mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
>> +	}
>> +	if (other)
>> +		sock_put(other);
>>  
>>  	return mask;
>>  }
> 
> 
> So I must object to these barrier comments; stating which other barrier
> they pair with is indeed good and required, but its not sufficient.
> 
> A barrier comment should also explain the data ordering -- the most
> important part.
> 
> As it stands its not clear to me these barriers are required at all, but
> this is not code I understand so I might well miss something obvious.
> 

So in patch 1/3 I've added sockets that call connect() onto the 'peer_wait'
queue of the server. The reason being that when the server reads from its
socket (unix_dgram_recvmsg()) it can wake up n clients that may be waiting
for the receive queue of the server to empty. This was previously
accomplished in unix_dgram_poll() via the:

sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);

which I've removed. The issue with that approach is that the 'other' socket
or server socket can close() and go away out from under the poll() call.
Thus, I've converted back unix_dgram_poll(), to simply wait on its
own socket's wait queue, which is the semantics that poll()/select()/
epoll() expect. However, I still needed a way to signal the client socket,
and thus I've added the callback on connect() in patch 1/3.

However, now that the client sockets are added during connect(), and
not poll() as was previously done, this means that any calls to
unix_dgram_recvmsg() have to walk the entire wakeup list, even if nobody
is sitting in poll().

Thus, I've introduced the UNIX_SOCK flag to signal that we are in poll()
to the server side, such that it doesn't have to potentially walk a long
list of wakeups for no reason. This makes a difference on this test
case:

http://www.spinics.net/lists/netdev/msg145533.html

which I found while working on this issue. And this patch restores the
performance for that test case.

So what we need to guarantee is that we either see that the socket
as writable in unix_dgram_poll(), *or* that we perform the proper
wakeup in unix_dgram_recvmsg().

So unix_dgram_poll() does:

...

set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
smp_mb__after_atomic();
if (unix_dgram_writable(sk, other))
	mask |= POLLOUT | POLLWRNORM | POLLWRBAND;


and the wakeup side in unix_dgram_recvmsg():

skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
if (!skb) {
 ....
}
smp_mb();
if (test_bit(UNIX_NOSPACE, &u->flags)) {
       clear_bit(UNIX_NOSPACE, &u->flags);
       wake_up_interruptible_sync_poll(&u->peer_wait,
                                       POLLOUT | POLLWRNORM |
                                       POLLWRBAND);
}

the '__skb_recv_datagram()' there potentially sets the wakeup
condition that we are interested in.

The barrier in unix_wait_for_peer() is for the same thing - either we
see the condition there and don't go to sleep or we get a proper wakeup.

Finally, I needed a barrier in unix_dgram_sendmsg() in the -EAGAIN
case b/c epoll edge trigger needs to guarantee a wakeup happens there
as well (it can't rely on UNIX_NOSPACE being set from
unix_dgram_recvmsg()). 

Thanks,

-Jason
