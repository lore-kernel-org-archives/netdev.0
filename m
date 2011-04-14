From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: Race condition when creating multiple namespaces?
Date: Thu, 14 Apr 2011 22:46:41 +0200
Message-ID: <201104142246.41642.hans@schillstrom.com>
References: <201104112301.46776.hans@schillstrom.com> <m1ei58co08.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:55272 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1DNUqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 16:46:45 -0400
In-Reply-To: <m1ei58co08.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I thought this might have been a kvm bug, but now I've got it in  net-netx 2.6.39-rc2 too

On Tuesday, April 12, 2011 02:27:35 Eric W. Biederman wrote:
> Hans Schillstrom <hans@schillstrom.com> writes:
> 
> > Hello
> > I'v been strugling with this for some time now
> >
> > When creating multiple namespaces using lxc-start,  un-initialized network namespace parts will be called by the new process in the namespace.
> > ex. when using conntrack or ipvsadm to quickly,  (a sleep 2 "solves" the problem).
> > (From what I can see syscall clone() is used in lx-start  i.e. do_fork will be called later on.)
> > Actually I was debugging ip_vs when closing multiple ns  when I fell into this one.
> >
> > I have a loop that create 33 containers whith lxc-start ... -- test.sh
> > the first thing the new conatiner does in test.sh is
> > #!/bin/bash
> > iptables -t mangle -A PREROUTING -m conntrack --ctstate RELATED,ESTABLISHED -j CONNMARK --restore-mark
> > nc -l -p1234
> >
> > This results in NULL ptr in ip_conntrack_net_init(struct *net)
> 
> Ouch!
> 
> > and in anoither test test.sh looks like this
> > #!/bin/bash
> > ipvsadm --start-daemon=master --mcast-interface=lo
> > nc -l -p1234
> >
> > And this results in an uniitialized spinlock in ip_vs_sync
> >
> > I put a printk in nsproxy: copy_namespaces() and could see a dozens of them
> > before anything appears from ipvs or conntrack.
> >
> > My feeling is that when you start up user processes in a new name space, 
> > all kernel related init should have been done (you should not need to add a sleep to get it working)
> >
> > All test  made by using todays net-next-2.6 (2.6.39-rc1)
> >

Same problem in rc2 from today

> > Note:
> > That neither conntrack or ip_vs modules where loaded,
> > if modules where loaded before creating new namespaces it all works...
> >
> > Finally the question,
> > Should it really work to load modules within a namespace , 
> > that is a part of netns ?
> 
> >From an implementation point of view kernel modules are not in a
> namespace, so there should be no difference between being in a namespace
> and loading a kernel networking module and not being in a namespace and
> loading in a kernel module.
> 
> It does sound like you have hit a module loading race, and perhaps
> a race that is confined to network namespaces.
> 

When the namespace was created I had a bunch of IPv4 & IPv6 tunnels and eth0 & eth1


[ 1114.323402] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[ 1114.330293] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[ 1114.331002] IP: [<ffffffff8104de50>] __sysctl_head_next+0x70/0x130
[ 1114.331002] PGD 169693067 PUD 16bfce067 PMD 0 
[ 1114.331002] Oops: 0000 [#1] PREEMPT SMP 
[ 1114.331002] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host2/target2:0:0/2:0:0:0/scsi_generic/sg0/dev
[ 1114.331002] CPU 1 
[ 1114.331002] Modules linked in: nf_conntrack(+) macvlan arptable_filter arp_tables 3c59x nouveau ttm drm_kms_helper
[ 1114.331002] 
[ 1114.331002] Pid: 936, comm: modprobe Not tainted 2.6.39-rc2+ #21 System manufacturer System Product Name/P5B
[ 1114.331002] RIP: 0010:[<ffffffff8104de50>]  [<ffffffff8104de50>] __sysctl_head_next+0x70/0x130
[ 1114.331002] RSP: 0018:ffff880169c1bb98  EFLAGS: 00010286
[ 1114.331002] RAX: ffff88016bdb1530 RBX: fffffffffffffff8 RCX: 0000000000000000
[ 1114.331002] RDX: 000000000000e901 RSI: ffff880169c1bda8 RDI: ffffffff816b94a0
[ 1114.331002] RBP: ffff880169c1bbb8 R08: 0000000000000000 R09: ffff880169eee2b0
[ 1114.331002] R10: 0000000000000000 R11: 0000000000000002 R12: 0000000000000000
[ 1114.331002] R13: ffff880169c1bda8 R14: ffffffffa0103300 R15: 0000000000000001
[ 1114.331002] FS:  00007f6039af3700(0000) GS:ffff88017fc80000(0000) knlGS:0000000000000000
[ 1114.331002] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1114.331002] CR2: 0000000000000018 CR3: 000000016968d000 CR4: 00000000000006e0
[ 1114.331002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1114.331002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1114.331002] Process modprobe (pid: 936, threadinfo ffff880169c1a000, task ffff88016bcc16c0)
[ 1114.331002] Stack:
[ 1114.331002]  ffff88017fffcc00 ffff880169eec9c8 ffff880169c1bbf0 ffff880169eee388
[ 1114.331002]  ffff880169c1bc28 ffffffff8106fba5 000000007fffde48 ffff880169c1bda8
[ 1114.331002]  0000000201c94f80 ffff88016958f818 ffff880169c1bc38 0000000000000000
[ 1114.331002] Call Trace:
[ 1114.331002]  [<ffffffff8106fba5>] sysctl_check_table+0x2b5/0x3f0
[ 1114.331002]  [<ffffffff8106f955>] sysctl_check_table+0x65/0x3f0
[ 1114.331002]  [<ffffffff8106f955>] sysctl_check_table+0x65/0x3f0
[ 1114.331002]  [<ffffffff8104dadc>] __register_sysctl_paths+0xfc/0x320
[ 1114.331002]  [<ffffffff810fd85a>] ? cache_alloc_debugcheck_after+0xea/0x220
[ 1114.331002]  [<ffffffffa01006ce>] ? nf_conntrack_acct_init+0x3e/0xe0 [nf_conntrack]
[ 1114.331002]  [<ffffffff811007ef>] ? __kmalloc_track_caller+0x11f/0x2a0
[ 1114.331002]  [<ffffffff814534f1>] register_net_sysctl_table+0x61/0x70
[ 1114.331002]  [<ffffffffa01006f4>] nf_conntrack_acct_init+0x64/0xe0 [nf_conntrack]
[ 1114.331002]  [<ffffffffa00f8604>] nf_conntrack_init+0xf4/0x350 [nf_conntrack]
[ 1114.331002]  [<ffffffffa00fb614>] nf_conntrack_net_init+0x14/0x1a0 [nf_conntrack]
[ 1114.331002]  [<ffffffff813718d7>] ops_init+0x47/0x130
[ 1114.331002]  [<ffffffff81371de3>] register_pernet_operations+0xa3/0x180
[ 1114.331002]  [<ffffffffa010c000>] ? 0xffffffffa010bfff
[ 1114.331002]  [<ffffffffa010c000>] ? 0xffffffffa010bfff
[ 1114.331002]  [<ffffffff81371fec>] register_pernet_subsys+0x2c/0x50
[ 1114.331002]  [<ffffffffa010c010>] nf_conntrack_standalone_init+0x10/0x12 [nf_conntrack]
[ 1114.331002]  [<ffffffff810001d3>] do_one_initcall+0x43/0x170
[ 1114.331002]  [<ffffffff8108393b>] sys_init_module+0xbb/0x200
[ 1114.331002]  [<ffffffff81469beb>] system_call_fastpath+0x16/0x1b
[ 1114.331002] Code: 87 00 00 00 48 8b 5b 30 4d 8b 24 24 48 8b 43 30 48 85 c0 0f 84 92 00 00 00 4c 89 ee 48 89 df ff d0 49 39 c4 74 45 49 8d 5c 24 f8 
[ 1114.331002]  83 7b 20 00 75 d2 83 43 18 01 48 c7 c7 60 9a 67 81 e8 a9 b2 
[ 1114.331002] RIP  [<ffffffff8104de50>] __sysctl_head_next+0x70/0x130
[ 1114.331002]  RSP <ffff880169c1bb98>
[ 1114.331002] CR2: 0000000000000018
[ 1114.691196] ---[ end trace b3f24866c78b4f05 ]---
[ 1114.696485] note: modprobe[936] exited with preempt_count 1
[ 1114.702440] BUG: sleeping function called from invalid context at /opt/src/ericsson/kvm/net-next-2.6/kernel/rwsem.c:21


> My head is in another problem so I won't be able to look at this for
> a bit.  But if you are getting into ip_conntrack_net_init with
> a NULL network namespace something spectacularly bad is happening.
> 
> In particular it looks like you must be hitting a bug in for_each_net.
> Which would pretty much have to be a race in adding or removing from
> net_namespace_list.
> 
> I took a quick skim through the code and whenever we modify the
> net_namespace we hold but the net_mutex and inside it the rtnl_lock so I
> don't immediate see how you could be getting a NULL net into
> ip_conntrack_net_init.
> 
> Is there a codepath besides register_pernet_subsys that is calling
> ip_conntrack_net_init?
> 
In this case it's ip_vs that tries to load nf_conntrack

> Do you have any local modifications that could be messing up register_pernet_subsys?

nop
> 
> Eric
> 
