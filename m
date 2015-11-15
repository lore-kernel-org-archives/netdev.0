From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Sun, 15 Nov 2015 18:32:55 +0000
Message-ID: <87vb93dsfc.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
	<87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<5646617C.9080506@akamai.com>
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
In-Reply-To: <5646617C.9080506@akamai.com> (Jason Baron's message of "Fri, 13
	Nov 2015 17:17:32 -0500")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 11/13/2015 01:51 PM, Rainer Weikusat wrote:
>
> [...]
>
>>  
>> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
>> -		if (!timeo) {
>> -			err = -EAGAIN;
>> -			goto out_unlock;
>> -		}
>> +	if (unix_peer(sk) == other && !unix_dgram_peer_recv_ready(sk, other)) {
>
> Remind me why the 'unix_peer(sk) == other' is added here? If the remote
> is not connected we still want to make sure that we don't overflow the
> the remote rcv queue, right?

Good point. The check is actually wrong there as the original code would
also check the limit in case of an unconnected send to a socket found
via address lookup. It belongs into the 2nd if (were I originally put
it).

>
> In terms of this added 'double' lock for both sk and other, where
> previously we just held the 'other' lock. I think we could continue to
> just hold the 'other' lock unless the remote queue is full, so something
> like:
>
>         if (unix_peer(other) != sk && unix_recvq_full(other)) {
>                 bool need_wakeup = false;
>
> 		....skipping the blocking case...
>
>                 err = -EAGAIN;
>                 if (!other_connected)
>                         goto out_unlock;
>                 unix_state_unlock(other);
>                 unix_state_lock(sk);

That was my original idea. The problem with this is that the code
starting after the _lock and running until the main code path unlock has
to be executed in one go with the other lock held as the results of the
tests above this one may become invalid as soon as the other lock is
released. This means instead of continuing execution with the send code
proper after the block in case other became receive-ready between the
first and the second test (possible because _dgram_recvmsg does not
take the unix state lock), the whole procedure starting with acquiring
the other lock would need to be restarted. Given sufficiently unfavorable
circumstances, this could even turn into an endless loop which couldn't
be interrupted. (unless code for this was added). 

[...]

> we currently wake the entire queue on every remote read even when we
> have room in the rcv buffer. So this patch will cut down on ctxt
> switching rate dramatically from what we currently have.

In my opinion, this could be improved by making the throttling mechanism
work like a flip flop: If the queue lenght hits the limit after a
_sendmsg, set a "no more applicants" flag blocking future sends until
cleared (checking the flag would replace the present
check). After the receive queue ran empty (or almost empty),
_dgram_sendmsg would clear the flag and do a wakeup. But this should be
an independent patch (if implemented).
