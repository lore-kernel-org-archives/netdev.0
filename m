From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Tue, 10 Nov 2015 17:38:46 +0000
Message-ID: <874mgtn49l.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<564121D0.2000305@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
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
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <564121D0.2000305@akamai.com> (Jason Baron's message of "Mon, 9
	Nov 2015 17:44:32 -0500")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 11/09/2015 09:40 AM, Rainer Weikusat wrote:

[...]

>> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
>> +	if (!unix_dgram_peer_recv_ready(sk, other)) {
>>  		if (!timeo) {
>> -			err = -EAGAIN;
>> -			goto out_unlock;
>> +			if (unix_dgram_peer_wake_me(sk, other)) {
>> +				err = -EAGAIN;
>> +				goto out_unlock;
>> +			}
>> +
>> +			goto restart;
>>  		}
>
>
> So this will cause 'unix_state_lock(other) to be called twice in a
> row if we 'goto restart' (and hence will softlock the box). It just
> needs a 'unix_state_unlock(other);' before the 'goto restart'.

The goto restart was nonsense to begin with in this code path:
Restarting something is necessary after sleeping for some time but for
the case above, execution just continues. I've changed that (updated
patch should follow 'soon') to

	if (!unix_dgram_peer_recv_ready(sk, other)) {
		if (timeo) {
			timeo = unix_wait_for_peer(other, timeo);

			err = sock_intr_errno(timeo);
			if (signal_pending(current))
				goto out_free;

			goto restart;
		}
		
		if (unix_dgram_peer_wake_me(sk, other)) {
			err = -EAGAIN;
			goto out_unlock;
		}
	}

> I also tested this patch with a single unix server and 200 client
> threads doing roughly epoll() followed by write() until -EAGAIN in a
> loop. The throughput for the test was roughly the same as current
> upstream, but the cpu usage was a lot higher. I think its b/c this patch
> takes the server wait queue lock in the _poll() routine. This causes a
> lot of contention. The previous patch you posted for this where you did
> not clear the wait queue on every wakeup and thus didn't need the queue
> lock in poll() (unless we were adding to it), performed much better.

I'm somewhat unsure what to make of that: The previous patch would also
take the wait queue lock whenever poll was about to return 'not
writable' because of the length of the server receive queue unless
another thread using the same client socket also noticed this and
enqueued this same socket already. And "hundreds of clients using a
single client socket in order to send data to a single server socket"
doesn't seem very realistic to me.

Also, this code shouldn't usually be executed as the server should
usually be capable of keeping up with the data sent by clients. If it's
permanently incapable of that, you're effectively performing a
(successful) DDOS against it. Which should result in "high CPU
utilization" in either case. It may be possible to improve this by
tuning/ changing the flow control mechanism. Out of my head, I'd suggest
making the queue longer (the default value is 10) and delaying wake ups
until the server actually did catch up, IOW, the receive queue is empty
or almost empty. But this ought to be done with a different patch.
