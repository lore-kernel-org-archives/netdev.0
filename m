From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:)
Date: Tue, 17 Nov 2015 21:37:46 +0000
Message-ID: <87d1v85mtx.fsf@doppelsaurus.mobileactivedefense.com>
References: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151117.151421.249423864481324472.davem@davemloft.net>
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
In-Reply-To: <20151117.151421.249423864481324472.davem@davemloft.net> (David
	Miller's message of "Tue, 17 Nov 2015 15:14:21 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Mon, 16 Nov 2015 22:28:40 +0000
>
>> An AF_UNIX datagram socket being the client in an n:1 association with
>> some server socket is only allowed to send messages to the server if the
>> receive queue of this socket contains at most sk_max_ack_backlog
>> datagrams.

[...]

>> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Fixes: ec0d215f9420 ("af_unix: fix 'poll for write'/connected DGRAM sockets")
>
> So because of a corner case of epoll handling and sender socket release,
> every single datagram sendmsg has to do a double lock now?
>
> I do not dispute the correctness of your fix at this point, but that
> added cost in the fast path is really too high.

This leaves only the option of a somewhat incorrect solution and what is
or isn't acceptable in this respect is somewhat difficult to decide. The
basic options would be

	- return EAGAIN even if sending became possible (Jason's most
          recent suggestions)

	- retry sending a limited number of times, eg, once, before
          returning EAGAIN, on the grounds that this is nicer to the
          application and that redoing all the stuff up to the _lock in
          dgram_sendmsg can possibly/ likely be avoided

Which one do you prefer?
