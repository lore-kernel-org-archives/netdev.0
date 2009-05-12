From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Wed, 13 May 2009 00:34:52 +0200
Message-ID: <6A2877E5-CC82-42E7-BE28-31E42FAAB4CD@it-loops.com>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com> <20090505122735.b87dd129.akpm@linux-foundation.org> <F661DCE3-7DDC-42BE-AE0F-937C3478A33C@it-loops.com>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:57131
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722AbZELWe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 18:34:59 -0400
In-Reply-To: <F661DCE3-7DDC-42BE-AE0F-937C3478A33C@it-loops.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 5, 2009, at 10:29 PM, Michael Guntsche wrote:
>
> Here is a full dump from the console again including the line  
> before the "cut here" text.
> Wan is the device going to the ADSL-modem.
>
> [  172.251007] skb_over_panic: text:c0187650 len:1514 put:1514  
> head:c79a8800 data:c79a8880 tail:0xc79a8e6a end:0xc79a8e60 dev:wan
>
>

since I still had the panics with rc5 I went ahead and started  
looking for the commit that caused the problem. After some testing  
(actually a lot of compile cycles) I found out that commit

0fd56bb5be6455d0d42241e65aed057244665e5e gianfar: Add support for skb  
recycling

was the culprit. The commits before it work and starting with this  
one the skb_over_pancis start to occur.

This is as far as I can debug it though. Maybe someone more  
knowledgeable about this stuff could take a look at it or tell me how  
I can figure out what's happening exactly.

For testing purposes I reverted this commit from the current master  
and it has been running the last hour without any problems. Before  
that the panic would occur almost immediately after a download was  
started.


Once again part of the panic which is more or less the same everytime...

[  113.218513] skb_over_panic: text:c015a74c len:1514 put:1514  
head:c7a07800 data:c7a07880 tail:0xc7a07e6a end:0xc7a07e60 dev:wan
[  113.230039] ------------[ cut here ]------------
[  113.234669] kernel BUG at net/core/skbuff.c:124!
[  113.239302] Oops: Exception in kernel mode, sig: 5 [#1]
[  113.244539] MikroTik RouterBOARD 600 series
[  113.248729] Modules linked in:
[  113.251797] NIP: c01a2ad0 LR: c01a2ad0 CTR: c014e37c
[  113.256776] REGS: c0367cb0 TRAP: 0700   Not tainted  (2.6.29-rc3)
[  113.262883] MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002024  XER:  
20000000
[  113.269562] TASK = c0344588[0] 'swapper' THREAD: c0366000
[  113.274799] GPR00: c01a2ad0 c0367d60 c0344588 00000085 00002625  
ffffffff c014b948 00002625
[  113.283223] GPR08: 00000030 c0370000 00002625 c03723a8 84002082  
1001b1cc 007d66c0 00000008
[  113.291647] GPR16: c02e70bc c02e70e8 c78423d8 c0345678 00000040  
c0366000 c7971800 00000000
[  113.300071] GPR24: 00000001 00000000 c78eb300 c7971ff0 c7842000  
000005ea c795c3c0 c7a07880
[  113.308689] NIP [c01a2ad0] skb_over_panic+0x48/0x5c
[  113.313582] LR [c01a2ad0] skb_over_panic+0x48/0x5c
[  113.318382] Call Trace:
[  113.320838] [c0367d60] [c01a2ad0] skb_over_panic+0x48/0x5c  
(unreliable)
[  113.327485] [c0367d70] [c01a42cc] skb_put+0x5c/0x60
[  113.332390] [c0367d80] [c015a74c] gfar_clean_rx_ring+0x20c/0x438
[  113.338422] [c0367dd0] [c015c160] gfar_poll+0x288/0x370
[  113.343672] [c0367e30] [c01af538] net_rx_action+0x94/0x188
[  113.349191] [c0367e60] [c002d0f0] __do_softirq+0x84/0x124
[  113.354621] [c0367e90] [c00063f8] do_softirq+0x58/0x5c
[  113.359781] [c0367ea0] [c002cf6c] irq_exit+0x94/0x98
[  113.364768] [c0367eb0] [c000649c] do_IRQ+0xa0/0xc4
[  113.369582] [c0367ed0] [c0014220] ret_from_except+0x0/0x14
[  113.375101] --- Exception: 501 at cpu_idle+0xa0/0xec
[  113.375109]     LR = cpu_idle+0xa0/0xec
[  113.383923] [c0367f90] [c0009164] cpu_idle+0x50/0xec (unreliable)
[  113.390054] [c0367fb0] [c027c8bc] __got2_end+0x58/0x68
[  113.395225] [c0367fc0] [c03167e4] start_kernel+0x220/0x2a0
[  113.400731] [c0367ff0] [00003438] 0x3438


Kind regards,
Michael
