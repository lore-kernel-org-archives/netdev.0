From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [RFC PATCH 30/30] Documentation/networking: Document net policy
Date: Mon, 18 Jul 2016 09:58:59 -0700
Message-ID: <e1cb122a-2982-cfcd-7c26-39429993bf5b@infradead.org>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <1468824984-65318-31-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51653 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbcGRRAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:00:07 -0400
In-Reply-To: <1468824984-65318-31-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/16 23:56, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
> 
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  Documentation/networking/netpolicy.txt | 158 +++++++++++++++++++++++++++++++++
>  1 file changed, 158 insertions(+)
>  create mode 100644 Documentation/networking/netpolicy.txt
> 
> diff --git a/Documentation/networking/netpolicy.txt b/Documentation/networking/netpolicy.txt
> new file mode 100644
> index 0000000..2ce938e
> --- /dev/null
> +++ b/Documentation/networking/netpolicy.txt
> @@ -0,0 +1,158 @@
> +What is Linux Net Policy?
> +
> +It is a big challenge to get good network performance. First, the network
> +performance is not good with default system settings. Second, it is too
> +difficult to do automatic tuning for all possible workloads, since workloads
> +have different requirements. Some workloads may want high throughput. Some may
> +need low latency. Last but not least, there are lots of manual configurations.
> +Fine grained configuration is too difficult for users.
> +
> +"NET policy" intends to simplify the network configuration and get a
> +good network performance according to the hints(policy) which is applied by
> +user. It provides some typical "policies" for user which can be set
> +per-socket, per-task or per-device. The kernel will automatically figures out

                                      drop:       will

> +how to merge different requests to get good network performance.
> +
> +"Net policy" is designed for multiqueue network devices. This document
> +describes the concepts and APIs of "net policy" support.
> +
> +NET POLICY CONCEPTS
> +
> +Scope of Net Policies
> +
> +    Device net policy: this policy applies to the whole device. Once the
> +    device net policy is set, it automatically configures the system
> +    according to the applied policy. The configuration usually includes irq
> +    affinity, irq balance disable, interrupt moderation, and so on. But the
> +    device net policy does not change the packet direction.
> +
> +    Task net policy: this is a per-task policy. When it is applied to specific
> +    task, all packets transmissions of the task will be redirect to the

                 packet                                    redirected

> +    assigned queues accordingly. If a task does not define a task policy,
> +    it "falls back" to the system default way to direct the packets. The
> +    per-task policy must be compatible with device net policy.
> +
> +    Socket net policy: this is a per-socket policy. When it is applied to
> +    specific socket, all packets transmissions of the socket will be redirect

                            packet                                      redirected

> +    to the assigned queues accordingly. If a socket does not define a socket
> +    policy, it "falls back" to the system default way to direct the packets.
> +    The per-socket policy must be compatible with both device net policy and
> +    per-task policy.
> +
> +Components of Net Policies
> +
> +    Net policy object: it is a combination of cpu and queue. The queue irq has
> +    to set affinity with the cpu. It can be shared between sockets and tasks.
> +    A reference counter is used to track the sharing number.

I would prefer to see CPU instead of cpu and IRQ instead of irq throughout the file.

> +
> +    Net policy object list: each device policy has an object list. Once the
> +    device policy is determined, the net policy object will be inserted into
> +    the net policy object list. The net policy object list does not change
> +    unless the cpu/queue number is changed, the netpolicy is disabled or
> +    the device policy is changed.
> +    The network performance for objects could be different because of the
> +    queue/cpu topology and dev location. The objects which can bring high
> +    performance are in the front of the list.
> +
> +    RCU hash table: a RCU hash table to maintain the relationship between

                       an RCU

> +    the task/socket and the assigned object. The task/socket can get the
> +    assigned object by searching the table.
> +    If it is the first time, there is no assigned object in the table. It will
> +    go through the object list to find the available object based on position
> +    and reference number.
> +    If the net policy object list changes, all the assigned object will become

                                                               objects

> +    invalid.
> +
> +NET POLICY APIs
> +
> +Interfaces between net policy and device driver
> +
> +    int (*ndo_netpolicy_init)(struct net_device *dev,
> +                              struct netpolicy_info *info);
> +
> +    The device driver who has NET policy support must implement this interface.
> +    In this interface, the device driver do necessory initialization, and fill

                                            does necessary

> +    the info for net policy module. The information could inlcude supported

                                                             include

> +    policy, MIX policy support, queue pair support and so on.
> +
> +    int (*ndo_get_irq_info)(struct net_device *dev,
> +                            struct netpolicy_dev_info *info);
> +
> +    This interface is used to get more accurate device irq information.
> +
> +    int (*ndo_set_net_policy)(struct net_device *dev,
> +                              enum netpolicy_name name);
> +
> +    This interface is used to set device net policy by name

                                                          name.

> +
> +Interfaces between net policy and kernel
> +
> +    int netpolicy_register(struct netpolicy_reg *reg);
> +    void netpolicy_unregister(struct netpolicy_reg *reg);
> +
> +    This interface is used to register per task/socket net policy.
> +    If it's the first time to register, an record will be created and inserted

                                           a record

> +    into RCU hash table. The record includes ptr, policy and object
> +    information. There is only one user for each record. The record cannot be
> +    share.

       shared.

> +
> +
> +    int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
> +
> +    This interface is used to find the proper queue(object) for packet
> +    receiving and transmitting. The proper queue is picked from object list
> +    according to policy, reference, location and so on.
> +
> +
> +    int netpolicy_set_rules(struct netpolicy_reg *reg,
> +                            u32 queue_index,
> +                            struct netpolicy_flow_spec *flow);
> +
> +    This interface is used to add device specific rules. Once the rule is
> +    applied, the packet from specific IP and port will be redirect to the

                                                             redirected

> +    given queue. This interface usually be used in receive side.

                                   is usually used on the receive side.

> +
> +NET POLICY INTERFACE
> +
> +Device net policy setting
> +
> +    /proc/net/netpolicy/$DEV/policy
> +
> +    Concatenating(cat) the "policy" file can show the available device
> +    policies, if there is no device policy applied. Otherwise, the device
> +    policy name will be print out. If it is MIX policy, the policy for each

                           printed

> +    queue will also be print out.

                          printed

> +    User can set device net policy by writing policy name.
> +
> +Task policy setting
> +
> +    /proc/$PID/net_policy
> +
> +    Concatenating(cat) the "net_policy" file can show the applied per task
> +    policy.
> +    User can set per task net policy by writing policy name.
> +
> +    OR
> +
> +    prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL)
> +
> +    "prctl" is an alternative way to set/get per task policy.
> +
> +Socket policy setting
> +
> +    setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
> +
> +    The socket net policy can be set by option SO_NETPOLICY of setsockopt

                                                                  setsockopt.

> +
> +AVAILABLE NET POLICIES
> +
> +    The available net policies are defined as below:
> +    - CPU: intends to get higher throughput and lower CPU%. This policy can be
> +           applied as either device net policy or task/socket net policy.
> +    - BULK: intends to get highest throughput. This policy can be applied as
> +            either device net policy or task/socket net policy.
> +    - LATENCY: intends to get lowest latency. This policy can be applied as
> +               either device net policy or task/socket net policy.
> +    - MIX: combination of other policies, which allows each queue has

                                                                     to have a

> +           different policy. This policy can only be set as device net policy.
> +
> 


-- 
~Randy
