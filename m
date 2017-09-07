From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH v3 0/6] Configuring traffic classes
 via new hardware offload mechanism in tc/mqprio
Date: Thu, 7 Sep 2017 10:22:50 -0700
Message-ID: <bd18cda5-4827-2246-f736-630527a9fcbc@intel.com>
References: <150478158684.24662.17975701233699487888.stgit@anamdev.jf.intel.com>
 <a37ba2ca-145a-0228-961d-c805434e7d40@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32956 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752784AbdIGRZy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 13:25:54 -0400
In-Reply-To: <a37ba2ca-145a-0228-961d-c805434e7d40@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/2017 9:45 AM, Shannon Nelson wrote:
> On 9/7/2017 4:00 AM, Amritha Nambiar wrote:
>> The following series introduces a new hardware offload mode in
>> tc/mqprio where the TCs, the queue configurations and
>> bandwidth rate limits are offloaded to the hardware. The existing
>> mqprio framework is extended to configure the queue counts and
>> layout and also added support for rate limiting. This is achieved
>> through new netlink attributes for the 'mode' option which takes
>> values such as 'dcb' (default) and 'channel' and a 'shaper' option
>> for QoS attributes such as bandwidth rate limits in hw mode 1.
>> Legacy devices can fall back to the existing setup supporting hw mode
>> 1 without these additional options where only the TCs are offloaded
>> and then the 'mode' and 'shaper' options defaults to DCB support.
>> The i40e driver enables the new mqprio hardware offload mechanism
>> factoring the TCs, queue configuration and bandwidth rates by
>> creating HW channel VSIs.
>>
>> In this new mode, the priority to traffic class mapping and the
>> user specified queue ranges are used to configure the traffic
>> class when the 'mode' option is set to 'channel'. This is achieved by
>> creating HW channels(VSI). A new channel is created for each of the
>> traffic class configuration offloaded via mqprio framework except for
>> the first TC (TC0) which is for the main VSI. TC0 for the main VSI is
>> also reconfigured as per user provided queue parameters. Finally,
>> bandwidth rate limits are set on these traffic classes through the
>> shaper attribute by sending these rates in addition to the number of
>> TCs and the queue configurations.
>>
>> Example:
>>      # tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
>>        queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
>>        min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit
>>
>>      To dump the bandwidth rates:
>>
>>      # tc qdisc show dev eth0
>>
>>      qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>>                   queues:(0:3) (4:7)
>>                   mode:channel
>>                   shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gbit
>>
>> ---
>>
>> Amritha Nambiar (6):
>>        mqprio: Introduce new hardware offload mode and shaper in mqprio
>>        i40e: Add macro for PF reset bit
>>        i40e: Add infrastructure for queue channel support
>>        i40e: Enable 'channel' mode in mqprio for TC configs
>>        i40e: Refactor VF BW rate limiting
>>        i40e: Add support setting TC max bandwidth rates
>>
> 
> It would be nice to know what has changed since the last review, either 
> summarized here or in the individual patch files.  This helps in knowing 
> how much attention should be given to this new set of patches, and 
> encourages further review.  I don't remember seeing any responses to my 
> previous comments, and it looks like not all of them were acted upon.

For all those patch files that have changed since the last revision, I
have captured all the new changes in the section titled "v3: " of each
patch file. Also, I had replied to most of your comments that they'll be
fixed in v3 and the one in the mqprio patch that error handling was
already being done and these responses can be verified in patchwork. I
missed to respond to your comment regarding supporting macvlan offloads
through these channels, that will not be a part of this series and will
be looked upon at a later time in a subsequent patch series.

> 
> sln
> 
>>
>>   drivers/net/ethernet/intel/i40e/i40e.h             |   44 +
>>   drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    3
>>   drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    8
>>   drivers/net/ethernet/intel/i40e/i40e_main.c        | 1463 +++++++++++++++++---
>>   drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    2
>>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   50 -
>>   include/net/pkt_cls.h                              |    9
>>   include/uapi/linux/pkt_sched.h                     |   32
>>   net/sched/sch_mqprio.c                             |  183 ++-
>>   9 files changed, 1551 insertions(+), 243 deletions(-)
>>
>> --
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@osuosl.org
>> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>>
