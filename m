From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 18:30:58 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C197F1@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <578D0244.7010707@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"tj@kernel.org" <tj@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <578D0244.7010707@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> 
> Hi Kan,
> 
> On 07/18/2016 08:55 AM, kan.liang@intel.com wrote:
> > From: Kan Liang <kan.liang@intel.com>
> >
> > It is a big challenge to get good network performance. First, the
> > network performance is not good with default system settings. Second,
> > it is too difficult to do automatic tuning for all possible workloads,
> > since workloads have different requirements. Some workloads may want
> > high throughput. Some may need low latency. Last but not least, there are
> lots of manual configurations.
> > Fine grained configuration is too difficult for users.
> >
> > NET policy intends to simplify the network configuration and get a
> > good network performance according to the hints(policy) which is
> > applied by user. It provides some typical "policies" for user which
> > can be set per-socket, per-task or per-device. The kernel will
> > automatically figures out how to merge different requests to get good
> network performance.
> > Net policy is designed for multiqueue network devices. This
> > implementation is only for Intel NICs using i40e driver. But the
> > concepts and generic code should apply to other multiqueue NICs too.
> > Net policy is also a combination of generic policy manager code and
> > some ethtool callbacks (per queue coalesce setting, flow
> > classification rules) to configure the driver.
> > This series also supports CPU hotplug and device hotplug.
> >
> > Here are some key Interfaces/APIs for NET policy.
> >
> >     /proc/net/netpolicy/$DEV/policy
> >     User can set/get per device policy from /proc
> >
> >     /proc/$PID/net_policy
> >     User can set/get per task policy from /proc
> >     prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL)
> >     An alternative way to set/get per task policy is from prctl.
> >
> >     setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
> >     User can set/get per socket policy by setsockopt
> >
> >
> >     int (*ndo_netpolicy_init)(struct net_device *dev,
> >                               struct netpolicy_info *info);
> >     Initialize device driver for NET policy
> >
> >     int (*ndo_get_irq_info)(struct net_device *dev,
> >                             struct netpolicy_dev_info *info);
> >     Collect device irq information
> >
> >     int (*ndo_set_net_policy)(struct net_device *dev,
> >                               enum netpolicy_name name);
> >     Configure device according to policy name
> >
> >     netpolicy_register(struct netpolicy_reg *reg);
> >     netpolicy_unregister(struct netpolicy_reg *reg);
> >     NET policy API to register/unregister per task/socket net policy.
> >     For each task/socket, an record will be created and inserted into an RCU
> >     hash table.
> >
> >     netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
> >     NET policy API to find the proper queue for packet receiving and
> >     transmitting.
> >
> >     netpolicy_set_rules(struct netpolicy_reg *reg, u32 queue_index,
> >                          struct netpolicy_flow_spec *flow);
> >     NET policy API to add flow director rules.
> >
> > For using NET policy, the per-device policy must be set in advance. It
> > will automatically configure the system and re-organize the resource
> > of the system accordingly. For system configuration, in this series,
> > it will disable irq balance, set device queue irq affinity, and modify
> > interrupt moderation. For re-organizing the resource, current
> > implementation forces that CPU and queue irq are 1:1 mapping. An 1:1
> mapping group is also called net policy object.
> > For each device policy, it maintains a policy list. Once the device
> > policy is applied, the objects will be insert and tracked in that
> > device policy list. The policy list only be updated when cpu/device
> > hotplug, queue number changes or device policy changes.
> > The user can use /proc, prctl and setsockopt to set per-task and
> > per-socket net policy. Once the policy is set, an related record will
> > be inserted into RCU hash table. The record includes ptr, policy and
> > net policy object. The ptr is the pointer address of task/socket. The
> > object will not be assigned until the first package receive/transmit.
> > The object is picked by round-robin from object list. Once the object
> > is determined, the following packets will be set to redirect to the
> queue(object).
> > The object can be shared. The per-task or per-socket policy can be
> inherited.
> >
> > Now NET policy supports four per device policies and three per
> > task/socket policies.
> >      - BULK policy: This policy is designed for high throughput. It can be
> >        applied to either per device policy or per task/socket policy.
> >      - CPU policy: This policy is designed for high throughput but lower CPU
> >        utilization. It can be applied to either per device policy or
> >        per task/socket policy.
> >      - LATENCY policy: This policy is designed for low latency. It can be
> >        applied to either per device policy or per task/socket policy.
> >      - MIX policy: This policy can only be applied to per device policy. This
> >        is designed for the case which miscellaneous types of workload running
> >        on the device.
> 
> I'm missing a bit of discussion on the existing facilities there are under
> networking and why they cannot be adapted to support these kind of hints?
>

Currently, I use existing ethtool interfaces to configure the device.
There could be more later.
 
> On a higher level picture, why for example, a new cgroup in combination
> with tc shouldn't be the ones resolving these policies on resource usage?
>

The NET policy doesn't support cgroup yet, but it's on my todo list.
The granularity for the device resource is per queue. The packet will be
redirected to the specific queue.
I'm not sure if cgroup with tc can do that.

 
> If sockets want to provide specific hints that may or may not be granted, then
> this could be via SO_MARK, maybe SO_PRIORITY with above semantics or
> some new marker perhaps that can be accessed from lower layers.
>
 
I think SO_MARK tries to filter the packet for connections.
We need an interface to filter the packet per device queue.
There is no such options as far as I know.

Thanks,
Kan
