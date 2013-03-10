From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Sun, 10 Mar 2013 17:28:50 +0200
Message-ID: <201303101728.50883.jackm@dev.mellanox.co.il>
References: <51360D7C.3060209@mellanox.com> <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com> <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Liran Liss <liranl@mellanox.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:59207 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3CJP25 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 11:28:57 -0400
Received: by mail-wi0-f177.google.com with SMTP id hm14so484549wib.10
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 08:28:56 -0700 (PDT)
In-Reply-To: <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Ming, Greg, Roland, Dave, all...

>From a quick scan of ethernet drivers in Dave Miller's net-next git, I
notice that the following drivers (apart from the Mellanox mlx4 driver)
enable SRIOV during the PF probe:
  cisco enic (function "enic_probe")
  neterion vxge driver(function "vxge_probe")
  Solarflare efx driver (function "efx_pci_probe", which invokes "efx_sriov_init")
  emulex driver (function "be_probe" --> be_setup --> be_vf_setup)

It would seem that these drivers are susceptible to the nested probe/deadlock
race condition as well.

I believe that it is healthiest for everyone if the probe code in the kernel itself
would avoid such nested probe calls (rather than forcing vendors to deal
with this issue).  The kernel code is certainly aware
(or could easily track) that it is invoking the a driver's probe function
while that same probe function has already been invoked and has not yet returned!

-Jack

On Thursday 07 March 2013 04:03, Ming Lei wrote:
> On Thu, Mar 7, 2013 at 4:54 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> > On Wed, Mar 6, 2013 at 4:43 AM, Ming Lei <ming.lei@canonical.com> wrote:
> >> You are adding one new PCI device inside another PCI device's probe(),
> >> so the new device will be probed, since PCI probe() is scheduled by
> >> work_on_cpu, then cause flush_work() called inside worker function,
> >> which might be a real deadlock.
> >
> > So if I understand correct, you recommend to somehow avoid this nested probing?
> 
> Yes, you might need to avoid the nested probing in your driver.
> 
> >
> >> I am wondering why this commit can cause the problem, since the PCI
> >> device will be probed with its driver if there is one driver for it. There is no
> >> any limit on when the driver should be loaded into system, either before
> >> device is added or after.
> >
> > FWIW to undertstanding the issue - the same driver (mlx4_core) is used
> > by the PF and VF, so the VF driver is already loaded at the time its
> > been added as new PCI device.
> >
> >> From driver core view, looks no wrong things are found.
> >
> > So this got me confused, you pointed on possible deadlock, are you
> > saying the deadlock wouldn't be the result of how the driver code is
> > going nor the commited we bisected?
> 
> My commit only affects the driver loading path, but your warning
> is hit in driver probe path triggered by device addition, so the lockdep
> warning should still be triggered without my commit since the two paths
> are totally independent, right?
> 
> Thanks,
> --
> Ming Lei
> 
