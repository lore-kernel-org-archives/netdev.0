From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC net-next 0/9] TC filter HW offloads
Date: Mon, 1 Feb 2016 11:59:39 -0800
Message-ID: <CALx6S34r1odpdjiskenY4aYWkb9-SDXpqrx5MyNtt3OtugkYPw@mail.gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
	<56AF23A0.70703@gmail.com>
	<56af6cff.46bb1c0a.fb9dd.04f2@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36128 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbcBAT7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 14:59:40 -0500
Received: by mail-io0-f176.google.com with SMTP id g73so171429789ioe.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 11:59:40 -0800 (PST)
In-Reply-To: <56af6cff.46bb1c0a.fb9dd.04f2@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2016 at 6:37 AM, Amir Vadai <amir@vadai.me> wrote:
> On Mon, Feb 01, 2016 at 01:21:36AM -0800, John Fastabend wrote:
>> On 16-02-01 12:34 AM, Amir Vadai wrote:
>> > Hi,
>> >
>> > So... just before sending that, I noted Jonh's series that
>> > deals with tc and u32. One notable difference between the
>> > two approaches is that here we "normalize" the upper layer
>> > way of describing matching and actions into a generic structure
>> > (flow dissector, etc), which should allow to use offload different
>> > potential consumer tools (TC flower, TC u32 subset), netfilter, etc).
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
>
Flow dissector structure is not meant to be a generic interface and it
is limited in that regard. For instance, it can only give one set of
IP addresses in a flow when an encapsulation is being done so there
are multiple addresses. This is why we are interested in something
like BPF for programming HW which can describe arbitrary packet
formats as opposed to other structure based interfaces that restrict
expressibility.

Also, the code dealing with flow_dissector is pretty verbose and isn't
driver specific I would think. Might be better get some of that into a
common library.

Tom

>>
>> > Another difference is with this series uses the switchdev
>> > framework which would allow using the proposed HW offloading
>> > mechanisms for physical and SRIOV embedded switches too that
>> > make use of switchdev.
>>
>> But 'tc' infrastructure is useful even without SRIOV or any
>> switching at all. I don't think it needs to go into switchdev.
>> Even my vanilla 10G nic can drop/mark pkts coming onto the
>> physical functions.
> ok, we could work it out - as you suggested in a similar way fdb_add is
> doing.
>
>>
>> >
>> > This patchset introduces an infrastructure to offload matching of flows and
>> > some basic actions to hardware, currenrtly using iproute2 / tc tool.
>> >
>> > In this patchset, the classification is described using the flower filter, and
>> > the supported actions are drop (using gact) and mark (using skbedit).
>> >
>>
>> ditto I just didn't show the mark patch set on my side. I also would
>> like to get pedit shortly.
>>
>> > Flow classifcation is described using a flow dissector that is built by
>> > the tc filter. The filter also calls the actions to be serialized into the new
>> > structure - switchdev_obj_port_flow_act.
>> >
>> > The flow dissector and the serialized actions are passed using switchdev ops to
>> > the HW driver, which parse it to hardware commands. We propose to use the
>> > kernel flow-dissector to describe flows/ACLs in the switchdev framework which
>> > by itself could be also used for HW offloading of other kernel networking
>> > components.
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
>
>>
>> >
>> > An implementation for the above is provided using mlx5 driver and Mellanox
>> > ConnectX4 HW.
>> >
>> > Some issues that will be addressed before making the final submission:
>> > 1. 'offload' should be a generic filter attribute and not flower filter
>> >    specific.
>>
>> I'm not sure its worth normalizing now. See how I created a code and
>> set of structures for each filter. Maybe some helper libraries would
>> be in order.
>>
>> > 2. Serialization of actions will be changed into a list instead of one big
>> >    structure to describe all actions.
>> >
>> > Few more matters to discuss
>> >
>> > 1. Should HW offloading be done only under explicit admin directive?
>>
>> I took the approach of having one big bit I set per netdev to turn it
>> on and off. Then I have a flag similar to your patch on cls_flower to
>> turn it on/off per rule if I care to. I didn't send the per rule patch
>> because I view it as an optimization.
>>
>> But the case where it matters is mark on a NIC where you don't really
>> need/want to match the same packet twice and mark it again. For a switch
>> it may not matter because the host bound traffic is the exception not
>> the rule.
> Yeh, if the cpu gets the packet, there is no need to process the
> filter again in software.
>
>>
>> >
>> > 2. switchdev is used today for physical switch HW and on an upcoming proposal
>> > for SRIOV e-switch vport representors too. Here, we're doing that with a NIC,
>> > that can potentially serve as an uplink port for v-switch (e.g under Para-Virtual
>> > scheme).
>>
>> Sure but remember where switchdev may be relevant for SRIOV loading
>> 'tc' like rules into a NIC doesn't mean you need/want/care/support
>> SRIOV. So I don't think we should use switchdev or at least I don't
>> think it should be required. A bunch of helper functions for switches
>> may be useful in switchdev.
> ack
>
>>
>> .John
>>
>>
