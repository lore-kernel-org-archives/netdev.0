From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Fri, 06 Nov 2015 12:34:45 +0100
Message-ID: <563C9055.705@iogearbox.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>	 <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net>	 <1446723516.4184.33.camel@edumazet-glaptop2.roam.corp.google.com>	 <563B5202.1020207@iogearbox.net> <1446740279.4184.40.camel@edumazet-glaptop2.roam.corp.google.com> <563BDEA5.9080907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, tklauser@distanz.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37126 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161168AbbKFLfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 06:35:08 -0500
In-Reply-To: <563BDEA5.9080907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 11:56 PM, Daniel Borkmann wrote:
> On 11/05/2015 05:17 PM, Eric Dumazet wrote:
>> On Thu, 2015-11-05 at 13:56 +0100, Daniel Borkmann wrote:
>>> On 11/05/2015 12:38 PM, Eric Dumazet wrote:
>>
>>>> If I am not mistaken, af_packet also lacks the ability to properly set
>>>> skb->protocol
>>>>
>>>> I noticed this using trafgen on a bonding device, when I did my SYNFLOOD
>>>> tests for TCP listener rewrite.
>>>>
>>>> The bonding hash function might uses flow dissector, but as this flow
>>>> dissection depends on skb->protocol, all the traffic is directed on a
>>>> single slave.
>>>
>>> Right, if I see this correctly, when you trigger the flushing of TX_RING
>>> via sendmsg(), one can hand over a sockaddr_ll, where we infer sll_protocol
>>> and tag every skb's skb->protocol with that in tpacket_fill_skb() for the
>>> current flushing run. Otherwise, we use the po->num specified at socket
>>> creation / bind time for everything (trafgen case).
>>>
>>> If needed on a per skb basis, perhaps we could map some tpacket_hdr{,2}
>>> member that is not used from TX_RING side (perhaps union on tp_snaplen)?
>>
>> If po->num is 0 (as in trafgen case), we could also get the proto from
>> Ethernet header provided by the user.
>>
>> The skb_probe_transport_header() call from tpacket_fill_skb() is useless
>> in the current kernel.
>>
>> Let say an application wants to mix IPv6 and IPv4 packets, using a
>> single TX ring....
>
> Sorry for the late answer.
>
> For the skb->protocol issue, perhaps something like this. Also noticed that
> we should rather do the vlan check when we have the actual linear data from
> the ring slot, the current way seems buggy if I see this correctly. Both
> patches squashed below.

Hmm, I believe there's another bug in TX_RING with SOCK_DGRAM, will do some
more experiments and post some patches later on.

Best,
Daniel
