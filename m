From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 07 Nov 2004 09:57:34 +0100
Message-ID: <418DE37E.2050504@trash.net>
References: <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041106145036.GB28715@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>So using the RCU protected list only enforces the unlinking
>to be safe while within a list walk  and the rcu callback
>to be deferred until the list walk is complete but may
>be executed right after qdisc_lookup and then may free the
>entry that was returned.
>
>So we must either rcu_read_lock all codeblocks that use
>a result of a qdisc_lookup which is not trivial or ensure
>that all rcu callbacks have finished before the next rtnetlink
>message is processed.
>
>Maybe the easiest would be to have a refcnt which is
>incremented when a rcu callback is set up and decremented
>when it finishs and sleep on it after processing a
>rtnetlink message until it reaches 0 again.
>
>Thoughts?
>  
>
Before the RCU change distruction of the qdisc and all inner
qdiscs happend immediately and under the rtnl semaphore. This
made sure nothing holding the rtnl semaphore could end up with
invalid memory. This is not true anymore, qdiscs found on
dev->qdisc_list can be suddenly destroyed.

dev->qdisc_list is protected by qdisc_tree_lock everywhere but in
qdisc_lookup, this is also the only structure that is consistently
protected by this lock. To fix the list corruption we can either
protect qdisc_lookup with qdisc_tree_lock or use rcu-list macros
and remove all read_lock(&qdisc_tree_locks) (and replace it by
a spinlock).

Unfortunately, since we can not rely on the rtnl protection for
memory anymore, it seems we need to refcount all uses of
dev->qdisc_list that before relied on this protection and can't
use rcu_read_lock. To make this safe, we need to atomically
atomic_dec_and_test/list_del in qdisc_destroy and atomically do
list_for_each_entry/atomic_inc in qdisc_lookup, so we should
should simply keep the non-rcu lists and use qdisc_tree_lock
in qdisc_lookup.

I'm working on a patch, but it will take a few days.

Regards
Patrick
