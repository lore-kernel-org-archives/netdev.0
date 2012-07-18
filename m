From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 13:14:09 -0400
Message-ID: <20120718171409.GJ25563@hmsreliant.think-freely.org>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
 <20120718124539.GC25563@hmsreliant.think-freely.org>
 <5006C679.2040605@intel.com>
 <5006D2E0.1070404@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53752 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab2GRROU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 13:14:20 -0400
Content-Disposition: inline
In-Reply-To: <5006D2E0.1070404@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 08:14:40AM -0700, John Fastabend wrote:
> On 7/18/2012 7:21 AM, John Fastabend wrote:
> >On 7/18/2012 5:45 AM, Neil Horman wrote:
> >>On Tue, Jul 17, 2012 at 05:33:16PM -0700, John Fastabend wrote:
> >>>When the netprio cgroup is built in the kernel cgroup_init will call
> >>>cgrp_create which eventually calls update_netdev_tables. This is
> >>>being called before do_initcalls() so a null ptr dereference occurs
> >>>on init_net.
> >>>
> >>>This patch adds a check on init_net.count to verify the structure
> >>>has been initialized. The failure was introduced here,
> >>>
> >>>commit ef209f15980360f6945873df3cd710c5f62f2a3e
> >>>Author: Gao feng <gaofeng@cn.fujitsu.com>
> >>>Date:   Wed Jul 11 21:50:15 2012 +0000
> >>>
> >>>     net: cgroup: fix access the unallocated memory in netprio cgroup
> >>>
> >>>Tested with ping with netprio_cgroup as a module and built in.
> >>>
> >>>Marked RFC for now I think DaveM might have a reason why this needs
> >>>some improvement.
> >>>
> >>>Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> >>>Cc: Neil Horman <nhorman@tuxdriver.com>
> >>>Cc: Eric Dumazet <edumazet@google.com>
> >>>Cc: Gao feng <gaofeng@cn.fujitsu.com>
> >>>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>>---
> >>>
> >>>  net/core/netprio_cgroup.c |    3 +++
> >>>  1 files changed, 3 insertions(+), 0 deletions(-)
> >>>
> >>>diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> >>>index b2e9caa..e9fd7fd 100644
> >>>--- a/net/core/netprio_cgroup.c
> >>>+++ b/net/core/netprio_cgroup.c
> >>>@@ -116,6 +116,9 @@ static int update_netdev_tables(void)
> >>>      u32 max_len;
> >>>      struct netprio_map *map;
> >>>
> >>>+    if (!atomic_read(&init_net.count))
> >>>+        return ret;
> >>>+
> >>>      rtnl_lock();
> >>>      max_len = atomic_read(&max_prioidx) + 1;
> >>>      for_each_netdev(&init_net, dev) {
> >>>
> >>>
> >>
> >>John, do you have a stack trace of this.  I'm having a hard time
> >>seeing how we
> >>get into this path prior to the network stack being initalized.
> >
> >Mark had a partial trace
> >
> >[    0.003455] Dentry cache hash table entries: 262144 (order: 9,
> >2097152 bytes)
> >[    0.005550] Inode-cache hash table entries: 131072 (order: 8, 1048576
> >bytes)
> >[    0.007165] Mount-cache hash table entries: 256
> >[    0.010289] Initializing cgroup subsys net_cls
> >[    0.010947] Initializing cgroup subsys net_prio
> >[    0.011039] BUG: unable to handle kernel NULL pointer dereference at
> >0000000000000828
> >[    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
> >
> >
> >>
> >>It also brings up another point.  If this is happening, and we're
> >>creating the
> >>root cgroup from start_kernel, Then we're actually initalizing some
> >>cgroups
> >>twice, because a few cgroups register themselves via
> >>cgroup_load_subsys in
> >>module_init specified routines.  So if you're building netprio_cgroup or
> >>net_cls_cgroup as part of the monolithic kernel, you'll get
> >>cgroup_create called
> >>prior to your module_init() call.  Thats not good.
> >
> >Well your module_init() wouldn't be called in this case right? I think
> >netprio has a bug where we only register a netdevice notifier when
> >its built as a module.
> >
> >same issue with cls_cgroup and register_tcf_proto_ops?
> >
> 
> Neil, I was very unclear in the above. What I meant here was
> cgroup_load_subsys() checks ss->module so you should _not_
> get two create calls. And returns 0 so the register calls for
> netdev notifiers should get setup.
> 
> I missed the return 0 part and so I thought we might abort before
> this occurs but it looks ok to me on second glance.
> 

John, et al.

Just so we all have it, I've got the problem reproduced here, and it gives me
this backtrace:

 0.149924] Mount-cache hash table entries: 256
[    0.163754] Initializing cgroup subsys cpuacct
[    0.176991] Initializing cgroup subsys memory
[    0.190012] Initializing cgroup subsys devices
[    0.203249] Initializing cgroup subsys freezer
[    0.216484] Initializing cgroup subsys net_cls
[    0.229719] Initializing cgroup subsys blkio
[    0.242436] Initializing cgroup subsys perf_event
[    0.256451] Initializing cgroup subsys net_prio
[    0.269948] BUG: unable to handle kernel NULL pointer dereference at
0000000000000698
[    0.293303] IP: [<ffffffff81512e37>] cgrp_create+0x107/0x1c0
[    0.310175] PGD 0 
[    0.316157] Oops: 0000 [#1] SMP 
[    0.325775] CPU 0 
[    0.331227] Modules linked in:
[    0.340846] 
[    0.345264] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc7+ #1 AMD Dinar/Dinar
[    0.366555] RIP: 0010:[<ffffffff81512e37>]  [<ffffffff81512e37>]
cgrp_create+0x107/0x1c0
[    0.390681] RSP: 0000:ffffffff81c01ea8  EFLAGS: 00010213
[    0.406501] RAX: 0000000000000000 RBX: ffffffffffffff10 RCX: 0000000000000000
[    0.427764] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffffffff81c9d840
[    0.449026] RBP: ffffffff81c01ed8 R08: 00000000000164e0 R09: 0000000000000000
[    0.470289] R10: ffff8804278303c0 R11: 0000000000000000 R12: 0000000000000001
[    0.491553] R13: ffff8804278303c0 R14: ffff881036fd0700 R15: 0000000000000000
[    0.512819] FS:  0000000000000000(0000) GS:ffff880427c00000(0000)
knlGS:0000000000000000
[    0.536932] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.554049] CR2: 0000000000000698 CR3: 0000000001c0b000 CR4: 00000000000406b0
[    0.575311] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.596574] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    0.617838] Process swapper/0 (pid: 0, threadinfo ffffffff81c00000, task
ffffffff81c13420)
[    0.642471] Stack:
[    0.648442]  ffffffff81c01eb8 ffffffff81c9f320 ffffffff81c9f320
ffffffff81c9f320
[    0.670522]  ffffffff81c9f320 ffffffff81d482c0 ffffffff81c01ef8
ffffffff81d10397
[    0.692604]  ffffffff81e99790 0000000000000048 ffffffff81c01f18
ffffffff81d1062e
[    0.714687] Call Trace:
[    0.721960]  [<ffffffff81d10397>] cgroup_init_subsys+0x51/0xdf
[    0.739337]  [<ffffffff81d1062e>] cgroup_init+0x36/0x119
[    0.755160]  [<ffffffff81cf5c02>] start_kernel+0x38f/0x3c4
[    0.771501]  [<ffffffff81cf5672>] ? repair_env_string+0x5e/0x5e
[    0.789138]  [<ffffffff81cf5356>] x86_64_start_reservations+0x131/0x135
[    0.808849]  [<ffffffff81cf545a>] x86_64_start_kernel+0x100/0x10f
[    0.827003] Code: 10 ff ff ff 75 25 e9 89 00 00 00 66 0f 1f 84 00 00 00 00 00
48 8b 93 f0 00 00 00 48 81 fa 38 39 f9 81 48 8d 9a 10 ff ff ff 74 69 <48> 8b 93
88 07 00 00 48 85 d2 74 dd 44 3b 62 10 76 d7 48 8d bb 
[    0.883860] RIP  [<ffffffff81512e37>] cgrp_create+0x107/0x1c0
[    0.900988]  RSP <ffffffff81c01ea8>
[    0.911366] CR2: 0000000000000698
[    0.921235] ---[ end trace a7919e7f17c0a725 ]---


So yes, it appears to me that we're calling cgrp_create from cgroup_init_subsys
prior to having the module_init routine called for netprio_cgroup.  It seems to
me that (given that we have a cgroup_early_init patch), we can move the
cgroup_init call until later in the boot process.  I'll spend the some time in
the next few weeks tinkering with that.
Best
Neil
