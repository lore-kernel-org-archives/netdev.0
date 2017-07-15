From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH 1/6] [next-queue]net: mqprio: Introduce new hardware
 offload mode in mqprio for offloading full TC configurations
Date: Fri, 14 Jul 2017 19:00:51 -0700
Message-ID: <a6da0912-2182-8c85-6e94-44b6b790ce47@intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
 <149976831535.2896.16233967758531918702.stgit@anamdev.jf.intel.com>
 <d88ee2ba-ff7b-74dd-3b0b-9887fd7d1de9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Patil, Kiran" <kiran.patil@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "Parikh, Neerav" <neerav.parikh@intel.com>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8323 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751092AbdGOCAw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 22:00:52 -0400
In-Reply-To: <d88ee2ba-ff7b-74dd-3b0b-9887fd7d1de9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/2017 1:36 AM, Jamal Hadi Salim wrote:
> On 17-07-11 06:18 AM, Amritha Nambiar wrote:
>> This patch introduces a new hardware offload mode in mqprio
>> which makes full use of the mqprio options, the TCs, the
>> queue configurations and the bandwidth rates for the TCs.
>> This is achieved by setting the value 2 for the "hw" option.
>> This new offload mode supports new attributes for traffic
>> class such as minimum and maximum values for bandwidth rate limits.
>>
>> Introduces a new datastructure 'tc_mqprio_qopt_offload' for offloading
>> mqprio queue options and use this to be shared between the kernel and
>> device driver. This contains a copy of the exisiting datastructure
>> for mqprio queue options. This new datastructure can be extended when
>> adding new attributes for traffic class such as bandwidth rate limits. The
>> existing datastructure for mqprio queue options will be shared between the
>> kernel and userspace.
>>
>> This patch enables configuring additional attributes associated
>> with a traffic class such as minimum and maximum bandwidth
>> rates and can be offloaded to the hardware in the new offload mode.
>> The min and max limits for bandwidth rates are provided
>> by the user along with the the TCs and the queue configurations
>> when creating the mqprio qdisc.
>>
>> Example:
>> # tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
>>     queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
>>
> I know this has nothing to do with your patches - but that is very
> unfriendly ;-> Most mortals will have a problem with the map (but you
> can argue it has been there since prio qdisc was introduced) - leave
> alone the 4@4 syntax and now min_rate where i have to type in obvious
> defaults like "0Mbit".

The min_rate and max_rate are optional attributes for the traffic class 
and it is
not mandatory to have both. It is also possible to have either one of 
them, say,
devices that do not support setting min rate need to specify only
the max rate and need not type in the default 0Mbit. My bad, I should 
probably
have given a better example.

# tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
    queues 4@0 4@4 max_rate 55Mbit 60Mbit hw 2


> You have some great features that not many people can use as a result.
> Note:
> This is just a comment maybe someone can be kind enough to fix (or
> it would get annoying enough I will fix it); i.e should not be
> holding your good work.
>
>> To dump the bandwidth rates:
>>
>> # tc qdisc show dev eth0
>>
>> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>>                queues:(0:3) (4:7)
>>                min rates:0bit 0bit
>>                max rates:55Mbit 60Mbit
>>
>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
>> ---
>>    include/linux/netdevice.h      |    2
>>    include/net/pkt_cls.h          |    7 ++
>>    include/uapi/linux/pkt_sched.h |   13 +++
>>    net/sched/sch_mqprio.c         |  170 +++++++++++++++++++++++++++++++++++++---
>>    4 files changed, 181 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index e48ee2e..12c6c3f 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -779,6 +779,7 @@ enum {
>>    	TC_SETUP_CLSFLOWER,
>>    	TC_SETUP_MATCHALL,
>>    	TC_SETUP_CLSBPF,
>> +	TC_SETUP_MQPRIO_EXT,
>>    };
>>
>>    struct tc_cls_u32_offload;
>> @@ -791,6 +792,7 @@ struct tc_to_netdev {
>>    		struct tc_cls_matchall_offload *cls_mall;
>>    		struct tc_cls_bpf_offload *cls_bpf;
>>    		struct tc_mqprio_qopt *mqprio;
>> +		struct tc_mqprio_qopt_offload *mqprio_qopt;
>>    	};
>>    	bool egress_dev;
>>    };
>
>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>> index 537d0a0..9facda2 100644
>> --- a/include/net/pkt_cls.h
>> +++ b/include/net/pkt_cls.h
>> @@ -569,6 +569,13 @@ struct tc_cls_bpf_offload {
>>    	u32 gen_flags;
>>    };
>>    
>> +struct tc_mqprio_qopt_offload {
>> +	/* struct tc_mqprio_qopt must always be the first element */
>> +	struct tc_mqprio_qopt qopt;
>> +	u32 flags;
>> +	u64 min_rate[TC_QOPT_MAX_QUEUE];
>> +	u64 max_rate[TC_QOPT_MAX_QUEUE];
>> +};
>>
> Quickly scanned code.
> My opinion is: struct tc_mqprio_qopt is messed up in terms of
> alignments. And you just made it worse. Why not create a new struct
> call it "tc_mqprio_qopt_hw" or something indicating it is for hw
> offload. You can then fixup stuff. I think it will depend on whether
> you can have both hw priority and rate in all network cards.
> If some hw cannot support rate offload then I would suggest it becomes
> optional via TLVs etc.
> If you are willing to do that clean up I can say more.

The existing struct tc_mqprio_qopt does have alignment issues, but is 
shared with
the userspace. The new struct tc_mqprio_qopt_offload is shared with the 
device
driver. This contains a copy of the existing tc_mqprio_qopt for mqprio queue
options for legacy users. The rates are optional attributes obtained as 
TLVs from
the userspace via additional netlink attributes. This would be clear 
from the
corresponding iproute2 RFC patch I submitted.
([PATCH RFC, iproute2] tc/mqprio: Add support to configure bandwidth 
rate limit through mqprio).

>
>>    /* This structure holds cookie structure that is passed from user
>>     * to the kernel for actions and classifiers
>> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>> index 099bf55..cf2a146 100644
>> --- a/include/uapi/linux/pkt_sched.h
>> +++ b/include/uapi/linux/pkt_sched.h
>> @@ -620,6 +620,7 @@ struct tc_drr_stats {
>>    enum {
>>    	TC_MQPRIO_HW_OFFLOAD_NONE,	/* no offload requested */
>>    	TC_MQPRIO_HW_OFFLOAD_TCS,	/* offload TCs, no queue counts */
>> +	TC_MQPRIO_HW_OFFLOAD,		/* fully supported offload */
>>    	__TC_MQPRIO_HW_OFFLOAD_MAX
>>    };
>>    
>> @@ -633,6 +634,18 @@ struct tc_mqprio_qopt {
>>    	__u16	offset[TC_QOPT_MAX_QUEUE];
>>    };
>>    
>> +#define TC_MQPRIO_F_MIN_RATE  0x1
>> +#define TC_MQPRIO_F_MAX_RATE  0x2
>> +
>> +enum {
>> +	TCA_MQPRIO_UNSPEC,
>> +	TCA_MQPRIO_MIN_RATE64,
>> +	TCA_MQPRIO_MAX_RATE64,
>> +	__TCA_MQPRIO_MAX,
>> +};
>> +
>> +#define TCA_MQPRIO_MAX (__TCA_MQPRIO_MAX - 1)
>> +
>>    /* SFB */
>>    
>>    enum {
>> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
>> index e0c0272..6524d12 100644
>> --- a/net/sched/sch_mqprio.c
>> +++ b/net/sched/sch_mqprio.c
>> @@ -18,10 +18,13 @@
>>    #include <net/netlink.h>
>>    #include <net/pkt_sched.h>
>>    #include <net/sch_generic.h>
>> +#include <net/pkt_cls.h>
>>    
>>    struct mqprio_sched {
>>    	struct Qdisc		**qdiscs;
>>    	int hw_offload;
>> +	u32 flags;
>> +	u64 min_rate[TC_QOPT_MAX_QUEUE], max_rate[TC_QOPT_MAX_QUEUE];
>>    };
> You have to change this before Jiri sees it ;->

I had to store the rates here since tc_mqprio_qopt_offload:offload is only a
temporary variable and I need to retrieve these rates so they can be 
reported
when someone attempts to display the current qdisc configuration using the
dump command. The rates here are obtained from the optional netlink 
attributes.
Did you mean I should have retrieved these rates by querying the device 
instead
of storing them here? I think that would require extending struct 
net_device for
the rates.

>
>
> I will review more later.
>
> cheers,
> jamal
