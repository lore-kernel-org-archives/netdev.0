From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Tue, 23 Feb 2016 15:30:08 -0800
Message-ID: <56CCEB80.3030803@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190321.5970.58924.stgit@john-Precision-Tower-5810> <56CCDD5C.2040000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	jiri@resnulli.us, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33612 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbcBWXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 18:30:26 -0500
Received: by mail-pa0-f41.google.com with SMTP id fl4so1012706pad.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 15:30:26 -0800 (PST)
In-Reply-To: <56CCDD5C.2040000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 02:29 PM, Samudrala, Sridhar wrote:
> 
> 
> On 2/23/2016 11:03 AM, John Fastabend wrote:
>> In the initial implementation the only way to stop a rule from being
>> inserted into the hardware table was via the device feature flag.
>> However this doesn't work well when working on an end host system
>> where packets are expect to hit both the hardware and software
>> datapaths.
>>
>> For example we can imagine a rule that will match an IP address and
>> increment a field. If we install this rule in both hardware and
>> software we may increment the field twice. To date we have only
>> added support for the drop action so we have been able to ignore
>> these cases. But as we extend the action support we will hit this
>> example plus more such cases. Arguably these are not even corner
>> cases in many working systems these cases will be common.
> Is there a usecase to support running the same rule in both hardware as
> well
> as software? If a rule is offloaded to hardware,  isn't the assumption that
> we don't need to do that in software.

The default behaviour today is to load a rule into both software
and opportunistically hardware. This is the same model as many of
the other hardware offloads. This way user space doesn't have to
be concerned if it is running on hardware that supports the offload
or not.

If software is a bit "smarter" it can load software only rules and
hardware only rules. This allows the logic to decide if a rule is
"safe" to offload to be less restrictive because we avoid the
class of examples noted in the commit msg.

>>
>> To avoid forcing the driver to always abort (i.e. the above example)
>> this patch adds a flag to add a rule in software only. A careful
>> user can use this flag to build software and hardware datapaths
>> that work together. One example we have found particularly useful
>> is to use hardware resources to set the skb->mark on the skb when
>> the match may be expensive to run in software but a mark lookup
>> in a hash table is cheap. The idea here is hardware can do in one
>> lookup what the u32 classifier may need to traverse multiple lists
>> and hash tables to compute. The flag is only passed down on inserts
>> on deletion to avoid stale references in hardware we always try
>> to remove a rule if it exists.
>>
>> Notice we do not add a hardware only case here. If you were to
>> add a hardware only case then you are stuck with the problem
>> of where to stick the software representation of that filter
>> rule. If its stuck on the same filter list as the software only and
>> software/hardware rules it then has to be walked over and ignored
>> in the classify path. The overhead is not huge but is measurable.
>> And with so much work being invested in speeding up rx/tx of
>> pkt processing this is unacceptable IMO. The other option is to
>> have a special hook just for hardware only resources. This is
>> implemented in the next patch.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   include/uapi/linux/pkt_cls.h |    3 +++
>>   net/sched/cls_u32.c          |   43
>> ++++++++++++++++++++++++++++++------------
>>   2 files changed, 34 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>> index 4398737..143ea21 100644
>> --- a/include/uapi/linux/pkt_cls.h
>> +++ b/include/uapi/linux/pkt_cls.h
>> @@ -160,6 +160,8 @@ enum {
>>   #define TC_U32_UNSPEC    0
>>   #define TC_U32_ROOT    (0xFFF00000)
>>   +#define TCA_U32_FLAGS_SOFTWARE 1
> Does this flag indicate software-only rule?
> Instead should we add a flag to indicate HW only.
>

Yes software only rule. As I said in the commit log having
a HW only flag has issues with how to represent it in software
in such a way that software performance is not impacted. The
next patch in this series provides this functionality.

.John
