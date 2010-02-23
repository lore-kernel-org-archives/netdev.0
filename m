From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 23 Feb 2010 13:15:08 +0100
Message-ID: <20100223131508.4c6cb866@neptune.home>
References: <20091229084929.54912c0c@pluto.restena.lu>
	<1262077540.12520.4.camel@localhost>
	<20091229145403.39f82773@pluto.restena.lu>
	<1262149691.2788.63.camel@localhost>
	<20100219091034.5fbb0165@pluto.restena.lu>
	<1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from legolas.restena.lu ([158.64.1.34]:59343 "EHLO
	legolas.restena.lu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480Ab0BWMPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 07:15:42 -0500
In-Reply-To: <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Benjamin,

On Fri, 19 February 2010 "Benjamin Li" <benli@broadcom.com> wrote:
> >From your logs it looks like the device came up using MSI, but in the
> MSI-X poll routine was being called:
> 
> [    9.836673] bnx2: eth0: using MSI
> ...
> 
> [  134.643459]  [<ffffffffa004019e>] bnx2_poll_msix+0x3e/0xd0 [bnx2]
> [  134.643465]  [<ffffffff8135bcd1>] netpoll_poll+0xe1/0x3c0
> 
> which is incorrect.  If we are in MSI mode, the bnx2_poll() routine
> should be used.
> 
> I think what is going on here is that during the bnx2x driver
> initialization the current bnx2 driver adds all possible NAPI
> structures that map to all the hardware vectors (BNX2_MAX_MSIX_VEC=9)
> to the NAPI list in the net_device structure regardless if they are
> used or not (Seen in drivers/net/bnx2.c:bnx2_init_napi()).  This can
> cause uninitialized NAPI structures to be placed on the napi_list.
> Because this device is in MSI mode, only 1 vector is initialized.
> Now, the problem is triggered when net/core/netpoll.c:poll_napi() is
> called. This is because this routine will run through the entire
> napi_list calling all the poll routines.  In your particular case, it
> is calling the poll routine on an uninitialized vector causing the
> kernel panic.
> 
> Please try the patch below to see if it solves your problem.  Note,
> this only have been compile tested and tested against basic traffic
> runs. Unfortunately, I could not reproduce the kernel panic with the
> instructions below to verify the patch.
> 
> Thanks again for all your help in helping us track this down.

I applied the patch today and tried to reproduce with my showcases.

Seems that it's harder to trigger now but I still end up being able to
crash the box. Don't know if it's the same cause or not (could also
be the tcp-retransmit ghost)...

This time I had to run a few paralell scp's (8Mb/s each) to the box and 
'echo t > /proc/sysrq-trigger' multiple times via ssh session for it to
happen. It didn't trigger with by netbomb though I will try some more
and see)

I don't know if it's the same reason or not (hopefully something
reached disk as serial console is dead and pings are not
answered anymore.
It's probably some printk/bug/warn that triggers in network stack and
deadlocks with netconsole.

Regards,
Bruno
