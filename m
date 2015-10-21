From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Wed, 21 Oct 2015 18:34:12 +0100
Message-ID: <87d1w8f7mz.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <87vba1i383.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Tue, 20 Oct 2015 23:29:00 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Jason Baron <jbaron@akamai.com> writes:
>> On 10/18/2015 04:58 PM, Rainer Weikusat wrote:

[...]

>> 1)
>>
>> In unix_peer_wake_relay() function, 'sk_wq' is an __rcu pointer and thus
>> it requires proper dereferencing. Something like:
>>
>> struct unix_sock *u;
>> struct socket_wq *wq;
>>
>> u = container_of(wait, struct unix_sock, wait);
>> rcu_read_lock();
>> wq = rcu_dereference(u->sk.sk_wq);
>> if (wq_has_sleeper(wq))
>> 	wake_up_interruptible_sync_poll(&wq->wait, key);
>> rcu_read_unlock();
>
> I think this may be unecessary

I consider this unnecessary now.

Rationale: The wait queue is allocated and freed in tandem with the
socket inode which means it will remain allocated until after the
protocol release function (unix_release with the bulk of the
implementation being in unix_release_sock) returned. As the connection
with the other socket is broken in unix_release_sock, any relayed wake
up must have completed before this time (since both operations take
place while holding the same wait queue lock).
