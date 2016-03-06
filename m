From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sun, 6 Mar 2016 13:09:32 +0300
Message-ID: <20160306100932.GP4184@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160305155714.GM4184@uranus.lan>
 <20160305.113312.1758700509401944239.davem@davemloft.net>
 <20160305184459.GO4184@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36550 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbcCFKJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 05:09:45 -0500
Received: by mail-lb0-f177.google.com with SMTP id x1so102424001lbj.3
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 02:09:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160305184459.GO4184@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2016 at 09:44:59PM +0300, Cyrill Gorcunov wrote:
> On Sat, Mar 05, 2016 at 11:33:12AM -0500, David Miller wrote:
> ...
> > 
> > Probably the same optimization can be applied there, see patch below.
> > And if that doesn't do it, there is a really easy way to batch the
> > delete by scanning the FIB tree in one go and deleting every entry
> > that points to "in_dev".  But I suspect we really won't need that.
> 
> It made it to work faster but still for 10000 addresses it takes
> ~3-4 minutes to become alive again.
> 
> David, give me some time, I'll prepare tests and report the
> results on patches and unpatched versions. And thanks a huge
> for both patches!

Hi David! So I tried both patched and unpatched versions and the
results didn't varies much.

Unpatched
=========

[root@pcs7 ~]# ./exploit.sh
START 4 addresses STOP 1457255479 1457255480		-> 1
START 144 addresses STOP 1457255481 1457255482		-> 1
START 484 addresses STOP 1457255485 1457255490		-> 5
START 1024 addresses STOP 1457255496 1457255506		-> 10
START 1764 addresses STOP 1457255516 1457255532		-> 16
START 2704 addresses STOP 1457255548 1457255574		-> 26
START 3844 addresses STOP 1457255597 1457255633		-> 36
START 5184 addresses STOP 1457255665 1457255714		-> 49
START 6724 addresses STOP 1457255755 1457255819		-> 64
START 8464 addresses STOP 1457255872 1457255952		-> 80

Patched
=======

[root@pcs7 ~]# ./exploit.sh
START 4 addresses STOP 1457256166 1457256167		-> 1
START 144 addresses STOP 1457256168 1457256170		-> 2
START 484 addresses STOP 1457256173 1457256178		-> 5
START 1024 addresses STOP 1457256184 1457256194		-> 10
START 1764 addresses STOP 1457256206 1457256225		-> 19
START 2704 addresses STOP 1457256243 1457256272		-> 29
START 3844 addresses STOP 1457256303 1457256343		-> 40
START 5184 addresses STOP 1457256377 1457256427		-> 50
START 6724 addresses STOP 1457256472 1457256538		-> 66
START 8464 addresses STOP 1457256609 1457256697		-> 88

The script itself I've been using is the following
---
#!/bin/sh

if [ -z $1 ]; then
       for x in `seq 1 10 100`; do
                echo -n "START "
                (unshare -n /bin/sh exploit.sh $x)
                echo -n " "
                ssh -q -t root@localhost "exit"
                echo `date +%s`
                d2=`date +%s`
       done
else
        for x in `seq 0 $1`; do
                for y in `seq 0 $1`; do
                        ip a a 127.1.$x.$y dev lo
                done
        done
        num=`ip a l dev lo | grep -c "inet "`
        echo -n "$num addresses "
        echo -n "STOP "
        echo -n `date +%s`
        exit
fi
---

This is strange that on patched version it took even longer
but I think this is due to the fact that the test is ran
on VM instead of real hardware.

Anyway, then I run this script for 255 as parameter
in one pass which gen. requests to create 65025 addresses
and kernel start complaining:

Perf output
-----------
  24.95%  [kernel]                      [k] __local_bh_enable_ip
  21.52%  [kernel]                      [k] lock_acquire
  15.54%  [kernel]                      [k] lock_release
   9.84%  [kernel]                      [k] lock_is_held
   7.47%  [kernel]                      [k] lock_acquired
   4.08%  [kernel]                      [k] __local_bh_disable_ip
   1.86%  [kernel]                      [k] native_save_fl
   1.74%  [kernel]                      [k] ___might_sleep
   1.34%  [kernel]                      [k] _raw_spin_unlock_irqrestore
   1.10%  [kernel]                      [k] do_raw_spin_trylock
   0.98%  [kernel]                      [k] __slab_alloc.isra.43.constprop.47
   0.97%  [kernel]                      [k] debug_lockdep_rcu_enabled
   0.93%  [kernel]                      [k] nf_ct_iterate_cleanup
   0.90%  [kernel]                      [k] _raw_spin_lock
   0.54%  [kernel]                      [k] __do_softirq
   0.49%  [kernel]                      [k] get_parent_ip
   0.48%  [kernel]                      [k] _raw_spin_unlock
   0.46%  [kernel]                      [k] preempt_count_sub
   0.42%  [kernel]                      [k] native_save_fl
   0.40%  [kernel]                      [k] preempt_count_add
   0.39%  [kernel]                      [k] do_raw_spin_unlock
   0.36%  [kernel]                      [k] in_lock_functions
   0.35%  [kernel]                      [k] arch_local_irq_save
   0.22%  [kernel]                      [k] _raw_spin_unlock_irq
   0.19%  [kernel]                      [k] nf_conntrack_lock
   0.18%  [kernel]                      [k] local_bh_enable
   0.16%  [kernel]                      [k] trace_preempt_off
   0.16%  [kernel]                      [k] arch_local_irq_save
   0.14%  [kernel]                      [k] console_unlock
   0.14%  [kernel]                      [k] preempt_trace
   0.12%  [kernel]                      [k] local_bh_disable
   0.12%  [kernel]                      [k] _cond_resched
   0.06%  [kernel]                      [k] read_seqcount_begin.constprop.22
   0.06%  perf                          [.] dso__find_symbol
   0.05%  [kernel]                      [k] acpi_pm_read
---

dmesg output
------------

[ 1680.436091] INFO: task kworker/0:2:6888 blocked for more than 120 seconds.
[ 1680.437270]       Tainted: G        W       4.5.0-rc6-dirty #18
[ 1680.438310] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1680.439911] kworker/0:2     D ffff8800a2c6bca8     0  6888      2 0x00080080
[ 1680.441137] Workqueue: ipv6_addrconf addrconf_verify_work
[ 1680.442136]  ffff8800a2c6bca8 00ff8800a3c28000 00000000001d5f40 ffff88013a7d5f40
[ 1680.444679]  ffff8800a3c28000 ffff8800a2c6c000 0000000000000246 ffff8800a3c28000
[ 1680.446352]  ffffffff81f31e28 ffffffff81683614 ffff8800a2c6bcc0 ffffffff818365a6
[ 1680.449354] Call Trace:
[ 1680.450039]  [<ffffffff81683614>] ? rtnl_lock+0x17/0x19
[ 1680.450972]  [<ffffffff818365a6>] schedule+0x8b/0xa3
[ 1680.451882]  [<ffffffff8183675a>] schedule_preempt_disabled+0x18/0x24
[ 1680.452948]  [<ffffffff818373eb>] mutex_lock_nested+0x1f1/0x3f1
[ 1680.453959]  [<ffffffff81683614>] rtnl_lock+0x17/0x19
[ 1680.454887]  [<ffffffff81683614>] ? rtnl_lock+0x17/0x19
[ 1680.455858]  [<ffffffff81779fc1>] addrconf_verify_work+0xe/0x1a
[ 1680.456868]  [<ffffffff8109e41a>] process_one_work+0x264/0x4d7
[ 1680.457868]  [<ffffffff8109eb9f>] worker_thread+0x209/0x2c2
[ 1680.458840]  [<ffffffff81136d55>] ? trace_preempt_on+0x9/0x1d
[ 1680.459828]  [<ffffffff8109e996>] ? rescuer_thread+0x2d6/0x2d6
[ 1680.460828]  [<ffffffff810a41a8>] kthread+0xd4/0xdc
[ 1680.461722]  [<ffffffff810a40d4>] ? kthread_parkme+0x24/0x24
[ 1680.462713]  [<ffffffff8183b63f>] ret_from_fork+0x3f/0x70
[ 1680.463703]  [<ffffffff810a40d4>] ? kthread_parkme+0x24/0x24
[ 1680.466805] 3 locks held by kworker/0:2/6888:
[ 1680.467684]  #0:  ("%s"("ipv6_addrconf")){.+.+..}, at: [<ffffffff8109e319>] process_one_work+0x163/0x4d7
[ 1680.469592]  #1:  ((addr_chk_work).work){+.+...}, at: [<ffffffff8109e319>] process_one_work+0x163/0x4d7
[ 1680.471517]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81683614>] rtnl_lock+0x17/0x19
[ 1680.473664] INFO: task sshd:30767 blocked for more than 120 seconds.
[ 1680.474722]       Tainted: G        W       4.5.0-rc6-dirty #18
[ 1680.475723] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1680.478599] sshd            D ffff880137cdfc58     0 30767   1423 0x00080080
[ 1680.479812]  ffff880137cdfc58 00ff8800ba334000 00000000001d5f40 ffff88013a9d5f40
[ 1680.481532]  ffff8800ba334000 ffff880137ce0000 0000000000000246 ffff8800ba334000
[ 1680.483163]  ffffffff81f31e28 ffffffff81683614 ffff880137cdfc70 ffffffff818365a6
[ 1680.484796] Call Trace:
[ 1680.485437]  [<ffffffff81683614>] ? rtnl_lock+0x17/0x19
[ 1680.486375]  [<ffffffff818365a6>] schedule+0x8b/0xa3
[ 1680.487310]  [<ffffffff8183675a>] schedule_preempt_disabled+0x18/0x24
[ 1680.488362]  [<ffffffff818373eb>] mutex_lock_nested+0x1f1/0x3f1
[ 1680.489359]  [<ffffffff81683614>] rtnl_lock+0x17/0x19
[ 1680.490275]  [<ffffffff81683614>] ? rtnl_lock+0x17/0x19
[ 1680.491202]  [<ffffffff81684365>] rtnetlink_rcv+0x13/0x2a
[ 1680.492147]  [<ffffffff816c8396>] netlink_unicast+0x138/0x1c6
[ 1680.493124]  [<ffffffff816c86bd>] netlink_sendmsg+0x299/0x2e1
[ 1680.494117]  [<ffffffff8165b089>] sock_sendmsg_nosec+0x12/0x1d
[ 1680.495138]  [<ffffffff8165cb18>] SYSC_sendto+0x100/0x142
[ 1680.496088]  [<ffffffff81119e7c>] ? __audit_syscall_entry+0xc0/0xe4
[ 1680.497125]  [<ffffffff8100161c>] ? do_audit_syscall_entry+0x60/0x62
[ 1680.498238]  [<ffffffff810017dd>] ? syscall_trace_enter_phase1+0x10e/0x12f
[ 1680.499338]  [<ffffffff81001017>] ? trace_hardirqs_on_thunk+0x17/0x19
[ 1680.500395]  [<ffffffff8165d18a>] SyS_sendto+0xe/0x10
[ 1680.501308]  [<ffffffff8183b2d7>] entry_SYSCALL_64_fastpath+0x12/0x6f
[ 1680.505284] 1 lock held by sshd/30767:
[ 1680.506080]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81683614>] rtnl_lock+0x17/0x19

And of course it's not accessible via sshd anymore, until everything is cleaned up.
On the other hands I think it's expected results -- 65 thousands of addresses
is a big number and unfortunately there is no way yet to somehow prevent the
net-admins in containers to create them. I didn't look yet maybe it's allowed
to do so via memory cgroup.

IOW, thanks a huge (!) for both patches and I think it's worth to have them
both in -net tree 'cause they are definitely needed, but same time I'll have
to investigate this problem more deeply on Wednesday on the real testing
machine, and will check if memory cgroup may help us here to limit the
resources.

	Cyrill
