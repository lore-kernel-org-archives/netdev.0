From: <Narendra_K@Dell.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Tue, 5 Oct 2010 20:33:29 +0530
Message-ID: <20101005150317.GA15555@libnet-test.oslab.blr.amer.dell.com>
References: <24764.1283361274@death> <20100901183113.GA25227@midget.suse.cz>
 <12656.1283371238@death>
 <20100901205656.GA14982@smudla-wifi.bakulak.kosire.czf>
 <3617.1283388840@death> <20100902170847.GB8840@midget.suse.cz>
 <9698.1283990791@death> <25924.1284677073@death>
 <20100924112352.GA32716@auslistsprd01.us.dell.com>
 <20101001182232.GB25971@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <fubar@us.ibm.com>, <bonding-devel@lists.sourceforge.net>,
	<markine@google.com>, <jarkao2@gmail.com>, <chavey@google.com>,
	<netdev@vger.kernel.org>
To: <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:42439 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0JEPIG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 11:08:06 -0400
In-Reply-To: <20101001182232.GB25971@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 01, 2010 at 11:52:32PM +0530, Jiri Bohac wrote:
>    On Fri, Sep 24, 2010 at 06:23:53AM -0500, Narendra K wrote:
>    > On Fri, Sep 17, 2010 at 04:14:33AM +0530, Jay Vosburgh wrote:
>    > > Jay Vosburgh <fubar@us.ibm.com> wrote:
>    > The follwing call trace was seen -
>    >
>    > 2.6.35.with.upstream.patch-next-20100811-0.7-default+
>    > [14602.945876] ------------[ cut here ]------------
>    > [14602.950474] kernel BUG at kernel/workqueue.c:2844!
>    > [14602.955242] invalid opcode: 0000 [#1] SMP
>    > [14602.959341] last sysfs file: /sys/class/net/bonding_masters
>    > [14602.964888] CPU 1
>    > [14602.966714] Modules linked in: af_packet bonding ipv6
>    cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq
>    mperf microcode fuse loop dm_mod joydev usbhid hid bnx2 tpm_tis tpm
>    tpm_bios rtc_cmos iTCO_wdt iTCO_vendor_support sr_mod power_meter cdrom sg
>    serio_raw mptctl pcspkr rtc_core usb_storage dcdbas rtc_lib button
>    uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif edd ext3 mbcache jbd fan
>    processor ide_pci_generic ide_core ata_generic ata_piix libata mptsas
>    mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
>    > [14603.015002]
>    > [14603.016524] Pid: 4006, comm: ifdown-bonding Not tainted
>    2.6.35.with.upstream.patch-next-20100811-0.7-default+ #2 0M233H/PowerEdge
>    R710
>    > [14603.028554] RIP: 0010:[<ffffffff81067b50>]  [<ffffffff81067b50>]
>    destroy_workqueue+0x1d0/0x1e0
>    > [14603.037144] RSP: 0018:ffff88022a379d88  EFLAGS: 00010286
>    > [14603.042432] RAX: 000000000000003c RBX: ffff880228674240 RCX:
>    ffff880228f0e800
>    > [14603.049534] RDX: 0000000000001000 RSI: 0000000000000002 RDI:
>    000000000000001a
>    > [14603.056638] RBP: ffff88022a379da8 R08: ffff88022a379cf8 R09:
>    0000000000000000
>    > [14603.063741] R10: 00000000ffffffff R11: 0000000000000000 R12:
>    0000000000000002
>    > [14603.070842] R13: ffffffff817b8560 R14: ffff8802299d1480 R15:
>    ffff8802299d1488
>    > [14603.077944] FS:  00007f8e6a28f700(0000) GS:ffff880001c00000(0000)
>    knlGS:0000000000000000
>    > [14603.085999] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>    > [14603.091719] CR2: 00007f8e6a2c2000 CR3: 0000000127d1c000 CR4:
>    00000000000006e0
>    > [14603.098822] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>    0000000000000000
>    > [14603.105924] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>    0000000000000400
>    > [14603.113026] Process ifdown-bonding (pid: 4006, threadinfo
>    ffff88022a378000, task ffff8802299b0080)
>    > [14603.121944] Stack:
>    > [14603.123944]  ffff88022a379da8 ffff8802299d1000 ffff8802299d1000
>    000000010036b6a4
>    > [14603.131182] <0> ffff88022a379dc8 ffffffffa030a91d ffff8802299d1000
>    000000010036b6a4
>    > [14603.138857] <0> ffff88022a379e28 ffffffff812e0a08 ffff88022a379e38
>    ffff88022a379de8
>    > [14603.146718] Call Trace:
>    > [14603.149158]  [<ffffffffa030a91d>] bond_destructor+0x1d/0x30 [bonding]
>    > [14603.155572]  [<ffffffff812e0a08>] netdev_run_todo+0x1a8/0x270
>    > [14603.161293]  [<ffffffff812ee859>] rtnl_unlock+0x9/0x10
>    > [14603.166411]  [<ffffffffa0317824>] bonding_store_bonds+0x1c4/0x1f0
>    [bonding]
>    > [14603.173342]  [<ffffffff810f26be>] ? alloc_pages_current+0x9e/0x110
>    > [14603.179497]  [<ffffffff81285c9e>] class_attr_store+0x1e/0x20
>    > [14603.185132]  [<ffffffff8116e365>] sysfs_write_file+0xc5/0x140
>    > [14603.190853]  [<ffffffff8110a68f>] vfs_write+0xcf/0x190
>    > [14603.195967]  [<ffffffff8110a840>] sys_write+0x50/0x90
>    > [14603.200996]  [<ffffffff81002ec2>] system_call_fastpath+0x16/0x1b
>    > [14603.206974] Code: 00 7f 14 8b 3b eb 91 3d 00 10 00 00 89 c2 77 10 8b
>    3b e9 07 ff ff ff 3d 00 10 00 00 89 c2 76 f0 8b 3b e9 a9 fe ff ff 0f 0b eb
>    fe <0f> 0b eb fe 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8b 3d 00
>    > [14603.226419] RIP  [<ffffffff81067b50>] destroy_workqueue+0x1d0/0x1e0
>    > [14603.232669]  RSP <ffff88022a379d88>
>    > [    0.000000] Initializing cgroup subsys cpuset
>    > [    0.000000] Initializing cgroup subsys cpu
> 
>    This should be the BUG_ON(cwq->nr_active) in
>    destroy_workqueue()
> 
>    This is really strange. bondng_store_bonds() can do two things:
>    create or delete a bonding device.
> 
>    I checked the delete path, where I would normally expect such a
>    problem, but I can't find a way it could fail in this way.
>    bondng_store_bonds() calls unregister_netdevice(), which
>    - calls rollback_registered() -> bond_close()
>    - puts the device on the net_todo_list.
>    On rtnl_unlock() netdev_run_todo() gets called and that calls
>    bond_destructor().
> 
>    bond_close() now makes sure the rearming work items are not
>    pending, thus, the only work items that may still be pending on
>    the workqueue are the non-rearming "commit" work items.
>    flush_workqueue(), called at the beginning of destroy_workqueue()
>    should have waited for these to finish.
>    If all of the above is correct, this BUG_ON should never trigger.
> 
>    Maybe I am overlooking something, or it may be some kind of
>    failure/race condition in the create path, resulting in
>    bond_destructor() being called as well.
> 
>    Narendra, any chance to capture the dmesg lines preceeding the
>    BUG message? This should show which of the above cases it is.

Jiri, I will try to reproduce the issue with ignore_loglevel to capture
more data on the serial console and share it shortly.

> 
>    I will try to come up with a debug patch that will tell us which
>    work remains active on the work queue.
> 
>    --
>    Jiri Bohac <jbohac@suse.cz>
>    SUSE Labs, SUSE CZ

-- 
With regards,
Narendra K
