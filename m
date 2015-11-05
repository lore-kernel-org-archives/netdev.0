From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 13:56:34 +0100
Message-ID: <563B5202.1020207@iogearbox.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>	 <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net> <1446723516.4184.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, tklauser@distanz.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55231 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032442AbbKEM4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 07:56:38 -0500
In-Reply-To: <1446723516.4184.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 12:38 PM, Eric Dumazet wrote:
> On Thu, 2015-11-05 at 10:39 +0100, Daniel Borkmann wrote:
>> On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
>>> On Thursday 05 November 2015 00:04:14 David Miller wrote:
>>>> As part of fixing y2038 problems, Arnd is going to have to make a new
>>>> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
>>>> the time values to 64-bit.
>>>>
>>>> So I want everyone to think about whether there are any other changes
>>>> we might want to make given that we have to make a v4 anyways.
>>>>
>>>> Particularly, I am rather certain that the buffer management could be
>>>> improved.  Some have complained that v3 is kinda awkward to use and/or
>>>> suboptimal is various ways.
>>>
>>> I have taken a closer look at the actual timestamp data now, and noticed
>>> that we use __u32 for both tp_sec and ts_sec in the user visible data.
>>> This means that once we fix the internal implementation to use 64-bit
>>> timestamps, we actually won't overflow until 2106 because the 2038 overflow
>>> is only for signed 32-bit numbers as we have in 'struct timespec'.
>>>
>>> So the good news is that we can keep the existing v1 through v3 formats
>>> beyond 2038, but only as long as all user space that cares about the
>>> value also interprets it as unsigned.
>>
>> Right, I was just about to ask that. So we could just make a union in
>> AF_PACKET's UAPI for a single 64-bit variable (as in ktime_t) to fix that.
>
> If I am not mistaken, af_packet also lacks the ability to properly set
> skb->protocol
>
> I noticed this using trafgen on a bonding device, when I did my SYNFLOOD
> tests for TCP listener rewrite.
>
> The bonding hash function might uses flow dissector, but as this flow
> dissection depends on skb->protocol, all the traffic is directed on a
> single slave.

Right, if I see this correctly, when you trigger the flushing of TX_RING
via sendmsg(), one can hand over a sockaddr_ll, where we infer sll_protocol
and tag every skb's skb->protocol with that in tpacket_fill_skb() for the
current flushing run. Otherwise, we use the po->num specified at socket
creation / bind time for everything (trafgen case).

If needed on a per skb basis, perhaps we could map some tpacket_hdr{,2}
member that is not used from TX_RING side (perhaps union on tp_snaplen)?
