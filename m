From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: How do I receive vlan tags on an AF_PACKET socket in 3.4 kernel?
Date: Wed, 31 Jul 2013 14:54:26 +0200
Message-ID: <51F90902.3020201@redhat.com>
References: <CAMJ=MEe4cvp7-fwbCnq7SLM=44Zy8Jrz35FwRoWG-ytahdPRQA@mail.gmail.com> <1375193392.10515.28.camel@edumazet-glaptop> <CAMJ=MEdfn2uPHbNQZ1LOytOqwFTbAyV1ZtxOW8NomLCZJq+caQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab3GaMyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 08:54:32 -0400
In-Reply-To: <CAMJ=MEdfn2uPHbNQZ1LOytOqwFTbAyV1ZtxOW8NomLCZJq+caQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2013 02:51 PM, Ronny Meeus wrote:
> On Tue, Jul 30, 2013 at 4:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2013-07-30 at 15:07 +0200, Ronny Meeus wrote:
>>> Hello
>>>
>>> I have ported a legacy application that is processing several packet
>>> streams based on protocol and vlan.
>>> Internally in the application a dispatching is done based on the
>>> VLAN/Protocol field in the Ethernet packets.
>>>
>>> To receive the packets I use a AF_PACKET socket on a pure Ethernet
>>> interface (not vlan aware).
>>> A BPF filter is attached to the socket to drop packets I'm not
>>> interested in as soon as possible in the processing path.
>>>
>>> This setup worked well until I switched to a 3.4 kernel (I was using
>>> 2.6.32 before).
>>> In the 3.4 kernel I see that the vlan information is stripped from the
>>> packets I receive from the socket.
>>>
>>> After some searches on Google and browsing the Linux code I found that
>>> the Vlan is stripped from the packet very early in the receive path.
>>> This is the info of the commit:
>>>
>>> commit bcc6d47903612c3861201cc3a866fb604f26b8b2
>>> Author: Jiri Pirko <jpirko@redhat.com>
>>> Date:   Thu Apr 7 19:48:33 2011 +0000
>>>
>>>      net: vlan: make non-hw-accel rx path similar to hw-accel
>>>
>>>      Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
>>>      enabled, skb is untagged by NIC, vlan_tci is set and the skb gets into
>>>      vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>>>
>>>      For non-rx-vlan-hw-accel however, tagged skb goes thru whole
>>>      __netif_receive_skb, it's untagged in ptype_base hander and reinjected
>>>
>>>      This incosistency is fixed by this patch. Vlan untagging happens early in
>>>      __netif_receive_skb so the rest of code (ptype_all handlers, rx_handlers)
>>>      see the skb like it was untagged by hw.
>>>
>>>
>>> Now the question is: What is the correct solution to handle this?
>>>
>>> One option I found is using the pcap library since this uses the
>>> auxillary data received from the recvmsg call to reconstruct the vlan
>>> headers, but this would mean that first of all I have to adapt my
>>> application(s) and more importantly that I loose the BPF filter
>>> feature since this is implemented in the kernel.
>>> Another disadvantage is that this requires more processing since the
>>> mac header needs to be moved the packet to make room to store the VLAN
>>> tags.
>>> So first cycles are lost in the kernel to strip the info and a bit
>>> later, the packet to be reconstructed again.
>>>
>>> Is there any other way to proceed?
>>>
>>> A side question: If I would switch to the libpcap approach, I assume
>>> the application can work on both the 2.6 and 3.4 version of the
>>> kernel, but is there a guarantee that this will also work on future
>>> versions?
>>
>>
>> If you use a BPF, it can access vlan tag (skb->vlan_tci) since linux-3.8
>>
>> commit f3335031b9452baebfe49b8b5e55d3fe0c4677d1
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Sat Oct 27 02:26:17 2012 +0000
>>
>>      net: filter: add vlan tag access
>>
>>      BPF filters lack ability to access skb->vlan_tci
>>
>>      This patch adds two new ancillary accessors :
>>
>>      SKF_AD_VLAN_TAG         (44) mapped to vlan_tx_tag_get(skb)
>>
>>      SKF_AD_VLAN_TAG_PRESENT (48) mapped to vlan_tx_tag_present(skb)
>>
>>      This allows libpcap/tcpdump to use a kernel filter instead of
>>      having to fallback to accept all packets, then filter them in
>>      user space.
>>
>>      Signed-off-by: Eric Dumazet <edumazet@google.com>
>>      Suggested-by: Ani Sinha <ani@aristanetworks.com>
>>      Suggested-by: Daniel Borkmann <danborkmann@iogearbox.net>
>>      Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>
>> You can update your BPF to use these new features, and get support for
>> both old kernels and new ones.
>
> Thanks for the feedback. High level it is almost clear.
>
> At implementation level I do not understand how it is supposed to work.
> If I use tcpdump to generate a filter for example on vlan 4094 I see
> no reference at all to the newly added instructions to get the VLAN.
>
> ~ # tcpdump -i eth-ntb vlan 4094 -d
> tcpdump: WARNING: eth-ntb: no IPv4 address assigned
> (000) ldh      [12]
> (001) jeq      #0x8100          jt 3    jf 2
> (002) jeq      #0x9100          jt 3    jf 7
> (003) ldh      [14]
> (004) and      #0xfff
> (005) jeq      #0xffe           jt 6    jf 7
> (006) ret      #65535
> (007) ret      #0

I assume that's because libpcap BPF compiler has not implemented it so far.

Therefore, tcpdump doesn't make use of it either.
