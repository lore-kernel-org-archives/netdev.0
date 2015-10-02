From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: fix use-after-free with unix_dgram_poll()
Date: Fri, 02 Oct 2015 21:11:32 +0100
Message-ID: <87eghdt4i3.fsf@doppelsaurus.mobileactivedefense.com>
References: <20151002191039.9124420ED@prod-mail-relay10.akamai.com>
	<871tdd3w5s.fsf@doppelsaurus.mobileactivedefense.com>
	<560EDFF0.9080108@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560EDFF0.9080108@akamai.com> (Jason Baron's message of "Fri, 02
	Oct 2015 15:50:08 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 10/02/2015 03:30 PM, Rainer Weikusat wrote:
>> Jason Baron <jbaron@akamai.com> writes:
>>> From: Jason Baron <jbaron@akamai.com>
>>>
>>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>>> queue associated with the socket s that we've called poll() on, but it also
>>> calls sock_poll_wait() for a remote peer socket's wait queue, if it's connected.
>>> Thus, if we call poll()/select()/epoll() for the socket s, there are then
>>> a couple of code paths in which the remote peer socket s2 and its associated
>>> peer_wait queue can be freed before poll()/select()/epoll() have a chance
>>> to remove themselves from this remote peer socket s2's wait queue.
>> 
>> [...]
>> 
>>> This works because we will continue to get POLLOUT wakeups from
>>> unix_write_space(), which is called via sock_wfree().
>> 
>> As pointed out in my original comment, this doesn't work (as far as I
>> can/ could tell) because it will only wake up sockets which had a chance
>> to enqueue datagrams to the queue of the receiving socket as only
>> skbuffs enqueued there will be consumed. A socket which is really
>> waiting for space in the receiving queue won't ever be woken up in this
>> way.
>
> Ok, good point. I was hoping to avoid a more complex approach here. I think
> then that the patch I posted in the previous thread on this would address
> this concern. I will post it for review.

Some comments on that: From what I remember, this introduced another
wait queue solely for "peer events" in the connecting socket and
enqueued it there on connect. I think this should use the peer_wait
queue because that's what its purpose seems to be and it should also
only be put onto this wait queue if it's actually interested, similar to
the way this is handled in unix_dgram_sendmsg (via
unix_wait_for_peer). But this (likely) implies it would be necessary to
get rid of the second registration in unix_dgram_disconnected (which
gets called if a datagram socket disconnects from another) which may not
be feasible.

Insofar this stays an issue, I'll put more work into this but right now,
my "work" (as in "stuff I'm supposed to do for the people who pay me")
priorities are something rather different.
