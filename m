From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/3] net: sched: cls_u32 add bit to specify
 software only rules
Date: Fri, 26 Feb 2016 06:29:33 -0800
Message-ID: <56D0614D.4030607@gmail.com>
References: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810> <20160225232045.9820.6694.stgit@john-Precision-Tower-5810> <20160226102952.GB2158@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, simon.horman@netronome.com,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34178 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbcBZO3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 09:29:48 -0500
Received: by mail-pf0-f178.google.com with SMTP id x65so53037821pfb.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 06:29:47 -0800 (PST)
In-Reply-To: <20160226102952.GB2158@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-26 02:29 AM, Jiri Pirko wrote:
> Fri, Feb 26, 2016 at 12:20:45AM CET, john.fastabend@gmail.com wrote:
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
>> The flags field is part of the classifier specific options. Although
>> it is tempting to lift this into the generic structure doing this
>> proves difficult do to how the tc netlink attributes are implemented
>> along with how the dump/change routines are called. There is also
>> precedence for putting seemingly generic pieces in the specific
>> classifier options such as TCA_U32_POLICE, TCA_U32_ACT, etc. So
>> although not ideal I've left FLAGS in the u32 options as well as it
>> simplifies the code greatly and user space has already learned how
>> to manage these bits ala 'tc' tool.
>>
>> Another thing if trying to update a rule we require the flags to
>> be unchanged. This is to force user space, software u32 and
>> the hardware u32 to keep in sync. Thanks to Simon Horman for
>> catching this case.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>> include/net/pkt_cls.h        |   13 +++++++++++--
>> include/uapi/linux/pkt_cls.h |    1 +
>> net/sched/cls_u32.c          |   37 +++++++++++++++++++++++++++----------
>> 3 files changed, 39 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>> index 6096e96..42dc412 100644
>> --- a/include/net/pkt_cls.h
>> +++ b/include/net/pkt_cls.h
>> @@ -392,12 +392,21 @@ struct tc_cls_u32_offload {
>> 	};
>> };
>>
>> -static inline bool tc_should_offload(struct net_device *dev)
>> +/* tca flags definitions */
>> +#define TCA_CLS_FLAGS_SOFTWARE 1
> 
> I'm sorry, the flag name is misleading to me.
> We have by default, both SW and HW.
> 
> Now this flag should say: "do not push to HW".
> 
> In future, there will be another flag saying: "do not push to SW".
> 
> So I suggest what I already suggested before:
> 
> TCA_CLS_FLAGS_SKIP_HW for this one and
> TCA_CLS_FLAGS_SKIP_KERNEL for the future one.
> 
> Sounds sane?
> 

Sounds reasonable I'll change it in the next revision.
