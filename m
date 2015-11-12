From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Thu, 12 Nov 2015 19:11:41 +0000
Message-ID: <87bnazt4lu.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
	<56437C69.6090009@akamai.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56437C69.6090009@akamai.com> (Jason Baron's message of "Wed, 11
	Nov 2015 12:35:37 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
>> +
>> +/* Needs sk unix state lock. After recv_ready indicated not ready,
>> + * establish peer_wait connection if still needed.
>> + */
>> +static int unix_dgram_peer_wake_me(struct sock *sk, struct sock *other)
>> +{
>> +	int connected;
>> +
>> +	connected = unix_dgram_peer_wake_connect(sk, other);
>> +
>> +	if (unix_recvq_full(other))
>> +		return 1;
>> +
>> +	if (connected)
>> +		unix_dgram_peer_wake_disconnect(sk, other);
>> +
>> +	return 0;
>> +}
>> +
>
> So the comment above this function says 'needs unix state lock', however
> the usage in unix_dgram_sendmsg() has the 'other' lock, while the usage
> in unix_dgram_poll() has the 'sk' lock. So this looks racy.

That's one thing which is broken with this patch. Judging from a 'quick'
look at the _dgram_sendmsg code, the unix_state_lock(other) will need to
be turned into a unix_state_double_lock(sk, other) and the remaining
code changed accordingly (since all of the checks must be done without
unlocking other). 

There's also something else seriously wrong with the present patch: Some
code in unix_dgram_connect presently (with this change) looks like this:

        /*
         * If it was connected, reconnect.
         */
        if (unix_peer(sk)) {
                struct sock *old_peer = unix_peer(sk);
                unix_peer(sk) = other;

                if (unix_dgram_peer_wake_disconnect(sk, other))
                        wake_up_interruptible_poll(sk_sleep(sk),
                                                   POLLOUT |
                                                   POLLWRNORM |
                                                   POLLWRBAND);

                unix_state_double_unlock(sk, other);

                if (other != old_peer)
                        unix_dgram_disconnected(sk, old_peer);
                sock_put(old_peer);

and trying to disconnect from a peer the socket is just being
connected to is - of course - "flowering tomfoolery" (literal
translation of the German "bluehender Bloedsinn") --- it needs to
disconnect from old_peer instead.

I'll address the suggestion and send an updated patch "later today" (may
become "early tomorrow"). I have some code addressing both issues but
that's part of a release of 'our' kernel fork, ie, 3.2.54-based I'll
need to do 'soon'.
