From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Wed, 11 Nov 2015 16:12:27 +0000
Message-ID: <87ziyk347o.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <1447244898.1936942.435925969.525D20D9@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Wed, 11 Nov 2015 13:28:18 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On Tue, Nov 10, 2015, at 22:55, Rainer Weikusat wrote:
>> An AF_UNIX datagram socket being the client in an n:1 association with
>> some server socket is only allowed to send messages to the server if the
>> receive queue of this socket contains at most sk_max_ack_backlog
>> datagrams.

[...]

> This whole patch seems pretty complicated to me.
>
> Can't we just remove the unix_recvq_full checks alltogether and unify
> unix_dgram_poll with unix_poll?
>
> If we want to be cautious we could simply make unix_max_dgram_qlen limit
> the number of skbs which are in flight from a sending socket. The skb
> destructor can then decrement this. This seems much simpler.
>
> Would this work?

In the way this is intended to work, cf

http://marc.info/?t=115627606000002&r=1&w=2

only if the limit would also apply to sockets which didn't sent anything
so far. Which means it'll end up in the exact same situation as before:
Sending something using a certain socket may not be possible because of
data sent by other sockets, so either, code trying to send using this
sockets ends up busy-waiting for "space again available" despite it's
trying to use select/ poll/ epolll/ $whatnot to get notified of this
condition and sleep until then or this notification needs to be
propagated to sleeping threads which didn't get to send anything yet.
