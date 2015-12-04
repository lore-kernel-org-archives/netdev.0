From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 12:43:47 -0800
Message-ID: <CALx6S35Jyb_cmG-bBjWRPAV_g4V7yudFi_zoMgg8QtoZ_tqdPQ@mail.gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
	<CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
	<1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
	<1449260785.11089.458370265.3954BCFA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37172 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbbLDUns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 15:43:48 -0500
Received: by igcto18 with SMTP id to18so44673221igc.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 12:43:48 -0800 (PST)
In-Reply-To: <1449260785.11089.458370265.3954BCFA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 12:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Dave,
>
> On Fri, Dec 4, 2015, at 21:06, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 04 Dec 2015 20:59:05 +0100
>>
>> > Yes, I agree, I am totally with you here. If generic offloading can be
>> > realized by NICs I am totally with you that this should be the way to
>> > go. I don't see that coming in the next (small number of) years, so I
>> > don't see a reason to stop this patchset.
>>
>> If I just apply this and say "yeah ok", the message is completely lost
>> and your prediction about "small number of years" indeed will occur.
>>
>> However if I push back hard on this, as I will, then the message has
>> some chance of seeping back to the people designing these chips.
>>
>> So that's what I'm going to do, like it or not.
>>
>> Or can someone convince me that someone who understand this stuff
>> is telling the hardware guys to universally put 2's complement
>> checksums into the descriptors?
>>
>> Who is doing that at each and every prominent ethernet hardware
>> verndor?
>>
>> Who?
>>
>> If I get silence, or some vague non-specific response, then I'm going
>> to hold my ground and keep pushing back on this stuff.
>
> This is not only about 1's checksumming but also about TSO (and to some
> smaller degree about RSS, as I tried to explain): if we attach a geneve
> header in front of a skb we expect the hardware to recognize it and
> duplicate it while doing the hardware segmentation. The hardware can
> only do so if it is in knowledge of the specific port (in this case UDP
> port used for geneve) which is in use for this particular tunneling
> transport protocol. We currently cannot describe this in a generic way,
> thus this patchset. (Please correct me if I am wrong!)
>
Yes, you are wrong. Port numbers are not used in transmit path to
signal offload. To perform TSO on UDP encapsulated packets the skb is
marked with SKB_GSO_UDP_TUNNEL or SKB_GSO_UDP_TUNNEL_CSUM and
SKB_GSO_TCP, etc. The driver can use information along with the
offsets of the inner and outer headers in the packet to set up the
operation in the device.  Some devices only support TSO for VXLAN, but
regardless SKB_GSO_UDP_TUNNEL is generic for all known UDP
encapsulations. Protocol specific offload is not needed. Please start
looking at http://people.netfilter.org/pablo/netdev0.1/papers/UDP-Encapsulation-in-Linux.pdf
and the kernel code to see how things _actually_ work.

> The other way to do it would probably be to enlarge the skb and push the
> structure of the packet into it, so hardware has more semantic knowledge
> about the frames structure. I guess(!!!) DPDK does it like that?
>
> If it would only be about checksuming I probably would agree.
>
> Bye,
> Hannes
