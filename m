From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sun, 14 Sep 2003 12:55:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030914125549.A7790@electric-eye.fr.zoreil.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com> <20030913080252.GE94744@gaz.sfgoth.com> <20030913110353.B23840@electric-eye.fr.zoreil.com> <20030913201559.GI94744@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
Content-Disposition: inline
In-Reply-To: <20030913201559.GI94744@gaz.sfgoth.com>; from mitch@sfgoth.com on Sat, Sep 13, 2003 at 01:15:59PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr <mitch@sfgoth.com> :
[...]
> I don't understand what you're saying - are you saying that the locking
> isn't needed?  Or just the recheck isn't needed?  It sounds like if we're
> only avoiding the race because of the bh_lock_sock() then we do need to
> recheck, right?

- the locking is needed
- the recheck is needed
(- it does more than the recheck)

My point was related to the comment included in the patch, namely
"/* re-check under lock */"
>From a reader's view, it is important to know why things are done and the
comment only tells _what_ is done.

So why is locking required ?

The comment just before the head of packet_rcv() suggests it.

As usual packet handler [1] in Linux, this code is run in a BH context.
It can race with user-space when it uses the struct sock related part of
the sk_buff (and it could race with tasklets when it messes with the
struct sk_buff itself)

User-space can change sk->sk_filter through setsockopt() +
SO_{ATTACH/DETACH}_FILTER but it takes care to only do so in sections 
surrounded by spin_{lock/unlock}_bh() [2]. As the first "if (sk->sk_filter)"
in packet_rcv() takes no lock, there is a time window where it is possible
that sk->sk_filter has been changed by user-space code on one cpu whereas
packet_rcv() still sees the old value. However, user is guaranteed that a
packet received _after_ his call to setsockopt() has returned will be
correctly handled by packet_rcv(). Whence 1) user is happy 2) packet_rcv()
isn't forced to take a lock before examination of sk->sk_filter when there
is no BPF handling to do (optimization).

Now let's assume some BPF-related action _appears_ to be needed. Without
locking, even filter = sk->sk_filter in packet_rcv() could race with
sk->sk_filter = NULL in sock_setsockopt() and result in partially set
content for "filter". That's why user-space code forbids BH on its CPU and
stops BH on others CPU with sk->sk_lock.slock. As soon as packet_rcv()
try to lock sk->sk_lock.slock, locking between packet_rcv() and user space
is fine.
As there is no point in issuing "forbid BH on my CPU" from packet_rcv(),
this part of the locking is forgotten. Thus packet_rcv() only issues a
spin_{lock/unlock} (which protects from tasklets on different CPU as well).
spin_{lock/unlock} is named bh_{lock/unlock}_sock. I assume it is on
documentation purpose and to allow an evil plan in the future.

[1] net/core/dev.c::dev_add_pack() and struct packet_type in
    include/linux/netdevice.h
[2] net/core/sock.c::sock_setsockopt() ... SO_DETACH_FILTER and
    net/core/filter.c::sk_attach_filter()

> Could you do a patch for what you think it should look like?  You obviously
> understand the locking issues here better than I.

See previously posted patch. Imho the non-trivial part isn't the locking
itself but the fact that the first test of sk->sk_filter is done _without_
lock. May be something like the following comment before this test:

/* Racing with user-space for optimization purpose: don't panic */

Tell me if it is correctly worded and I'll patch it.

Btw, the locking issues are rather well explained in 
Documentation/DocBook/kernel-locking.tmpl (and in Schimmel's book as well).

--
Ueimor
