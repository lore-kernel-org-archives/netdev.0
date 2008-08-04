From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: 2.6.27-rc1-git4 BUG: sched while atomic
Date: Mon, 04 Aug 2008 15:00:55 -0300
Message-ID: <489743D7.7040209@linux.vnet.ibm.com>
References: <20080804094835.da083484.randy.dunlap@oracle.com> <20080804101712.659780ef@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	netdev <netdev@vger.kernel.org>, mchan@broadcom.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:60296 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756727AbYHDSG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 14:06:26 -0400
Received: from mailhub3.br.ibm.com (unknown [9.18.232.110])
	by igw3.br.ibm.com (Postfix) with ESMTP id 0D08039000D
	for <netdev@vger.kernel.org>; Mon,  4 Aug 2008 14:47:14 -0300 (BRST)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m74I1RWI4366392
	for <netdev@vger.kernel.org>; Mon, 4 Aug 2008 15:01:33 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m74I1KdS026188
	for <netdev@vger.kernel.org>; Mon, 4 Aug 2008 15:01:22 -0300
In-Reply-To: <20080804101712.659780ef@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also have an issue like this one using the latest linus's tree (2.6.27-rc1).  
My calltrace is a bit different, follows: 

BUG: scheduling while atomic: ip/3205/0x00000100
Modules linked in: autofs4 hidp rfcomm l2cap bluetooth sunrpc iptable_filter ip_tables ip6t_REJECT xt_tcpudp ip6table_filter ip6_tables x_tables ipv6 dm_mirror dm_log dm_multipath dm_mod snd_powermac snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_timer snd soundcore parport_pc lp parport sg tg3 libphy windfarm_pid windfarm_smu_sat i2c_core shpchp ipr libata sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Call Trace:

[c0000001eb98b160] [c00000000001038c] .show_stack+0x70/0x184 (unreliable)
[c0000001eb98b210] [c00000000006b03c] .__schedule_bug+0x6c/0x88
[c0000001eb98b2a0] [c0000000004020c8] .schedule+0xc4/0x8e4
[c0000001eb98b390] [c000000000402f48] .schedule_timeout+0xa8/0xe8
[c0000001eb98b460] [c00000000007f478] .msleep+0x20/0x38
[c0000001eb98b4d0] [c0000000001e5608] .pci_set_power_state+0x274/0x3cc
[c0000001eb98b580] [d0000000004774f0] .tg3_set_power_state+0x80/0xab4 [tg3]
[c0000001eb98b630] [d000000000480fa4] .tg3_open+0x5c/0x96c [tg3]
[c0000001eb98b6f0] [c00000000036d658] .dev_open+0xe4/0x154
[c0000001eb98b770] [c00000000036baf4] .dev_change_flags+0x104/0x204
[c0000001eb98b810] [c0000000003c9e40] .devinet_ioctl+0x2c4/0x758
[c0000001eb98b910] [c0000000003cadf0] .inet_ioctl+0xd8/0x12c
[c0000001eb98b990] [c00000000035cad8] .sock_ioctl+0x2b8/0x310
[c0000001eb98ba30] [c000000000108c74] .vfs_ioctl+0x5c/0xf0
[c0000001eb98bad0] [c000000000109114] .do_vfs_ioctl+0x40c/0x448
[c0000001eb98bb80] [c0000000001091c0] .sys_ioctl+0x70/0xb4
[c0000001eb98bc30] [c00000000013ddb4] .dev_ifsioc+0x1b0/0x3e4
[c0000001eb98bd40] [c00000000013d374] .compat_sys_ioctl+0x3d4/0x468
[c0000001eb98be30] [c0000000000086b4] syscall_exit+0x0/0x40

This error is easily reproducible, just run "ifup ethX; ifdown ethX".
The cable connection is ok, and the device is working fine with older kernels.
It's important to note that I am running on a PPC machine (JS21). 

Stephen Hemminger wrote:
> On Mon, 4 Aug 2008 09:48:35 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
>> Usually (e.g., in 2.6.27-rc1 & earlier), I see lots of these messages for
>> some reason:
>>
>> tg3: eth2: Link is up at 1000 Mbps, full duplex.
>> tg3: eth2: Flow control is off for TX and off for RX.
>> tg3: eth3: Link is up at 1000 Mbps, full duplex.
>> tg3: eth3: Flow control is off for TX and off for RX.
>> bnx2: eth1: using MSI
>> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
>> tg3: eth2: Link is up at 1000 Mbps, full duplex.
>> tg3: eth2: Flow control is off for TX and off for RX.
>> tg3: eth3: Link is up at 1000 Mbps, full duplex.
>> tg3: eth3: Flow control is off for TX and off for RX.
>> bnx2: eth1: using MSI
>> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
>> tg3: eth2: Link is up at 1000 Mbps, full duplex.
>> tg3: eth2: Flow control is off for TX and off for RX.
>> tg3: eth3: Link is up at 1000 Mbps, full duplex.
>> tg3: eth3: Flow control is off for TX and off for RX.
>> bnx2: eth1: using MSI
>> bnx2: eth1 NIC SerDes Link is Up, 1000 Mbps full duplex
>> tg3: eth2: Link is up at 1000 Mbps, full duplex.
>> tg3: eth2: Flow control is off for TX and off for RX.
>> tg3: eth3: Link is up at 1000 Mbps, full duplex.
>> tg3: eth3: Flow control is off for TX and off for RX.
>> bnx2: eth1: using MSI
> 
> You have a bad cable or broken ethernet switch that is causing
> the link to restart autonegotiation.
> 
>> In 2.6.27-rc1-git4, I now see this (39 times):
>>
>> BUG: scheduling while atomic: ifconfig/16971/0x00000100
>> Modules linked in: parport_pc lp parport tg3 lpfc cciss ehci_hcd ohci_hcd uhci_hcd
>> Pid: 16971, comm: ifconfig Not tainted 2.6.27-rc1-git4 #1
>>
>> Call Trace:
>>  [<ffffffff80283db9>] ? page_add_new_anon_rmap+0x20/0x22
>>  [<ffffffff802310e9>] __schedule_bug+0x62/0x66
>>  [<ffffffff80551146>] schedule+0x99/0x759
>>  [<ffffffff8023dc9f>] ? __mod_timer+0xc1/0xd3
>>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>>  [<ffffffff80551ce4>] schedule_timeout+0x8d/0xb4
>>  [<ffffffff8023d99e>] ? process_timeout+0x0/0xb
>>  [<ffffffff80551cdf>] ? schedule_timeout+0x88/0xb4
>>  [<ffffffff80551d24>] schedule_timeout_uninterruptible+0x19/0x1b
>>  [<ffffffff8023dcc5>] msleep+0x14/0x1e
>>  [<ffffffff80375f2f>] pci_set_power_state+0x1cd/0x292
>>  [<ffffffff803739fc>] ? pci_bus_write_config_dword+0x64/0x73
>>  [<ffffffffa00651b6>] tg3_set_power_state+0x58/0x884 [tg3]
>>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>>  [<ffffffffa006b57a>] tg3_open+0x46/0x6cc [tg3]
>>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>>  [<ffffffff804bdcfe>] dev_open+0x73/0xa8
>>  [<ffffffff804bbf5e>] dev_change_flags+0xab/0x167
>>  [<ffffffff804f7094>] devinet_ioctl+0x269/0x5da
>>  [<ffffffff8026d9da>] ? unlock_page+0x2d/0x32
>>  [<ffffffff804f7ca8>] inet_ioctl+0x92/0xaa
>>  [<ffffffff804b2046>] sock_ioctl+0x1d1/0x1fb
>>  [<ffffffff802a50aa>] vfs_ioctl+0x2a/0x77
>>  [<ffffffff802a534c>] do_vfs_ioctl+0x255/0x272
>>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>>  [<ffffffff802a53ab>] sys_ioctl+0x42/0x67
>>  [<ffffffff8020beeb>] system_call_fastpath+0x16/0x1b
> 
> This is a bug.
