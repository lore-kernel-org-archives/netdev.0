From: Ming Lei <ming.lei@canonical.com>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Mon, 11 Mar 2013 09:26:13 +0800
Message-ID: <CACVXFVO5OO9wFz1-4hqQn05kW4WaGpYPCoQDdNTPKO1pQXphWQ@mail.gmail.com>
References: <51360D7C.3060209@mellanox.com>
	<CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
	<CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
	<201303101728.50883.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Liran Liss <liranl@mellanox.com>
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60348 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab3CKB0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 21:26:16 -0400
Received: from mail-vb0-f46.google.com ([209.85.212.46])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1UErVG-0004ZR-Ka
	for netdev@vger.kernel.org; Mon, 11 Mar 2013 01:26:14 +0000
Received: by mail-vb0-f46.google.com with SMTP id b13so1371013vby.19
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 18:26:13 -0700 (PDT)
In-Reply-To: <201303101728.50883.jackm@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 11:28 PM, Jack Morgenstein
<jackm@dev.mellanox.co.il> wrote:
> Hello, Ming, Greg, Roland, Dave, all...
>
> From a quick scan of ethernet drivers in Dave Miller's net-next git, I
> notice that the following drivers (apart from the Mellanox mlx4 driver)
> enable SRIOV during the PF probe:
>   cisco enic (function "enic_probe")
>   neterion vxge driver(function "vxge_probe")
>   Solarflare efx driver (function "efx_pci_probe", which invokes "efx_sriov_init")
>   emulex driver (function "be_probe" --> be_setup --> be_vf_setup)
>
> It would seem that these drivers are susceptible to the nested probe/deadlock
> race condition as well.
>
> I believe that it is healthiest for everyone if the probe code in the kernel itself
> would avoid such nested probe calls (rather than forcing vendors to deal
> with this issue).  The kernel code is certainly aware
> (or could easily track) that it is invoking the a driver's probe function
> while that same probe function has already been invoked and has not yet returned!

Generally nested probe() should be fine if your driver knows how to end
the nesting, also USB drivers use nested probe too, which is healthy. This
report is only related with PCI driver probe, which is scheduled as work
function, so flush_work() around nested probe() may cause deadlock.

IMO, fixing the problem generally might need to touch PCI driver probe
code(pci_call_probe).

Thanks,
--
Ming Lei
