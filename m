From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Mon, 11 Mar 2013 20:24:05 +0000
Message-ID: <1363033445.2608.72.camel@bwh-desktop.uk.solarflarecom.com>
References: <51360D7C.3060209@mellanox.com>
	 <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
	 <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
	 <201303101728.50883.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Liran Liss <liranl@mellanox.com>
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41187 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445Ab3CKUYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 16:24:10 -0400
In-Reply-To: <201303101728.50883.jackm@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 17:28 +0200, Jack Morgenstein wrote:
> Hello, Ming, Greg, Roland, Dave, all...
> 
> From a quick scan of ethernet drivers in Dave Miller's net-next git, I
> notice that the following drivers (apart from the Mellanox mlx4 driver)
> enable SRIOV during the PF probe:
>   cisco enic (function "enic_probe")
>   neterion vxge driver(function "vxge_probe")
>   Solarflare efx driver (function "efx_pci_probe", which invokes "efx_sriov_init")

It's actually called 'sfc', despite using the 'efx' prefix for
hysterical raisins.

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
[...]

Does it make a difference whether the VF driver is the same code as the
PF driver?  I suspect not.

Since Donald Dutile's changes to allow setting the number of VFs through
sysfs, PF drivers should not need to enable VFs during their own probe
function any more.  (Though I think that it will take a non-trivial
amount of work to change that in sfc, anyway.)  This should avoid the
apparent problems with nested probes.

By the way, since VF net drivers will acquire the RTNL lock during their
probe functions, the PF net driver must not hold the RTNL lock while
calling pci_enable_sriov().  This allows rtnl_vfinfo_size() and
rtnl_vf_ports_fill() to race with the change to number of VFs enabled,
if the PF's net device is already registered - which will definitely be
the case if the change is being made through the new sysfs method.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
