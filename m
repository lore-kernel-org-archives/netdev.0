From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 15:40:53 +0000
Message-ID: <1300462853.2589.9.camel@bwh-desktop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17822 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756663Ab1CRPk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 11:40:57 -0400
In-Reply-To: <1300446743.11985.317.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 12:12 +0100, Jesper Dangaard Brouer wrote:
> Hi
> 
> I'm seeing the LRO disable warnings using kernel 2.6.38:
> 
> [    8.664759] NET: Registered protocol family 10
> [    8.838148] ADDRCONF(NETDEV_UP): eth71: link is not ready
> [    8.872639] ------------[ cut here ]------------
> [    8.872645] WARNING: at net/core/dev.c:1363 dev_disable_lro+0x7b/0x80()
> [    8.872647] Hardware name: ProLiant DL370 G6
> [    8.872648] Modules linked in: ipv6 nf_conntrack ip_tables loop i7core_edac edac_core ipmi_si ipmi_msghandler joydev hpilo pcspkr sg hpsa igb ata_piix netxen_nic dca [last unloaded: scsi_wait_scan]
> [    8.872660] Pid: 2221, comm: sysctl Not tainted 2.6.38-comx04 #2
> [    8.872662] Call Trace:
> [    8.872671]  [<ffffffff81056e1f>] ? warn_slowpath_common+0x7f/0xc0
> [    8.872675]  [<ffffffff81056e7a>] ? warn_slowpath_null+0x1a/0x20
> [    8.872680]  [<ffffffff8140c0ab>] ? dev_disable_lro+0x7b/0x80
> [    8.872686]  [<ffffffff81474f27>] ? devinet_sysctl_forward+0x147/0x180
> [    8.872691]  [<ffffffff811872f7>] ? proc_sys_call_handler+0x97/0xd0
> [    8.872700]  [<ffffffff81187344>] ? proc_sys_write+0x14/0x20
> [    8.872704]  [<ffffffff81124148>] ? vfs_write+0xc8/0x180
> [    8.872707]  [<ffffffff81124301>] ? sys_write+0x51/0x90
> [    8.872712]  [<ffffffff8100b8c2>] ? system_call_fastpath+0x16/0x1b
> [    8.872714] ---[ end trace 6245283cb8d484cc ]---
> 
> The strange part is that I didn't see this warning on my testlab and
> pre-prod servers.  The warning is from the first production server,
> which got kernel 2.6.38 deployed this morning.
> 
> The NIC driver is igb.
>
> The only difference in hardware between the production and
> pre-production server (which didn't show the warning), is the
> prod-server have an extra dual-port original Intel NIC, dev-named
> "eth71".  And its just after the init of eth71, the warning occurs.

The warning is triggered if you enable forwarding or bridging on a
device without LRO, and the driver fails to disable LRO when requested.
You can see from the call chain that this is being triggered by a sysctl
write, not during registration.

> We usually use a 6 port NIC from Hotlava, which is based on the same
> chip 82576 and also uses the same igb driver.
> 
> Intel orig NIC eth71
>  albpd4:~# ethtool -i eth71
>  driver: igb
>  version: 2.1.0-k2
[...]

This appears to be the in-tree version of igb, which never enables LRO.
So I can't see how it could trigger this warning.

Are any other drivers being used for other interfaces?

And I'm sorry I forgot to include device & driver in this warning!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

