From: kan.liang@intel.com
Subject: [RFC V2 PATCH 00/25] Kernel NET policy
Date: Thu,  4 Aug 2016 15:36:04 -0400
Message-ID: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
Cc: mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

(re-send to correct system time issue. Sorry for any inconvenience.)
It is a big challenge to get good network performance. First, the network
performance is not good with default system settings. Second, it is too
difficult to do automatic tuning for all possible workloads, since workloads
have different requirements. Some workloads may want high throughput. Some may
need low latency. Last but not least, there are lots of manual configurations.
Fine grained configuration is too difficult for users.

NET policy intends to simplify the network configuration and get a good network
performance according to the hints(policy) which is applied by user. It
provides some typical "policies" for user which can be set per-socket, per-task
or per-device. The kernel will automatically figures out how to merge different
requests to get good network performance.

NET policy is designed for multiqueue network devices. This implementation is
only for Intel NICs using i40e driver. But the concepts and generic code should
apply to other multiqueue NICs too.

NET policy is also a combination of generic policy manager code and some
ethtool callbacks (per queue coalesce setting, flow classification rules) to
configure the driver.

This series also supports CPU hotplug and device hotplug.

Here are some common questions about NET policy.
 1. Why userspace tool cannot do the same thing?
    A: Kernel is more suitable for NET policy.
       - User space code would be far more complicated to get right and perform
         well . It always need to work with out of date state compared to the
         latest, because it cannot do any locking with the kernel state.
       - User space code is less efficient than kernel code, because of the
         additional context switches needed.
       - Kernel is in the right position to coordinate requests from multiple
         users.

 2. Is NET policy looking for optimal settings?
    A: No. The NET policy intends to get a good network performance according
       to user's specific request. Our target for good performance is ~90% of
       the optimal settings.

 3. How's the configuration impact the connection rates?
    A: There are two places to acquire rtnl mutex to configure the device.
       - One is to do device policy setting. It happens on initalization stage,
         hotplug or queue number changes. The device policy will be set to
         NET_POLICY_NONE. If so, it "falls back" to the system default way to
         direct the packets. It doesn't block the connection.
       - The other is to set Rx network flow classification options or rules.
         It uses work queue to do asynchronized setting. It avoid destroying
         the connection rates.

 4. Why not using existing mechanism for NET policy?
    For example, cgroup tc or existing SOCKET options.
    A: The NET policy has already used existing mechanism as many as it can.
       For example, it uses existing ethtool interface to configure the device.
       However, the NET policy stiil need to introduce new interfaces to meet
       its special request.
       For resource usage, current cgroup tc is not suitable for per-socket
       setting. Also, current tc can only set rate limit. The NET policy wants
       to change interrupt moderation per device queue. So in this series, it
       will not use cgroup tc. But in some places, cgroup and NET policy are
       similar. For example, both of them isolates the resource usage. Both of
       them do traffic controller. So it is on the NET policy TODO list to
       work well with cgroup.
       For socket options, SO_MARK or may be SO_PRIORITY is close to NET policy's
       requirement. But they can not be reused for NET policy. SO_MARK can be
       used for routing and packet filtering. But the NET policy doesn't intend to
       change the routing. It only redirects the packet to the specific device
       queue. Also, the target queue is assigned by NET policy subsystem at run
       time. It should not be set in advance. SO_PRIORITY can set protocol-defined
       priority for all packets on the socket. But the policies don't have priority.

 5. Why disable IRQ balance?
    A: Disabling IRQ balance is a common way (recommend way for some devices) to
       tune network performance.


Here are some key Interfaces/APIs for NET policy.

Interfaces which export to user space

   /proc/net/netpolicy/$DEV/policy
   User can set/get per device policy from /proc

   /proc/$PID/net_policy
   User can set/get per task policy from /proc
   prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL)
   An alternative way to set/get per task policy is from prctl.

   setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
   User can set/get per socket policy by setsockopt

New ndo opt

   int (*ndo_netpolicy_init)(struct net_device *dev,
                             struct netpolicy_info *info);
   Initialize device driver for NET policy

   int (*ndo_get_irq_info)(struct net_device *dev,
                           struct netpolicy_dev_info *info);
   Collect device information. Currently, only collecting IRQ
   informance should be enough.

   int (*ndo_set_net_policy)(struct net_device *dev,
                             enum netpolicy_name name);
   This interface is used to set device NET policy by name. It is device driver's
   responsibility to set driver specific configuration for the given policy.

NET policy subsystem APIs

   netpolicy_register(struct netpolicy_instance *instance,
                      enum netpolicy_name policy)
   netpolicy_unregister(struct netpolicy_instance *instance)
   Register/unregister per task/socket NET policy.
   The socket/task can only be benefited when it register itself with
   specific policy. After registeration, an record will be created and inserted
   into a RCU hash table, which include all the NET policy related information
   for the socket/task.

   netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx);
   Find the proper queue according to policy for packet receiving and
   transmitting

   netpolicy_set_rules(struct netpolicy_instance *instance);
   Configure Rx network flow classification rules

For using NET policy, the per-device policy must be set in advance. It will
automatically configure the system and re-organize the resource of the system
accordingly. For system configuration, in this series, it will disable irq
balance, set device queue irq affinity, and modify interrupt moderation. For
re-organizing the resource, current implementation forces that CPU and queue
irq are 1:1 mapping. An 1:1 mapping group is also called NET policy object.
For each device policy, it maintains a policy list. Once the device policy is
applied, the objects will be insert and tracked in that device policy list. The
policy list only be updated when CPU/device hotplug, queue number changes or
device policy changes.
The user can use /proc, prctl and setsockopt to set per-task and per-socket
NET policy. Once the policy is set, an related record will be inserted into RCU
hash table. The record includes ptr, policy and NET policy object. The ptr is
the pointer address of task/socket. The object will not be assigned until the
first package receive/transmit. The object is picked by round-robin from object
list. Once the object is determined, the following packets will be set to
redirect to the queue(object).
The object can be shared. The per-task or per-socket policy can be inherited.

Now NET policy supports four per device policies and three per task/socket
policies.
    - BULK policy: This policy is designed for high throughput. It can be
      applied to either per device policy or per task/socket policy.
    - CPU policy: This policy is designed for high throughput but lower CPU
      utilization (power saving). It can be applied to either per device policy
      or per task/socket policy.
    - LATENCY policy: This policy is designed for low latency. It can be
      applied to either per device policy or per task/socket policy.
    - MIX policy: This policy can only be applied to per device policy. This
      is designed for the case which miscellaneous types of workload running
      on the device.

Lots of tests are done for NET policy on platforms with Intel Xeon E5 V2
and XL710 40G NIC. The baseline test is with Linux 4.6.0 kernel.
Netperf is used to evaluate the throughput and latency performance.
  - "netperf -f m -t TCP_RR -H server_IP -c -C -l 60 -- -r buffersize
    -b burst -D" is used to evaluate throughput performance, which is
    called throughput-first workload.
  - "netperf -t TCP_RR -H server_IP -c -C -l 60 -- -r buffersize" is
    used to evaluate latency performance, which is called latency-first
    workload.
  - Different loads are also evaluated by running 1, 12, 24, 48 or 96
    throughput-first workloads/latency-first workload simultaneously.

For "BULK" policy, the throughput performance is on average ~1.27X than
baseline.
For "CPU" policy, the throughput performance is on average ~1.25X than
baseline, and has lower CPU% (on average ~5% lower than "BULK" policy).
For "LATENCY" policy, the latency is on average 51.5% less than the baseline.
For "MIX" policy, mixed workloads performance is evaluated.
The mixed workloads are combination of throughput-first workload and
latency-first workload. Five different types of combinations are evaluated
(pure throughput-first workload, pure latency-first workloads,
 2/3 throughput-first workload + 1/3 latency-first workloads,
 1/3 throughput-first workload + 2/3 latency-first workloads and
 1/2 throughput-first workload + 1/2 latency-first workloads).
For caculating the performance of mixed workloads, a weighted sum system
is introduced.
Score = normalized_latency * Weight + normalized_throughput * (1 - Weight).
If we assume that the user has an equal interest in latency and throughput
performance, the Score for "MIX" policy is on average ~1.83X than baseline.


Changes since V1:
 - Using work queue to set Rx network flow classification rules and search
   available NET policy object asynchronously.
 - Using RCU lock to replace read-write lock
 - Redo performance test and update performance results.
 - Some minor modification for codes and documents.
 - Remove i40e related patches which will be submitted in separate thread.

Kan Liang (25):
  net: introduce NET policy
  net/netpolicy: init NET policy
  net/netpolicy: get device queue irq information
  net/netpolicy: get CPU information
  net/netpolicy: create CPU and queue mapping
  net/netpolicy: set and remove IRQ affinity
  net/netpolicy: enable and disable NET policy
  net/netpolicy: introduce NET policy object
  net/netpolicy: set NET policy by policy name
  net/netpolicy: add three new NET policies
  net/netpolicy: add MIX policy
  net/netpolicy: NET device hotplug
  net/netpolicy: support CPU hotplug
  net/netpolicy: handle channel changes
  net/netpolicy: implement netpolicy register
  net/netpolicy: introduce per socket netpolicy
  net/netpolicy: introduce netpolicy_pick_queue
  net/netpolicy: set tx queues according to policy
  net/netpolicy: set Rx queues according to policy
  net/netpolicy: introduce per task net policy
  net/netpolicy: set per task policy by proc
  net/netpolicy: fast path for finding the queues
  net/netpolicy: optimize for queue pair
  net/netpolicy: limit the total record number
  Documentation/networking: Document NET policy

 Documentation/networking/netpolicy.txt |  157 ++++
 arch/alpha/include/uapi/asm/socket.h   |    2 +
 arch/avr32/include/uapi/asm/socket.h   |    2 +
 arch/frv/include/uapi/asm/socket.h     |    2 +
 arch/ia64/include/uapi/asm/socket.h    |    2 +
 arch/m32r/include/uapi/asm/socket.h    |    2 +
 arch/mips/include/uapi/asm/socket.h    |    2 +
 arch/mn10300/include/uapi/asm/socket.h |    2 +
 arch/parisc/include/uapi/asm/socket.h  |    2 +
 arch/powerpc/include/uapi/asm/socket.h |    2 +
 arch/s390/include/uapi/asm/socket.h    |    2 +
 arch/sparc/include/uapi/asm/socket.h   |    2 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 fs/proc/base.c                         |   64 ++
 include/linux/init_task.h              |    9 +
 include/linux/netdevice.h              |   31 +
 include/linux/netpolicy.h              |  163 ++++
 include/linux/sched.h                  |    5 +
 include/net/net_namespace.h            |    3 +
 include/net/request_sock.h             |    4 +-
 include/net/sock.h                     |   28 +
 include/uapi/asm-generic/socket.h      |    2 +
 include/uapi/linux/prctl.h             |    4 +
 kernel/exit.c                          |    4 +
 kernel/fork.c                          |    6 +
 kernel/sys.c                           |   31 +
 net/Kconfig                            |    7 +
 net/core/Makefile                      |    1 +
 net/core/dev.c                         |   20 +-
 net/core/ethtool.c                     |    8 +-
 net/core/netpolicy.c                   | 1511 ++++++++++++++++++++++++++++++++
 net/core/sock.c                        |   36 +
 net/ipv4/af_inet.c                     |   71 ++
 net/ipv4/udp.c                         |    4 +
 34 files changed, 2189 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/networking/netpolicy.txt
 create mode 100644 include/linux/netpolicy.h
 create mode 100644 net/core/netpolicy.c

-- 
2.5.5
