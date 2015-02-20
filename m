From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Fri, 20 Feb 2015 11:45:51 -0800
Message-ID: <20150220194551.GA29730@roeck-us.net>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <54E76EFA.1050209@cumulusnetworks.com>
 <54E7876A.3060303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org, jiri@resnulli.us, andrew@lunn.ch,
	gospo@cumulusnetworks.com, vbandaru@broadcom.com,
	siva.mannem.lnx@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50389 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbbBTTp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:45:58 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOtWP-003Lgw-K8
	for netdev@vger.kernel.org; Fri, 20 Feb 2015 19:45:57 +0000
Content-Disposition: inline
In-Reply-To: <54E7876A.3060303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 11:13:46AM -0800, Florian Fainelli wrote:
> On 20/02/15 09:29, roopa wrote:
> > On 2/19/15, 11:09 PM, sfeldma@gmail.com wrote:
> >> From: Scott Feldman <sfeldma@gmail.com>
> >>
> >> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
> >> offload hardware.   Switchdev driver/devices can set this flag when
> >> learning a
> >> new FDB entry and SW (the bridge driver) will skip this entry when
> >> running its
> >> ageing task.  If flag is set, the driver/device is responsible for
> >> calling
> >> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry
> >> expires.
> >>
> >> This give the flexibility for driver/device to decide ageing policy
> >> based on
> >> its capabilities.  For devices managing many FDB entries, it is
> >> desireable for
> >> the device to aged out its own entries.  Devices not capable of aged
> >> entries
> >> can rely of SW to age out the entries.
> >>
> > scott, patches look good. However, I am not sure yet if there is a need
> > to make it a per fdb entry flag.
> 
> I agree, in fact, most of the HW I have access to only has a global age
> timer configuration knob. Is this configurable on a per-port basis for

Same here (for all the Marvell switches I am aware of). There is only a single
timer with a granularity of 15 seconds (or maybe 16 seconds on some chips).

> higher end switches, or even maybe per-FDB entry?
> 
For the Marvell switches, the only per-fdb entry is a flag to indicate
static vs. dynamic.

> > 
> > At some point we will also need the hw ageing parameter to be configurable.
> > So other approach could be,
> > - ageing parameter on bridge gets offloaded the hw
> > - so, by default hw and kernel age their own entries using the same
> > bridge device default timer
> > - User can explicitly disable HW ageing by using self (this needs some
> > more thought because now the call is on the bridge device)
> 
> I think we want to be careful with both SW and HW aging entries since a
> host CPU's clock might be suspended/drifting etc.. at least, we probably
> want one or the other to take precedence other the other one?

I may be missing something, but I don't immediately see how this patch set
helps me solve any of the problems I am seeing when integrating the Marvell
switch code. Even if the switch internally does hardware aging, it still
seems to me that we'll need software aging on top of that, even if the
bridge code in the kernel has the same addresses in its fdb as the switch.
I see no feasible means to keep the fdb in the switch synchronized
with the fdb in the kernel.

How would this work with Broadcom switch chips ?

Thanks,
Guenter
