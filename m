From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro
	2.6.31-rc3
Date: Thu, 16 Jul 2009 00:35:19 +0100
Message-ID: <1247700919.2788.11.camel@achroite>
References: <4A5E5F8A.308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34077 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752750AbZGOXf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 19:35:28 -0400
In-Reply-To: <4A5E5F8A.308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-15 at 16:00 -0700, Ben Greear wrote:
> I just got a fancy new 10G NIC and tried it out in a (patched elsewhe=
re, but stock ixgbe driver) 2.6.31-rc3) kernel.

And what exactly are those patches?

> First of all, it runs very fast:  sustained 9.5Gbps tx + rx on two po=
rts concurrently (using modified pktgen),
> with 1500 byte pkts.
>=20
> I did see a warning in the boot logs though.
[...]
> BUG: scheduling while atomic: S99lanforge/2133/0x00000002
> Modules linked in: sco stp llc bnep l2cap bluetooth nfs lockd fscache=
 nfs_acl auth_rpcgss sunrpc ipv6 dm_multipath uinput ixgbe i2c_i801 i2c=
_core dca mdio=20
> e1000e iTCO_wdt iTCO_vendor_support pcspkr ata_generic pata_acpi [las=
t unloaded: bridge]
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
=EF=BB=BF
I introduced dev_disable_lro() and calls to it because LRO doesn't work
in conjunction with bridging or forwarding.  (GRO does not have this
problem as it allows the original packets to be regenerated.)

So far as I can see, none of the functions in this backtrace should be
entering atomic context, so I suspect that the patches "elsewhere" migh=
t
be doing something strange.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

