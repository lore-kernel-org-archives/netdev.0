From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Tue, 20 Oct 2015 23:29:00 +0100
Message-ID: <87vba1i383.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <5625073C.5010809@akamai.com> (Jason Baron's message of "Mon, 19
	Oct 2015 11:07:40 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 10/18/2015 04:58 PM, Rainer Weikusat wrote:
>
> [...]
>
>> 
>> The idea behind 'the wait queue' (insofar I'm aware of it) is that it
>> will be used as list of threads who need to be notified when the
>> associated event occurs. Since you seem to argue that the run-of-the-mill
>> algorithm is too slow for this particular case, is there anything to
>> back this up?
>>
>
> Generally the poll() routines only add to a wait queue once at the
> beginning, and all subsequent calls to poll() simply check the wakeup
> conditions. So here you are proposing to add/remove to the wait queue on
> subsequent invocations of poll(). So the initial patch I did, continued
> in the usual pattern and only added once on registration or connect().

The code uses the private member of a wait_queue_t to record if it the
add_wait_queue was already executed so the add/remove will only happen
if the wakeup condition changed in the meantime (which usually ought to
be the case, though). As far as I understand this, this really only
makes a difference for epoll as only epoll will keep everything on the
wait queues managed by it between 'polling calls'. In order to support
epoll-style wait queue management outside of epoll, the poll management
code would need to execute a cleanup callback instead of just the setup
callback it already executes.

> 1)
>
> In unix_peer_wake_relay() function, 'sk_wq' is an __rcu pointer and thus
> it requires proper dereferencing. Something like:
>
> struct unix_sock *u;
> struct socket_wq *wq;
>
> u = container_of(wait, struct unix_sock, wait);
> rcu_read_lock();
> wq = rcu_dereference(u->sk.sk_wq);
> if (wq_has_sleeper(wq))
> 	wake_up_interruptible_sync_poll(&wq->wait, key);
> rcu_read_unlock();

I think this may be unecessary but I need more time to check this than
the odd "half an hour after work after 11pm [UK time]" I could put into
this today.

> 2)
>
> For the case of epoll() in edge triggered mode we need to ensure that
> when we return -EAGAIN from unix_dgram_sendmsg() when unix_recvq_full()
> is true, we need to add a unix_peer_wake_connect() call to guarantee a
> wakeup. Otherwise, we are going to potentially hang there.

I consider this necessary.
