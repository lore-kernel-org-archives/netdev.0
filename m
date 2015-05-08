From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH] net: deinline netif_tx_stop_queue() and netif_tx_stop_all_queues()
Date: Fri, 08 May 2015 11:45:22 +0200
Message-ID: <554C85B2.1010605@redhat.com>
References: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com> <554B9D82.80101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <554B9D82.80101@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2015 07:14 PM, Alexander Duyck wrote:
> On 05/07/2015 04:41 AM, Denys Vlasenko wrote:
>> These functions compile to ~60 bytes of machine code each.
>>
>> With this .config: http://busybox.net/~vda/kernel_config
>> there are 617 calls to netif_tx_stop_queue()
>> and 49 calls to netif_tx_stop_all_queues() in vmlinux.
>>
>> Code size is reduced by 27 kbytes:
>>
>>      text     data      bss       dec     hex filename
>> 82426986 22255416 20627456 125309858 77813a2 vmlinux.before
>> 82399481 22255416 20627456 125282353 777a831 vmlinux
>>
>> It may seem strange that a seemingly simple code like one in
>> netif_tx_stop_queue() compiles to ~60 bytes of code.
>> Well, it's true. Here's its disassembly:
>>
>>      netif_tx_stop_queue:
...
>>         55                      push   %rbp
>>         be 7a 18 00 00          mov    $0x187a,%esi
>>         48 c7 c7 50 59 d8 85    mov    $.rodata+0x1d85950,%rdi
>>         48 89 e5                mov    %rsp,%rbp
>>         e8 54 5a 7d fd          callq  <warn_slowpath_null>
>>         48 c7 c7 5f 59 d8 85    mov    $.rodata+0x1d8595f,%rdi
>>         31 c0                   xor    %eax,%eax
>>         e8 b0 47 48 00          callq  <printk>
>>         eb 09                   jmp    <netif_tx_stop_queue+0x38>
> 
> This is the WARN_ON action.  One thing you might try doing is moving
> this to a function of its own instead of moving the entire thing
> out of being an inline.

If WARN_ON check would be moved into a function, the call overhead
would still be there, while each callsite will be larder than with
this patch.

> You may find you still get most
> of the space savings as I wonder if the string for the printk
> isn't being duplicated for each caller.

Yes, strings are duplicated:

$ strings vmlinux0  | grep 'cannot be called before register_netdev'
6netif_stop_queue() cannot be called before register_netdev()
6tun: netif_stop_queue() cannot be called before register_netdev()
6cc770: netif_stop_queue() cannot be called before register_netdev()
63c589_cs: netif_stop_queue() cannot be called before register_netdev()
63c574_cs: netif_stop_queue() cannot be called before register_netdev()
6typhoon netif_stop_queue() cannot be called before register_netdev()
6axnet_cs: netif_stop_queue() cannot be called before register_netdev()
6pcnet_cs: netif_stop_queue() cannot be called before register_netdev()
...

However, they amount only to ~5.7k out of 27k:

$ strings vmlinux0  | grep 'cannot be called before register_netdev' | wc -c
5731


>>         f0 80 8f e0 01 00 00 01 lock orb $0x1,0x1e0(%rdi)
> 
> This is your set bit operation.  If you were to drop the whole WARN_ON
> then this is the only thing you would be inlining.

It's up to networking people to decide. I would happily send a patch which drops
WARN_ON if they say that's ok with them. Davem?


> That is only 8 bytes in size which would probably be comparable to the callq
> and register sorting needed for a function call.

"lock or" in my tests takes 21 cycles even on exclusively cached
L1 data cache line. Added "call+ret" is 4-5 cycles.

> Have you done any performance testing on this change?

No.

> I suspect there will likely be a noticeable impact some some tests.

(1) It's *transmit off* operation. Usually it means that we have to turn
transmit off because hw TX queue is full. So the bottleneck is likely
the network, not the CPU.

(2) It was auto-deinlined by gcc anyway. We already were unknownigly
using the uninlined version for some time. Apparently, it wasn't noticed.


-- 
vda

