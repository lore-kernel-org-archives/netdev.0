From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: iw lockdep warning on wireless-testing
Date: Tue, 24 Jun 2008 17:05:50 +0800
Message-ID: <1214298350.14590.238.camel@debian.sh.intel.com>
References: <1214293174.14590.229.camel@debian.sh.intel.com>
	 (sfid-20080624_094030_856715_6751BF69)  <1214297955.8967.258.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1214297955.8967.258.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-06-24 at 10:59 +0200, Johannes Berg wrote:
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.26-rc6-wl #57
> > -------------------------------------------------------
> > iw/2763 is trying to acquire lock:
> >  (genl_mutex){--..}, at: [<ffffffff81216e4c>] ctrl_dumpfamily
> +0x31/0xf7
> > 
> > but task is already holding lock:
> >  (nlk->cb_mutex){--..}, at: [<ffffffff812137c8>] netlink_dump
> +0x40/0x19d
> > 
> > which lock already depends on the new lock.
> 
> None of those is anything nl80211 has influence over, afaict.

Agreed. I can follow the two scenarios below. Apparently it's a ABBA
locking issue. Just don't know which should be the correct sequence for
using with the two locks.

Thanks,
-yi

> > the existing dependency chain (in reverse order) is:
> > 
> > -> #1 (nlk->cb_mutex){--..}:
> >        [<ffffffff810518cb>] __lock_acquire+0xa4c/0xc28
> >        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
> >        [<ffffffff81051e5d>] lock_acquire+0x51/0x6c
> >        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
> >        [<ffffffff8104eab1>] debug_mutex_lock_common+0x16/0x23
> >        [<ffffffff8127c622>] mutex_lock_nested+0xde/0x23f
> >        [<ffffffff81215774>] netlink_dump_start+0xd9/0x169
> >        [<ffffffff81216d7e>] genl_rcv_msg+0xae/0x14b
> >        [<ffffffff8127c774>] mutex_lock_nested+0x230/0x23f
> >        [<ffffffff81216cd0>] genl_rcv_msg+0x0/0x14b
> >        [<ffffffff8121483a>] netlink_rcv_skb+0x34/0x7c
> >        [<ffffffff81216fe1>] genl_rcv+0x21/0x30
> >        [<ffffffff812145ec>] netlink_unicast+0x1f7/0x287
> >        [<ffffffff811f7eb7>] __alloc_skb+0x84/0x132
> >        [<ffffffff81214d60>] netlink_sendmsg+0x274/0x287
> >        [<ffffffff811f1b49>] sock_sendmsg+0xe2/0xff
> >        [<ffffffff8104582f>] autoremove_wake_function+0x0/0x2e
> >        [<ffffffff81050878>] mark_held_locks+0x49/0x67
> >        [<ffffffff811f1d7d>] sys_sendmsg+0x217/0x28a
> >        [<ffffffff8107de49>] __do_fault+0x35d/0x3a5
> >        [<ffffffff8100bf10>] tracesys+0xd5/0xda
> >        [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > -> #0 (genl_mutex){--..}:
> >        [<ffffffff81050226>] print_circular_bug_header+0xc8/0xcf
> >        [<ffffffff810517d0>] __lock_acquire+0x951/0xc28
> >        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
> >        [<ffffffff81051e5d>] lock_acquire+0x51/0x6c
> >        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
> >        [<ffffffff8104eab1>] debug_mutex_lock_common+0x16/0x23
> >        [<ffffffff8127c622>] mutex_lock_nested+0xde/0x23f
> >        [<ffffffff81050a10>] trace_hardirqs_on+0xf3/0x117
> >        [<ffffffff81216e4c>] ctrl_dumpfamily+0x31/0xf7
> >        [<ffffffff812137e3>] netlink_dump+0x5b/0x19d
> >        [<ffffffff81214ef3>] netlink_recvmsg+0x180/0x2a8
> >        [<ffffffff811f1a48>] sock_recvmsg+0xf0/0x10f
> >        [<ffffffff8104582f>] autoremove_wake_function+0x0/0x2e
> >        [<ffffffff81050878>] mark_held_locks+0x49/0x67
> >        [<ffffffff811f295c>] sys_recvmsg+0x15c/0x254
> >        [<ffffffff81067ac3>] audit_syscall_entry+0x12d/0x160
> >        [<ffffffff8127d6da>] trace_hardirqs_on_thunk+0x35/0x3a
> >        [<ffffffff8100bf10>] tracesys+0xd5/0xda
> >        [<ffffffffffffffff>] 0xffffffffffffffff

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
