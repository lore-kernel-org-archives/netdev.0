From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: Re: dm9000 patch
Date: Thu, 30 Dec 2010 10:59:35 +0100
Message-ID: <4D1C5807.5050702@gmail.com>
References: <4D1A5C2A.5050606@gmail.com>	<20101229060637.GA31010@jasper.tkos.co.il>	<4D1B33F2.5060600@gmail.com>	<20101229180650.GE6067@tarshish>	<AANLkTim0+GbddLdkPFoggeCKpU7on7mta0V2mZZLgviE@mail.gmail.com>
	<4D1BA0D0.1060407@gmail.com> <4D1BD461.4070104@snapgear.com>
Reply-To: uClinux development list <uclinux-dev@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Baruch Siach <baruch@tkos.co.il>,
	uClinux development list <uclinux-dev@uclinux.org>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <uclinux-dev-bounces@uclinux.org>
In-Reply-To: <4D1BD461.4070104@snapgear.com>
List-Unsubscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=unsubscribe>
List-Archive: <http://mailman.uclinux.org/pipermail/uclinux-dev>
List-Post: <mailto:uclinux-dev@uclinux.org>
List-Help: <mailto:uclinux-dev-request@uclinux.org?subject=help>
List-Subscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=subscribe>
Sender: uclinux-dev-bounces@uclinux.org
Errors-To: uclinux-dev-bounces@uclinux.org
List-Id: netdev.vger.kernel.org

Hi all,

Joe,
about the debug line inside dm9000_interrupt,

     //dm9000_dbg(db, 3, "entering %s\n", __func__);

nothing change, first browsing attempt crashed the board with the same 
call stack trace:

[    4.660000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   54.340000] BUG: spinlock recursion on CPU#0, swapper/0
[   54.340000]  lock: 00191244, .magic: dead4ead, .owner: swapper/0, 
.owner_cpu: 0
[   54.340000] Stack from 001a1b44:
[   54.340000]         001a1b70 000ad968 0018409b 00191244 dead4ead 
0018d7a8 00000000 00000000
[   54.340000]         00191244 0002b4ea 0014d190 001a1ba4 000adb3a 
00191244 00184101 00191244
[   54.340000]         001a1c98 0000001f 0014d15e ffffffe3 00191208 
0002b4ea 0014d190 0002caf6
[   54.340000]         001a1bb0 0014d1ac 00191244 001a1bdc 0002b602 
00191244 0000001f 001a1c98
[   54.340000]         0000001f 0014d15e 00191244 0002b4ea 0014d190 
0002caf6 001a1bf0 00000bb6
[   54.340000]         0000001f 00191244 00cfc6c0 001a1c38 000033c6 
0000001f 001a1c00 00000001
[   54.340000] Call Trace:
[   54.340000]  [000ad968] spin_bug+0x86/0x11a
[   54.340000]  [000adb3a] do_raw_spin_lock+0x58/0x120
[   54.340000]  [0014d1ac] _raw_spin_lock+0x1c/0x22
[   54.340000]  [0002b602] __do_IRQ+0x2c/0x108
[   54.340000]  [00000bb6] do_IRQ+0x48/0x62
[   54.340000]  [000033c6] inthandler+0x6a/0x74
[   54.340000]  [0014d16c] _raw_spin_unlock+0xe/0x32
[   54.340000]  [0002b6d2] __do_IRQ+0xfc/0x108
[   54.340000]  [00000bb6] do_IRQ+0x48/0x62
[   54.340000]  [000033c6] inthandler+0x6a/0x74
[   54.340000]  [00130f66] tcp_v4_conn_request+0x3fa/0x57c
[   54.340000]  [0012a1a6] tcp_rcv_state_process+0x25e/0xa66
[   54.340000]  [00130984] tcp_v4_do_rcv+0x7c/0x1c8
[   54.340000]  [00132834] tcp_v4_rcv+0x546/0x6d2

Greg,

i phisically connected the HW interrupt pin of dm9000 to MCF5307 IRQ7 
pin (pin68). dm9000 is configured (through a resistor to3.3V on pin 57) 
not as default, but to act with HIGH to LOW interrupt edge, as MCF5307 
understand, and the interrupt line is pulled up to 3.3V to avoid flickering.


             PULL UP RES to 3.3V

dm9000  |         |
    IRQ  |---------+-------------------| MCCF5307 PIN 68 (IRQ7)


IRQ 7 is the "level 7" autovectored interrupt (vect 31 dec).

Checking well the MCF5307 datasheet i have seen that "level 7" interrupt 
i casually choosed seems to be a special level:

/18.7.1 Level 7 Interrupts
Level 7 interrupts are nonmaskable and are handled differently than 
other interrupts.
Level 7 interrupts are edge triggered by a transition from a lower 
priority request to the
level 7 request. Interrupts at all other levels are level sensitive. 
Therefore, if IRQ7 remains
asserted, the MCF5307 recognizes only one level 7 interrupt because only 
one transition
from a lower level request to a level 7 request occurred. For the 
processor to
recognize two consecutive level 7 interrupts, one of the following must 
occur:

1) The interrupt request on the interrupt control pins is raised to 
level 7 and stays there
until an interrupt-acknowledge cycle begins. The level later drops but 
then returns to
level 7, causing a second transition on the interrupt control lines.

2) The interrupt request on the interrupt control pins is raised to 
level 7 and stays there.
If the level 7 interrupt routine lowers the mask level, a second level 7 
interrupt is
recognized without a transition of the interrupt control pins. After the 
level 7 routine
completes, the MCF5307 compares the mask level to the request level on 
the IRQx
signals. Because the mask level is lower than the requested level, the 
interrupt mask
is set back to level 7. To ensure it is recognized, the level 7 request 
on IRQ7 must be
held until the second interrupt-acknowledge bus cycle begins./

I guess i can try to use another IRQ line, for example IRQ1 and see what 
happen. Let me know your thought and i can try right now to hw wire up 
the fix.

still many thanks,

regards,
angelo


On 30/12/2010 01:37, Greg Ungerer wrote:
> Hi Angelo,
>
> On 30/12/10 06:57, Angelo Dureghello wrote:
>> Hi all,
>> thanks for the help,
>> the kernel is a main line kernel. Then yes, i am still using uclinux
>> tree for libc/tools.
>
> How is the DM9000 hardware connected to the 5307?
> I am wondering how you connected the interrupt (and to
> which interrupt) and the addressing (direct of a chip select)?
>
> (For example NETtel based 5307 platform support of the SMC91x code is
> in mainline as arch/m68knommu/platform/5307/nettel.c). Can you show
> the code you used to setup your dm9000 hardware?
> (Specifically I guess I want to know if you use the "auto-vectored"
> interrupt mode?)
>
> Thanks
> Greg
>
>
>> I collected another spinlock recursion with a slightly different call
>> stack trace, as always, the spinlock recursion issue happen on a high
>> tx/rx traffic of the dm9000e, in this case just asking an index.html
>> with some images and texts:
>>
>> [ 1108.930000] BUG: spinlock recursion on CPU#0, httpd/29
>> [ 1108.930000] lock: 00c42c06, .magic: dead4ead, .owner: httpd/29,
>> .owner_cpu: 0
>> [ 1108.930000] Stack from 00d7a688:
>> [ 1108.930000] 00d7a6b4 000ad988 001840ca 00c42c06 dead4ead 00d641d4
>> 0000001d 00000000
>> [ 1108.930000] 00c42c06 000064f0 00c42800 00d7a6e8 000adb5a 00c42c06
>> 00184130 00002704
>> [ 1108.930000] 00000000 0000001f 0014d17e 00159912 00c42b60 000064f0
>> 00c42800 0002cb16
>> [ 1108.930000] 00d7a6f8 0014d24e 00c42c06 00000000 00d7a738 000e485c
>> 00c42c06 00000000
>> [ 1108.930000] 00000000 0000001f 0014d17e 00159912 0000004a 00cfc600
>> 000064f0 00009a74
>> [ 1108.930000] 0002cb16 00191204 00d7a760 0002b6f2 00d7a760 0002b514
>> 0000001f 00c42800
>> [ 1108.930000] Call Trace:
>> [ 1108.930000] [000ad988] spin_bug+0x86/0x11a
>> [ 1108.930000] [000adb5a] do_raw_spin_lock+0x58/0x120
>> [ 1108.930000] [0014d24e] _raw_spin_lock_irqsave+0x28/0x32
>> [ 1108.930000] [000e485c] dm9000_interrupt+0x1a/0x2e0
>> [ 1108.930000] [0002b514] handle_IRQ_event+0x2a/0xec
>> [ 1108.930000] [0002b680] __do_IRQ+0xaa/0x128
>> [ 1108.930000] [00000bb6] do_IRQ+0x48/0x62
>> [ 1108.930000] [000033c6] inthandler+0x6a/0x74
>> [ 1108.930000] [000fb626] dev_hard_start_xmit+0x170/0x4c4
>> [ 1108.930000] [0010b80e] sch_direct_xmit+0xc0/0x1bc
>> [ 1108.930000] [000fe9de] dev_queue_xmit+0x160/0x3e6
>> [ 1108.930000] [001195c4] ip_finish_output+0xec/0x320
>> [ 1108.930000] [0011a768] ip_output+0x9e/0xa8
>> [ 1108.930000] [00119856] ip_local_out+0x26/0x30
>> [ 1108.930000] [0011a56e] ip_build_and_send_pkt+0x16e/0x178
>> [ 1108.930000] [0012fc96] tcp_v4_send_synack+0x52/0x90
>> [ 1108.930000] [00130f86] tcp_v4_conn_request+0x3fa/0x57c
>> [ 1108.930000] [0012a1c6] tcp_rcv_state_process+0x25e/0xa66
>> [ 1108.930000] [001309a4] tcp_v4_do_rcv+0x7c/0x1c8
>> [ 1108.930000] [00132854] tcp_v4_rcv+0x546/0x6d2
>> [ 1108.930000] [001153a8] ip_local_deliver+0x9c/0x1b0
>> [ 1108.930000] [001158e8] ip_rcv+0x42c/0x5f0
>> [ 1108.930000] [000fa74e] __netif_receive_skb+0x196/0x2ec
>> [ 1108.930000] [000fe142] process_backlog+0x72/0x11e
>> [ 1108.930000] [000fe290] net_rx_action+0xa2/0x150
>> [ 1108.930000] [0000e13c] __do_softirq+0x74/0xe4
>> [ 1108.930000] [0000e1e2] do_softirq+0x36/0x40
>> [ 1108.930000] [0000e6c6] local_bh_enable+0x7a/0xa4
>> [ 1108.930000] [000fe972] dev_queue_xmit+0xf4/0x3e6
>> [ 1108.930000] [001195c4] ip_finish_output+0xec/0x320
>> [ 1108.930000] [0011a768] ip_output+0x9e/0xa8
>> [ 1108.930000] [00119856] ip_local_out+0x26/0x30
>> [ 1108.930000] [0011a90a] ip_queue_xmit+0x198/0x426
>> [ 1108.930000] [0012bcc8] tcp_transmit_skb+0x3f0/0x76c
>> [ 1108.930000] [0012cfda] tcp_write_xmit+0x178/0x868
>> [ 1108.930000] [0012d6f8] __tcp_push_pending_frames+0x2e/0x9a
>> [ 1108.930000] [001222be] tcp_sendmsg+0x82e/0x98c
>> [ 1108.930000] [0013d9c0] inet_sendmsg+0x32/0x54
>> [ 1108.930000] [000ec25e] sock_aio_write+0xc8/0x138
>> [ 1108.930000] [00043e7e] do_sync_write+0x9e/0xfe
>> [ 1108.930000] [00043f56] vfs_write+0x78/0x84
>> [ 1108.930000] [0004446c] sys_write+0x40/0x7a
>> [ 1108.930000] [00003244] system_call+0x84/0xc2
>> [ 1108.930000]
>>
>> seems like while i transmit a packet, dm9000_interrupt try to acquire
>> the spinlock owned from the same task.
>>
>> Compiling the kernel i am getting:
>> CC kernel/irq/handle.o
>> kernel/irq/handle.c:432:3: warning: #warning __do_IRQ is deprecated.
>> Please convert to proper flow handlers
>>
>> Could the usage of __do_IRQ super-handler be a cause of the issue ?
>>
>>
>> many thanks,
>> angelo
>>
>> On 29/12/2010 19:45, Geert Uytterhoeven wrote:
>>> On Wed, Dec 29, 2010 at 19:06, Baruch Siach<baruch@tkos.co.il> wrote:
>>>> Hi Angelo,
>>>>
>>>> On Wed, Dec 29, 2010 at 02:13:22PM +0100, Angelo Dureghello wrote:
>>>>> just FYI, i tested kernel 2.6.36.2, unfortunately the issue is still
>>>>> there, below the call stack trace.
>>>> Help from the m68k experts seems to be needed. Adding the relevant
>>>> list to Cc.
>>> This is uClinux? Added Cc...
>>>
>>>>> [ 4.620000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
>>>>> [ 39.390000] BUG: spinlock recursion on CPU#0, httpd/29
>>>>> [ 39.390000] lock: 00189c44, .magic: dead4ead, .owner: httpd/29,
>>>>> .owner_cpu: 0
>>>>> [ 39.390000] Stack from 00d6a990:
>>>>> [ 39.390000] 00d6a9bc 000a9710 0017cac7 00189c44 dead4ead
>>>>> 00de48f4 0000001d 00000000
>>>>> [ 39.390000] 00189c44 0002a646 00145f70 00d6a9f0 000a98e2
>>>>> 00189c44 0017cb2d 00189c44
>>>>> [ 39.390000] 00d6aad8 0000001f 00145f5c 001523f6 00189c08
>>>>> 0002a646 00145f70 0002bc52
>>>>> [ 39.390000] 00d6a9fc 00145f7e 00189c44 00d6aa28 0002a75e
>>>>> 00189c44 0000001f 00d6aad8
>>>>> [ 39.390000] 0000001f 00145f5c 00189c08 0002a646 00145f70
>>>>> 0002bc52 00d6aa3c 00000bb6
>>>>> [ 39.390000] 0000001f 00189c44 00cfc780 00d6aa84 0000337a
>>>>> 0000001f 00d6aa4c 00000001
>>>>> [ 39.390000] Call Trace:
>>>>> [ 39.390000] [000a9710] spin_bug+0x86/0x11a
>>>>> [ 39.390000] [000a98e2] do_raw_spin_lock+0x58/0x120
>>>>> [ 39.390000] [00145f7e] _raw_spin_lock+0xe/0x14
>>>>> [ 39.390000] [0002a75e] __do_IRQ+0x2c/0x108
>>>>> [ 39.390000] [00000bb6] do_IRQ+0x48/0x62
>>>>> [ 39.390000] [0000337a] inthandler+0x6a/0x74
>>>>> [ 39.390000] [0002a82e] __do_IRQ+0xfc/0x108
>>>>> [ 39.390000] [00000bb6] do_IRQ+0x48/0x62
>>>>> [ 39.390000] [0000337a] inthandler+0x6a/0x74
>>>>> [ 39.390000] [000ef0ce] skb_release_all+0x10/0x20
>>>>> [ 39.390000] [000ee6bc] __kfree_skb+0x10/0x92
>>>>> [ 39.390000] [000ee75e] consume_skb+0x20/0x34
>>>>> [ 39.390000] [000e004e] dm9000_start_xmit+0xdc/0xec
>>>>> [ 39.390000] [000f67a2] dev_hard_start_xmit+0x146/0x472
>>>>> [ 39.390000] [00106506] sch_direct_xmit+0xc0/0x1bc
>>>>> [ 39.390000] [000f9914] dev_queue_xmit+0x160/0x3e4
>>>>> [ 39.390000] [00113b3e] ip_finish_output+0xee/0x318
>>>>> [ 39.390000] [001142b4] ip_output+0x7c/0x88
>>>>> [ 39.390000] [00113dc6] ip_local_out+0x26/0x30
>>>>> [ 39.390000] [00114d9a] ip_queue_xmit+0x152/0x374
>>>>> [ 39.390000] [00125c8c] tcp_transmit_skb+0x3f0/0x732
>>>>> [ 39.390000] [00126f26] tcp_write_xmit+0x178/0x868
>>>>> [ 39.390000] [00127644] __tcp_push_pending_frames+0x2e/0x9a
>>>>> [ 39.390000] [0011c3d6] tcp_sendmsg+0x82e/0x98c
>>>>> [ 39.390000] [00137544] inet_sendmsg+0x32/0x54
>>>>> [ 39.390000] [000e79a6] sock_aio_write+0xc8/0x138
>>>>> [ 39.390000] [00042590] do_sync_write+0x9e/0xfe
>>>>> [ 39.390000] [00042668] vfs_write+0x78/0x84
>>>>> [ 39.390000] [00042a92] sys_write+0x40/0x7a
>>>>> [ 39.390000] [00003224] system_call+0x84/0xc2
>>>>> [ 39.390000]
>>>>>
>>>>> dm9000e is as default not visible/selectable in menuconfig for
>>>>> Coldfire architectures, so this probably cannot be considered as a
>>>>> kernel bug.
>>>>>
>>>>> I going forward in investigations, every help is appreciated,
>>>>>
>>>>> regards,
>>>>> angelo
>>>>>
>>>>>
>>>>>
>>>>> On 29/12/2010 07:06, Baruch Siach wrote:
>>>>>> Hi Angelo,
>>>>>>
>>>>>> On Tue, Dec 28, 2010 at 10:52:42PM +0100, Angelo Dureghello wrote:
>>>>>>> sorry to contact you directly but i couldn't get any help from the
>>>>>>> kernel.org mailing list, since i am not a developer my mails are
>>>>>>> generally skipped.
>>>>>> The best way to get the contact info for a piece of kernel code, is
>>>>>> using the
>>>>>> get_maintainer.pl script. Running 'scripts/get_maintainer.pl -f
>>>>>> drivers/net/dm9000.c' gives the following output:
>>>>>>
>>>>>> netdev@vger.kernel.org
>>>>>> linux-kernel@vger.kernel.org
>>>>>>
>>>>>> I added both to Cc.
>>>>>>
>>>>>>> I am very near to have a custom board working with MCF5307 cpu and
>>>>>>> dm9000.
>>>>>>> I am using kernel 2.6.36-rc3 with your last patch about
>>>>>>> spinlock-recursion already included.
>>>>>> You should try to update to the latest .36 kernel, which is 
>>>>>> currently
>>>>>> 2.6.36.2. The problem that you experience might be unrelated to the
>>>>>> dm9000
>>>>>> driver (or to networking at all), so it might have been fixed in
>>>>>> this version.
>>>>>>
>>>>>>> I have "ping" and "telnet" to the embedded board fully working.
>>>>>>> If i try to get a sample web page with some images from the board
>>>>>>> httpd with a browser, in 80% of cases i get a trap/oops:
>>>>>> Try to enable KALLSYMS in your kernel .config to make your stack
>>>>>> trace more
>>>>>> meaningful. This is under 'General setup -> Configure standard
>>>>>> kernel features
>>>>>> (for small systems) -> Load all symbols for debugging/ksymoops'.
>>>>>>
>>>>>> I hope this helps.
>>>>>>
>>>>>> baruch
>>>>>>
>>>>>>> [ 4.590000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
>>>>>>> [ 67.630000] BUG: spinlock recursion on CPU#0, httpd/29
>>>>>>> [ 67.630000] lock: 00c42c06, .magic: dead4ead, .owner: httpd/29,
>>>>>>> .owner_cpu: 0
>>>>>>> [ 67.630000] Stack from 00d7b914:
>>>>>>> [ 67.630000] 00d7b940 000a8cf0 0015f693 00c42c06 dead4ead
>>>>>>> 00dec1d4 0000001d 00000000
>>>>>>> [ 67.630000] 00c42c06 00006188 00c42800 00d7b974 000a8ec2
>>>>>>> 00c42c06 0015f6f9 00002704
>>>>>>> [ 67.630000] 00000000 0000001f 00146fa4 00152f0c 00c42b60
>>>>>>> 00006188 00c42800 0002b312
>>>>>>> [ 67.630000] 00d7b984 0014701e 00c42c06 00000000 00d7b9c4
>>>>>>> 000df21c 00c42c06 00000000
>>>>>>> [ 67.630000] 00000000 0000001f 00146fa4 00152f0c 000005ea
>>>>>>> 00cfc640 00006188 000096e8
>>>>>>> [ 67.630000] 0002b312 00146fa4 00c42b60 00002704 00d7b9ec
>>>>>>> 00029d3a 0000001f 00c42800
>>>>>>> [ 67.630000] Call Trace:
>>>>>>> [ 67.630000] [000a8cf0] [000a8ec2] [0014701e] [000df21c] [00029d3a]
>>>>>>> [ 67.630000] [00029e84] [00000bb6] [0000336e] [000df162] [000effd6]
>>>>>>> [ 67.630000] [00100482] [000f312e] [000f9ebc] [0010dd2a] [0010e4a0]
>>>>>>> [ 67.630000] [0010dfb2] [0010ef80] [0011fed6] [00121170] [0012188e]
>>>>>>> [ 67.630000] [0011ecc6] [001249fe] [000e4084] [0011621c] [00131a44]
>>>>>>> [ 67.630000] [000e11ee] [00041944] [00041a1c] [00041e46] [00003218]
>>>>>>> [ 67.630000] BUG: spinlock lockup on CPU#0, httpd/29, 00c42c06
>>>>>>> [ 67.630000] Stack from 00d7b934:
>>>>>>> [ 67.630000] 00d7b974 000a8f66 0015f703 00000000 00dec1d4
>>>>>>> 0000001d 00c42c06 00002704
>>>>>>> [ 67.630000] 00000000 0000001f 00146fa4 00152f0c 00c42b60
>>>>>>> 00006188 00c42800 0002b312
>>>>>>> [ 67.630000] 00d7b984 0014701e 00c42c06 00000000 00d7b9c4
>>>>>>> 000df21c 00c42c06 00000000
>>>>>>> [ 67.630000] 00000000 0000001f 00146fa4 00152f0c 000005ea
>>>>>>> 00cfc640 00006188 000096e8
>>>>>>> [ 67.630000] 0002b312 00146fa4 00c42b60 00002704 00d7b9ec
>>>>>>> 00029d3a 0000001f 00c42800
>>>>>>> [ 67.630000] 0016c1b4 00cfc640 0000001f 0016c178 00029d10
>>>>>>> 00146fb8 00d7ba20 00029e84
>>>>>>> [ 67.630000] Call Trace:
>>>>>>> [ 67.630000] [000a8f66] [0014701e] [000df21c] [00029d3a] [00029e84]
>>>>>>> [ 67.630000] [00000bb6] [0000336e] [000df162] [000effd6] [00100482]
>>>>>>> [ 67.630000] [000f312e] [000f9ebc] [0010dd2a] [0010e4a0] [0010dfb2]
>>>>>>> [ 67.630000] [0010ef80] [0011fed6] [00121170] [0012188e] [0011ecc6]
>>>>>>> [ 67.630000] [001249fe] [000e4084] [0011621c] [00131a44] [000e11ee]
>>>>>>> [ 67.630000] [00041944] [00041a1c] [00041e46] [00003218]
>>>>>>>
>>>>>>> As i said, i was hoping in your patch but i sadly discovered it is
>>>>>>> already included in this kernel version.
>>>>>>> Hope you can give me some help or can forward me to an appropriate
>>>>>>> mailing list.
>>>> -- 
>>>> ~. .~ Tk Open Systems
>>>> =}------------------------------------------------ooO--U--Ooo------------{= 
>>>>
>>>>
>>>> - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe
>>>> linux-kernel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>> Please read the FAQ at http://www.tux.org/lkml/
>>>>
>>>
>>>
>>
>> _______________________________________________
>> uClinux-dev mailing list
>> uClinux-dev@uclinux.org
>> http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
>> This message was resent by uclinux-dev@uclinux.org
>> To unsubscribe see:
>> http://mailman.uclinux.org/mailman/options/uclinux-dev
>>
>
>


_______________________________________________
uClinux-dev mailing list
uClinux-dev@uclinux.org
http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
This message was resent by uclinux-dev@uclinux.org
To unsubscribe see:
http://mailman.uclinux.org/mailman/options/uclinux-dev
