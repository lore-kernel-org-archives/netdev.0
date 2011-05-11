From: TB <lkml@techboom.com>
Subject: Re: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide
 error
Date: Wed, 11 May 2011 10:49:01 -0400
Message-ID: <4DCAA1DD.6010609@techboom.com>
References: <20110504113351.4643a0c9@nehalam>	<16668.1304537481@localhost>	<20110504123738.7bb4d1ee@nehalam>	<20110504.124053.260068550.davem@davemloft.net>	<20110504130456.425dee68@nehalam>	<alpine.WNT.2.00.1105041352020.6048@JBRANDEB-DESK2.amr.corp.intel.com>	<4DC41EB2.6070404@techboom.com> <20110506095359.57c4fb38@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Injong Rhee <injongrhee@gmail.com>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110506095359.57c4fb38@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-05-06 12:53 PM, Stephen Hemminger wrote:
> On Fri, 06 May 2011 12:15:46 -0400
> TB <lkml@techboom.com> wrote:
> 
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> On 11-05-04 04:53 PM, Brandeburg, Jesse wrote:
>>>
>>>
>>> On Wed, 4 May 2011, Stephen Hemminger wrote:
>>>
>>>> TCP Cubic keeps a metric that estimates the amount of delayed
>>>> acknowledgements to use in adjusting the window. If an abnormally
>>>> large number of packets are acknowledged at once, then the update
>>>> could wrap and reach zero. This kind of ACK could only
>>>> happen when there was a large window and huge number of
>>>> ACK's were lost.
>>>>
>>>> This patch limits the value of delayed ack ratio. The choice of 32
>>>> is just a conservative value since normally it should be range of 
>>>> 1 to 4 packets.
>>>>
>>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>
>>> patch seems fine, but please credit the reporter (lkml@techboom.com) with 
>>> reporting the issue with logs, maybe even with Reported-by: and some kind 
>>> of reference to the panic message or the email thread in the text or 
>>> header?
>>
>> We're currently testing the patch on 6 production servers
> 
> Thank you, is there some regularity to the failures previously?

This is now being tested on about 50 servers and we just had another
panic, on a server with 2.6.38.5 and this patch.

[405542.454073] ------------[ cut here ]------------
[405542.454109] kernel BUG at net/ipv4/tcp_output.c:1006!
[405542.454136] invalid opcode: 0000 [#1]

[405542.454166] last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.2/host6/scsi_host/host6/proc_name
[405542.454213] CPU 0

[405542.454220] Modules linked in:
 i2c_i801
 evdev
 i2c_core
 button
 [last unloaded: scsi_wait_scan]

[405542.454300]
[405542.454320] Pid: 0, comm: swapper Not tainted 2.6.38.5 #8

/

[405542.454379] RIP: 0010:[<ffffffff814e7ed2>]
 [<ffffffff814e7ed2>] tcp_fragment+0x22/0x29a
[405542.454433] RSP: 0018:ffff8800bf403a30  EFLAGS: 00010202
[405542.454460] RAX: ffff88000cd35000 RBX: ffff88006b84f480 RCX:
0000000000000218
[405542.454504] RDX: 0000000000001708 RSI: ffff88006b84f480 RDI:
ffff880008d6b200
[405542.454548] RBP: 0000000000001540 R08: 0000000000000002 R09:
000000001027984a
[405542.454592] R10: ffff8800b915f428 R11: ffff880008d6b200 R12:
ffff88006b84f4a8
[405542.454636] R13: 0000000000001708 R14: 0000000000000000 R15:
ffff880008d6b200
[405542.454680] FS:  0000000000000000(0000) GS:ffff8800bf400000(0000)
knlGS:0000000000000000
[405542.454726] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[405542.454754] CR2: 00007f94055c7000 CR3: 000000083e0bd000 CR4:
00000000000006f0
[405542.454798] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[405542.454842] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[405542.454886] Process swapper (pid: 0, threadinfo ffffffff8176c000,
task ffffffff81777020)
[405542.454931] Stack:
[405542.454951]  0000000000000000
 0000021808d6b798
 00000002000005b4
 ffff88006b84f480

[405542.455006]  ffff880008d6b200
 ffff88006b84f4a8
 0000000000000015
 0000000000000000

[405542.455061]  ffff880008d6b300
 ffffffff814df7a4
 ffff8802a3965140
 00000000000001a0

[405542.455115] Call Trace:
[405542.455137]  <IRQ>

[405542.455162]  [<ffffffff814df7a4>] ? tcp_mark_head_lost+0x13c/0x202
[405542.455192]  [<ffffffff814e33a8>] ? tcp_ack+0xe98/0x1a89
[405542.455220]  [<ffffffff814e42ca>] ? tcp_validate_incoming+0x69/0x290
[405542.455250]  [<ffffffff814e4c9b>] ? tcp_rcv_established+0x7aa/0xa13
[405542.455281]  [<ffffffff814ec60b>] ? tcp_v4_do_rcv+0x1b2/0x382
[405542.455310]  [<ffffffff814c95d4>] ? nf_iterate+0x40/0x78
[405542.455338]  [<ffffffff814ecc5f>] ? tcp_v4_rcv+0x484/0x797
[405542.455368]  [<ffffffff814d11c7>] ? ip_local_deliver_finish+0xab/0x139
[405542.455398]  [<ffffffff814ae2b3>] ? __netif_receive_skb+0x31c/0x349
[405542.455428]  [<ffffffff814aec82>] ? netif_receive_skb+0x67/0x6d
[405542.455457]  [<ffffffff814af1fb>] ? napi_gro_receive+0x9d/0xab
[405542.455485]  [<ffffffff814aed57>] ? napi_skb_finish+0x1c/0x31
[405542.455516]  [<ffffffff813e4248>] ? igb_poll+0x7d5/0xb2e
[405542.455544]  [<ffffffff813e432f>] ? igb_poll+0x8bc/0xb2e
[405542.455572]  [<ffffffff813e211a>] ? igb_msix_ring+0x6e/0x75
[405542.455602]  [<ffffffff8106749c>] ? handle_IRQ_event+0x51/0x119
[405542.455631]  [<ffffffff814af337>] ? net_rx_action+0xa7/0x212
[405542.455661]  [<ffffffff8103b6c2>] ? __do_softirq+0xbe/0x184
[405542.455690]  [<ffffffff8100364c>] ? call_softirq+0x1c/0x28
[405542.455719]  [<ffffffff81005085>] ? do_softirq+0x31/0x63
[405542.455746]  [<ffffffff8103b56c>] ? irq_exit+0x36/0x78
[405542.455773]  [<ffffffff81004784>] ? do_IRQ+0x98/0xae
[405542.455802]  [<ffffffff81562ed3>] ? ret_from_intr+0x0/0xe
[405542.455829]  <EOI>

[405542.455860]  [<ffffffff81009a41>] ? mwait_idle+0xb9/0xf3
[405542.455888]  [<ffffffff81001c6e>] ? cpu_idle+0x57/0x8d
[405542.455921]  [<ffffffff81801c49>] ? start_kernel+0x34e/0x35a
[405542.455950]  [<ffffffff81801398>] ? x86_64_start_kernel+0xf3/0xf9
[405542.455977] Code:
f>

[405542.456239] RIP
 [<ffffffff814e7ed2>] tcp_fragment+0x22/0x29a
[405542.456270]  RSP <ffff8800bf403a30>
[405542.456543] ---[ end trace 231aaa222f893065 ]---
[405542.456600] Kernel panic - not syncing: Fatal exception in interrupt
[405542.456659] Pid: 0, comm: swapper Tainted: G      D     2.6.38.5 #8
[405542.456719] Call Trace:
[405542.456770]  <IRQ>
 [<ffffffff81560960>] ? panic+0x9d/0x1a0
[405542.456863]  [<ffffffff81562ed3>] ? ret_from_intr+0x0/0xe
[405542.456923]  [<ffffffff810365bb>] ? kmsg_dump+0x46/0xec
[405542.456981]  [<ffffffff81006176>] ? oops_end+0x9f/0xac
[405542.457039]  [<ffffffff81003f83>] ? do_invalid_op+0x85/0x8f
[405542.457097]  [<ffffffff814e7ed2>] ? tcp_fragment+0x22/0x29a
[405542.457156]  [<ffffffff814e80a9>] ? tcp_fragment+0x1f9/0x29a
[405542.457216]  [<ffffffff810033d5>] ? invalid_op+0x15/0x20
[405542.457276]  [<ffffffff814e7ed2>] ? tcp_fragment+0x22/0x29a
[405542.457337]  [<ffffffff814df7a4>] ? tcp_mark_head_lost+0x13c/0x202
[405542.457400]  [<ffffffff814e33a8>] ? tcp_ack+0xe98/0x1a89
[405542.457461]  [<ffffffff814e42ca>] ? tcp_validate_incoming+0x69/0x290
[405542.457524]  [<ffffffff814e4c9b>] ? tcp_rcv_established+0x7aa/0xa13
[405542.457586]  [<ffffffff814ec60b>] ? tcp_v4_do_rcv+0x1b2/0x382
[405542.457645]  [<ffffffff814c95d4>] ? nf_iterate+0x40/0x78
[405542.457703]  [<ffffffff814ecc5f>] ? tcp_v4_rcv+0x484/0x797
[405542.457761]  [<ffffffff814d11c7>] ? ip_local_deliver_finish+0xab/0x139
[405542.457827]  [<ffffffff814ae2b3>] ? __netif_receive_skb+0x31c/0x349
[405542.457894]  [<ffffffff814aec82>] ? netif_receive_skb+0x67/0x6d
[405542.457953]  [<ffffffff814af1fb>] ? napi_gro_receive+0x9d/0xab
[405542.458021]  [<ffffffff814aed57>] ? napi_skb_finish+0x1c/0x31
[405542.458080]  [<ffffffff813e4248>] ? igb_poll+0x7d5/0xb2e
[405542.458138]  [<ffffffff813e432f>] ? igb_poll+0x8bc/0xb2e
[405542.458196]  [<ffffffff813e211a>] ? igb_msix_ring+0x6e/0x75
[405542.458254]  [<ffffffff8106749c>] ? handle_IRQ_event+0x51/0x119
[405542.458313]  [<ffffffff814af337>] ? net_rx_action+0xa7/0x212
[405542.458371]  [<ffffffff8103b6c2>] ? __do_softirq+0xbe/0x184
[405542.458430]  [<ffffffff8100364c>] ? call_softirq+0x1c/0x28
[405542.458488]  [<ffffffff81005085>] ? do_softirq+0x31/0x63
[405542.458545]  [<ffffffff8103b56c>] ? irq_exit+0x36/0x78
[405542.458602]  [<ffffffff81004784>] ? do_IRQ+0x98/0xae
[405542.458660]  [<ffffffff81562ed3>] ? ret_from_intr+0x0/0xe
[405542.458717]  <EOI>
 [<ffffffff81009a41>] ? mwait_idle+0xb9/0xf3
[405542.458810]  [<ffffffff81001c6e>] ? cpu_idle+0x57/0x8d
[405542.458867]  [<ffffffff81801c49>] ? start_kernel+0x34e/0x35a
[405542.458926]  [<ffffffff81801398>] ? x86_64_start_kernel+0xf3/0xf9
