From: Alexander Nyberg <alexn@dsv.su.se>
Subject: Re: Reproducible panics with tulip
Date: Sat, 19 Mar 2005 10:21:32 +0100
Message-ID: <1111224092.964.2.camel@localhost.localdomain>
References: <1111178167.1147.9.camel@localhost.localdomain>
	 <20050318215229.GA24509@electric-eye.fr.zoreil.com>
	 <20050318223939.GB24509@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050318223939.GB24509@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > Warning: kfree_skb on hard IRQ c46c3950
> > 
> > ... however this one may stick.
> 
> /me slaps his head
> 
> Nope, it should go away with netconsole: tulip_rx fails an allocation,
> netconsole tries to printk in IRQ context and issues:
> -> netpoll_send_udp
>    -> find_skb
>      -> zap_completion_queue
>         -> __kfree_skb <- whence the warning.
> 
> So, please increase /proc/sys/vm/min_free_kbytes as a start and, at your
> option:
> - disable netconsole
> - apply patch below:

I guess it was unclear in the output mess, the real problem at the
bottom was:

Unable to handle kernel NULL pointer dereference at virtual address 00000064
 printing eip:
c023c9f7
*pde = 00000000
Oops: 0000 [#1]
DEBUG_PAGEALLOC
CPU:    0
EIP:    0060:[<c023c9f7>]    Not tainted VLI
EFLAGS: 00010246   (2.6.12-rc1)
EIP is at tulip_rx+0x187/0x3e0
eax: 00000000   ebx: c70a0220   ecx: 00000000   edx: 00000640
esi: 00000040   edi: 00000000   ebp: c46c3ba8   esp: c46c3b64
ds: 007b   es: 007b   ss: 0068
Process rpciod/0 (pid: 595, threadinfo=c46c2000 task=c4673b10)
Stack: c46c3e40 c07f5f60 c0c1f824 c46c3b90 c028ecb9 00000000 c46c3b80 00000000
       0000003c 00000000 0000000f 00000070 00000031 c70a0000 c70a0220 00009fde
       0000001e c46c3c00 c023d5a5 00000040 00000000 00000000 00000084 c4687e8c
Call Trace:
 [<c010340a>] show_stack+0x7a/0x90
 [<c0103588>] show_registers+0x148/0x1b0
 [<c010376a>] die+0xda/0x150
 [<c010eb20>] do_page_fault+0x2f0/0x625
 [<c01030a3>] error_code+0x2b/0x30
 [<c023d5a5>] tulip_interrupt+0x955/0x970
 [<c012afda>] handle_IRQ_event+0x2a/0x60
 [<c012b0b4>] __do_IRQ+0xa4/0xf0
 [<c010471c>] do_IRQ+0x1c/0x30
 [<c0102ffe>] common_interrupt+0x1a/0x20
 [<c027507b>] kfree_skbmem+0xb/0x20
 [<c02750e3>] __kfree_skb+0x53/0xc0
 [<c02b8d6b>] packet_rcv_spkt+0x11b/0x200
 [<c027a47b>] netif_receive_skb+0x12b/0x190
 [<c027a55e>] process_backlog+0x7e/0x100
 [<c027a645>] net_rx_action+0x65/0xe0
 [<c011a4fa>] __do_softirq+0x7a/0x90
 [<c011a53c>] do_softirq+0x2c/0x30
 [<c0104721>] do_IRQ+0x21/0x30
 [<c0102ffe>] common_interrupt+0x1a/0x20
 [<c02afe64>] inet_sendpage+0x74/0xa0
 [<c02c592e>] xdr_sendpages+0x13e/0x220
 [<c02bdc2d>] xprt_transmit+0xcd/0x470
 [<c02bbd1b>] call_transmit+0x4b/0xb0
 [<c02bf44c>] __rpc_execute+0x5c/0x300
 [<c0123680>] worker_thread+0x150/0x1e0
 [<c0126c45>] kthread+0x95/0xa0
 [<c0100b65>] kernel_thread_helper+0x5/0x10
Code: 07 83 e8 04 66 3d ee 05 0f 8f f3 01 00 00 98 3b 05 90 d5 3f c0 89 45 dc 0f 8c 07 01 00 00 8b 4d ec 8b 8c cb 18 01 00 00 89 4d e0 <8b> 51 64 8b b1 90 00 00 00 85 d2 0f 85 dc 00 00 00 8b 55 dc 8b
 <0>Kernel panic - not syncing: Fatal exception in interrupt
