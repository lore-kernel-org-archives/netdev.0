From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [RFC] unix: fix use-after-free in unix_dgram_poll()
Date: Thu, 29 Oct 2015 14:23:50 +0000
Message-ID: <87d1vx3g95.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
	<561DCFA4.3010300@akamai.com>
	<87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
	<561F156E.9050905@akamai.com>
	<87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
	<5625073C.5010809@akamai.com>
	<87vba1i383.fsf@doppelsaurus.mobileactivedefense.com>
	<874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<56310C9B.1010608@akamai.com>
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
In-Reply-To: <56310C9B.1010608@akamai.com> (Jason Baron's message of "Wed, 28
	Oct 2015 13:57:47 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 10/28/2015 12:46 PM, Rainer Weikusat wrote:
>> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
>>> Jason Baron <jbaron@akamai.com> writes:

[...]

>> and the not-so-nice additional property that the connect and
>> disconnect functions need to take the peer_wait.lock spinlock
>> explicitly so that this lock is used to ensure that no two threads
>> modifiy the private pointer of the client wait_queue_t.
>
> Hmmm...I thought these were already all guarded by unix_state_lock(sk).
> In any case, rest of the patch overall looks good to me.

All but the one in unix_dgram_peer_wake_relay: That's
called with the wait queue lock of the peer_wait queue held and even if
it was desirable to acquire the state lock of the involved socket, it
wouldn't easily be possible because 'other code' (in poll and sendmsg)
acquires the wait queue lock while holding the state lock.

The idea behind this is that the state lock ensures that the 'connection
state' doesn't change while some code is examining it and that the wait
queue lock of the peer_wait queue is (slightly ab-)used to ensure
exclusive access to the private pointer which guards against concurrent
inserts or removes of the same wait_queue_t.

Poking around in the implementation of abstract interfaces like this
isn't something I'm overly fond of but 'other code' does this too, eg,
in eventfd.c
