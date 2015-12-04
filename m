From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 10:28:32 -0800
Message-ID: <CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<20151129.222138.1582847465760563254.davem@davemloft.net>
	<CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
	<CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
	<CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
	<CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
	<20151201154445.GF29497@tuxdriver.com>
	<1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
	<CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
	<1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
	<CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
	<1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35550 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbbLDS2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:28:33 -0500
Received: by igl9 with SMTP id 9so38597687igl.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 10:28:32 -0800 (PST)
In-Reply-To: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I do know that, but fact is, the current drivers do it. I am concerned
> about the amount of entropy in one single 16 bit field used to
> distinguish flows. Flow labels fine and good, but if current hardware
> does not support it, it does not help. Imagine containers with lots of
> applications, 16 bit doesn't seem to fit here.
>
Based on what? RSS indirection table is only seven bits so even 16
bits would be overkill for that. Please provide a concrete example,
data where 16 bits wouldn't be sufficient.

>> > Please provide a sketch up for a protocol generic api that can tell
>> > hardware where a inner protocol header starts that supports vxlan,
>> > vxlan-gpe, geneve and ipv6 extension headers and knows which protocol is
>> > starting at that point.
>> >
>> BPF. Implementing protocol generic offloads are not just a HW concern
>> either, adding kernel GRO code for every possible protocol that comes
>> along doesn't scale well. This becomes especially obvious when we
>> consider how to provide offloads for applications protocols. If the
>> kernel provides a programmable framework for the offloads then
>> application protocols, such as QUIC, could use use that without
>> needing to hack the kernel to support the specific protocol (which no
>> one wants!). Application protocol parsing in KCM and some other use
>> cases of BPF have already foreshadowed this, and we are working on a
>> prototype for a BPF programmable engine in the kernel. Presumably,
>> this same model could eventually be applied as the HW API to
>> programmable offload.
>
> So your proposal is like this:
>
> dev->ops->ndo_add_offload(struct net_device *, struct bpf_prog *) ?
>
> What do network cards do when they don't support bpf in hardware as
> currently all cards. Should they do program equivalence testing on the
> bpf program to check if it conforms some of its offload capabilities and
> activate those for the port they parsed out of the bpf program? I don't
> really care about more function pointers in struct net_device_ops
> because it really doesn't matter but what really concerns me is the huge
> size of the drivers in the kernel. Just tell the driver specifically
> what is wanted and let them do that. Don't force them to do program
> inspection or anything.
>
Nobody is forcing anyone to do anything. If someone implements generic
offload like this it's treated just like any other optional feature of
a NIC.

> About your argument regarding GRO for every possible protocol:
>
> Adding GRO for QUIC or SPUD transparently does not work as it breaks the
> semantics of UDP. UDP is a framed protocol not a streamed one so it does
> not make sense to add that. You can implement GRO for fragmented UDP,
> though. The length of the packet is end-to-end information. If you add a
> new protocol with a new socket type, sure you can add GRO engine
> transparently for that but not simply peeking data inside UDP if you
> don't know how the local application uses this data. In case of
> forwarding you can never do that, it will break the internet actually.
> In case you are the end host GRO engine can ask the socket what type it
> is or what framing inside UDP is used. Thus this cannot work on hardware
> either.
>
This is not correct, We already have many instances of GRO being used
over UDP in several UDP encapsulations, there is no issue with
breaking UDP semantics. QUIC is a stream based transport like TCP so
it will fit into the model (granted the fact that this incoming from
userspace and the per packet security will make it little more
challenging to implement offload). I don't know if this is needed, but
I can only assume that server performance in QUIC must be miserable if
all the I/O is 1350 bytes.

> I am not very happy with the use cases of BPF outside of tracing and
> cls_bpf and packet steering.
>
> Please don't propose that we should use BPF as the API for HW
> programmable offloading currently. It does not make sense.
>
If you have an alternative, please propose it now.

> Bye,
> Hannes
