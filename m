From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Thu, 3 Dec 2015 17:35:42 +0100
Message-ID: <56606F5E.4070209@tpip.net>
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
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:40472 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbbLCQp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 11:45:26 -0500
In-Reply-To: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/03/2015 04:59 PM, Hannes Frederic Sowa wrote:
> Hi Tom,
>
> On Wed, Dec 2, 2015, at 20:15, Tom Herbert wrote:
>> On Wed, Dec 2, 2015 at 8:35 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> On Wed, Dec 2, 2015, at 04:50, Tom Herbert wrote:
>>>> That completely misses the whole point of the rest of this thread.
>>>> Protocol specific offloads are what we are trying to discourage not
>>>> encourage. Adding any more ndo functions for this purpose should be an
>>>> exception, not the norm. The bar should be naturally high considering
>>>> the cost of exposing this to ndo.
>>>
>>> Why?
>>>
>>> I wonder why we need protocol generic offloads? I know there are
>>> currently a lot of overlay encapsulation protocols. Are there many more
>>> coming?
>>>
>> Yes, and assume that there are more coming with an unbounded limit
>> (for instance I just noticed today that there is a netdev1.1 talk on
>> supporting GTP in the kernel). Besides, this problem space not just
>> limited to offload of encapsulation protocols, but how to generalize
>> offload of any transport, IPv[46], application protocols, protocol
>> implemented in user space, security protocols, etc.
>
> GTP seems to be a tunneling protocol also based on TCP, I hope the same
> standards apply to it as STT at that time (depending on the
> implementation, of course). There are some other protocols on its way, I
> see but they can just be realized as kernel modules and that's it.

GTP is UDP based. The standard permits a variable length header (one can
add extensions after a fixed header), but that is seldom (or even never)
used. Tunnel are identified by a 32bit tunnel endpoint id for GTPv1 and
a 64bit flow id for GTPv0. UDP destination ports differ for v1 and v0,
so it's easy to distinguish.

The biggest pain when implementing GTP are the path maintenance procedures.
But this really has nothing to do with offloads

Andreas

> I am also not sure I can follow, some time ago the use of TOE (TCP
> Offload Engine) were pretty much banished from entering the linux
> kernel, has this really changed? It would be needed to do hardware
> offloading of all other protocols inside TCP, no?
>
> There are really a lot of tunneling protocols nowadays.
>
>>> Besides, this offload is about TSO and RSS and they do need to parse the
>>> packet to get the information where the inner header starts. It is not
>>> only about checksum offloading.
>>>
>> RSS does not require the device to parse the inner header. All the UDP
>> encapsulations protocols being defined set the source port to entropy
>> flow value and most devices already support RSS+UDP (just needs to be
>> enabled) so this works just fine with dumb NICs. In fact, this is one
>> of the main motivations of encapsulating UDP in the first place, to
>> leverage existing RSS and ECMP mechanisms. The more general solution
>> is to use IPv6 flow label (RFC6438). We need HW support to include the
>> flow label into the hash for ECMP and RSS, but once we have that much
>> of the motivation for using UDP goes away and we can get back to just
>> doing GRE/IP, IPIP, MPLS/IP, etc. (hence eliminate overhead and
>> complexity of UDP encap).
>
> I do know that, but fact is, the current drivers do it. I am concerned
> about the amount of entropy in one single 16 bit field used to
> distinguish flows. Flow labels fine and good, but if current hardware
> does not support it, it does not help. Imagine containers with lots of
> applications, 16 bit doesn't seem to fit here.
>
>>> Please provide a sketch up for a protocol generic api that can tell
>>> hardware where a inner protocol header starts that supports vxlan,
>>> vxlan-gpe, geneve and ipv6 extension headers and knows which protocol is
>>> starting at that point.
>>>
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
> I am not very happy with the use cases of BPF outside of tracing and
> cls_bpf and packet steering.
>
> Please don't propose that we should use BPF as the API for HW
> programmable offloading currently. It does not make sense.
>
> Bye,
> Hannes
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
