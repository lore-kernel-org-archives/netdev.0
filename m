From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Sun, 21 Sep 2014 13:07:48 +0200
Message-ID: <541EB184.3080705@redhat.com>
References: <1411077211-20117-1-git-send-email-maheshb@google.com> <541BFEA4.9080702@redhat.com> <541C0E2A.3050309@redhat.com> <CAF2d9jjHbqpMCrS9Zm=rDO9w68TZddLztN_-QF8KBrLhZNMXWw@mail.gmail.com> <541D54CD.5030206@redhat.com> <CAF2d9jg7HDJt-2imR1P4ks5dvSo_91AVkN4aJL2Xix2tWpESoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbaIULID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2014 07:08:03 -0400
In-Reply-To: <CAF2d9jg7HDJt-2imR1P4ks5dvSo_91AVkN4aJL2Xix2tWpESoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2014 10:04 PM, Mahesh Bandewar wrote:
> On Sat, Sep 20, 2014 at 3:19 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> On 09/20/2014 02:09 AM, Mahesh Bandewar wrote:
>>> On Fri, Sep 19, 2014 at 4:06 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>>>>
>>>> On 09/19/2014 12:00 PM, Nikolay Aleksandrov wrote:
>>>>> On 09/18/2014 11:53 PM, Mahesh Bandewar wrote:
>>>>>> Earlier change to use usable slave array for TLB mode had an additional
>>>>>> performance advantage. So extending the same logic to all other modes
>>>>>> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>>>>>> Also consolidating this with the earlier TLB change.
>>>>>>
>>>>>> The main idea is to build the usable slaves array in the control path
>>>>>> and use that array for slave selection during xmit operation.
>>>>>>
>>>>>> Measured performance in a setup with a bond of 4x1G NICs with 200
>>>>>> instances of netperf for the modes involved (3ad, xor, tlb)
>>>>>> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>>>>>
>>>>>> Mode        TPS-Before   TPS-After
>>>>>>
>>>>>> 802.3ad   : 468,694      493,101
>>>>>> TLB (lb=0): 392,583      392,965
>>>>>> XOR       : 475,696      484,517
>>>>>>
>>>>>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>>>>> ---
>>>>>> v1:
>>>>>>   (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>>>>>>       the slave that need to be removed.
>>>>>>   (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>>>>>>       transition gracefully.
>>>>>>   (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>>>>>>       failure.
>>>>>>   (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>>>>>>       will populate the array even if these parameters are not used.
>>>>>>   (e) 3AD: Should handle the ad_agg_selection_logic correctly.
>>>>>> v2:
>>>>>>   (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>>>>>>   (b) Slave link-events now refresh array for all these modes.
>>>>>>   (c) Moved free-array call from bond_close() to bond_uninit().
>>>>>> v3:
>>>>>>   (a) Fixed null pointer dereference.
>>>>>>   (b) Removed bond->lock lockdep dependency.
>>>>>> v4:
>>>>>>   (a) Made to changes to comply with Nikolay's locking changes
>>>>>>   (b) Added a work-queue to refresh slave-array when RTNL is not held
>>>>>>   (c) Array refresh happens ONLY with RTNL now.
>>>>>>   (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
>>>>>>
>>>> <<<snip>>>
>>>>>> @@ -3839,6 +4003,7 @@ static void bond_uninit(struct net_device *bond_dev)
>>>>>>      struct bonding *bond = netdev_priv(bond_dev);
>>>>>>      struct list_head *iter;
>>>>>>      struct slave *slave;
>>>>>> +    struct bond_up_slave *arr;
>>>>>>
>>>>>>      bond_netpoll_cleanup(bond_dev);
>>>>>>
>>>>>> @@ -3847,6 +4012,12 @@ static void bond_uninit(struct net_device *bond_dev)
>>>>>>              __bond_release_one(bond_dev, slave->dev, true);
>>>>>>      netdev_info(bond_dev, "Released all slaves\n");
>>>>>>
>>>> Sorry but I just spotted a major problem, bond_3ad_unbind_slave() (called
>>>> from __bond_release_one) calls ad_agg_selection_logic() which can re-arm
>>>> the slave_arr work after it's supposed to be stopped here (i.e. the bond
>>>> device has been closed so all works should've been stopped) so we might
>>>> leak memory and access freed memory after all since it'll keep
>>>> re-scheduling itself until it can acquire rtnl which is after the bond
>>>> device has been destroyed.
>>>>
>>> This should not be a problem. ndo_close (bond_close()) is called
>>> before ndo_uninit(bond_uninit()), so the work-queues get cancelled
>>> there so if rearm tries to schedule some work after queue gets
>>> cancelled, it can't do much and wont harm anything.
>>> Hence there wont be any arrays built once it's free-ed completely and
>>> therefore no memory leak. I addded some instrumentation and tried
>>> following sequence -
>>>
>>> # modprobe bonding mode=4
>>> # ip link set bond0 up
>>> # [Add ip]
>>> # [Add default route]
>>> # ifenslave bond0 eth0 eth1 eth2 eth3
>>> ....
>>> [Run some backgound traffic. I used netperf.]
>>>
>>> # ip link bond0 down
>>>
>>> I did not see anything "bad" happening. Did your trial produced
>>> something unpleasant?
>>>
>> The test you've done is irrelevant to the situation that I described
>> because ndo_uninit() is called when the device is being destroyed. Moreover
>> the case I told you about would require to have an active aggregator and an
>> inactive one (i.e. so agg selection logic will get called), here is the result:
>> [  428.916586] bond1 (unregistering): Removing an active aggregator
>> [  428.916589] Failed to build slave-array.
>> [  428.916849] bond1 (unregistering): Releasing active interface eth1
>> [  428.920342] bond1 (unregistering): Released all slaves
>> [  428.923043] Failed to update slave array from WT
>> [  428.924098] Failed to update slave array from WT
>> [  428.925125] Failed to update slave array from WT
>> [  428.926120] Failed to update slave array from WT
>> [  428.927096] Failed to update slave array from WT
>> [  428.928101] Failed to update slave array from WT
>> [  428.929120] Failed to update slave array from WT
>> [  428.930086] BUG: unable to handle kernel NULL pointer dereference at
>>        (null)
>> [  428.930644] IP: [<ffffffff810aa37b>] __queue_work+0x7b/0x350
>> [  428.930946] PGD 0
>> [  428.931053] Oops: 0000 [#1] SMP
>> [  428.931053] Modules linked in: sfc ptp pps_core mdio i2c_algo_bit mtd
>> bonding(O) snd_hda_codec_generic joydev crct10dif_pclmul crc32_pclmul
>> i2c_piix4 ppdev crc32c_intel ghash_clmulni_intel parport_pc snd_hda_intel
>> snd_hda_controller snd_hda_codec snd_hwdep snd_pcm snd_timer 9pnet_virtio
>> snd 9pnet pcspkr parport i2ccore serio_raw virtio_console virtio_balloon
>> pvpanic soundcore virtio_blk virtio_net ata_generic floppy pata_acpi
>> virtio_pci virtio_ring virtio
>> [  428.935022] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O
>> 3.17.0-rc4+ #30
>> [  428.935022] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [  428.935022] task: ffffffff81c1b460 ti: ffffffff81c00000 task.ti:
>> ffffffff81c00000
>> [  428.935022] RIP: 0010:[<ffffffff810aa37b>]  [<ffffffff810aa37b>]
>> __queue_work+0x7b/0x350
>> [  428.935022] RSP: 0018:ffff88005f003e28  EFLAGS: 00010086
>> [  428.935022] RAX: ffff88005c05c800 RBX: 0000000000000000 RCX:
>> 0000000000000000
>> [  428.935022] RDX: 0000000000000000 RSI: 0000000000000006 RDI:
>> ffff88005a4fbd58
>> [  428.935022] RBP: ffff88005f003e60 R08: 0000000000000046 R09:
>> ffffffff8225abc2
>> [  428.935022] R10: 0000000000000004 R11: 0000000000000005 R12:
>> ffff88005a4fbd58
>> [  428.935022] R13: 0000000000000008 R14: ffff88004b211800 R15:
>> 00000000000102f0
>> [  428.935022] FS:  0000000000000000(0000) GS:ffff88005f000000(0000)
>> knlGS:0000000000000000
>> [  428.935022] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  428.935022] CR2: 0000000000000000 CR3: 000000004abde000 CR4:
>> 00000000000406f0
>> [  428.935022] Stack:
>> [  428.935022]  0a19522f72b12222 0000000081c1b460 ffffffff8225abc0
>> ffff88005a4fbd78
>> [  428.935022]  0000000000000101 ffffffff810aa650 ffff88005a4fbd58
>> ffff88005f003e70
>> [  428.935022]  ffffffff810aa668 ffff88005f003ea8 ffffffff810f3536
>> ffffffff8225abc0
>> [  428.935022] Call Trace:
>> [  428.935022]  <IRQ>
>> [  428.935022]
>> [  428.935022]  [<ffffffff810aa650>] ? __queue_work+0x350/0x350
>> [  428.935022]  [<ffffffff810aa668>] delayed_work_timer_fn+0x18/0x20
>> [  428.935022]  [<ffffffff810f3536>] call_timer_fn+0x36/0x120
>> [  428.935022]  [<ffffffff810aa650>] ? __queue_work+0x350/0x350
>> [  428.935022]  [<ffffffff810f38f5>] run_timer_softirq+0x1a5/0x320
>> [  428.935022]  [<ffffffff81096dc5>] __do_softirq+0xf5/0x2b0
>> [  428.935022]  [<ffffffff810971fd>] irq_exit+0xbd/0xd0
>> [  428.935022]  [<ffffffff8173b715>] smp_apic_timer_interrupt+0x45/0x60
>> [  428.935022]  [<ffffffff8173981d>] apic_timer_interrupt+0x6d/0x80
>> [  428.935022]  <EOI>
>> [  428.935022]
>> [  428.935022]  [<ffffffff810581c6>] ? native_safe_halt+0x6/0x10
>> [  428.935022]  [<ffffffff8101f36f>] default_idle+0x1f/0xe0
>> [  428.935022]  [<ffffffff8101fd8f>] arch_cpu_idle+0xf/0x20
>> [  428.935022]  [<ffffffff810d25dd>] cpu_startup_entry+0x38d/0x3c0
>> [  428.935022]  [<ffffffff81722927>] rest_init+0x87/0x90
>> [  428.935022]  [<ffffffff81d3510e>] start_kernel+0x482/0x4a3
>> [  428.935022]  [<ffffffff81d34a85>] ? set_init_arg+0x53/0x53
>> [  428.935022]  [<ffffffff81d34120>] ? early_idt_handlers+0x120/0x120
>> [  428.935022]  [<ffffffff81d345ee>] x86_64_start_reservations+0x2a/0x2c
>> [  428.935022]  [<ffffffff81d3473d>] x86_64_start_kernel+0x14d/0x170
>> [  428.935022] Code: 84 bb 01 00 00 a8 02 0f 85 eb 00 00 00 48 63 45 d4 49
>> 8b 9e 08 01 00 00 48 03 1c c5 60 fa d0 81 4c 89 e7 e8 18 f5 ff ff 48 85 c0
>> <48> 8b 3b 0f 84 7c 01 00 00 48 39 c7 0f 84 73 01 00 00 48 89 c7
>> [  428.935022] RIP  [<ffffffff810aa37b>] __queue_work+0x7b/0x350
>> [  428.935022]  RSP <ffff88005f003e28>
>> [  428.935022] CR2: 0000000000000000
>>
>> This is because it keeps trying to re-schedule even though the interface's
>> memory has been freed.
>>
> Hmm, how do we handle this?
> 
This is tricky and what concerns me more is that people might make this
mistake again in the future. It's easy to unknowingly make use of a
function that re-schedules this from the wrong place.
What I just noticed is that for all 3ad cases you could pull the scheduling
in the bond_3ad_state_machine_handler() function.
The call sites of ad_agg_selection_logic() are:
- 3ad unbind slave (no need to schedule here as __bond_release_one would
rebuild the array anyhow)
- bond_3ad_state_machine_handler() <- here's where the schedule should
happen as this gets stopped first when the bond is closed and can't get
restarted unless it's opened again.
- ad_port_selection_logic() <- this is called from
bond_3ad_state_machine_handler() only, so this case will be handled as well.

The other 2 functions that you convert - ad_enable/disable_collecting are
used only from ad_mux_machine() which is only called in
bond_3ad_state_machine_handler().

So basically you can pull all rebuild schedules in their common caller -
bond_3ad_state_machine_handler(), just make a flag to note that a rebuild
is needed probably something similar to should_notify_rtnl.
This way you can remove the scheduling from the various 3ad functions that
may get used and will have it only in 1 place which is more easily controlled.

Of course, the alternative would be once again - convert
bond_3ad_state_machine_handler() to RTNL, but that has its own set of problems.

>> While testing this I spotted another issue as well - Failed to build
>> slave_arr message has been printed too many times because you print it in
>> 3ad mode when there's no active aggregator (bond_3ad_get_active_agg_info
>> check in bond_update_slave_arr) which leads to re-scheduling which also
>> lead to a deadlock.
>>
> I think this can be corrected with pr_ratelimited() call.
> 
IMO it shouldn't print anything if it couldn't rebuild the array due to
missing active aggregator as that's not an error condition. It should
though probably clean out the slave array because transmission shouldn't be
possible without an active aggregator in 3ad.
