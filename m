From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 23 Nov 2015 21:37:17 +0000
Message-ID: <87si3w9z3m.fsf@doppelsaurus.mobileactivedefense.com>
References: <87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
	<87vb8w2ulg.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151123.123033.522701221384821229.davem@davemloft.net>
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
In-Reply-To: <20151123.123033.522701221384821229.davem@davemloft.net> (David
	Miller's message of "Mon, 23 Nov 2015 12:30:33 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:
>> An AF_UNIX datagram socket being the client in an n:1 association

[...]

> Applied and queued up for -stable,

I'm sorry for this 13th hour request/ suggestion but while thinking
about a reply to Dmitry, it occurred to me that the restart_locked/
sk_locked logic could be avoided by moving the test for this condition
in front of all the others while leaving the 'act on it' code at its
back, ie, reorganize unix_dgram_sendmsg such that it looks like this:

	unix_state_lock(other);
	
	if (unix_peer(other) != sk && unix_recvq_full(other)) {
		need_wait = 1;
		
		if (!timeo) {
			unix_state_unlock(other);
			unix_state_double_lock(sk, other);

			if (unix_peer(other) == sk ||
			    (unix_peer(sk) == other &&
			     !unix_dgram_peer_wake_me(sk, other)))
				need_wait = 0;

			unix_state_unlock(sk);
		}
	}

        /* original code here */
        
	if (need_wait) {
		if (timeo) {
			timeo = unix_wait_for_peer(other, timeo);

			err = sock_intr_errno(timeo);
			if (signal_pending(current))
				goto out_free;
			
			goto restart;
		}
		
		err = -EAGAIN;
		goto out_unlock;
	}

        /* original tail here */

This might cause a socket to be enqueued to the peer despite it's not
allowed to send to it but I don't think this matters much. This is a
less conservative modification but one which results in simpler code
overall. The kernel I'm currently running has been modified like this
and 'survived' the usual tests.
