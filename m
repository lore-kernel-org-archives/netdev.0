From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 10:00:50 -0700
Message-ID: <CAKgT0UfA6ShdVta615ZqH8WvedgxSd3SjA5nZ+5EZGROWYa_sg@mail.gmail.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	keescook@chromium.org, viro@zeniv.linux.org.uk,
	gorcunov@openvz.org, john.stultz@linaro.org,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>, decot@googlers.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33178 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbcGRRAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:00:54 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 17, 2016 at 11:55 PM,  <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> It is a big challenge to get good network performance. First, the network
> performance is not good with default system settings. Second, it is too
> difficult to do automatic tuning for all possible workloads, since workloads
> have different requirements. Some workloads may want high throughput. Some may
> need low latency. Last but not least, there are lots of manual configurations.
> Fine grained configuration is too difficult for users.

The problem as I see it is that this is just going to end up likely
being an even more intrusive version of irqbalance.  I really don't
like the way that turned out as it did a number of really dumb things
that usually result in it being disabled as soon as you actually want
to do anything that will actually involve any kind of performance
tuning.  If this stuff is pushed into the kernel it will be even
harder to get rid of and that is definitely a bad thing.

> NET policy intends to simplify the network configuration and get a good network
> performance according to the hints(policy) which is applied by user. It
> provides some typical "policies" for user which can be set per-socket, per-task
> or per-device. The kernel will automatically figures out how to merge different
> requests to get good network performance.

So where is your policy for power saving?  From past experience I can
tell you that while performance tuning is a good thing, doing so at
the expense of power management is bad.  In addition you seem to be
making a lot of assumptions here that the end users are going to
rewrite their applications to use the new socket options you added in
order to try and tune the performance.  I have a hard time believing
most developers are going to go to all that trouble.  In addition I
suspect that even if they do go to that trouble they will probably
still screw it up and you will end up with applications advertising
latency as a goal when they should have specified CPU and so on.

> Net policy is designed for multiqueue network devices. This implementation is
> only for Intel NICs using i40e driver. But the concepts and generic code should
> apply to other multiqueue NICs too.

I would argue that your code is not very generic.  The fact that it is
relying on flow director already greatly limits what you can do.  If
you want to make this truly generic I would say you need to find ways
to make this work on everything all the way down to things like i40evf
and igb which don't have support for Flow Director.

> Net policy is also a combination of generic policy manager code and some
> ethtool callbacks (per queue coalesce setting, flow classification rules) to
> configure the driver.
> This series also supports CPU hotplug and device hotplug.
>
> Here are some key Interfaces/APIs for NET policy.
>
>    /proc/net/netpolicy/$DEV/policy
>    User can set/get per device policy from /proc
>
>    /proc/$PID/net_policy
>    User can set/get per task policy from /proc
>    prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL)
>    An alternative way to set/get per task policy is from prctl.
>
>    setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
>    User can set/get per socket policy by setsockopt
>
>
>    int (*ndo_netpolicy_init)(struct net_device *dev,
>                              struct netpolicy_info *info);
>    Initialize device driver for NET policy
>
>    int (*ndo_get_irq_info)(struct net_device *dev,
>                            struct netpolicy_dev_info *info);
>    Collect device irq information

Instead of making the irq info a part of the ndo ops it might make
more sense to make it part of an ethtool op.  Maybe you could make it
so that you could specify a single queue at a time and get things like
statistics, IRQ, and ring information.

>    int (*ndo_set_net_policy)(struct net_device *dev,
>                              enum netpolicy_name name);
>    Configure device according to policy name

I really don't like this piece of it.  I really think we shouldn't be
leaving so much up to the driver to determine how to handle things.
In addition just passing one of 4 different types doesn't do much for
actual configuration because the actual configuration of the device is
much more complex then that.  Essentially all this does is provide a
benchmark tuning interface.

>    netpolicy_register(struct netpolicy_reg *reg);
>    netpolicy_unregister(struct netpolicy_reg *reg);
>    NET policy API to register/unregister per task/socket net policy.
>    For each task/socket, an record will be created and inserted into an RCU
>    hash table.

This piece will take a significant amount of time before it could ever
catch on.  Once again this just looks like a benchmark tuning
interface.  It isn't of much value.

>    netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
>    NET policy API to find the proper queue for packet receiving and
>    transmitting.
>
>    netpolicy_set_rules(struct netpolicy_reg *reg, u32 queue_index,
>                         struct netpolicy_flow_spec *flow);
>    NET policy API to add flow director rules.

So Flow Director is a very Intel-centric approach.  I would suggest
taking a now at NTUPLE and RXNFC rules as that is what is actually
implemented in the kernel.  In addition I would recommend exploring
RPS and ndo_rx_flow_steer as those are existing interfaces for
configuring a specific flow to be delivered to a specific CPU.

> For using NET policy, the per-device policy must be set in advance. It will
> automatically configure the system and re-organize the resource of the system
> accordingly. For system configuration, in this series, it will disable irq
> balance, set device queue irq affinity, and modify interrupt moderation. For
> re-organizing the resource, current implementation forces that CPU and queue
> irq are 1:1 mapping. An 1:1 mapping group is also called net policy object.
> For each device policy, it maintains a policy list. Once the device policy is
> applied, the objects will be insert and tracked in that device policy list. The
> policy list only be updated when cpu/device hotplug, queue number changes or
> device policy changes.

So as a beginning step it might make more sense to try and fix
irqbalance instead of disabling it.  That is a huge red flag for me.
You are just implementing something that is more intrusive than
irqbalance and my concern here is we can't just disable it and
reconfigure things like we can with the current irqbalance.  If
irqbalance never got it right then why should we trust this?

Also how will you code handle a non 1:1 mapping.  For example I know
one thing I have been looking at trying out was implementing a setup
that would allocate 1 Tx queue per logical CPU, and 1 Rx queue per
physical CPU.  The reason for that being that from past experience on
ixgbe I have found that more Rx queues does not equal more performance
when you start stacking active queues on SMT pairs.  If you don't have
enough queues for the number of CPUs in a case such as this how would
your code handle it?

> The user can use /proc, prctl and setsockopt to set per-task and per-socket
> net policy. Once the policy is set, an related record will be inserted into RCU
> hash table. The record includes ptr, policy and net policy object. The ptr is
> the pointer address of task/socket. The object will not be assigned until the
> first package receive/transmit. The object is picked by round-robin from object
> list. Once the object is determined, the following packets will be set to
> redirect to the queue(object).
> The object can be shared. The per-task or per-socket policy can be inherited.
>
> Now NET policy supports four per device policies and three per task/socket
> policies.
>     - BULK policy: This policy is designed for high throughput. It can be
>       applied to either per device policy or per task/socket policy.
>     - CPU policy: This policy is designed for high throughput but lower CPU
>       utilization. It can be applied to either per device policy or
>       per task/socket policy.
>     - LATENCY policy: This policy is designed for low latency. It can be
>       applied to either per device policy or per task/socket policy.
>     - MIX policy: This policy can only be applied to per device policy. This
>       is designed for the case which miscellaneous types of workload running
>       on the device.

This is a rather sparse list of policies.  I know most organizations
with large data centers care about power savings AND latency.  What
you have here is a rather simplistic set of targets.  I think actual
configuration is much more complex then that.

> Lots of tests are done for net policy on platforms with Intel Xeon E5 V2
> and XL710 40G NIC. The baseline test is with Linux 4.6.0 kernel.

So I assume you are saying you applied your patches on top of a 4.6.0
kernel then for testing correct?  I'm just wanting to verify we aren't
looking 4.6.0 versus the current net-next or Linus's 4.7-RCX tree.

> Netperf is used to evaluate the throughput and latency performance.
>   - "netperf -f m -t TCP_RR -H server_IP -c -C -l 60 -- -r buffersize
>     -b burst -D" is used to evaluate throughput performance, which is
>     called throughput-first workload.

While this is okay for testing performance you might be better off
using a TCP_STREAM, TCP_MAERTS, and perhaps UDP_STREAM test.  There
aren't too many real-world applications that will give you the kind of
traffic pattern you see with TCP_RR being used for a bulk throughput
test.

>   - "netperf -t TCP_RR -H server_IP -c -C -l 60 -- -r buffersize" is
>     used to evaluate latency performance, which is called latency-first
>     workload.
>   - Different loads are also evaluated by running 1, 12, 24, 48 or 96
>     throughput-first workloads/latency-first workload simultaneously.
>
> For "BULK" policy, the throughput performance is on average ~1.26X than
> baseline.
> For "CPU" policy, the throughput performance is on average ~1.20X than
> baseline, and has lower CPU% (on average ~5% lower than "BULK" policy).
> For "LATENCY" policy, the latency is on average 53.5% less than the baseline.

I have misgivings about just throwing out random numbers with no
actual data to back it up.  What kind of throughput and CPU
utilization were you actually seeing?  The idea is that we should be
able to take your patches and apply them on our own system to see
similar values and I'm suspecting that in many cases you might be
focusing on the wrong things.  For example I could get good "LATENCY"
numbers by just disabling interrupt throttling.  That would look
really good for latency, but my CPU utilization would be through the
roof.  It might be useful if you could provide throughput, CPU
utilization, and latency numbers for your baseline versus each of
these settings.

> For "MIX" policy, mixed workloads performance is evaluated.
> The mixed workloads are combination of throughput-first workload and
> latency-first workload. Five different types of combinations are evaluated
> (pure throughput-first workload, pure latency-first workloads,
>  2/3 throughput-first workload + 1/3 latency-first workloads,
>  1/3 throughput-first workload + 2/3 latency-first workloads and
>  1/2 throughput-first workload + 1/2 latency-first workloads).
> For caculating the performance of mixed workloads, a weighted sum system
> is introduced.
> Score = normalized_latency * Weight + normalized_throughput * (1 - Weight).
> If we assume that the user has an equal interest in latency and throughput
> performance, the Score for "MIX" policy is on average ~1.52X than baseline.

This scoring system of yours makes no sense.  Just give us the numbers
on what the average latency did versus your "baseline" and the same
for the throughput.

> Kan Liang (30):
>   net: introduce NET policy
>   net/netpolicy: init NET policy
>   i40e/netpolicy: Implement ndo_netpolicy_init
>   net/netpolicy: get driver information
>   i40e/netpolicy: implement ndo_get_irq_info
>   net/netpolicy: get CPU information
>   net/netpolicy: create CPU and queue mapping
>   net/netpolicy: set and remove irq affinity
>   net/netpolicy: enable and disable net policy
>   net/netpolicy: introduce netpolicy object
>   net/netpolicy: set net policy by policy name
>   i40e/netpolicy: implement ndo_set_net_policy
>   i40e/netpolicy: add three new net policies
>   net/netpolicy: add MIX policy
>   i40e/netpolicy: add MIX policy support
>   net/netpolicy: net device hotplug
>   net/netpolicy: support CPU hotplug
>   net/netpolicy: handle channel changes
>   net/netpolicy: implement netpolicy register
>   net/netpolicy: introduce per socket netpolicy
>   net/policy: introduce netpolicy_pick_queue
>   net/netpolicy: set tx queues according to policy
>   i40e/ethtool: support RX_CLS_LOC_ANY
>   net/netpolicy: set rx queues according to policy
>   net/netpolicy: introduce per task net policy
>   net/netpolicy: set per task policy by proc
>   net/netpolicy: fast path for finding the queues
>   net/netpolicy: optimize for queue pair
>   net/netpolicy: limit the total record number
>   Documentation/networking: Document net policy

30 patches is quite a bit to review.  You might have better luck
getting review and/or feedback if you could split this up into at
least 2 patch sets of 15 or so patches when you try to actually submit
this.
