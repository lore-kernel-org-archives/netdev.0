From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC Hanging clean-up of a namespace
Date: Fri, 20 Jan 2012 02:08:37 -0800
Message-ID: <m1y5t2u1ne.fsf@fess.ebiederm.org>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
	<m1lip32xoi.fsf@fess.ebiederm.org> <20120119214052.GA12249@hell>
	<201201200708.51684.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox\@diac24.net" <equinox@diac24.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42594 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab2ATKGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 05:06:13 -0500
In-Reply-To: <201201200708.51684.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Fri, 20 Jan 2012 07:08:50 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> On Thursday 19 January 2012 22:40:53 Hagen Paul Pfeifer wrote:
>> * Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:
>> 
>> >This thread is a fascinating disconnect from reality all of the way
>> >around.
>> >
>> >- inet_twsk_purge already implements throwing out of timewait sockets
>> >  when a network namespaces is being cleaned up.  So the RFC is nonsense.
>> 
>> This is how it is implemented, not how it should be. TIME_WAIT is not the
>> problem, it is there to keep the stack from sending wrong RST messages. Maybe
>> the 2*MSL could be fixed by a more accurate 2*RTT.
>> 
>
> I was only refering to my printk's i.e. the last sockets leaving the namespace was
> from tcp_timer() with state 7, 2 minutes after free_nsproxy() was called.
> (and assumed that was the time_wait)

Which kernel are you running?  I can't find a mention of a function
named tcp_timer() anywhere in the kernel since 2.6.16 when the kernel
was put into git.

There is a file named net/ipv4/tcp_timer.c

But if you are actually describing normal sockets and not timewait
sockets then it is remotely possible that something like what you are
talking about is happening.  Normal sockets keep the network namespace
alive.  So if something was keeping the sockets open.  Like perhaps a
process that has one of your sockets from your network namespace open
then it could happen.

nsproxy is not the only place that references to the network namespace
are allowed to live that keep the network namespace alive.

>> >- Keeping the timewait sockets at that point we purge them in the code
>> >  can achieve nothing.  We don't have any userspace processes or network
>> >  devices associated with the timewait sockets at the point we get rid
>> >  of them.  The network namespace exists so long as a userspace process
>> >  can find it.  The network namespace exit is asynchronous in it's own
>> >  workqueue so userspace definitely is not blocked.
>> 
>
> One example of a real life problem is when a container crash where a VLAN from
> a physical interface is used in the container, and you automatically reboot
> that container.  A new namespace is created with that VLAN again and what happens ?
> That VLAN id is busy (waiting for tcp_timer) and the continer start fails ...
> So you have to wait a couple of minutes :-(

Yes the vlan is busy until that the network namespace is cleaned up, and
we get as far as calling dellink on the network namespace.

There are a lot of reasons why a network namespace would not be cleaned
up immediately.  Especially in older kernels.

One problem people running older kernels had troubles with was vsftp
created an empty network namespace for every connection.  On kernels pre
2.6.34 I think before we had batching support for cleaning up network
devices and network namespaces the kernel could simply not keep up with
the rate that vsftp was creating and destroying network namespaces, and
would slowly fall farther and farther behind in it's cleanup.

If you are running an older kernel it is quite possible that you are
missing some cleanups.  It is also possible that you are hitting one of
the cases where we can only destroy 4 network devices a second and you
have lots of network devices dying with your network namespace.

Eric
