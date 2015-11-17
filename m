From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:)
Date: Tue, 17 Nov 2015 22:09:40 +0000
Message-ID: <878u5w5lcr.fsf@doppelsaurus.mobileactivedefense.com>
References: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151117.151421.249423864481324472.davem@davemloft.net>
	<87d1v85mtx.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, jbaron@akamai.com,
	dvyukov@google.com, syzkaller@googlegroups.com, mkubecek@suse.cz,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	kcc@google.com, glider@google.com, andreyknvl@google.com,
	sasha.levin@oracle.com, jln@google.com, keescook@google.com,
	minipli@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1v85mtx.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Tue, 17 Nov 2015 21:37:46 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> The basic options would be
>
> 	- return EAGAIN even if sending became possible (Jason's most
>           recent suggestions)
>
> 	- retry sending a limited number of times, eg, once, before
>           returning EAGAIN, on the grounds that this is nicer to the
>           application and that redoing all the stuff up to the _lock in
>           dgram_sendmsg can possibly/ likely be avoided

A third option: Use trylock to acquire the sk lock. If this succeeds,
there's no risk of deadlocking anyone even if acquiring the locks in the
wrong order. This could look as follows (NB: I didn't even compile this,
I just wrote the code to get an idea how complicated it would be):

		int need_wakeup;

[...]

		need_wakeup = 0;
		err = 0;
		if (spin_lock_trylock(unix_sk(sk)->lock)) {
			if (unix_peer(sk) != other ||
				unix_dgram_peer_wake_me(sk, other))
				err = -EAGAIN;
		} else {
			err = -EAGAIN;
			
			unix_state_unlock(other);
			unix_state_lock(sk);
			
			need_wakeup = unix_peer(sk) != other &&
				      unix_dgram_peer_wake_connect(sk, other) &&
				      sk_receive_queue_len(other) == 0;
		}
		
		unix_state_unlock(sk);
		
		if (err) {
			if (need_wakeup)
				wake_up_interruptible_poll(sk_sleep(sk),
							   POLLOUT |
							   POLLWRNORM |
							   POLLWRBAND);

			goto out_free;
		}
