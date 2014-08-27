From: Brian Rak <brak@gameservers.com>
Subject: Re: skb_warn_bad_offload warnings with FreeBSD guests
Date: Wed, 27 Aug 2014 13:11:55 -0400
Message-ID: <53FE115B.7000806@gameservers.com>
References: <53F76D7E.4030307@gameservers.com> <53FB4775.8020507@gmail.com>	 <53FE02CC.50501@gameservers.com> <1409157890.3173.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.choopa.net ([216.155.136.52]:45301 "EHLO mail.choopa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027AbaH0RMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 13:12:01 -0400
In-Reply-To: <1409157890.3173.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8/27/2014 12:44 PM, Eric Dumazet wrote:
> On Wed, 2014-08-27 at 12:09 -0400, Brian Rak wrote:
>
>> I managed to intercept the raw packet + headers being delivered to the
>> tun device, though I'm having some trouble making sense of it. I've got
>> this call:
>>
>> writev(33, [{"\x00\x01\x42\x00\xa0\x05\x00\x00\x00\x00\x00\x00", 12},
>> .... ], 4) = 4258
>>
>> If I ignore the first 12 bytes that were written, I end up with a 4246
>> byte packet, which matches the warning message:
>>
>> kernel: igb: caps=(0x0000000390114bb3, 0x0000000000000000) len=4246
>> data_len=4180 gso_size=1440 gso_type=5 ip_summed=0
>>
>> Looking at the code (
>> https://github.com/torvalds/linux/blob/68e370289c29e3beac99d59c6d840d470af9dfcf/drivers/net/tun.c#L1037
>> ) it seems that the tun device is expecting a virtio_net_hdr, but that
>> structure is only 10 bytes long (
>> http://lxr.free-electrons.com/source/include/uapi/linux/virtio_net.h#L73
>> ).  I'm assuming the last two bytes are padding, because then the rest
>> of the structure decodes okay:
>>
>> flags =  0
>> gso_type = VIRTIO_NET_HDR_GSO_TCPV4
>> hdr_len = 66
>> gso_size =  1440
>> csum_start = 0
>> csum_offset = 0
>>
>> This matches what the warning message says, so I'm fairly confident in
>> it.  If I decode the remainder of the write call (ignoring the 2 bytes
>> after the header), I'm left with a perfectly normal looking TCP packet
>> (with a 4180 byte payload).
>>
>> Looking at the packet itself, I see a valid IP checksum, and a valid TCP
>> checksum.  So, it seems like FreeBSD is calculating the packet checksums
>> correctly, but I'm unsure of why Linux isn't noticing that.  I thought
>> it might be related to VIRTIO_NET_HDR_F_DATA_VALID, but I can't seem to
>> find any uses of this that seem relevant (not that FreeBSD sets it anyway).
>>
>> Shouldn't the tun code be setting ip_summed after receiving a packet
>> with a valid checksum?  It's not clear to me where ip_summed should be
>> getting set.
> You need VIRTIO_NET_HDR_F_NEEDS_CSUM, and to provide proper csum_start &
> csum_offset
>
Why?  The packet doesn't need a checksum (it already has a valid one).  
Does 'VIRTIO_NET_HDR_F_NEEDS_CSUM' not mean 'this packet needs a 
checksum calculated'?
