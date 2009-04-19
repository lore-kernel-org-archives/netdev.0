From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [BUG] 2.6.30-rc broke ixp4xx_eth, firmware breakage?
Date: Sun, 19 Apr 2009 23:14:24 +0200
Message-ID: <18923.37936.480968.59086@pilspetsen.it.uu.se>
References: <200904182153.n3ILrP6j027453@pilspetsen.it.uu.se>
	<20090418.211820.197285479.davem@davemloft.net>
	<18922.61340.630534.74677@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, khc@pm.waw.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hugh@veritas.com
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:62661 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811AbZDSVOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2009 17:14:41 -0400
In-Reply-To: <18922.61340.630534.74677@pilspetsen.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson writes:
 > David Miller writes:
 >  > From: Mikael Pettersson <mikpe@it.uu.se>
 >  > Date: Sat, 18 Apr 2009 23:53:25 +0200 (MEST)
 >  > 
 >  > > The ixp4xx_eth driver for my IXP420 XScale box (Synology DS101)
 >  > > worked fine in kernel 2.6.29. Now trying to boot 2.6.30-rc2 I'm
 >  > > greeted with the following failure during init:
 >  > > 
 >  > > Bringing up interface eth0:  RTNETLINK answers: No such file or directory
 >  > > Failed to bring up eth0.
 >  > > [FAILED]
 >  > > 
 >  > > There's a fairly long (at least 10 seconds) delay between the 'Bringing up'
 >  > > message and the RTNETLINK error.
 >  > > 
 >  > > A diff between the 2.6.29 and 2.6.30-rc2 boot logs indicates that
 >  > > the firmware doesn't get loaded:
 >  > 
 >  > Please make sure CONFIG_FIRMWARE_IN_KERNEL is set in your
 >  > configuration if this driver is being built statically
 >  > into your kernel.
 > 
 > ixp4xx_eth is built as a module and I have CONFIG_FIRMWARE_IN_KERNEL unset.
 > 
 >  > Otherwise, if modular, make sure the firmware files get installed into
 >  > the correct location and are available in the filesystem when the
 >  > driver loads.
 > 
 > The firmware isn't shipped with the kernel but is something users have to
 > download from Intel, build, and install themselves; once installed they work
 > across kernel versions. The files reside in /lib/firmware/'s top-level
 > directory, and they are available since firmware loading (triggered by init's
 > attempt to up eth0) occurs after / has been mounted. My userspace uses oldish
 > firmware-aware hotplug since udev's too heavy-weight.
 > 
 > This all works with 2.6.29 and older 2.6.2x kernels.
 > 
 > I'll do a bisect.

Bisection identified Arjan's f520360d93cdc37de5d972dac4bf3bdef6a7f6a7
"kobject: don't block for each kobject_uevent" as the culprit.
Hugh Dickins reverted that change a few days ago in commit
05f54c13cd0c33694eec39a265475c5d6cf223cf, noting that it was buggy
and broke CONFIG_UEVENT_HELPER_PATH by prematurely releasing memory
needed when exec:ing the helper program.

I tested 2.6.30-rc2 + Hugh's patch and with that everything works again.

Krzysztof: you can relax, ixp4xx_eth was just an innocent bystander.

Hugh: thanks for the revert, consider this a late Acked-by.

/Mikael
