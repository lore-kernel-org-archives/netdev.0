From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 15:49:03 -0800
Message-ID: <20050304154903.7b7e0fb1@dxpl.pdx.osdl.net>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
	<20050304145317.772859da@dxpl.pdx.osdl.net>
	<20050304230214.GC1148@electric-eye.fr.zoreil.com>
	<200503041728.54026.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <200503041728.54026.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am really killing this poor beast, the target is a 1.2 Ghz Celeron and it
is trying to handle 1,000,000 packets/sec (from tg3 Opteron)

Added this and took out "too much work at interrupt message"

--- drivers/net/r8169.c.orig    2005-03-04 13:19:08.000000000 -0800
+++ drivers/net/r8169.c 2005-03-04 15:41:30.000000000 -0800
@@ -2210,6 +2210,16 @@
                        pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
                                   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);

+                       if (pkt_size > tp->rx_buf_sz) {
+                               printk(KERN_WARNING "%s: status=%x opts=%x opts2
=%x addr=%x:%x\n",
+                                      dev->name, status, desc->opts1,
+                                      desc->opts2,
+                                      (u32) (desc->addr >> 32),
+                                      (u32) desc->addr);
+
+                               goto ditch;
+                       }
+
                        skb->dev = dev;
                        skb_put(skb, pkt_size);
                        skb->protocol = eth_type_trans(skb, dev);
@@ -2222,6 +2232,7 @@
                        tp->stats.rx_packets++;
                }

+       ditch:
                cur_rx++;
                rx_left--;
        }


And got this (before it died):

eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:106ad012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15194812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15194012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:9efb812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:9efb012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:10215812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:10215012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8de2812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8de2012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:1559a812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:10782012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b7f3812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b7f3012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15125812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:9ef9812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:9ef9012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15707812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15707012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:588c812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:588c012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15120812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15120012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:12b2c812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:12b2c012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:6561812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:6561012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:13bea812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:13bea012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:112b4812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:112b4012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:157d7812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:157d7012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:39a5812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:39a5012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:58c3812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:58c3012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:1582f812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1582f012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:116f6812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:116f6012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:109f0812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:109f0012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:13b82812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:13b82012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:ce31812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:ce31012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:29d3812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:29d3012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b3b4812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b3b4012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:5a73812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:5a73012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:d288812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:d288012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:107e3812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:107e3012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:15198812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:15198012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:16654812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16654012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16741812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16741012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b911812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:b911012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:12e5d812
eth0: status=24829808 opts=24829808 opts2=0 addr=0:a6ee012
eth0: status=4829808 opts=4829808 opts2=0 addr=0:127ff812
eth0: status=4829808 opts=4829808 opts2=0 addr=0:127ff012
eth0: status=14829808 opts=14829808 opts2=0 addr=0:16b84812
eth0: status=20802842 opts=20802842 opts2=0 addr=0:16b84012
eth0: status=802842 opts=802842 opts2=0 addr=0:125d1812
eth0: status=802842 opts=802842 opts2=0 addr=0:125d1012
eth0: status=802842 opts=802842 opts2=0 addr=0:11104812
eth0: status=802842 opts=802842 opts2=0 addr=0:11104012
eth0: status=802842 opts=802842 opts2=0 addr=0:636a812
eth0: status=10802842 opts=10802842 opts2=0 addr=0:636a012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:138d5812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:138d5012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11cb0812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11cb0012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:88a4812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:88a4012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1082a812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1082a012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:168af812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:168af012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:1660f812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:112c3012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:c3e0812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:c3e0012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1f7e812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1f7e012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:2f5c812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:2f5c012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:132f6812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:132f6012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:c74a812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:c74a012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:11140812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11140012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:127be812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:127be012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16475812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16475012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:114d7812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:114d7012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:87a3812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:87a3012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:11abb812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:11c68012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8968812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8968012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:5588812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:5588012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:14f77812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:14f77012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8951812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8951012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:5a6f812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:5a6f012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:12acc012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8e90812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8e90012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:9d53812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:9d53012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1390a812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:1390a012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8952812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8952012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11a76812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:11a76012
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:11167812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11167012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11548812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11548012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16428812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:16428012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8762812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8762012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:14139812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:14139012
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:1157c812
eth0: status=20803ff0 opts=20803ff0 opts2=0 addr=0:8dcd012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8de8812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8de8012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8f08812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8f08012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:116a4812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:116a4012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11b98812
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:11b98012
eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:8cf4812
eth0: status=10803ff0 opts=10803ff0 opts2=0 addr=0:8cf4012
Unable to handle kernel paging request at virtual address 4228b92f
 printing eip:
c011772d
*pde = 00000000
Oops: 0002 [#1]
PREEMPT
Modules linked in: r8169 i810 md5 ipv6 autofs4 sunrpc reiserfs video button battery ac 813dCPU:    0
EIP:    0060:[<c011772d>]    Not tainted VLI
EFLAGS: 00010003   (2.6.11-netrx)
EIP is at scheduler_tick+0x3d/0x2c0
eax: 4228b927   ebx: c036c000   ecx: 000f4240   edx: 000f44af
esi: d785ba40   edi: c036cf18   ebp: c036ceb0   esp: c036ce9c
ds: 007b   es: 007b   ss: 0068
Process '.(B'.(B@ (pid: 1109979719, threadinfo=c036c000 task=d785ba40)
Stack: 00000046 00000000 c036cf18 00000000 c036cf18 c036cec4 c010712a c02fd300
       00000000 c036cf18 c036cee0 c0137cc5 00000000 00000000 00000000 c033ea40
       c036c000 c036cf00 c0137dbe c036c000 c02fd300 c036cf18 000000e2 00000000
Call Trace:
 [<c010344a>] show_stack+0x7a/0x90
 [<c01035c9>] show_registers+0x149/0x1c0
 [<c01037cd>] die+0xdd/0x170
 [<c0115643>] do_page_fault+0x453/0x675
 [<c01030d7>] error_code+0x2b/0x30
 [<c010712a>] timer_interrupt+0x4a/0x120
 [<c0137cc5>] handle_IRQ_event+0x35/0x70
 [<c0137dbe>] __do_IRQ+0xbe/0x150
 [<c01048bf>] do_IRQ+0x5f/0x70
 [<c010309e>] common_interrupt+0x1a/0x20
 [<d8856bad>] rtl8169_interrupt+0xdd/0x130 [r8169]
 [<c0137cc5>] handle_IRQ_event+0x35/0x70
 [<c0137dbe>] __do_IRQ+0xbe/0x150
 [<c01048a1>] do_IRQ+0x41/0x70
 =======================
 [<c010309e>] common_interrupt+0x1a/0x20
 [<c02719ec>] ip_route_input_slow+0x39c/0x9f0
 [<c0274660>] ip_rcv+0x380/0x480
 [<c025eda5>] netif_receive_skb+0x1e5/0x220
 [<c025ee5e>] process_backlog+0x7e/0x100
 [<c025ef45>] net_rx_action+0x65/0xf0
 [<c011fbb2>] __do_softirq+0x42/0xa0
 [<c01049b4>] do_softirq+0x44/0x60
 =======================
 [<c011fcd8>] irq_exit+0x38/0x40
 [<c01048a8>] do_IRQ+0x48/0x70
 [<c010309e>] common_interrupt+0x1a/0x20
 [<c02b9507>] schedule_timeout+0x57/0xb0
 [<c017db4c>] ep_poll+0x10c/0x190
 [<c017cc72>] sys_epoll_wait+0x92/0xa0
 [<c0102ed9>] sysenter_past_esp+0x52/0x75
Code: 7d fc 21 e3 8b 33 e8 03 71 ff ff 39 35 80 ef 36 c0 a3 74 ef 36 c0 89 15 78 ef 36 c0
 <0>Kernel panic - not syncing: Fatal exception in interrupt
