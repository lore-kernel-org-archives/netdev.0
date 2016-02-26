From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/3] net: sched: cls_u32 add bit to specify
 software only rules
Date: Thu, 25 Feb 2016 23:21:31 -0800
Message-ID: <56CFFCFB.4060508@gmail.com>
References: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810> <20160225232045.9820.6694.stgit@john-Precision-Tower-5810> <56CFF89E.8070602@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	jiri@resnulli.us, daniel@iogearbox.net, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34817 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbcBZHVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 02:21:46 -0500
Received: by mail-pa0-f45.google.com with SMTP id ho8so47918910pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 23:21:46 -0800 (PST)
In-Reply-To: <56CFF89E.8070602@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 11:02 PM, Samudrala, Sridhar wrote:
> On 2/25/2016 3:20 PM, John Fastabend wrote:
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
> 
> I think this is supposed to be a new sentence starting with 'On deletion'

Yep.

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

[...]

>> u32_policy[TCA_U32_MAX + 1] = {
>>       [TCA_U32_SEL]        = { .len = sizeof(struct tc_u32_sel) },
>>       [TCA_U32_INDEV]        = { .type = NLA_STRING, .len = IFNAMSIZ },
>>       [TCA_U32_MARK]        = { .len = sizeof(struct tc_u32_mark) },
>> +    [TCA_U32_FLAGS]        = { .len = NLA_U32 },
> should be  .type = NLA_U32
> 

Yep stupid typo. I think I'm going to write some smatch files to
catch these sorts of things they should be detectable pragmatically.

Thanks.

>> <snip>
> 
