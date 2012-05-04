From: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Subject: RE: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Fri, 4 May 2012 13:55:58 +0000
Message-ID: <B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
References: <20120502234718.GA5432@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	<20120503160917.GA11310@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
	<20120503184632.GA28089@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
	<1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
 <87ehr1gdcv.fsf@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Hilman, Kevin" <khilman@ti.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56523 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab2EDN4o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 09:56:44 -0400
In-Reply-To: <87ehr1gdcv.fsf@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kevin,

On Fri, May 04, 2012 at 03:02:16, Hilman, Kevin wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> 
> > On Thu, 2012-05-03 at 19:25 +0000, Bedia, Vaibhav wrote:
> >> On Fri, May 04, 2012 at 00:16:32, Mark A. Greer wrote:
> >> [...]
> >> > > 
> >> > > So, if I understood this correctly, it's effectively like blocking a low power
> >> > > state transition (here wfi execution) when EMAC is active?
> >> > 
> >> > Assuming "it" is my patch, correct.
> >> > 
> >> 
> >> Recently I was thinking about how to get certain drivers to disallow some or all
> >> low power states and to me this also seems to fall in a similar category.
> >> 
> >> One of the suggestions that I got was to check if the 'wakeup' entry associated with
> >> the device under sysfs could be leveraged for this. The PM code could maintain
> >> a whitelist (or blacklist) of devices and it decides the low power state to enter
> >> based on the 'wakeup' entries associated with these devices. In this particular case,
> >> maybe the driver could simply set this entry to non-wakeup capable when necessary and
> >> then let the PM code take care of skipping the wfi execution.
> >> 
> >> Thoughts/brickbats welcome :)
> >
> > You can maybe (ab)use the pm_qos mechanism for this.
> 
> I thought of using this too, but it doesn't actually solve the problem:
> 
> Using PM QoS, you can avoid hitting the deeper idle states by setting a
> very low wakeup latency.  However, on ARM platforms, even the shallowest
> idle states use the WFI instruction, and the EMAC would still not be
> able to wake the system from WFI.  A possibility would be define the
> shallowest idle state to be one that doesn't call WFI and just does
> cpu_relax().  However, that would only work for CPUidle since PM QoS
> constraints are only checked by CPUidle.  So, a non-CPUidle kernel would
> still have this bug. :(
> 
> Ultimately, this is just broken HW.  This network HW was bolted onto an
> existing SoC without consideration for wakeup capabilities.  The result
> is that any use of this device with networking has to completely disable
> SoC power management.
> 

I was checking with internally with some folks on the issue being addressed
in this patch and unfortunately no one seems to be aware of this :(
Mark mentioned nfs mounted rootfs being slow but in my limited testing I
didn't observe this on an AM3517 board. I am yet to go through the PSP code
to be fully sure that wfi instruction is indeed being executed but I wanted
to check if I need to do something specific to reproduce this at my end.

Irrespective of the above problem being present in the h/w, I feel the approach
of adding platform callbacks for blocking deeper idle states will create problems
when this is required for multiple peripherals. I agree that the default behavior
should be to support the deepest idle state based on the peripherals being used but
IMO the user should have the flexibility to change this behavior if he wishes
to do so. 

I don't know whether the usage of the 'wakeup' entries for giving this
control to users qualifies as an abuse of the infrastructure. If it does, perhaps
there should some other mechanism for letting users control the system behavior.

Regards,
Vaibhav
