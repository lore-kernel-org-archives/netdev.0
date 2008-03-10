From: David Monro <davidm@davidmonro.net>
Subject: Re: cassini driver and IPv6
Date: Mon, 10 Mar 2008 19:34:24 +1030
Message-ID: <47D4F998.4000905@davidmonro.net>
References: <4377F74A.8090707@davidmonro.net> <20051114.214848.83997631.davem@davemloft.net> <47D4C552.5050704@davidmonro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: asun@darksunrising.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from davidmonro.net ([150.101.97.43]:46555 "EHLO
	barbican.davidmonro.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751368AbYCJJEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 05:04:48 -0400
In-Reply-To: <47D4C552.5050704@davidmonro.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh duh. Forgot to say this is on 2.6.24.3 (not that the basic issue has 
changed in over 2 years...)

Cheers,

	David

David Monro wrote:
> Well, I thought I would take another look at this, since I saw lots of 
> cassini-related code going into the kernel and its been some time since 
> I last played with this...
> 
> I'm using a board with Natsemi Saturn chips (one of the gigaswifts with 
> 2xGig ether and 2x scsi), on a little-endian PC rather than a sparc box 
> (not that that should matter...). _Most_ IPV6 packets don't seem to get 
> checksummed correctly  (they trigger the eth1: hw csum failure message 
> and a traceback as follows:
> 
>   [<c010505a>] show_trace_log_lvl+0x1a/0x30
>   [<c0105a72>] show_trace+0x12/0x20
>   [<c010642a>] dump_stack+0x6a/0x70
>   [<c0292f01>] netdev_rx_csum_fault+0x31/0x40
>   [<c028f300>] __skb_checksum_complete_head+0x60/0x70
>   [<c028f31b>] __skb_checksum_complete+0xb/0x10
>   [<e0fba769>] tcp_v6_rcv+0x459/0x920 [ipv6]
>   [<e0f9aa4f>] ip6_input_finish+0x12f/0x340 [ipv6]
>   [<e0f9ac7f>] ip6_input+0x1f/0x60 [ipv6]
>   [<e0f9af55>] ipv6_rcv+0x1f5/0x340 [ipv6]
>   [<c0292b54>] netif_receive_skb+0x364/0x510
>   [<c02958f6>] process_backlog+0x66/0xd0
>   [<c02953ee>] net_rx_action+0x15e/0x210
>   [<c0123f52>] __do_softirq+0x52/0xb0
>   [<c0123ff6>] do_softirq+0x46/0x50
>   [<c012445c>] irq_exit+0x6c/0x80
>   [<c01065b3>] do_IRQ+0x53/0x90
>   [<c0104afa>] common_interrupt+0x2e/0x34
>   [<c0116971>] do_page_fault+0xa1/0x5f0
>   [<c03081e2>] error_code+0x6a/0x70
> 
> ).
> 
> (Not all packets trigger it; eg I sent a ping6 with a length of 2000, 
> and as far as I can tell only the 2nd packet in each ping triggers the 
> failure - odd. Does it depend on the v6 extension headers present or 
> something I wonder. Actually, how on earth does the hardware produce the 
> pseudo header for tcp? And even odder - how could it possibly go wrong 
> with non-tcp packets like ping?)
> 
> Has anyone else ever tested a saturn (or actually any cassini device) 
> using ipv6?
> 
> I've spent a while looking at the packet parser stuff but I have only a 
> vague idea what it is doing and am certainly not in a position to debug 
> it. My current solution is simply to only do the checksumming stuff at 
> the bottom of cas_rx_process_pkt if ntohs(skb->protocol) == 0x0800 (ie, 
> IPv4), else set skb->csum to CHECKSUM_NONE, which is kinda dirty. If 
> someone with a non-saturn cassini can confirm that they don't get hw 
> csum errors with ipv6, then I'd have to assume a saturn-only hardware 
> bug and could wrap it with (cp->cas_flags & CAS_FLAG_SATURN) as well.
> 
> Does this seem reasonable?
> 
> Cheers,
> 
>     David
> 
> 
> 
> David S. Miller wrote:
>> From: David Monro <davidm@davidmonro.net>
>> Date: Mon, 14 Nov 2005 13:02:42 +1030
>>
>>> I don't know if it just needs to be told not to calulate the checksums
>>> for v6 packets, or what.
>>
>> It generates a generic checksum calculation on all packets,
>> similarly to the Sun GEM chip, which ought to be totally
>> protocol agnostic.
>>
>> The Cassini is a very complex chip, so debugging this without docs
>> will be a chore.  There are many things that influence how this chip
>> looks at the packet, including a packet parsing engine which tells it
>> where to split packets up into header and data portions for zero-copy
>> stuff.
>>
>> Special versions of this packet parser are needed to workaround bugs
>> in certain revisions of the chip, and I bet there are buffer alignment
>> constraints on receive and other odd things that need to be right.
>>
>> The only thing I can do to work on this bug is to use the driver
>> source, and reproduce the bug here and just tinker around, which
>> you can also do. :-)
>>
>>
> 
> 

