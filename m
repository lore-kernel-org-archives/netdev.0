From: Linda Walsh <lkml@tlinx.org>
Subject: Re: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Fri, 01 Mar 2013 21:21:31 -0800
Message-ID: <51318C5B.60001@tlinx.org>
References: <513063B4.8070604@tlinx.org> <1362155087.15793.54.camel@edumazet-glaptop> <51317FCF.1070400@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ishtar.tlinx.org ([173.164.175.65]:49841 "EHLO
	Ishtar.sc.tlinx.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3CBFVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 00:21:43 -0500
In-Reply-To: <51317FCF.1070400@tlinx.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





Linda Walsh wrote:
>
>
> This patch is not in the latest kernel.  I don't know if it is the
> 'best' way, but it does stop BUG error messages.
---
Update -- it *used* to stop the messages in 3.6.7.

It no longer stops the messages in 3.8.1 -- (and isn't present by
default -- tried
adding the unlock/lock -- no difference.

Weird. *sigh*

>
>
> -------- Original Message --------
> Subject: 	Re: BUG: scheduling while atomic:
> ifup-bonding/3711/0x00000002 -- V3.6.7
> Date: 	Wed, 28 Nov 2012 13:17:31 -0800
> From: 	Linda Walsh <lkml@tlinx.org>
> To: 	Cong Wang <xiyou.wangcong@gmail.com>
> CC: 	LKML <linux-kernel@vger.kernel.org>, Linux Kernel Network
> Developers <netdev@vger.kernel.org>
> References: 	<50B5248A.5010908@tlinx.org>
> <CAM_iQpUW2Oz9p0K0gGKc6JoD7WAu0kJtRa4uBSe+WfXg0Nn3jA@mail.gmail.com>
>
>
>
> Cong Wang wrote:
>> Does this quick fix help?
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 5f5b69f..4a4d9eb 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1785,7 +1785,9 @@ int bond_enslave(struct net_device *bond_dev,
>> struct net_device *slave_dev)
>>                 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
>>                         (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
>>
>> +       read_unlock(&bond->lock);
>>         bond_update_speed_duplex(new_slave);
>> +       read_lock(&bond->lock);
>>
>>         if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
>>                 /* if there is a primary slave, remember it */
>>
>> Thanks!
>>   
>
>
>
>
> Eric Dumazet wrote:
>> On Fri, 2013-03-01 at 00:15 -0800, Linda Walsh wrote:
>>   
>>> Just installed 3.8.1....
>>>
>>> Thought this had been fixed?  Note it causes the kernel to
>>> show up as tainted after the 1st...
>>>
>>>     
>>
>> CC netdev & Jay Vosburgh & Jeff Kirsher
>>
>>   
>>> As the system was coming up and initializing the bond0 driver:
>>>
>>>
>>> [   19.847743] ixgbe 0000:06:00.0: registered PHC device on eth_s2_0
>>> [   20.258245] BUG: scheduling while atomic: ifup-bonding/2003/0x00000002
>>> [   20.264812] 4 locks held by ifup-bonding/2003:
>>> [   20.269298]  #0:  (&buffer->mutex){......}, at: [<ffffffff811c401f>]
>>> sysfs_write_file+0x3f/0x150
>>> [   20.278319]  #1:  (s_active#59){......}, at: [<ffffffff811c409b>]
>>> sysfs_write_file+0xbb/0x150
>>> [   20.287088]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590bf0>]
>>> rtnl_trylock+0x10/0x20
>>> [   20.295373]  #3:  (&bond->lock){......}, at: [<ffffffff8145be6f>]
>>> bond_enslave+0x4ef/0xb80
>>> [   20.303912] Modules linked in: iptable_filter kvm_intel kvm acpi_cpufreq
>>> mperf button processor mousedev iTCO_wdt
>>> [   20.314695] Pid: 2003, comm: ifup-bonding Not tainted 3.8.1-Isht-Van #5
>>> [   20.321340] Call Trace:
>>> [   20.323833]  [<ffffffff8162b029>] __schedule_bug+0x5e/0x6c
>>> [   20.329356]  [<ffffffff81634592>] __schedule+0x762/0x7f0
>>> [   20.334701]  [<ffffffff81634734>] schedule+0x24/0x70
>>> [   20.339703]  [<ffffffff816336f4>] schedule_hrtimeout_range_clock+0xa4/0x130
>>> [   20.346699]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   20.352130]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
>>> [   20.358434]  [<ffffffff8163378e>] schedule_hrtimeout_range+0xe/0x10
>>> [   20.364734]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
>>> [   20.370082]  [<ffffffff814b2d7c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
>>> [   20.376905]  [<ffffffff814aeb0d>] ixgbe_read_phy_reg_generic+0x3d/0x140
>>> [   20.383553]  [<ffffffff814aedac>]
>>> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
>>> [   20.391499]  [<ffffffff8145be6f>] ? bond_enslave+0x4ef/0xb80
>>> [   20.397194]  [<ffffffff814a64e4>] ixgbe_get_settings+0x34/0x340
>>> [   20.403148]  [<ffffffff81586ab8>] __ethtool_get_settings+0x88/0x130
>>> [   20.409448]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
>>> [   20.415833]  [<ffffffff8145bed9>] bond_enslave+0x559/0xb80
>>> [   20.421356]  [<ffffffff8146454f>] bonding_store_slaves+0x16f/0x1c0
>>> [   20.427569]  [<ffffffff813bfb83>] dev_attr_store+0x13/0x30
>>> [   20.433091]  [<ffffffff811c40b4>] sysfs_write_file+0xd4/0x150
>>> [   20.438872]  [<ffffffff81154b81>] vfs_write+0xb1/0x190
>>> [   20.444047]  [<ffffffff81154ee0>] sys_write+0x50/0xa0
>>> [   20.449137]  [<ffffffff81637092>] system_call_fastpath+0x16/0x1b
>>> [   20.455264] BUG: scheduling while atomic: ifup-bonding/2003/0x00000002
>>> [   20.461851] 4 locks held by ifup-bonding/2003:
>>> [   20.466334]  #0:  (&buffer->mutex){......}, at: [<ffffffff811c401f>]
>>> sysfs_write_file+0x3f/0x150
>>> [   20.475356]  #1:  (s_active#59){......}, at: [<ffffffff811c409b>]
>>> sysfs_write_file+0xbb/0x150
>>> [   20.484117]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590bf0>]
>>> rtnl_trylock+0x10/0x20
>>> [   20.492403]  #3:  (&bond->lock){......}, at: [<ffffffff8145be6f>]
>>> bond_enslave+0x4ef/0xb80
>>> [   20.500902] Modules linked in: iptable_filter kvm_intel kvm acpi_cpufreq
>>> mperf button processor mousedev iTCO_wdt
>>> [   20.511640] Pid: 2003, comm: ifup-bonding Tainted: G        W
>>> 3.8.1-Isht-Van #5
>>> [   20.519240] Call Trace:
>>> [   20.521729]  [<ffffffff8162b029>] __schedule_bug+0x5e/0x6c
>>> [   20.527251]  [<ffffffff81634592>] __schedule+0x762/0x7f0
>>> [   20.532599]  [<ffffffff81634734>] schedule+0x24/0x70
>>> [   20.537599]  [<ffffffff816336f4>] schedule_hrtimeout_range_clock+0xa4/0x130
>>> [   20.544592]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   20.550026]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   20.555462]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
>>> [   20.561763]  [<ffffffff8163378e>] schedule_hrtimeout_range+0xe/0x10
>>> [   20.568064]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
>>> [   20.573415]  [<ffffffff814b2cae>] ixgbe_release_swfw_sync_X540+0x4e/0x60
>>> [   20.580146]  [<ffffffff814aebdd>] ixgbe_read_phy_reg_generic+0x10d/0x140
>>> [   20.586960]  [<ffffffff814aedac>]
>>> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
>>> [   20.594908]  [<ffffffff8145be6f>] ? bond_enslave+0x4ef/0xb80
>>> [   20.600601]  [<ffffffff814a64e4>] ixgbe_get_settings+0x34/0x340
>>> [   20.606557]  [<ffffffff81586ab8>] __ethtool_get_settings+0x88/0x130
>>> [   20.612858]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
>>> [   20.619244]  [<ffffffff8145bed9>] bond_enslave+0x559/0xb80
>>> [   20.624767]  [<ffffffff8146454f>] bonding_store_slaves+0x16f/0x1c0
>>> [   20.630983]  [<ffffffff813bfb83>] dev_attr_store+0x13/0x30
>>> [   20.636503]  [<ffffffff811c40b4>] sysfs_write_file+0xd4/0x150
>>> [   20.642283]  [<ffffffff81154b81>] vfs_write+0xb1/0x190
>>> [   20.647462]  [<ffffffff81154ee0>] sys_write+0x50/0xa0
>>> [   20.652548]  [<ffffffff81637092>] system_call_fastpath+0x16/0x1b
>>> [   20.658696] bonding: bond0: enslaving eth_s2_0 as an active interface with a
>>> down link.
>>> [   20.676577] bonding: bond0: Adding slave eth_s2_1.
>>> [   20.743760] pps pps1: new PPS source ptp1
>>> [   20.747792] ixgbe 0000:06:00.1: registered PHC device on eth_s2_1
>>> [   21.150267] BUG: scheduling while atomic: ifup-bonding/2003/0x00000002
>>> [   21.156836] 4 locks held by ifup-bonding/2003:
>>> [   21.161319]  #0:  (&buffer->mutex){......}, at: [<ffffffff811c401f>]
>>> sysfs_write_file+0x3f/0x150
>>> [   21.170388]  #1:  (s_active#59){......}, at: [<ffffffff811c409b>]
>>> sysfs_write_file+0xbb/0x150
>>> [   21.179149]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590bf0>]
>>> rtnl_trylock+0x10/0x20
>>> [   21.187403]  #3:  (&bond->lock){......}, at: [<ffffffff8145be6f>]
>>> bond_enslave+0x4ef/0xb80
>>> [   21.195904] Modules linked in: iptable_filter kvm_intel kvm acpi_cpufreq
>>> mperf button processor mousedev iTCO_wdt
>>> [   21.206644] Pid: 2003, comm: ifup-bonding Tainted: G        W
>>> 3.8.1-Isht-Van #5
>>> [   21.214240] Call Trace:
>>> [   21.216732]  [<ffffffff8162b029>] __schedule_bug+0x5e/0x6c
>>> [   21.222254]  [<ffffffff81634592>] __schedule+0x762/0x7f0
>>> [   21.227604]  [<ffffffff81634734>] schedule+0x24/0x70
>>> [   21.232606]  [<ffffffff816336f4>] schedule_hrtimeout_range_clock+0xa4/0x130
>>> [   21.239601]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   21.245033]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
>>> [   21.251339]  [<ffffffff8163378e>] schedule_hrtimeout_range+0xe/0x10
>>> [   21.257635]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
>>> [   21.262987]  [<ffffffff814b2d7c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
>>> [   21.269811]  [<ffffffff814aeb0d>] ixgbe_read_phy_reg_generic+0x3d/0x140
>>> [   21.276461]  [<ffffffff814aedac>]
>>> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
>>> [   21.284409]  [<ffffffff8145be6f>] ? bond_enslave+0x4ef/0xb80
>>> [   21.290106]  [<ffffffff814a64e4>] ixgbe_get_settings+0x34/0x340
>>> [   21.296067]  [<ffffffff81586ab8>] __ethtool_get_settings+0x88/0x130
>>> [   21.302369]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
>>> [   21.308754]  [<ffffffff8145bed9>] bond_enslave+0x559/0xb80
>>> [   21.314278]  [<ffffffff8146454f>] bonding_store_slaves+0x16f/0x1c0
>>> [   21.320491]  [<ffffffff813bfb83>] dev_attr_store+0x13/0x30
>>> [   21.326009]  [<ffffffff811c40b4>] sysfs_write_file+0xd4/0x150
>>> [   21.331793]  [<ffffffff81154b81>] vfs_write+0xb1/0x190
>>> [   21.336964]  [<ffffffff81154ee0>] sys_write+0x50/0xa0
>>> [   21.342053]  [<ffffffff81637092>] system_call_fastpath+0x16/0x1b
>>> [   21.348191] BUG: scheduling while atomic: ifup-bonding/2003/0x00000002
>>> [   21.354775] 4 locks held by ifup-bonding/2003:
>>> [   21.359258]  #0:  (&buffer->mutex){......}, at: [<ffffffff811c401f>]
>>> sysfs_write_file+0x3f/0x150
>>> [   21.368283]  #1:  (s_active#59){......}, at: [<ffffffff811c409b>]
>>> sysfs_write_file+0xbb/0x150
>>> [   21.377104]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590bf0>]
>>> rtnl_trylock+0x10/0x20
>>> [   21.385343]  #3:  (&bond->lock){......}, at: [<ffffffff8145be6f>]
>>> bond_enslave+0x4ef/0xb80
>>> [   21.393887] Modules linked in: iptable_filter kvm_intel kvm acpi_cpufreq
>>> mperf button processor mousedev iTCO_wdt
>>> [   21.404575] Pid: 2003, comm: ifup-bonding Tainted: G        W
>>> 3.8.1-Isht-Van #5
>>> [   21.412176] Call Trace:
>>> [   21.414666]  [<ffffffff8162b029>] __schedule_bug+0x5e/0x6c
>>> [   21.420188]  [<ffffffff81634592>] __schedule+0x762/0x7f0
>>> [   21.425536]  [<ffffffff81634734>] schedule+0x24/0x70
>>> [   21.430541]  [<ffffffff816336f4>] schedule_hrtimeout_range_clock+0xa4/0x130
>>> [   21.437532]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   21.442967]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
>>> [   21.448407]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
>>> [   21.454712]  [<ffffffff8163378e>] schedule_hrtimeout_range+0xe/0x10
>>> [   21.461015]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
>>> [   21.466370]  [<ffffffff814b2cae>] ixgbe_release_swfw_sync_X540+0x4e/0x60
>>> [   21.473105]  [<ffffffff814aebdd>] ixgbe_read_phy_reg_generic+0x10d/0x140
>>> [   21.479843]  [<ffffffff814aedac>]
>>> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
>>> [   21.487787]  [<ffffffff8145be6f>] ? bond_enslave+0x4ef/0xb80
>>> [   21.493513]  [<ffffffff814a64e4>] ixgbe_get_settings+0x34/0x340
>>> [   21.499468]  [<ffffffff81586ab8>] __ethtool_get_settings+0x88/0x130
>>> [   21.505767]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
>>> [   21.512153]  [<ffffffff8145bed9>] bond_enslave+0x559/0xb80
>>> [   21.517677]  [<ffffffff8146454f>] bonding_store_slaves+0x16f/0x1c0
>>> [   21.523889]  [<ffffffff813bfb83>] dev_attr_store+0x13/0x30
>>> [   21.529412]  [<ffffffff811c40b4>] sysfs_write_file+0xd4/0x150
>>> [   21.535193]  [<ffffffff81154b81>] vfs_write+0xb1/0x190
>>> [   21.540373]  [<ffffffff81154ee0>] sys_write+0x50/0xa0
>>> [   21.545463]  [<ffffffff81637092>] system_call_fastpath+0x16/0x1b
>>> --
>>>     
>>
>>   
>
