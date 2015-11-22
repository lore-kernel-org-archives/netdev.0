From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: alternate queueing mechanism (was: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue)
Date: Sun, 22 Nov 2015 21:43:58 +0000
Message-ID: <87k2p9u2u9.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<564121D0.2000305@akamai.com>
	<874mgtn49l.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
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
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:39557 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbbKVVod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 16:44:33 -0500
In-Reply-To: <874mgtn49l.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Tue, 10 Nov 2015 17:38:46 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:

[AF_UNIX SOCK_DGRAM throughput]

> It may be possible to improve this by tuning/ changing the flow
> control mechanism. Out of my head, I'd suggest making the queue longer
> (the default value is 10) and delaying wake ups until the server
> actually did catch up, IOW, the receive queue is empty or almost
> empty. But this ought to be done with a different patch.

Because I was curious about the effects, I implemented this using a
slightly modified design than the one I originally suggested to account
for the different uses of the 'is the receive queue full' check. The
code uses a datagram-specific checking function,

static int unix_dgram_recvq_full(struct sock const *sk)
{
	struct unix_sock *u;

	u = unix_sk(sk);
	if (test_bit(UNIX_DG_FULL, &u->flags))
		return 1;

	if (!unix_recvq_full(sk))
		return 0;

	__set_bit(UNIX_DG_FULL, &u->flags);
	return 1;
}

which gets called instead of the other for the n:1 datagram checks and a

if (test_bit(UNIX_DG_FULL, &u->flags) &&
    !skb_queue_len(&sk->sk_receive_queue)) {
	__clear_bit(UNIX_DG_FULL, &u->flags);
	wake_up_interruptible_sync_poll(&u->peer_wait,
					POLLOUT | POLLWRNORM |
					POLLWRBAND);
}

in unix_dgram_recvmsg to delay wakeups until the queued datagrams have
been consumed if the queue overflowed before. This has the additional,
nice side effect that wakeups won't ever be done for 1:1 connected
datagram sockets (both SOCK_DGRAM and SOCK_SEQPACKET) where they're of
no use, anyway.

Compared to a 'stock' 4.3 running the test program I posted (supposed to
make the overhead noticable by sending lots of small messages), the
average number of bytes sent per second increased by about 782,961.79
(ca 764.61K), about 5.32% of the 4.3 number (14,714,579.91), with a
fairly simple code change.
