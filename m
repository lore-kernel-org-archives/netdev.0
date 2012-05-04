From: Kevin Hilman <khilman@ti.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform callbacks
Date: Fri, 04 May 2012 07:31:30 -0700
Message-ID: <87fwbgdnlp.fsf@ti.com>
References: <20120502234718.GA5432@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	<20120503160917.GA11310@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
	<20120503184632.GA28089@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
	<1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
	<87ehr1gdcv.fsf@ti.com>
	<B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Bedia\, Vaibhav" <vaibhav.bedia@ti.com>, nsekhar@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
	(Vaibhav Bedia's message of "Fri, 4 May 2012 13:55:58 +0000")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+Sekhar

"Bedia, Vaibhav" <vaibhav.bedia@ti.com> writes:

> Hi Kevin,
>
> On Fri, May 04, 2012 at 03:02:16, Hilman, Kevin wrote:
>> Ben Hutchings <bhutchings@solarflare.com> writes:
>> 
>> > On Thu, 2012-05-03 at 19:25 +0000, Bedia, Vaibhav wrote:
>> >> On Fri, May 04, 2012 at 00:16:32, Mark A. Greer wrote:
>> >> [...]
>> >> > > 
>> >> > > So, if I understood this correctly, it's effectively like blocking a low power
>> >> > > state transition (here wfi execution) when EMAC is active?
>> >> > 
>> >> > Assuming "it" is my patch, correct.
>> >> > 
>> >> 
>> >> Recently I was thinking about how to get certain drivers to disallow some or all
>> >> low power states and to me this also seems to fall in a similar category.
>> >> 
>> >> One of the suggestions that I got was to check if the 'wakeup' entry associated with
>> >> the device under sysfs could be leveraged for this. The PM code could maintain
>> >> a whitelist (or blacklist) of devices and it decides the low power state to enter
>> >> based on the 'wakeup' entries associated with these devices. In this particular case,
>> >> maybe the driver could simply set this entry to non-wakeup capable when necessary and
>> >> then let the PM code take care of skipping the wfi execution.
>> >> 
>> >> Thoughts/brickbats welcome :)
>> >
>> > You can maybe (ab)use the pm_qos mechanism for this.
>> 
>> I thought of using this too, but it doesn't actually solve the problem:
>> 
>> Using PM QoS, you can avoid hitting the deeper idle states by setting a
>> very low wakeup latency.  However, on ARM platforms, even the shallowest
>> idle states use the WFI instruction, and the EMAC would still not be
>> able to wake the system from WFI.  A possibility would be define the
>> shallowest idle state to be one that doesn't call WFI and just does
>> cpu_relax().  However, that would only work for CPUidle since PM QoS
>> constraints are only checked by CPUidle.  So, a non-CPUidle kernel would
>> still have this bug. :(
>> 
>> Ultimately, this is just broken HW.  This network HW was bolted onto an
>> existing SoC without consideration for wakeup capabilities.  The result
>> is that any use of this device with networking has to completely disable
>> SoC power management.
>> 
>
> I was checking with internally with some folks on the issue being addressed
> in this patch and unfortunately no one seems to be aware of this :(

Do you mean they are not aware that the EMAC cannot wakeup th SoC, or
they are not aware that having a device that cannot wakup the SoC has
such an impact on Linux.

> Mark mentioned nfs mounted rootfs being slow but in my limited testing I
> didn't observe this on an AM3517 board. I am yet to go through the PSP code
> to be fully sure that wfi instruction is indeed being executed but I wanted
> to check if I need to do something specific to reproduce this at my end.

Based on my discussion with Mark, I suspect that the kernel you're using
is simply not going idle.

> Irrespective of the above problem being present in the h/w, I feel the approach
> of adding platform callbacks for blocking deeper idle states will create problems
> when this is required for multiple peripherals. 

I agree.  If we have to do this for multiple peripherals, the curren
approach it will become unwieldy.

> I agree that the default behavior should be to support the deepest
> idle state based on the peripherals being used but IMO the user should
> have the flexibility to change this behavior if he wishes to do so.

Well, we always have the option of booting with 'nohlt' on the
commandline.

Since nobody seems to have thought about idle power management in the HW
design, maybe we shouldn't break our backs to hack around the
HW brokenness.

Personally, I'm perfectly OK leaving the default behavior of
sluggish/unresponsive devices that are not wakeup capable.  The only fix
is to not sleep, and that can be accomplished on the cmdline using
nohlt (at the expense of some energy savings.)

> I don't know whether the usage of the 'wakeup' entries for giving this
> control to users qualifies as an abuse of the infrastructure. 

It does.

> If it does, perhaps there should some other mechanism for letting
> users control the system behavior.

Come to think of it, the right solution here is probably to use runtime
PM.  We could then to add some custom hooks for davinci_emac in the
device code to use enable_hlt/disable_hlt based on activity.

In order to do that though, the davinci_emac driver needs to be runtime
PM converted.

Kevin








