From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 08:14:40 -0700
Message-ID: <5006D2E0.1070404@intel.com>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab> <20120718124539.GC25563@hmsreliant.think-freely.org> <5006C679.2040605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44913 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab2GRPOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 11:14:49 -0400
In-Reply-To: <5006C679.2040605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 7:21 AM, John Fastabend wrote:
> On 7/18/2012 5:45 AM, Neil Horman wrote:
>> On Tue, Jul 17, 2012 at 05:33:16PM -0700, John Fastabend wrote:
>>> When the netprio cgroup is built in the kernel cgroup_init will call
>>> cgrp_create which eventually calls update_netdev_tables. This is
>>> being called before do_initcalls() so a null ptr dereference occurs
>>> on init_net.
>>>
>>> This patch adds a check on init_net.count to verify the structure
>>> has been initialized. The failure was introduced here,
>>>
>>> commit ef209f15980360f6945873df3cd710c5f62f2a3e
>>> Author: Gao feng <gaofeng@cn.fujitsu.com>
>>> Date:   Wed Jul 11 21:50:15 2012 +0000
>>>
>>>      net: cgroup: fix access the unallocated memory in netprio cgroup
>>>
>>> Tested with ping with netprio_cgroup as a module and built in.
>>>
>>> Marked RFC for now I think DaveM might have a reason why this needs
>>> some improvement.
>>>
>>> Reported-by: Mark Rustad <mark.d.rustad@intel.com>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Cc: Eric Dumazet <edumazet@google.com>
>>> Cc: Gao feng <gaofeng@cn.fujitsu.com>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>>
>>>   net/core/netprio_cgroup.c |    3 +++
>>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
>>> index b2e9caa..e9fd7fd 100644
>>> --- a/net/core/netprio_cgroup.c
>>> +++ b/net/core/netprio_cgroup.c
>>> @@ -116,6 +116,9 @@ static int update_netdev_tables(void)
>>>       u32 max_len;
>>>       struct netprio_map *map;
>>>
>>> +    if (!atomic_read(&init_net.count))
>>> +        return ret;
>>> +
>>>       rtnl_lock();
>>>       max_len = atomic_read(&max_prioidx) + 1;
>>>       for_each_netdev(&init_net, dev) {
>>>
>>>
>>
>> John, do you have a stack trace of this.  I'm having a hard time
>> seeing how we
>> get into this path prior to the network stack being initalized.
>
> Mark had a partial trace
>
> [    0.003455] Dentry cache hash table entries: 262144 (order: 9,
> 2097152 bytes)
> [    0.005550] Inode-cache hash table entries: 131072 (order: 8, 1048576
> bytes)
> [    0.007165] Mount-cache hash table entries: 256
> [    0.010289] Initializing cgroup subsys net_cls
> [    0.010947] Initializing cgroup subsys net_prio
> [    0.011039] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000828
> [    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
>
>
>>
>> It also brings up another point.  If this is happening, and we're
>> creating the
>> root cgroup from start_kernel, Then we're actually initalizing some
>> cgroups
>> twice, because a few cgroups register themselves via
>> cgroup_load_subsys in
>> module_init specified routines.  So if you're building netprio_cgroup or
>> net_cls_cgroup as part of the monolithic kernel, you'll get
>> cgroup_create called
>> prior to your module_init() call.  Thats not good.
>
> Well your module_init() wouldn't be called in this case right? I think
> netprio has a bug where we only register a netdevice notifier when
> its built as a module.
>
> same issue with cls_cgroup and register_tcf_proto_ops?
>

Neil, I was very unclear in the above. What I meant here was
cgroup_load_subsys() checks ss->module so you should _not_
get two create calls. And returns 0 so the register calls for
netdev notifiers should get setup.

I missed the return 0 part and so I thought we might abort before
this occurs but it looks ok to me on second glance.
