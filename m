From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wil6210: remove obsolete msm platform code
Date: Thu, 02 Oct 2014 14:11:22 +0200
Message-ID: <3354043.ejE77YinPM@wuerfel>
References: <3995357.SmO1fZQuHn@wuerfel> <1572828.LhiMXjHRdV@lx-wigig-72>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	wil6210@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:57366 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaJBMMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 08:12:00 -0400
In-Reply-To: <1572828.LhiMXjHRdV@lx-wigig-72>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 October 2014 14:29:06 Vladimir Kondratiev wrote:
> On Tuesday, September 30, 2014 05:48:20 PM Arnd Bergmann wrote:
> > The wil6210 driver has a glue layer for the Qualcomm MSM platform
> > code, which apparently could never build and is unlikely to
> > ever be able to in the future, as the MSM platform is being phased
> > out in favor of the new QCOM platform, and the driver relies
> > on out-of-tree infrastructure. Trying to build it currently
> > results in this error:
> > 
> > drivers/net/wireless/ath/wil6210/wil_platform_msm.c:19:27: fatal error: linux/msm-bus.h: No such file or directory
> > 
> > Removing the driver fixes the build and makes it possible to
> > build an allmodconfig kernel for MSM.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > 
> 
> We are investigating this, looking for the appropriate solution.
> Thanks for pointing to this.

FWIW, I took a closer look at the actual driver code now. It's
actually worse than I thought and I don't see any possible way
out other than removing this driver completely and starting a
new one, if you want to use it for mach-qcom. I hadn't realized
before that this is actually new code rather than ancient bitrot
that suddenly started causing problems.

Some of the worst problems are:

- the driver scans for DT properties that are completely
  undocumented and have not been reviewed

- if they had been reviewed, the first comment you would have
  received is that the binding makes no sense: you scan for
  another node rather than taking the node you already have for
  the PCI device, then pass data into a random soc-specific
  driver API that is not part of the upstream kernel.

- as mentioned in the my patch above, the code has never been
  compiled on a mainline kernel and now breaks builds.

I think the only way forward is to have the platform support for
whatever chip this is meant for reviewed and merged first and
then you can write a new glue driver for the interfaces we end
up putting into the kernel.
My guess is that with proper interfaces between the platform
bus driver and the wil driver glue, there would be very little
left in terms of interface and you can just call a generic
interface from the PCI driver, passing the 'struct device'
for the PCI dev in to an exported interface when provided.

	Arnd
