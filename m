From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Fri, 13 Nov 2015 17:17:32 -0500
Message-ID: <5646617C.9080506@akamai.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/13/2015 01:51 PM, Rainer Weikusat wrote:

[...]

>  
> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
> -		if (!timeo) {
> -			err = -EAGAIN;
> -			goto out_unlock;
> -		}
> +	if (unix_peer(sk) == other && !unix_dgram_peer_recv_ready(sk, other)) {

Remind me why the 'unix_peer(sk) == other' is added here? If the remote
is not connected we still want to make sure that we don't overflow the
the remote rcv queue, right?

In terms of this added 'double' lock for both sk and other, where
previously we just held the 'other' lock. I think we could continue to
just hold the 'other' lock unless the remote queue is full, so something
like:

        if (unix_peer(other) != sk && unix_recvq_full(other)) {
                bool need_wakeup = false;

		....skipping the blocking case...

                err = -EAGAIN;
                if (!other_connected)
                        goto out_unlock;
                unix_state_unlock(other);
                unix_state_lock(sk);

		/* if remote peer has changed under us, the connect()
                   will wake up any pending waiter, just return -EAGAIN

                if (unix_peer(sk) == other) {
			/* In case we see there is space available
			   queue the wakeup and we will try again. This
			   this should be an unlikely condition */
	 		if (!unix_dgram_peer_wake_me(sk, other))
                                need_wakeup = true;
                }
                unix_state_unlock(sk);
                if (need_wakeup)
                        wake_up_interruptible_poll(sk_sleep(sk),POLLOUT
| POLLWRNORM | POLLWRBAND);
                goto out_free;
        }

So I'm not sure if the 'double' lock really affects any workload, but
the above might be away to avoid it.

Also - it might be helpful to add a 'Fixes:' tag referencing where this
issue started, in the changelog.

Worth mentioning too is that this patch should improve the polling case
here dramatically, as we currently wake the entire queue on every remote
read even when we have room in the rcv buffer. So this patch will cut
down on ctxt switching rate dramatically from what we currently have.

Thanks,

-Jason
