From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro
 2.6.31-rc3
Date: Thu, 16 Jul 2009 12:13:48 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com>
References: <4A5E5F8A.308@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2173 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933066AbZGPTOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 15:14:21 -0400
In-Reply-To: <4A5E5F8A.308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jul 2009, Ben Greear wrote:

> I just got a fancy new 10G NIC and tried it out in a (patched elsewhere, but stock ixgbe driver) 2.6.31-rc3) kernel.
> 
> First of all, it runs very fast:  sustained 9.5Gbps tx + rx on two ports concurrently (using modified pktgen),
> with 1500 byte pkts.
> 
> I did see a warning in the boot logs though.

Yes, see below for an explanation.

> ixgbe: 0000:03:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
> ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x8) 00:0c:bd:00:90:1a
> ixgbe 0000:03:00.0: MAC: 2, PHY: 9, SFP+: 5, PBA No: e57138-000
> ixgbe 0000:03:00.0: This device is a pre-production adapter/LOM.  Please be aware there may be issues associated with your hardware.  If you are experiencing 
> problems please contact your Intel or hardware representative who provided you with this hardware.

It's self-explanatory; the EEPROM version on the NIC is not the 
production-level EEPROM.  If you run ethtool -i ethX on this interface, 
you will see what the firmware (EEPROM) version is.  My guess is it's 
going to be 0.5-1 or something; the production firmware is 0.9-3.  If you 
received this NIC from an Intel rep, they can get you the production 
EEPROM and tools necessary to reprogram the NIC.

> BUG: scheduling while atomic: S99lanforge/2133/0x00000002
> Modules linked in: sco stp llc bnep l2cap bluetooth nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 dm_multipath uinput ixgbe i2c_i801 i2c_core dca mdio 
> e1000e iTCO_wdt iTCO_vendor_support pcspkr ata_generic pata_acpi [last unloaded: bridge]
> Pid: 2133, comm: S99lanforge Not tainted 2.6.31-rc3 #2
> Call Trace:
>   [<ffffffff81042456>] __schedule_bug+0x5c/0x60
>   [<ffffffff813e6712>] schedule+0xc1/0x85e
>   [<ffffffff8104488a>] ? check_preempt_wakeup+0x2d/0x1b7
>   [<ffffffff813e880b>] ? _spin_unlock_irqrestore+0x37/0x42
>   [<ffffffff813e7182>] schedule_timeout+0x97/0xbb
>   [<ffffffff8105857e>] ? process_timeout+0x0/0xb
>   [<ffffffff813e71bf>] schedule_timeout_uninterruptible+0x19/0x1b
>   [<ffffffff81058a25>] msleep+0x16/0x1d
>   [<ffffffffa005e160>] ixgbe_stop_adapter_generic+0x38/0x97 [ixgbe]
>   [<ffffffffa0063e5a>] ixgbe_reset_hw_82599+0x13/0x1a4 [ixgbe]
>   [<ffffffffa005cfc3>] ixgbe_init_hw_generic+0xf/0x1d [ixgbe]
>   [<ffffffffa0056f04>] ixgbe_reset+0x1e/0xef [ixgbe]
>   [<ffffffffa005ee71>] ixgbe_set_flags+0x5c/0x66 [ixgbe]
>   [<ffffffff81343fe2>] dev_disable_lro+0x4d/0x69
>   [<ffffffff81398191>] devinet_sysctl_forward+0xd7/0x1a4
>   [<ffffffff81136111>] proc_sys_call_handler+0x8d/0xb7
>   [<ffffffff8113614a>] proc_sys_write+0xf/0x11
>   [<ffffffff810e856d>] vfs_write+0xa9/0x106
>   [<ffffffff810e8680>] sys_write+0x45/0x69
>   [<ffffffff81011b42>] system_call_fastpath+0x16/0x1b

We haven't seen such a panic in our testing, but we don't heavily test 
toggling the LRO flags.  We lightly touch the flags, but nothing heavy. 
Note that there is a difference in this device, 82599 (assumed since
your lspci shows you're linked at 5.0 Gt/sec), that we have a HW-based
LRO running.  This is the preferred configuration the driver uses at
load; there may be something broken with how we switch between HW LRO +
GRO and just straight GRO.

I will see if our validation guys can reproduce this.  In the meantime, 
can you try without preempt enabled?  Also, it wasn't obvious to me if 
this is 100% reproducible, or if it's racy.  Can you comment on that?

Cheers,
-PJ
