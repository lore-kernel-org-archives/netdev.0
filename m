From: Curtis Doty <Curtis@GreenKey.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 14 May 2007 13:24:45 -0700 (PDT)
Message-ID: <20070514202446.242C36F0C1@alopias.GreenKey.net>
References: <Line.LNX.4.64.0705141430120.8521@d.namei> <4648AE85.6020608@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alopias.GreenKey.net ([209.209.60.60]:56108 "EHLO
	alopias.GreenKey.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbXENUb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 16:31:29 -0400
In-Reply-To: <4648AE85.6020608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

8:46pm Patrick McHardy said:

> James Morris wrote:
>> ---------- Forwarded message ----------
>> Date: Mon, 14 May 2007 08:15:50 -0700 (PDT)
>> From: Curtis Doty <Curtis@GreenKey.net>
>> To: Linux Kernel <linux-kernel@vger.kernel.org>
>> Subject: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
>>
>> Summary: On a multi-homed box, after turning on
>> /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr, it now periodically oopses
>> when trying to lookup the source address to use for sending an ICMP in response
>> to a jump ipt_REJECT.
>>
>> I'm still trying to figure out what makes this test case unique. It spuriously
>> occurs with many fedora builds of 2.6.{18,19,20} all of which don't appear to
>> have any patches in this area of the kernel. Just _maybe_ it's because of a
>> combination of dogleg routing and overloading one vlan with multiple subnets:
>>
>> [..]
>>
>> BUG: unable to handle kernel NULL pointer dereference at virtual address
>> 000000a8
>> [...]
>> EIP is at inet_select_addr+0x4/0x9f
>> eax: 00000000   ebx: f8b97046   ecx: 000000fd   edx: 00000000
>> esi: 000000fd   edi: 00000001   ebp: f71cd0ac   esp: c078bc9c
>> ds: 007b   es: 007b   ss: 0068
>> Process swapper (pid: 0, ti=c078b000 task=c06fc480 task.ti=c0746000)
>> Stack: f8b97046 f601b130 c05fd0b6 f728b980 f728b980 f8b5adbb c05bcb6e c078bd74
>>        00000003 00000003 00000246 00000246 00000000 f887e014 f8a611a6 f7c1ea80
>>        f728b9a8 00000000 f727d220 f887e000 00000001 00000072 f7383800 f728b980
>> Call Trace:
>>  [<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
>>  [<c05fd0b6>] icmp_send+0x14d/0x39b
>
>
> A REJECT target in the output chain will trigger this in combination
> with icmp_errors_use_inbound_ifaddr because skb->dev is still NULL
> at this point and its passed to inet_select_addr.
>

Indeed, thanks!

curtis@host~$ nc kernel.org 42
BUG: unable to handle kernel NULL pointer dereference at virtual address 000000a8
  printing eip:
c05fe72b
*pde = 00000000
Oops: 0000 [#1]
...

And for now, the easy userland workaround is to add '-i ! eth+ -j DROP' 
just before any jumps to REJECT. This now causes delays/timeouts for any 
forbidden outbound traffic. But it's better than an oops.

Now I'm off to figure out what daemon is trying to make these odd 
connections...or if netfilter/conntrack is periodically scrambling its 
brains.

