From: Stanislaw Gruszka <stf_xl@wp.pl>
Subject: Re: [PATCH] sky2: initialize napi before registering device
Date: Mon, 27 Jan 2014 12:53:33 +0100
Message-ID: <20140127115333.GB2482@localhost.localdomain>
References: <20140125103454.GA2490@localhost.localdomain>
 <20140125170120.2e78cdb4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.7]:47401 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275AbaA0Lvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 06:51:32 -0500
Content-Disposition: inline
In-Reply-To: <20140125170120.2e78cdb4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 25, 2014 at 05:01:20PM -0800, Stephen Hemminger wrote:
> On Sat, 25 Jan 2014 11:34:54 +0100
> Stanislaw Gruszka <stf_xl@wp.pl> wrote:
> 
> > There is race condition when call netif_napi_add() after
> > register_netdevice(), as ->open() can be called without napi initialized
> > and trigger BUG_ON() on napi_enable(), like on below messages:
> > 
> > [    9.699863] sky2: driver version 1.30
> > [    9.699960] sky2 0000:02:00.0: Yukon-2 EC Ultra chip revision 2
> > [    9.700020] sky2 0000:02:00.0: irq 45 for MSI/MSI-X
> > [    9.700498] ------------[ cut here ]------------
> > [    9.703391] kernel BUG at include/linux/netdevice.h:501!
> > [    9.703391] invalid opcode: 0000 [#1] PREEMPT SMP
> > <snip>
> > [    9.830018] Call Trace:
> > [    9.830018]  [<fa996169>] sky2_open+0x309/0x360 [sky2]
> > [    9.830018]  [<c1007210>] ? via_no_dac+0x40/0x40
> > [    9.830018]  [<c1007210>] ? via_no_dac+0x40/0x40
> > [    9.830018]  [<c135ed4b>] __dev_open+0x9b/0x120
> > [    9.830018]  [<c1431cbe>] ? _raw_spin_unlock_bh+0x1e/0x20
> > [    9.830018]  [<c135efd9>] __dev_change_flags+0x89/0x150
> > [    9.830018]  [<c135f148>] dev_change_flags+0x18/0x50
> > [    9.830018]  [<c13bb8e0>] devinet_ioctl+0x5d0/0x6e0
> > [    9.830018]  [<c13bcced>] inet_ioctl+0x6d/0xa0
> > 
> > To fix the problem patch changes the order of initialization.
> > 
> > Bug report:
> > https://bugzilla.kernel.org/show_bug.cgi?id=67151
> > 
> > Reported-and-tested-by: ebrahim.azarisooreh@gmail.com
> > Signed-off-by: Stanislaw Gruszka <stf_xl@wp.pl>
> 
> That looks good, problem was introduced years ago.
> I wonder if netif_napi_del() should be in unwind if registration
> of either devices fails?

napif_napi_del() is called internally by free_netdev(), so we are
fine regarding error unwind and driver remove.

Thanks
Stanislaw
