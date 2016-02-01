From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC net-next 0/9] TC filter HW offloads
Date: Mon, 01 Feb 2016 12:14:04 -0800
Message-ID: <56AFBC8C.5070205@gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me> <56AF23A0.70703@gmail.com> <56af6cff.46bb1c0a.fb9dd.04f2@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36361 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbcBAUOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 15:14:20 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so87345562pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 12:14:20 -0800 (PST)
In-Reply-To: <56af6cff.46bb1c0a.fb9dd.04f2@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 06:37 AM, Amir Vadai wrote:
> On Mon, Feb 01, 2016 at 01:21:36AM -0800, John Fastabend wrote:
>> On 16-02-01 12:34 AM, Amir Vadai wrote:
>>> Hi,
>>>
>>> So... just before sending that, I noted Jonh's series that
>>> deals with tc and u32. One notable difference between the 
>>> two approaches is that here we "normalize" the upper layer
>>> way of describing matching and actions into a generic structure
>>> (flow dissector, etc), which should allow to use offload different
>>> potential consumer tools (TC flower, TC u32 subset), netfilter, etc).
>>
>> Except its not really normalizing anything in this patchset
>> right? For a "real" normalizing I would expect the netdev
>> needs to advertise its parse graph and headers in a protocol
>> oblivious way, along with the table setup and this middle
>> layer needs to map the general software side onto the hardware
>> side. I tried this and I came to the conclusion I would just
>> push rules down at the hardware at least for now until I get
>> enough hardware implementations to see if there really is any
>> advantage in this sort of generic middle layer. My main concern
>> is its slow and table layout, hardware architecture both try
>> to fight you when doing this. It can be done I'm just not sure
>> its worth it yet.
> What I was trying to do, is to find an extensible api to describe the
> rules. And yes, like in your design, the device doesn't advertise its
> capabilities, only if it is capable to do any offloading. The consumer
> pushes the rules and the device return success/fail.
> 
> Using u32 filter is nice since it is a very universal classifier (and
> you did implement parsing it in a very elegant way), but I'm not sure I
> like having in device drivers a specific code for different filters. So,
> if another consumer, for example the flower filter or netfilter, would
> want to use this api, it will need to speak the u32 language, or have
> its own implementation in the device driver?
> 

At the moment it seems easier to write an implementation for each
case. Sure I can write flower filters in u32 language but I can
just as easily build a flower jump table.

To do the general abstract solution right I think you need to read
the parse graph from the hardware and identify the nodes where the
keys match up and pass those down using a general flow API something
with a signature like

  flow_add(unsigned node_ids[], u8 keys[], u8 values[], u8 masks[];

I was sort of taking the lazy approach and planning to wait and see
what falls out and how other driver writers implement this and then
consolidate if needed later. At least I get the concrete cases covered
while the abstraction is cleaned up.

FWIW I think the implementation in ixgbe_model.h can be made to work
with flower fairly easily with some decorating of the flower enums onto
the u32 language.

>>
>> Also just as an aside flower can be emulated with u32 which can
>> be emulated with bpf, I don't think the structures here are
>> generic.
> This is why I used flow dissector - because it is a very abstract way to
> pass the classifications.
> If it is not flexible enough, maybe splitting the current flow
> dissector code, into (1) a generic api to describe structures in an
> abstract way (the offsets, bitmap, and structs), and (2) the code that
> is used to dissect skb's. This way we could express stuff using (1) that
> is not related to (2).

hmm for long term I think this is great but I wouldn't want to tie
this to closely to implementation in my series today. I think they
can evolve independently for the time being.

> 
>>
>>> Another difference is with this series uses the switchdev
>>> framework which would allow using the proposed HW offloading
>>> mechanisms for physical and SRIOV embedded switches too that
>>> make use of switchdev.
>>
>> But 'tc' infrastructure is useful even without SRIOV or any
>> switching at all. I don't think it needs to go into switchdev.
>> Even my vanilla 10G nic can drop/mark pkts coming onto the
>> physical functions.
> ok, we could work it out - as you suggested in a similar way fdb_add is
> doing.

I think I'll work this out now and send it out.

[...]

>>> The flow dissector and the serialized actions are passed using switchdev ops to
>>> the HW driver, which parse it to hardware commands. We propose to use the
>>> kernel flow-dissector to describe flows/ACLs in the switchdev framework which
>>> by itself could be also used for HW offloading of other kernel networking
>>> components.
>>
>> I'm not sure I like this or at least I don't want to make this the
>> exclusive mechanism. I think bpf/u32 are more flexible. In general
>> I'm opposed to getting stuck talking about specific protocols I want
>> this to be flexible so I don't need a new thing everytime folks add
>> a new header/bit/field/etc. If you use flow-dissector to describe
>> flows your limiting the hardware. Also I'm sure I'll want to match on
>> fields that flow-dissector doesn't care about and really never should
>> care about think HTTP for example.
> I agree that we need a flexible way to express the classifiers. I'm not
> sure that I see it as a problem to have the api extended over the years,
> as long as it is designed to be extensible.
> What you actually suggest is to use u32 as such an api, or make lower
> layer driver support multiple api's.
> I will try to see how does the code looks if using the u32 api from the
> flower filter.

same comment as above I'm leaning towards multiple apis at the moment
and consolidating as we go forward. The nice piece is none of this is
UAPI visible so we can rework it as needed.


Thanks,
John
