From: Caglar Akyuz <caglarakyuz@gmail.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Fri, 10 Sep 2010 18:23:52 +0300
Message-ID: <201009101823.52755.caglarakyuz@gmail.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <4C893ADE.809@ti.com> <4C8950D4.9060102@criticallink.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: cyril@ti.com, Kevin Hilman <khilman@deeprootsystems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Michael Williamson <michael.williamson@criticallink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39749 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464Ab0IJPRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 11:17:47 -0400
In-Reply-To: <4C8950D4.9060102@criticallink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 September 2010 12:25:40 am Michael Williamson wrote:
> Hi Cyril,
> 
> On 09/09/2010 03:51 PM, Cyril Chemparathy wrote:
> > Hi Mike,
> >
> > [...]
> >
> >> The hang is in wait_for_user_access() in the davinci_mdio_read() call. 
> >> Looks like the state machine got put back into IDLE somewhere between
> >> the MDIO probe and the EMAC probe. Seems like there should be some sort
> >> of time-out and error message in the wait_for_user_access() method....
> >> (maybe even a check for IDLE??)
> >>
> >> If I add a patch to check the state machine for IDLE and then re-enable
> >> it in the davinci_mdio_read() call, it is able to press on and come up. 
> >> I don't see any calls to the davinci_mdio_suspend() call, so I am
> >> wondering if the EMAC probe routine, particularly the application of the
> >> SOFTRESET, is causing the MDIO to drop back to IDLE / disabled.
> >>
> >> I can post the patch if you like, but it is a bit of a hack...
> >
> > An EMAC soft-reset clobbering the MDIO controller state is a
> > possibility.  I will poll TI designers to see if this could be the case.
> >
> > In any case, a couple of unanswered questions remain:
> >
> >   1. Why don't other davinci devices display similar behavior?
> >
> >   2. If the answer to #1 above is that the timing window is pretty slim
> >      (i.e., only if an MDIO read/write is in progress during EMAC
> >      soft-reset), why do we hit this situation consistently on
> >      mityomap?
> 
> Has it been confirmed that this only happens on mityomap?  Has anyone had
>  success using a da850 evm or other da850 platform?  The configuration for

Same problem exists on another DA850 board, Hawkboard.(Sorry no support in 
mainline yet)

>  the mityomap, wrt to the EMAC/MII/MDIO, is pretty much identical to the
>  da850 evm using the MII interface. The only difference I am aware of is
>  the assigned address to the PHY chip.  The reference clocks and rates are
>  identical, AFAIK, to the evm.
> 
> > I have put together a quick patch (tested dm365).  See attached.
> 
> Your patch doesn't work with my board.  It does attempt to reset the bus on

This patch fixes the problem here. I'm using kernel IP auto configuration and 
mounting fs over NFS. My system boots and I can login to my board.

Regards,
Caglar

>  the read call, but following wait_for_user_access() calls are timing out
>  and the _read() and _write() calls punt. I bumped up the MDIO_TIMEOUT to
>  100 ms, and it works.  I'm wondering if the scanning logic has to complete
>  an entire cycle (all 32 phys) before issuing a request, and if it's a lot
>  slower than expected.
> 
> I also found that the initial scanning logic would not reliably find the
>  PHY until I bumped up the delay time following the reset operation. 
>  Sometimes it would, sometimes no.
> 
> Also, your while(1) loops with the continue conditions on the second
>  wait_for_user_access() in the read and writes might need some
>  consideration, i.e.:
> 
>         while (1) {
>                 ret = wait_for_user_access(data);
>                 if (ret == -EAGAIN)
>                         continue;
>                 if (ret < 0)
>                         break;
> 
>                 __raw_writel(reg, &data->regs->user[0].access);
> 
>                 ret = wait_for_user_access(data);
>                 if (ret == -EAGAIN)
>                         continue;
>                         ^^^^^^^^^ <--- this will re-issue the request....
>  what you want? if (ret < 0)
>                         break;
> 
>                 reg = __raw_readl(&data->regs->user[0].access);
>                 ret = (reg & USERACCESS_ACK) ? (reg & USERACCESS_DATA) :
>  -EIO; break;
>         }
> 
> Also, on the shutdown, I get a major kernel trace.  Here is the dump, as
>  much as I could catch of it.... (I need a better terminal program)
> 
> Deconfiguring network interfaces... ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:143 local_bh_enable+0x40/0xb4()
> Modules linked in:
> [<c002e684>] (unwind_backtrace+0x0/0xec) from [<c003e284>]
>  (warn_slowpath_common+0x4c/0x64) [<c003e284>]
>  (warn_slowpath_common+0x4c/0x64) from [<c003e2b8>]
>  (warn_slowpath_null+0x1c/0x24) [<c003e2b8>] (warn_slowpath_null+0x1c/0x24)
>  from [<c0043e80>] (local_bh_enable+0x40/0xb4) [<c0043e80>]
>  (local_bh_enable+0x40/0xb4) from [<c01f3760>]
>  (__netif_receive_skb+0xf8/0x3d0) [<c01f3760>]
>  (__netif_receive_skb+0xf8/0x3d0) from [<c01d344c>]
>  (emac_rx_handler+0x40/0xcc) [<c01d344c>] (emac_rx_handler+0x40/0xcc) from
>  [<c01d3fe8>] (__cpdma_chan_free+0xac/0xb0) [<c01d3fe8>]
>  (__cpdma_chan_free+0xac/0xb0) from [<c01d40d0>]
>  (__cpdma_chan_process+0xe4/0x114) [<c01d40d0>]
>  (__cpdma_chan_process+0xe4/0x114) from [<c01d4238>]
>  (cpdma_chan_stop+0xf0/0x1c8) [<c01d4238>] (cpdma_chan_stop+0xf0/0x1c8)
>  from [<c01d4390>] (cpdma_ctlr_stop+0x80/0xe4) [<c01d4390>]
>  (cpdma_ctlr_stop+0x80/0xe4) from [<c01d2c00>] (emac_dev_stop+0xb0/0x13c)
>  [<c01d2c00>] (emac_dev_stop+0xb0/0x13c) from [<c01f5b40>]
>  (__dev_close+0x74/0x98) [<c01f5b40>] (__dev_close+0x74/0x98) from
>  [<c01f3168>] (__dev_change_flags+0xac/0x13c) [<c01f3168>]
>  (__dev_change_flags+0xac/0x13c) from [<c01f5994>]
>  (dev_change_flags+0x10/0x44) [<c01f5994>] (dev_change_flags+0x10/0x44)
>  from [<c023cf60>] (devinet_ioctl+0x2dc/0x6f4) [<c023cf60>]
>  (devinet_ioctl+0x2dc/0x6f4) from [<c01e484c>] (sock_ioctl+0x1fc/0x258)
>  [<c01e484c>] (sock_ioctl+0x1fc/0x258) from [<c00aa0f0>]
>  (do_vfs_ioctl+0x550/0x5c0) [<c00aa0f0>] (do_vfs_ioctl+0x550/0x5c0) from
>  [<c00aa198>] (sys_ioctl+0x38/0x5c) [<c00aa198>] (sys_ioctl+0x38/0x5c) from
>  [<c0029f00>] (ret_fast_syscall+0x0/0x2c) ---[ end trace 0e686330480db12e
>  ]---
> ------------[ cut here ]------------
> WARNING: at drivers/net/davinci_emac.c:1025 __cpdma_chan_free+0xac/0xb0()
> Modules linked in:
> [<c002e684>] (unwind_backtrace+0x0/0xec) from [<c003e284>]
>  (warn_slowpath_common+0x4c/0x64) [<c003e284>]
>  (warn_slowpath_common+0x4c/0x64) from [<c003e2b8>]
>  (warn_slowpath_null+0x1c/0x24) [<c003e2b8>] (warn_slowpath_null+0x1c/0x24)
>  from [<c01d3fe8>] (__cpdma_chan_free+0xac/0xb0) [<c01d3fe8>]
>  (__cpdma_chan_free+0xac/0xb0) from [<c01d40d0>]
>  (__cpdma_chan_process+0xe4/0x114) [<c01d40d0>]
>  (__cpdma_chan_process+0xe4/0x114) from [<c01d4238>]
>  (cpdma_chan_stop+0xf0/0x1c8) [<c01d4238>] (cpdma_chan_stop+0xf0/0x1c8)
>  from [<c01d4390>] (cpdma_ctlr_stop+0x80/0xe4) [<c01d4390>]
>  (cpdma_ctlr_stop+0x80/0xe4) from [<c01d2c00>] (emac_dev_stop+0xb0/0x13c)
>  [<c01d2c00>] (emac_dev_stop+0xb0/0x13c) from [<c01f5b40>]
>  (__dev_close+0x74/0x98) [<c01f5b40>] (__dev_close+0x74/0x98) from
>  [<c01f3168>] (__dev_change_flags+0xac/0x13c) [<c01f3168>]
>  (__dev_change_flags+0xac/0x13c) from [<c01f5994>]
>  (dev_change_flags+0x10/0x44) [<c01f5994>] (dev_change_flags+0x10/0x44)
>  from [<c023cf60>] (devinet_ioctl+0x2dc/0x6f4) [<c023cf60>]
>  (devinet_ioctl+0x2dc/0x6f4) from [<c01e484c>] (sock_ioctl+0x1fc/0x258)
>  [<c01e484c>] (sock_ioctl+0x1fc/0x258) from [<c00aa0f0>]
>  (do_vfs_ioctl+0x550/0x5c0) [<c00aa0f0>] (do_vfs_ioctl+0x550/0x5c0) from
>  [<c00aa198>] (sys_ioctl+0x38/0x5c) [<c00aa198>] (sys_ioctl+0x38/0x5c) from
>  [<c0029f00>] (ret_fast_syscall+0x0/0x2c) ---[ end trace 0e686330480db12f
>  ]---
> 
> 
> Thanks for the help.
> 
> -Mike
> --
> To unsubscribe from this list: send the line "unsubscribe linux-omap" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
