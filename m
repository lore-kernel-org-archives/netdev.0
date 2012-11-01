From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fw: [Bug 42764] BUG at net/core/skbuff.c:147
Date: Thu, 1 Nov 2012 16:53:26 +0000
Message-ID: <1351788806.2883.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121031135106.453cbe4d@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37761 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750745Ab2KAQx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:53:29 -0400
In-Reply-To: <20121031135106.453cbe4d@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 13:51 -0700, Stephen Hemminger wrote:
[...]
> This machine does a lot of network traffic, because it load data from a
> database every night.
> 
> Kernel version is 3.0.34
> 
> Sorry for not reporting hardware, I thought it was a protocol bug not related
> to a specific card.
> 
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:147!
> invalid opcode: 0000 [#1] SMP 
> CPU 2 
> Modules linked in: af_packet ipmi_devintf ipmi_si ipmi_msghandler ipv6 fuse
> loop sr_mod cdrom mptsas mptscsih mptbase scsi_transport_sas tpm_tis tpm bnx2
> tpm_bios sg i2c_piix4 i2c_core shpchp pci_hotplug button serio_raw linear
> scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc dm_round_robin sd_mod
> crc_t10dif qla2xxx scsi_transport_fc scsi_tgt dm_snapshot dm_multipath scsi_dh
> scsi_mod edd dm_mod ext3 mbcache jbd fan thermal processor thermal_sys hwmon
> [last unloaded: usbcore]
> 
> Pid: 21566, comm: nscd Not tainted 3.0.34-inps #5 IBM BladeCenter LS42
> -[7902CQG]-/Server Blade
> RIP: 0010:[<ffffffff8123fd12>]  [<ffffffff8123fd12>] skb_push+0x75/0x7e
> RSP: 0018:ffff880b956c39d8  EFLAGS: 00010292
> RAX: 0000000000000083 RBX: 0000000000000800 RCX: 0000000000023382
> RDX: 0000000000007878 RSI: 0000000000000046 RDI: ffffffff8152ee9c
> RBP: ffff880b956c39f8 R08: 0000000000000000 R09: 0720072007200720
> R10: ffff880b956c37c8 R11: 0720072007200720 R12: 0000000000000000
> R13: ffff8810231fb718 R14: 0000000000000055 R15: ffff880c25d24000
> FS:  00007fd9a9222950(0000) GS:ffff880c3fc00000(0000) knlGS:00000000e8dafb90
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fd9b403a000 CR3: 0000000c265e8000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nscd (pid: 21566, threadinfo ffff880b956c2000, task ffff8803e50e4790)
> Stack:
>  0000000000000057 0000000000000080 ffff880c25d24000 ffff880c71806440
>  ffff880b956c3a38 ffffffff8125e0c5 ffff880b956c3a28 0000000000000036
>  ffff8810231fb680 ffff8810231fb718 ffff880b2cc49380 ffff8810231fb710
> Call Trace:
>  [<ffffffff8125e0c5>] eth_header+0x29/0xa8
>  [<ffffffff81251a59>] neigh_resolve_output+0x284/0x2ed
[...]

The symptoms seem to match this fix:

commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c
Author: ramesh.nagappa@gmail.com <ramesh.nagappa@gmail.com>
Date:   Fri Oct 5 19:10:15 2012 +0000

    net: Fix skb_under_panic oops in neigh_resolve_output
    
    The retry loop in neigh_resolve_output() and neigh_connected_output()
    call dev_hard_header() with out reseting the skb to network_header.
    This causes the retry to fail with skb_under_panic. The fix is to
    reset the network_header within the retry loop.

which was backported into 3.0.49 and other stable branches.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
