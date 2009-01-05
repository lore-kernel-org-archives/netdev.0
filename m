From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to request_firmware()
Date: Mon, 05 Jan 2009 15:58:25 +0100
Message-ID: <49622011.4080203@hartkopp.net>
References: <1230626497.24796.26.camel@jaswinder.satnam>	 <49620AFE.6040409@hartkopp.net> <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	davem@redhat.com, jgarzik@redhat.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	mchan@broadcom.com, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <3f9a31f40901050612v700d2542r1e3e400bf0fe3d33@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jaswinder Singh Rajput wrote:
> On Mon, Jan 5, 2009 at 6:58 PM, Oliver Hartkopp <oliver@hartkopp.net> wrote:
>   
>> 077f849de42e58172e25ccb24df4c1a13e82420c ("firmware: convert tg3 driver to
>> request_firmware()")
>>
>> and i discovered that
>>
>> 1. I needed to compile the tg3 driver as *module* now as it was not able to
>> read the firmware when built-in.
>>
>>     
>
> Please compile it as build in.
>   

The firmware, right?!

When compiling tg3 as module the request_firmware() worked fine, as the 
fs is available then.

Now i went back to compiling tg3 as built-in driver and i also defined 
CONFIG_FIRMWARE_IN_KERNEL which is also working properly. Thanks for the 
advise.

Btw. the locking issue is still there:

(..)
[    0.918196] tg3.c:v3.97 (December 10, 2008)
[    0.918405] vendor=8086 device=2849
[    0.929869] tg3 0000:09:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.941454] tg3 0000:09:00.0: setting latency timer to 64
[    0.949079] tg3 0000:09:00.0: PME# disabled
[    0.971785] tg3 0000:09:00.0: firmware: using built-in firmware 
tigon/tg3_tso.bin
[    0.983963] eth0: Tigon3 [partno(BCM95755m) rev a002] (PCI Express) 
MAC address 00:1c:xx:xx:xx:xx:xx
[    0.995585] eth0: attached PHY is 5755 (10/100/1000Base-T Ethernet) 
(WireSpeed[1])
[    1.007223] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    1.018860] eth0: dma_rwctrl[76180000] dma_mask[64-bit]
(..)
[   15.621281] tg3 0000:09:00.0: PME# disabled
[   15.621656] tg3 0000:09:00.0: irq 319 for MSI/MSI-X
[   15.681883] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   17.260196]
[   17.260198] =================================
[   17.260473] [ INFO: inconsistent lock state ]
[   17.260672] 2.6.28-03196-gd1cea9d #9
[   17.260836] ---------------------------------
[   17.261036] inconsistent {softirq-on-R} -> {in-softirq-W} usage.
[   17.261311] swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
[   17.261538]  (dev_base_lock){-+--}, at: [<c03320e7>] 
linkwatch_fire_event+0x58/0xd6
[   17.261918] {softirq-on-R} state was registered at:
[   17.262141]   [<c013fe6f>] __lock_acquire+0x2a6/0xadd
[   17.262383]   [<c0140703>] lock_acquire+0x5d/0x7a
[   17.262608]   [<c03b63be>] _read_lock+0x1b/0x2a
[   17.262827]   [<c03337f3>] show_address+0x23/0x55
[   17.263053]   [<c028943c>] dev_attr_show+0x1b/0x38
[   17.263283]   [<c01a8802>] sysfs_read_file+0x92/0xef
[   17.263397]   [<c017453d>] vfs_read+0x79/0xaa
[   17.263397]   [<c0174607>] sys_read+0x3b/0x60
[   17.263397]   [<c0102fd5>] sysenter_do_call+0x12/0x35
[   17.263397]   [<ffffffff>] 0xffffffff
[   17.263397] irq event stamp: 136252
[   17.263397] hardirqs last  enabled at (136252): [<c032739a>] 
net_rx_action+0x118/0x13e
[   17.263397] hardirqs last disabled at (136251): [<c03272bb>] 
net_rx_action+0x39/0x13e
[   17.263397] softirqs last  enabled at (136232): [<c012794a>] 
__do_softirq+0x135/0x13d
[   17.263397] softirqs last disabled at (136249): [<c012798c>] 
do_softirq+0x3a/0x52
[   17.263397]
[   17.263397] other info that might help us debug this:
[   17.263397] 1 lock held by swapper/0:
[   17.263397]  #0:  (&tp->lock){-+..}, at: [<c029e06b>] tg3_poll+0x76/0x8bf
[   17.263397]
[   17.263397] stack backtrace:
[   17.263397] Pid: 0, comm: swapper Not tainted 2.6.28-03196-gd1cea9d #9
[   17.263397] Call Trace:
[   17.263397]  [<c03b42f7>] ? printk+0xf/0x11
[   17.263397]  [<c013eda5>] valid_state+0x12a/0x13d
[   17.263397]  [<c013f210>] mark_lock+0x14c/0x330
[   17.263397]  [<c013fdf2>] __lock_acquire+0x229/0xadd
[   17.263397]  [<c02077c5>] ? blk_rq_map_sg+0xeb/0x231
[   17.263397]  [<c013e438>] ? register_lock_class+0x17/0x26b
[   17.263397]  [<c0140703>] lock_acquire+0x5d/0x7a
[   17.263397]  [<c03320e7>] ? linkwatch_fire_event+0x58/0xd6
[   17.263397]  [<c03b629d>] _write_lock_bh+0x20/0x2f
[   17.263397]  [<c03320e7>] ? linkwatch_fire_event+0x58/0xd6
[   17.263397]  [<c03320e7>] linkwatch_fire_event+0x58/0xd6
[   17.263397]  [<c0334842>] netif_carrier_on+0x1c/0x34
[   17.263397]  [<c0295185>] tg3_setup_copper_phy+0xa80/0xac2
[   17.263397]  [<c02961f0>] tg3_setup_phy+0x1029/0x1172
[   17.263397]  [<c029e06b>] ? tg3_poll+0x76/0x8bf
[   17.263397]  [<c03b61b8>] ? _spin_lock+0x22/0x2a
[   17.263397]  [<c029e0ab>] tg3_poll+0xb6/0x8bf
[   17.263397]  [<c0140697>] ? __lock_acquire+0xace/0xadd
[   17.263397]  [<c032739a>] ? net_rx_action+0x118/0x13e
[   17.263397]  [<c03272e4>] net_rx_action+0x62/0x13e
[   17.263397]  [<c01278a4>] __do_softirq+0x8f/0x13d
[   17.263397]  [<c012798c>] do_softirq+0x3a/0x52
[   17.263397]  [<c0127ab0>] irq_exit+0x44/0x83
[   17.263397]  [<c0104d32>] do_IRQ+0x96/0xac
[   17.263397]  [<c010362c>] common_interrupt+0x2c/0x34
[   17.263397]  [<c013007b>] ? usermodehelper_disable+0x89/0xa3
[   17.263397]  [<c02606a2>] ? acpi_idle_enter_simple+0x151/0x182
[   17.263397]  [<c0260373>] acpi_idle_enter_bm+0xc6/0x2a4
[   17.263397]  [<c03117c5>] cpuidle_idle_call+0x60/0x93
[   17.263397]  [<c0102139>] cpu_idle+0x70/0x93
[   17.263397]  [<c03b1b70>] start_secondary+0x19a/0x1a2
[   17.321344] tg3: eth0: Link is up at 100 Mbps, full duplex.
[   17.331114] tg3: eth0: Flow control is on for TX and on for RX.
[   17.342066] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready


Regards,
Oliver

ps. I'm running Debian unstable if this info is needed.
