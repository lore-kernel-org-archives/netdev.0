From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 07 Dec 2015 23:33:48 -0800
Message-ID: <566687DC.7040805@gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>	<20151129.222138.1582847465760563254.davem@davemloft.net>	<CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>	<CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>	<CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>	<CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>	<20151201154445.GF29497@tuxdriver.com>	<1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>	<CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>	<1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>	<CALx6S34Zqn1t4RP
 kAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>	<565F8059.3010101@gmail.com> <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35998 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227AbbLHHeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 02:34:08 -0500
Received: by pacdm15 with SMTP id dm15so7886099pac.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 23:34:07 -0800 (PST)
In-Reply-To: <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-02 04:15 PM, Tom Herbert wrote:
> On Wed, Dec 2, 2015 at 3:35 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>> [...]
>>
>>>>
>>>> I wonder why we need protocol generic offloads? I know there are
>>>> currently a lot of overlay encapsulation protocols. Are there many more
>>>> coming?
>>>>
>>> Yes, and assume that there are more coming with an unbounded limit
>>> (for instance I just noticed today that there is a netdev1.1 talk on
>>> supporting GTP in the kernel). Besides, this problem space not just
>>> limited to offload of encapsulation protocols, but how to generalize
>>> offload of any transport, IPv[46], application protocols, protocol
>>> implemented in user space, security protocols, etc.
>>>
>>>> Besides, this offload is about TSO and RSS and they do need to parse the
>>>> packet to get the information where the inner header starts. It is not
>>>> only about checksum offloading.
>>>>
>>> RSS does not require the device to parse the inner header. All the UDP
>>> encapsulations protocols being defined set the source port to entropy
>>> flow value and most devices already support RSS+UDP (just needs to be
>>> enabled) so this works just fine with dumb NICs. In fact, this is one
>>> of the main motivations of encapsulating UDP in the first place, to
>>> leverage existing RSS and ECMP mechanisms. The more general solution
>>> is to use IPv6 flow label (RFC6438). We need HW support to include the
>>> flow label into the hash for ECMP and RSS, but once we have that much
>>> of the motivation for using UDP goes away and we can get back to just
>>> doing GRE/IP, IPIP, MPLS/IP, etc. (hence eliminate overhead and
>>> complexity of UDP encap).
>>>
>>>> Please provide a sketch up for a protocol generic api that can tell
>>>> hardware where a inner protocol header starts that supports vxlan,
>>>> vxlan-gpe, geneve and ipv6 extension headers and knows which protocol is
>>>> starting at that point.
>>>>
>>> BPF. Implementing protocol generic offloads are not just a HW concern
>>> either, adding kernel GRO code for every possible protocol that comes
>>> along doesn't scale well. This becomes especially obvious when we
>>> consider how to provide offloads for applications protocols. If the
>>> kernel provides a programmable framework for the offloads then
>>> application protocols, such as QUIC, could use use that without
>>> needing to hack the kernel to support the specific protocol (which no
>>> one wants!). Application protocol parsing in KCM and some other use
>>> cases of BPF have already foreshadowed this, and we are working on a
>>> prototype for a BPF programmable engine in the kernel. Presumably,
>>> this same model could eventually be applied as the HW API to
>>> programmable offload.
>>
>> Just keying off the last statement there...
>>
>> I think BPF programs are going to be hard to translate into hardware
>> for most devices. The problem is the BPF programs in general lack
>> structure. A parse graph would be much more friendly for hardware or
>> at minimum the BPF program would need to be a some sort of
>> well-structured program so a driver could turn that into a parse graph.
>>
> This might be relevant:
> http://richard.systems/research/pdf/IEEE_HPSR_BPF_OPENFLOW.pdf
> 

Thanks Tom interesting read but they seem to argue for a BPF engine in
hardware which I'm still not convinced is necessary and the numbers
provided are for a 1Gbps link where 10Gpbs/100Gbps+ would be more
valuable.

I am still leaning towards a fully programmable parse graph and a set
of basic actions push/pop/set/fwd/etc. This would be useful for other
features not just checksum offloads. I guess it doesn't necessarily
exclude also having 1s complement logic though.

.John
