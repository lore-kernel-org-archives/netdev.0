From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 19 Oct 2015 11:07:40 -0400
Message-ID: <5625073C.5010809@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>
 <f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
 <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
 <5612B9A9.8050301@akamai.com>
 <87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
 <561DCFA4.3010300@akamai.com>
 <87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
 <561F156E.9050905@akamai.com>
 <87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18/2015 04:58 PM, Rainer Weikusat wrote:

[...]

> 
> The idea behind 'the wait queue' (insofar I'm aware of it) is that it
> will be used as list of threads who need to be notified when the
> associated event occurs. Since you seem to argue that the run-of-the-mill
> algorithm is too slow for this particular case, is there anything to
> back this up?
>

Generally the poll() routines only add to a wait queue once at the
beginning, and all subsequent calls to poll() simply check the wakeup
conditions. So here you are proposing to add/remove to the wait queue on
subsequent invocations of poll(). So the initial patch I did, continued
in the usual pattern and only added once on registration or connect().

However, I do think that this is a special case since the registration
is on a shared wait queue, and thus having a long list of registered
waiters is going to affect all waiters. So I am fine with doing the
add/removes in the poll() routine and I agree that the patch below is
more compact that what I initially posted.

A couple of notes on your patch:

1)

In unix_peer_wake_relay() function, 'sk_wq' is an __rcu pointer and thus
it requires proper dereferencing. Something like:

struct unix_sock *u;
struct socket_wq *wq;

u = container_of(wait, struct unix_sock, wait);
rcu_read_lock();
wq = rcu_dereference(u->sk.sk_wq);
if (wq_has_sleeper(wq))
	wake_up_interruptible_sync_poll(&wq->wait, key);
rcu_read_unlock();


2)

For the case of epoll() in edge triggered mode we need to ensure that
when we return -EAGAIN from unix_dgram_sendmsg() when unix_recvq_full()
is true, we need to add a unix_peer_wake_connect() call to guarantee a
wakeup. Otherwise, we are going to potentially hang there.

With these changes (or tell me why they are not needed), I'm happy to
ack this patch.

Thanks,

-Jason
