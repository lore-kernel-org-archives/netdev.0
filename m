From: Stephen Hemminger <shemminger@osdl.org>
Subject: [BUG] Interrupted appletalk echo request
Date: Wed, 27 Aug 2003 16:43:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827164314.606f7877.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-atalk@lists.netspace.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jay Schulist <jschlst@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Testing some other things and ran into a problem (2.4 and 2.6)
if DDP socket program is interrupted while AARP entries are unresolved.

Enclosed is a instrumented version console log.

What is happening is that the AARP entry is getting expired when the
retries get exhausted.  This cause it flush all the skb's in its 
packet_queue. The socket for the socket buffer is still okay,
but the sleep task_list is garbage and points to poisoned entries.

DDP is doing the right thing and not destroying the socket if there
are outstanding writes. Does it need to clean up the socket sleep
queue or is that need to be done at a higher level.


Also, AARP shouldn't have an unbounded packet_queue for unresolved
entries...

[root@zqx3 root]# aecho 6.101
send f588b610 
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry limit f588b610
expire f588b610

send f588b610 
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610

atalk_remove_socket
atalk_destroy socket wmem=292

----6.101 AEP Statistics----
4 packets sent, 0 packets received, 100% packet loss
[root@zqx3 root]# 


kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry f588b610
kick retry limit f588b610
expire f588b610

eip: c011dbf9
------------[ cut here ]------------
kernel BUG at include/asm/spinlock.h:120!
invalid operand: 0000 [#1]
CPU:    0
EIP:    0060:[<c011dc89>]    Not tainted
EFLAGS: 00010086
EIP is at __wake_up+0x90/0x9a
eax: 0000000e   ebx: f5069244   ecx: 00000001   edx: c02e7ee0
esi: 00000001   edi: 00000001   ebp: c035de64   esp: c035de3c
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c035c000 task=c02e5280)
Stack: c02afefe c011dbf9 00000282 00004ef0 00000296 00000000 ffffffac f5069244 
       eac71104 f588b610 c035de80 c024aa4f c03894ff f5794e44 c0389121 eac71104 
       f588b614 c035de90 c024a123 eac71104 00000000 c035dea8 c024afaf f5794e44 
Call Trace:
 [<c011dbf9>] __wake_up+0x0/0x9a
 [<c024aa4f>] sock_def_write_space+0xa8/0xbd
 [<c024a123>] sock_wfree+0x48/0x4a
 [<c024afaf>] __kfree_skb+0x49/0xd9
 [<fa4f40cb>] __aarp_expire+0xcb/0x115 [appletalk]
 [<fa4f45d9>] __aarp_kick+0x3b/0x6a [appletalk]
 [<fa4f46be>] aarp_expire_timeout+0x6c/0xd7 [appletalk]
 [<fa4f4652>] aarp_expire_timeout+0x0/0xd7 [appletalk]
 [<c012bb6b>] run_timer_softirq+0xed/0x226
 [<c011d2a0>] scheduler_tick+0xf2/0x3df
 [<c011c786>] wake_up_process+0x26/0x2a
 [<c012723f>] do_softirq+0xd3/0xd5
 [<c0118878>] smp_apic_timer_interrupt+0xd9/0x141
 [<c0108d59>] default_idle+0x0/0x32
 [<c010bd36>] apic_timer_interrupt+0x1a/0x20
 [<c0108d59>] default_idle+0x0/0x32
 [<c0108d86>] default_idle+0x2d/0x32
 [<c0108e04>] cpu_idle+0x3a/0x43
 [<c0105000>] rest_init+0x0/0x80
 [<c035e872>] start_kernel+0x1a5/0x1ef
 [<c035e427>] unknown_bootoption+0x0/0xfa

Code: 0f 0b 78 00 a6 fe 2a c0 eb 89 55 89 e5 83 ec 10 c7 44 24 0c 
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing
