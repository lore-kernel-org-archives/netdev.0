From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [RFC PATCH v3 0/6] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Thu, 7 Sep 2017 13:09:27 -0700
Message-ID: <14376038-c365-9637-3517-aae8e99a4883@intel.com>
References: <150478158684.24662.17975701233699487888.stgit@anamdev.jf.intel.com>
 <3ecacf3d-1f02-fbc6-0e90-8e84dcd15a4e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:51808 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932378AbdIGUJo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 16:09:44 -0400
In-Reply-To: <3ecacf3d-1f02-fbc6-0e90-8e84dcd15a4e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/2017 11:34 AM, Florian Fainelli wrote:
> On 09/07/2017 04:00 AM, Amritha Nambiar wrote:
>> The following series introduces a new hardware offload mode in 
>> tc/mqprio where the TCs, the queue configurations and bandwidth 
>> rate limits are offloaded to the hardware. The existing mqprio 
>> framework is extended to configure the queue counts and layout and
>>  also added support for rate limiting. This is achieved through new
>>  netlink attributes for the 'mode' option which takes values such
>> as 'dcb' (default) and 'channel' and a 'shaper' option for QoS 
>> attributes such as bandwidth rate limits in hw mode 1.
> 
> So "dcb" defines a default priorities to queue mapping?

In the default offload implementation, only the basic hw offload was
supported factoring only the 'number of TCs' values. The rest of the
queue configuration was being ignored. This is the legacy behavior with
hw mode set to 1.
Example:
# tc qdisc add dev eth0 root mqprio num_tc 4  map 0 0 0 0 1 1 1 1 queues
4@0 4@4 hw 1
I just named this default behavior to 'dcb' while introducing a new
offload mechanism.

> 
>> Legacy devices can fall back to the existing setup supporting hw 
>> mode 1 without these additional options where only the TCs are 
>> offloaded and then the 'mode' and 'shaper' options defaults to DCB
>>  support.
> 
> That's the last part that confuses me, see below.

As I introduced new options for 'mode' and 'shaper', I set the defaults
for these options to 'dcb' so existing offloaders can continue to work
without supporting these new options. Patch 1 has a detailed description
on how this is done.

> 
>> The i40e driver enables the new mqprio hardware offload mechanism 
>> factoring the TCs, queue configuration and bandwidth rates by 
>> creating HW channel VSIs.
> 
> I am really confused by what you call hw_mode 1, as I understand it 
> there are really 3 different modes:

There are actually 2 modes now with 'hw' option set to 1, legacy/dcb and
channel.
> 
> - legacy: you don't define any traffic class mapping, but you can 
> still chain this scheduler with a match + action (like what 
> Documentation/networking/multiqueue.txt) you can optionally also add 
> "shaper" arguments, but there should not be any default DCB queue 
> mapping either?
> 
> - dcb: a default mapping for traffic classes to queues is defined, 
> optional "shaper" arguments

The legacy mode now becomes the dcb mode. In this mode, although the TC
values, the queue configurations, prio-tc-mapping are all offloaded to
the device, the existing implementation in current drivers support only
a basic hw offload factoring only the TC values.

Examples:
# ... num_tc 2  map 0 0 0 0 1 1 1 1 queues 4@0 4@4 hw 1
# ... num_tc 2  map 0 0 0 0 1 1 1 1 queues 4@0 4@4 hw 1 mode dcb
# ... num_tc 2  map 0 0 0 0 1 1 1 1 queues 4@0 4@4 hw 1 mode dcb\
  shaper dcb

> 
> - channel: (maybe calling that "custom_tc_map" would be clearer?) 
> where you express the exact traffic classes to queue mapping and 
> optional "shaper" arguments

In the channel mode, a full hw offload is supported, the TC values, the
queue configurations and additionally QoS attributes (optional) are all
used in the new implementation.

Examples:
# ... num_tc 2  map 0 0 0 0 1 1 1 1 queues 4@0 4@4 hw 1 mode channel
# ... num_tc 2  map 0 0 0 0 1 1 1 1 queues 4@0 4@4 hw 1 mode channel\
shaper bw_rlimit max_rate 4Gbit 5Gbit

> 
> I think that's what you are doing, but I just got confused by the 
> cover letter.
> 
>> 
>> In this new mode, the priority to traffic class mapping and the 
>> user specified queue ranges are used to configure the traffic class
>> when the 'mode' option is set to 'channel'. This is achieved by
>> creating HW channels(VSI). A new channel is created for each of the
>> traffic class configuration offloaded via mqprio framework except
>> for the first TC (TC0) which is for the main VSI. TC0 for the main
>> VSI is also reconfigured as per user provided queue parameters.
>> Finally, bandwidth rate limits are set on these traffic classes
>> through the shaper attribute by sending these rates in addition to
>> the number of TCs and the queue configurations.
>> 
>> Example: # tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1
>> 1 1 1\ queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
> 
> Do you see a case where you can declare a different number of
> traffic classes say 4 and map them onto just 2 hardware queues? If
> not, it seems a tiny bit redundant to have to specify both the map
> and the queue mapping should be sufficient, right?

This will be subjected to validation of the user input and will be
treated as invalid configuration. The 'map' specifies the mapping
between user priorities and traffic classes while the queue mapping is
the queue layout specifying the queue count and offsets.

> 
>> min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit
>> 
>> To dump the bandwidth rates:
>> 
>> # tc qdisc show dev eth0
>> 
>> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 
>> queues:(0:3) (4:7) mode:channel shaper:bw_rlimit   min_rate:1Gbit 
>> 2Gbit   max_rate:4Gbit 5Gbit
> 
> I am not well versed into tc, but being able to specify "shaper" 
> arguments has actually value outside of just the multiq scheduler and
> it could probably be an action on its own?

The mqprio scheduler already supports configuring the traffic classes
and enabling support for HW shapers was just a matter to extending it
with new netlink based attributes.

> 
>> 
>> ---
>> 
>> Amritha Nambiar (6): mqprio: Introduce new hardware offload mode 
>> and shaper in mqprio i40e: Add macro for PF reset bit i40e: Add 
>> infrastructure for queue channel support i40e: Enable 'channel' 
>> mode in mqprio for TC configs i40e: Refactor VF BW rate limiting 
>> i40e: Add support setting TC max bandwidth rates
>> 
>> 
>> drivers/net/ethernet/intel/i40e/i40e.h             |   44 + 
>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3 
>> drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8 
>> drivers/net/ethernet/intel/i40e/i40e_main.c        | 1463 
>> +++++++++++++++++--- drivers/net/ethernet/intel/i40e/i40e_txrx.h | 
>> 2 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   50 - 
>> include/net/pkt_cls.h                              |    9 
>> include/uapi/linux/pkt_sched.h                     |   32 
>> net/sched/sch_mqprio.c                             |  183 ++- 9 
>> files changed, 1551 insertions(+), 243 deletions(-)
>> 
>> --
>> 
> 
> 
