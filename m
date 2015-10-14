From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Tue, 13 Oct 2015 23:44:36 -0400
Message-ID: <561DCFA4.3010300@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>	<5612B9A9.8050301@akamai.com> <87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
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
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:43428 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbbJNDoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 23:44:39 -0400
In-Reply-To: <87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2015 04:41 PM, Rainer Weikusat wrote:
> Jason Baron <jbaron@akamai.com> writes:
>> On 10/05/2015 12:31 PM, Rainer Weikusat wrote:
> 
> [...]
> 
>>> Here's a more simple idea which _might_ work. The underlying problem
>>> seems to be that the second sock_poll_wait introduces a covert reference
>>> to the peer socket which isn't accounted for. The basic idea behind this
>>> is to execute an additional sock_hold for the peer whenever the
>>> sock_poll_wait is called for it and store it (the struct sock *) in a
>>> new struct unix_sock member.
> 
> [...]
> 
>> Interesting - will this work for the test case you supplied where we are in
>> epoll_wait() and another thread does a connect() to a new target? In that
>> case, even if we issue a wakeup to the epoll thread, its not going to have
>> a non-NULL poll_table, so it wouldn't be added to the new target. IE
>> the first test case here:
>>
>> https://lkml.org/lkml/2015/10/4/154
> 
> "Indeed it would not." I've also meanwhile found the time to check what
> is and isn't locked here and found that Eric's "this looks racy" was
> also justified. In theory, a clean solution could be based on modifying
> the various polling implementations to keep a piece of data for a polled
> something and provided that again on each subsequent poll call. This
> could then be used to keep the peer socket alive for as long as
> necessary were it possible to change the set of wait queues with every
> poll call. Since this also isn't the case, the idea to increment the
> reference count of the peer socket won't fly.
> 
> OTOH, something I seriously dislike about your relaying implementation
> is the unconditional add_wait_queue upon connect as this builds up a
> possibly large wait queue of entities entirely uninterested in the
> event which will need to be traversed even if peer_wait wakeups will
> only happen if at least someone actually wants to be notified. This
> could be changed such that the struct unix_sock member is only put onto
> the peer's wait queue in poll and only if it hasn't already been put
> onto it. The connection could then be severed if some kind of
> 'disconnect' occurs.
> 
> The code below (again based on 3.2.54) is what I'm currently running and
> it has survived testing during the day (without trying the exercise in
> hexadecimal as that doesn't cause failure for me, anyway). The wakeup
> relaying function checks that a socket wait queue actually still exists
> because I used to get null pointers oopses without every now and then
> (I've also tested this with an additional printk printing 'no q' in case
> the pointer was actually null to verify that this really occurs here).
> 

Hi,

What about the following race?

1) thread A does poll() on f, finds the wakeup condition low, and adds
itself to the remote peer_wait queue.

2) thread B sets the wake up condition in dgram_recvmsg(), but does not
execute the wakeup of threads yet.

3) thread C also does a poll() on f, finds now that the wakeup condition
is set, and hence removes f from the remote peer_wait queue.

Then, thread A misses the POLLOUT, and hangs.

I understand your concern about POLLIN only waiters-I think we
could add the 'relay callback' in dgram_poll() only for those who are
looking for POLLOUT, and simply avoid the de-registration, as in practice
I think its unlikely we are going to have a socket switching from
POLLOUT to *only* POLLIN. I suspect that will cover most of the cases
that concern you?

Thanks,

-Jason
