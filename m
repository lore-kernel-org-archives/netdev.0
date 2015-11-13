From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Fri, 13 Nov 2015 19:06:11 +0000
Message-ID: <876115sorg.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
	<1447244898.1936942.435925969.525D20D9@webmail.messagingengine.com>
	<87ziyk347o.fsf@doppelsaurus.mobileactivedefense.com>
	<1447267928.3704532.436332953.6FB2A816@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Jason Baron <jbaron@akamai.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
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
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447267928.3704532.436332953.6FB2A816@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Wed, 11 Nov 2015 19:52:08 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On Wed, Nov 11, 2015, at 17:12, Rainer Weikusat wrote:
>> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> > On Tue, Nov 10, 2015, at 22:55, Rainer Weikusat wrote:
>> >> An AF_UNIX datagram socket being the client in an n:1 association with
>> >> some server socket is only allowed to send messages to the server if the
>> >> receive queue of this socket contains at most sk_max_ack_backlog
>> >> datagrams.
>> 
>> [...]
>> 
>> > This whole patch seems pretty complicated to me.
>> >
>> > Can't we just remove the unix_recvq_full checks alltogether and unify
>> > unix_dgram_poll with unix_poll?
>> >
>> > If we want to be cautious we could simply make unix_max_dgram_qlen limit
>> > the number of skbs which are in flight from a sending socket. The skb
>> > destructor can then decrement this. This seems much simpler.
>> >
>> > Would this work?
>> 
>> In the way this is intended to work, cf
>> 
>> http://marc.info/?t=115627606000002&r=1&w=2
>
> Oh, I see, we don't limit closed but still referenced sockets. This
> actually makes sense on how fd handling is implemented, just as a range
> check.
>
> Have you checked if we can somehow deregister the socket in the poll
> event framework? You wrote that it does not provide such a function but
> maybe it would be easy to add?

I thought about this but this would amount to adding a general interface
for the sole purpose of enabling the af_unix code to talk to the
eventpoll code and I don't really like this idea: IMHO, there should be
at least two users (preferably three) before creating any kind of
'abstract interface'. An even more ideal "castle in the air"
(hypothetical) solution would be "change the eventpoll.c code such that
it won't be affected if a wait queue just goes away". That's at least
theoretically possible (although it might not be in practice).

I wouldn't mind doing that (assuming it was possible) if it was just
for the kernels my employer uses because I'm aware of the uses these
will be put to and in control of the corresponding userland code. But
for "general Linux code", changing epoll in order to help the af_unix
code is more potential trouble than it's worth: Exchanging a relatively
unimportant bug in some module for a much more visibly damaging bug in a
central facility would be a bad tradeoff.
