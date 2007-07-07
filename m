From: James Chapman <jchapman@katalix.com>
Subject: Re: RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9
 support from 7.5.5 ?
Date: Sat, 07 Jul 2007 13:23:11 +0100
Message-ID: <468F85AF.3010603@katalix.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <468594B7.6070309@intel.com> <468E92F8.7010501@garzik.org> <468EDAC4.8070300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:40130 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320AbXGGMXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 08:23:18 -0400
In-Reply-To: <468EDAC4.8070300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> * The multitude of tiny, fine-grained operations for MAC, NVM, PHY, 
>> etc. is a signal that organization is backwards.  You should be 
>> creating hardware-specific high level operations (PHY layer hooks, 
>> net_device hooks, interrupt handler) that call out to more-generic 
>> functions when necessary.  Doing so eliminates the need to create a 
>> new hook for every little twirl in the code path.

I think this is the key point that needs to be addressed in the new 
driver. All of the netdevice glue such as PCI ID tables, netdev open, 
close etc should be in its own driver for each device, which calls out 
to common code where appropriate.

> are you talking about the internals of e1000_phy/mac/nvm etc? i agree 
> that the amount of forward/backward mapping in here is a bit of a 
> spaghetti and could be more clear

Make it more clear by restructuring it, not by adding comments though.

>> * The multitude of files makes it difficult to review.  Much easier in 
>> one file, or a small few.
> 
> well, at least the files are reasonably well structured by topic. 
> Combining small files just to make reviewing easier seems strange to me, 
> besides making it easier to jump around in an editor it doesn't add any 
> value to the code organization, and just encourages more forward 
> declarations and horrible ordering issues.

There's a lot of common code across the e1000 family. But all of the 
chip-specific code for an individual driver could be in one file. I 
envisage something like this:-

e1000_core.c	- common code used by all drivers of the e1000 family.
		  Exports functions used by actual drivers. Loadable
		  as a separate module when built as a module.
e1000_82541.c	- driver for 82541
e1000_82542.c	- driver for 82542
e1000_xxxxx.c	- driver for xxxxx

If phylib were used, the phy-specific parts would move out naturally 
into a phy driver for each phy device. And if e1000_core.c were 
implemented well, few changes should occur over time as more e1000 
devices are released.

There would obviously be no overlap of PCI IDs in each driver. For the 
initial version, support just one device - more can be added later. The 
important thing is to get the structure right in the initial version.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

