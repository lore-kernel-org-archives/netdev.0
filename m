From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 7 Nov 2004 15:00:15 +0100
Message-ID: <20041107140015.GA31969@postel.suug.ch>
References: <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418DE37E.2050504@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Before the RCU change distruction of the qdisc and all inner
> qdiscs happend immediately and under the rtnl semaphore. This
> made sure nothing holding the rtnl semaphore could end up with
> invalid memory. This is not true anymore, qdiscs found on
> dev->qdisc_list can be suddenly destroyed.

And we should switch back to this again if possible. I haven't
audited all paths to dev_activate but we have at most
a list addition which might not be protected with an
rtnl semaphore. I'm not 100% sure about this yet.

> dev->qdisc_list is protected by qdisc_tree_lock everywhere but in
> qdisc_lookup, this is also the only structure that is consistently
> protected by this lock. To fix the list corruption we can either
> protect qdisc_lookup with qdisc_tree_lock or use rcu-list macros
> and remove all read_lock(&qdisc_tree_locks) (and replace it by
> a spinlock).

qdisc_lookup was the only one not yet protected by a preempt
disable.

> Unfortunately, since we can not rely on the rtnl protection for
> memory anymore, it seems we need to refcount all uses of
> dev->qdisc_list that before relied on this protection and can't
> use rcu_read_lock.

There is no list iteration not yet protected by the rtnl semaphore
and the only interruption is because of the rcu callback.

> To make this safe, we need to atomically
> atomic_dec_and_test/list_del in qdisc_destroy and atomically do
> list_for_each_entry/atomic_inc in qdisc_lookup, so we should
> should simply keep the non-rcu lists and use qdisc_tree_lock
> in qdisc_lookup.

You mean before qdisc_lookup and until the reference is released
again? These are huge locking regions involving calls which might
sleep and possible qdisc_destroy calling paths.  So this won't
work quite well.

So in my opinion we should screw that call_rcu because it doesn't
make much sense. In case dev_activate is not synchronized with
rtnl sempaphore we have to make sure that qdisc_destroy always
locks on qdisc_tree_lock which is not the case for a few paths as
of now, although I'm not sure if any of those actually ever call
qdisc_destroy with refcnt==1.

If screwing call_rcu is not possible we can still do a refcnt
incremented before call_rcu in qdisc_destroy and every base
caller of qdisc_destroy (excluding those in qdisc destroy routines)
sleeps on it after it invoked qdisc_destroy and reached a safe
place to sleep. So we can make sure that the qdisc is really gone
after invoking qdisc_destroy. Otherwise we will always run into
troubles with new messages arriving and qdisc deletions still
pending.
