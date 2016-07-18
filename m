From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 18:22:28 +0200
Message-ID: <578D0244.7010707@iogearbox.net>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, tj@kernel.org
To: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39717 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbcGRQWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:22:40 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kan,

On 07/18/2016 08:55 AM, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> It is a big challenge to get good network performance. First, the network
> performance is not good with default system settings. Second, it is too
> difficult to do automatic tuning for all possible workloads, since workloads
> have different requirements. Some workloads may want high throughput. Some may
> need low latency. Last but not least, there are lots of manual configurations.
> Fine grained configuration is too difficult for users.
>
> NET policy intends to simplify the network configuration and get a good network
> performance according to the hints(policy) which is applied by user. It
> provides some typical "policies" for user which can be set per-socket, per-task
> or per-device. The kernel will automatically figures out how to merge different
> requests to get good network performance.
> Net policy is designed for multiqueue network devices. This implementation is
> only for Intel NICs using i40e driver. But the concepts and generic code should
> apply to other multiqueue NICs too.
> Net policy is also a combination of generic policy manager code and some
> ethtool callbacks (per queue coalesce setting, flow classification rules) to
> configure the driver.
> This series also supports CPU hotplug and device hotplug.
>
> Here are some key Interfaces/APIs for NET policy.
>
>     /proc/net/netpolicy/$DEV/policy
>     User can set/get per device policy from /proc
>
>     /proc/$PID/net_policy
>     User can set/get per task policy from /proc
>     prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL)
>     An alternative way to set/get per task policy is from prctl.
>
>     setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
>     User can set/get per socket policy by setsockopt
>
>
>     int (*ndo_netpolicy_init)(struct net_device *dev,
>                               struct netpolicy_info *info);
>     Initialize device driver for NET policy
>
>     int (*ndo_get_irq_info)(struct net_device *dev,
>                             struct netpolicy_dev_info *info);
>     Collect device irq information
>
>     int (*ndo_set_net_policy)(struct net_device *dev,
>                               enum netpolicy_name name);
>     Configure device according to policy name
>
>     netpolicy_register(struct netpolicy_reg *reg);
>     netpolicy_unregister(struct netpolicy_reg *reg);
>     NET policy API to register/unregister per task/socket net policy.
>     For each task/socket, an record will be created and inserted into an RCU
>     hash table.
>
>     netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
>     NET policy API to find the proper queue for packet receiving and
>     transmitting.
>
>     netpolicy_set_rules(struct netpolicy_reg *reg, u32 queue_index,
>                          struct netpolicy_flow_spec *flow);
>     NET policy API to add flow director rules.
>
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
>      - BULK policy: This policy is designed for high throughput. It can be
>        applied to either per device policy or per task/socket policy.
>      - CPU policy: This policy is designed for high throughput but lower CPU
>        utilization. It can be applied to either per device policy or
>        per task/socket policy.
>      - LATENCY policy: This policy is designed for low latency. It can be
>        applied to either per device policy or per task/socket policy.
>      - MIX policy: This policy can only be applied to per device policy. This
>        is designed for the case which miscellaneous types of workload running
>        on the device.

I'm missing a bit of discussion on the existing facilities there are under
networking and why they cannot be adapted to support these kind of hints?

On a higher level picture, why for example, a new cgroup in combination with
tc shouldn't be the ones resolving these policies on resource usage?

If sockets want to provide specific hints that may or may not be granted,
then this could be via SO_MARK, maybe SO_PRIORITY with above semantics or
some new marker perhaps that can be accessed from lower layers.

> Kan Liang (30):
>    net: introduce NET policy
>    net/netpolicy: init NET policy
>    i40e/netpolicy: Implement ndo_netpolicy_init
>    net/netpolicy: get driver information
>    i40e/netpolicy: implement ndo_get_irq_info
>    net/netpolicy: get CPU information
>    net/netpolicy: create CPU and queue mapping
>    net/netpolicy: set and remove irq affinity
>    net/netpolicy: enable and disable net policy
>    net/netpolicy: introduce netpolicy object
>    net/netpolicy: set net policy by policy name
>    i40e/netpolicy: implement ndo_set_net_policy
>    i40e/netpolicy: add three new net policies
>    net/netpolicy: add MIX policy
>    i40e/netpolicy: add MIX policy support
>    net/netpolicy: net device hotplug
>    net/netpolicy: support CPU hotplug
>    net/netpolicy: handle channel changes
>    net/netpolicy: implement netpolicy register
>    net/netpolicy: introduce per socket netpolicy
>    net/policy: introduce netpolicy_pick_queue
>    net/netpolicy: set tx queues according to policy
>    i40e/ethtool: support RX_CLS_LOC_ANY
>    net/netpolicy: set rx queues according to policy
>    net/netpolicy: introduce per task net policy
>    net/netpolicy: set per task policy by proc
>    net/netpolicy: fast path for finding the queues
>    net/netpolicy: optimize for queue pair
>    net/netpolicy: limit the total record number
>    Documentation/networking: Document net policy
>
>   Documentation/networking/netpolicy.txt         |  158 +++
>   arch/alpha/include/uapi/asm/socket.h           |    2 +
>   arch/avr32/include/uapi/asm/socket.h           |    2 +
>   arch/frv/include/uapi/asm/socket.h             |    2 +
>   arch/ia64/include/uapi/asm/socket.h            |    2 +
>   arch/m32r/include/uapi/asm/socket.h            |    2 +
>   arch/mips/include/uapi/asm/socket.h            |    2 +
>   arch/mn10300/include/uapi/asm/socket.h         |    2 +
>   arch/parisc/include/uapi/asm/socket.h          |    2 +
>   arch/powerpc/include/uapi/asm/socket.h         |    2 +
>   arch/s390/include/uapi/asm/socket.h            |    2 +
>   arch/sparc/include/uapi/asm/socket.h           |    2 +
>   arch/xtensa/include/uapi/asm/socket.h          |    2 +
>   drivers/net/ethernet/intel/i40e/i40e.h         |    3 +
>   drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   44 +-
>   drivers/net/ethernet/intel/i40e/i40e_main.c    |  174 +++
>   fs/proc/base.c                                 |   64 ++
>   include/linux/init_task.h                      |   14 +
>   include/linux/netdevice.h                      |   31 +
>   include/linux/netpolicy.h                      |  160 +++
>   include/linux/sched.h                          |    5 +
>   include/net/net_namespace.h                    |    3 +
>   include/net/request_sock.h                     |    4 +-
>   include/net/sock.h                             |   10 +
>   include/uapi/asm-generic/socket.h              |    2 +
>   include/uapi/linux/prctl.h                     |    4 +
>   kernel/exit.c                                  |    4 +
>   kernel/fork.c                                  |   11 +
>   kernel/sys.c                                   |   31 +
>   net/Kconfig                                    |    7 +
>   net/core/Makefile                              |    1 +
>   net/core/dev.c                                 |   30 +-
>   net/core/ethtool.c                             |    8 +-
>   net/core/netpolicy.c                           | 1387 ++++++++++++++++++++++++
>   net/core/sock.c                                |   46 +
>   net/ipv4/af_inet.c                             |   75 ++
>   net/ipv4/udp.c                                 |    4 +
>   37 files changed, 2294 insertions(+), 10 deletions(-)
>   create mode 100644 Documentation/networking/netpolicy.txt
>   create mode 100644 include/linux/netpolicy.h
>   create mode 100644 net/core/netpolicy.c
>
