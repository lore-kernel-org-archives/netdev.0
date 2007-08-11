From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 02:43:41 +0200
Message-ID: <20070811004341.GA22213@stusta.de>
References: <200708110208.21624.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:57720 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754162AbXHKAn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:43:56 -0400
Content-Disposition: inline
In-Reply-To: <200708110208.21624.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 11, 2007 at 02:08:21AM +0200, Michael Buesch wrote:
> This fixes the SSB dependency hell and introduces some
> fake-options that only give some advice on what to select.
> 
> We live with these fake options only until menuconfig is able
> to tell more about needed dependencies and how to resolve them.
>...

-ENOMENUCONFIGPATCH

IOW: $t\rightarrow\infty$

> +config B44_ADVICE_HACK
> +	bool "B44 for PCI not available. Read the help text of this option!"
> +	depends on !B44_DEP_HACK
> +	---help---
> +	  The Broadcom 440x/47xx driver for PCI devices can not be enabled,
> +	  because the required dependencies are not selected.
> +
> +	  In order to be able to select the Broadcom 440x/47xx PCI driver, you
> +	  need to enable the following options first:
> +
> +	  CONFIG_SSB found in menu:
> +	  Device Drivers/Sonics Silicon Backplane/Sonics Silicon Backplane support
> +	  CONFIG_SSB_PCIHOST found in menu:
> +	  Device Drivers/Sonics Silicon Backplane/Support for SSB on PCI-bus host
> +	  CONFIG_SSB_DRIVER_PCICORE found in menu:
> +	  Device Drivers/Sonics Silicon Backplane/SSB PCI core driver
> +
>...


That's horrible - you shouldn't force the user to manually enable three 
options.

What is the problem you are trying to solve?
The dependencies of SSB?

There are less horrible solutions for this issue, e.g. [1]:


drivers/ssb/Kconfig:

config SSB_POSSIBLE
	bool
	depends on EXPERIMENTAL && HAS_IOMEM

config SSB
	tristate

config SSB_PCIHOST_POSSIBLE
	bool
	depends on SSB_POSSIBLE && PCI

config SSB_PCIHOST
	bool


drivers/net/Kconfig:

config B44
	tristate "Broadcom 440x/47xx ethernet support"
	depends on SSB_PCIHOST_POSSIBLE
	select SSB
	select SSB_PCIHOST


I can make a complete patch for the SSB options, but I need some
pieces of information before starting:

Is there any extremely good reason why options like SSB or SSB_PCIHOST 
have to be user visible? 

And according to the kconfig help text, we should remove the B44_PCI 
option and enable the code unconditionally?
(Or what was the person writing this help text smoking^Wthinking when
 writing it?)

cu
Adrian

[1] incomplete example for demonstrating an idea

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

