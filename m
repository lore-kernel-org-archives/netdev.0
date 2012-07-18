From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 11:25:20 -0400
Message-ID: <20120718152520.GG25563@hmsreliant.think-freely.org>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
 <20120718124539.GC25563@hmsreliant.think-freely.org>
 <5006C679.2040605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52059 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab2GRPZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 11:25:34 -0400
Content-Disposition: inline
In-Reply-To: <5006C679.2040605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 07:21:45AM -0700, John Fastabend wrote:
> On 7/18/2012 5:45 AM, Neil Horman wrote:
> >On Tue, Jul 17, 2012 at 05:33:16PM -0700, John Fastabend wrote:
> >>When the netprio cgroup is built in the kernel cgroup_init will call
> >>cgrp_create which eventually calls update_netdev_tables. This is
> >>being called before do_initcalls() so a null ptr dereference occurs
> >>on init_net.
> >>
> >>This patch adds a check on init_net.count to verify the structure
> >>has been initialized. The failure was introduced here,
> >>
> >>commit ef209f15980360f6945873df3cd710c5f62f2a3e
> >>Author: Gao feng <gaofeng@cn.fujitsu.com>
> >>Date:   Wed Jul 11 21:50:15 2012 +0000
> >>
> >>     net: cgroup: fix access the unallocated memory in netprio cgroup
> >>
> >>Tested with ping with netprio_cgroup as a module and built in.
> >>
> >>Marked RFC for now I think DaveM might have a reason why this needs
> >>some improvement.
> >>
> >>Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> >>Cc: Neil Horman <nhorman@tuxdriver.com>
> >>Cc: Eric Dumazet <edumazet@google.com>
> >>Cc: Gao feng <gaofeng@cn.fujitsu.com>
> >>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>---
> >>
> >>  net/core/netprio_cgroup.c |    3 +++
> >>  1 files changed, 3 insertions(+), 0 deletions(-)
> >>
> >>diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> >>index b2e9caa..e9fd7fd 100644
> >>--- a/net/core/netprio_cgroup.c
> >>+++ b/net/core/netprio_cgroup.c
> >>@@ -116,6 +116,9 @@ static int update_netdev_tables(void)
> >>  	u32 max_len;
> >>  	struct netprio_map *map;
> >>
> >>+	if (!atomic_read(&init_net.count))
> >>+		return ret;
> >>+
> >>  	rtnl_lock();
> >>  	max_len = atomic_read(&max_prioidx) + 1;
> >>  	for_each_netdev(&init_net, dev) {
> >>
> >>
> >
> >John, do you have a stack trace of this.  I'm having a hard time seeing how we
> >get into this path prior to the network stack being initalized.
> 
> Mark had a partial trace
> 
> [    0.003455] Dentry cache hash table entries: 262144 (order: 9,
> 2097152 bytes)
> [    0.005550] Inode-cache hash table entries: 131072 (order: 8,
> 1048576 bytes)
> [    0.007165] Mount-cache hash table entries: 256
> [    0.010289] Initializing cgroup subsys net_cls
> [    0.010947] Initializing cgroup subsys net_prio
> [    0.011039] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000828
> [    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
> 
> 
Well, I was really hoping to see what call path got us there, so this doesn't
really help.  I'll try to setup a system here to reproduce later today.

> >
> >It also brings up another point.  If this is happening, and we're creating the
> >root cgroup from start_kernel, Then we're actually initalizing some cgroups
> >twice, because a few cgroups register themselves via cgroup_load_subsys in
> >module_init specified routines.  So if you're building netprio_cgroup or
> >net_cls_cgroup as part of the monolithic kernel, you'll get cgroup_create called
> >prior to your module_init() call.  Thats not good.
> 
> Well your module_init() wouldn't be called in this case right? I think
> netprio has a bug where we only register a netdevice notifier when
> its built as a module.
> 
> same issue with cls_cgroup and register_tcf_proto_ops?
> 
No.  When not built monolitically, module_init is defined as __initcall, so it
still gets called during the boot process

> >
> >In fact, the cgroup_subsys struct has an early_init flag that cgroup_init
> >appears to use to skip the initialization of subsystems that don't need to be
> >initialized that early in boot (assuming thats the path we're going down to get
> >to this oops).
> 
> Do you mean ss->early_init? Not sure that helps us either we get called
> by cgroup_init because we don't have an early_init callback or we get
> called via cgroup_init_early even earlier.
> 
Yeah, I see what you mean.  Seems like what we need is to either:
1) move cgroup_init to later in the boot process.  If you're not early_init,
then I don't see why the subsystem can't wait until later in the boot process
(i.e. make cgroup_init a late_initcall or some such).

or

2) Allow module based cgroups to flag themselves as needing late init after the
rest of the kernel has booted.


Neil

> >
> >If you can post the call stack, I'd appreciate it, I'd like to dig a bit deeper
> >into this.
> 
> Yes I'll do this shortly.
> 
> >Neil
> >
> 
