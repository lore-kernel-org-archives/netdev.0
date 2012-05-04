From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Fri, 4 May 2012 09:35:57 -0700
Message-ID: <20120504163557.GA28910@animalcreek.com>
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
Cc: "Hilman, Kevin" <khilman@ti.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2012 at 01:55:58PM +0000, Bedia, Vaibhav wrote:

Hi Vaibhav.

> Hi Kevin,
> 
> On Fri, May 04, 2012 at 03:02:16, Hilman, Kevin wrote:
> > Ben Hutchings <bhutchings@solarflare.com> writes:
> > 
> > > On Thu, 2012-05-03 at 19:25 +0000, Bedia, Vaibhav wrote:
> > >> On Fri, May 04, 2012 at 00:16:32, Mark A. Greer wrote:
> > >> [...]
> > >> > > 
> > >> > > So, if I understood this correctly, it's effectively like blocking a low power
> > >> > > state transition (here wfi execution) when EMAC is active?
> > >> > 
> > >> > Assuming "it" is my patch, correct.
> > >> > 
> > >> 
> > >> Recently I was thinking about how to get certain drivers to disallow some or all
> > >> low power states and to me this also seems to fall in a similar category.
> > >> 
> > >> One of the suggestions that I got was to check if the 'wakeup' entry associated with
> > >> the device under sysfs could be leveraged for this. The PM code could maintain
> > >> a whitelist (or blacklist) of devices and it decides the low power state to enter
> > >> based on the 'wakeup' entries associated with these devices. In this particular case,
> > >> maybe the driver could simply set this entry to non-wakeup capable when necessary and
> > >> then let the PM code take care of skipping the wfi execution.
> > >> 
> > >> Thoughts/brickbats welcome :)
> > >
> > > You can maybe (ab)use the pm_qos mechanism for this.
> > 
> > I thought of using this too, but it doesn't actually solve the problem:
> > 
> > Using PM QoS, you can avoid hitting the deeper idle states by setting a
> > very low wakeup latency.  However, on ARM platforms, even the shallowest
> > idle states use the WFI instruction, and the EMAC would still not be
> > able to wake the system from WFI.  A possibility would be define the
> > shallowest idle state to be one that doesn't call WFI and just does
> > cpu_relax().  However, that would only work for CPUidle since PM QoS
> > constraints are only checked by CPUidle.  So, a non-CPUidle kernel would
> > still have this bug. :(
> > 
> > Ultimately, this is just broken HW.  This network HW was bolted onto an
> > existing SoC without consideration for wakeup capabilities.  The result
> > is that any use of this device with networking has to completely disable
> > SoC power management.
> > 
> 
> I was checking with internally with some folks on the issue being addressed
> in this patch and unfortunately no one seems to be aware of this :(

This is from the TI hardware engineer that I talked to after spending many
hours trying to get the EMAC to wake up the system.  It was a private
conversation so I won't share his name/email here.  If you want to contact
him, please reach me privately.

"No, AM35x can't be waken up from CPGMAC. If customer need to wake AM35x
 up from Ethernet, a wake up interrupt signal from Ethernet phy should be
 connected to one of wakeup capable GPIO pins."

> Mark mentioned nfs mounted rootfs being slow but in my limited testing I
> didn't observe this on an AM3517 board. I am yet to go through the PSP code
> to be fully sure that wfi instruction is indeed being executed but I wanted
> to check if I need to do something specific to reproduce this at my end.

When you go through the PSP code, look for the definition & use of
omap3_can_sleep().  That routine returns '0' when either cpu_is_omap3505()
or cpu_is_omap3517() ruturns true (among other conditions).  You will see
that its used in omap3_pm_idle() to exit early so pm_idle never executes
the wfi.

I expect that you don't have CONFIG_CPU_IDLE enabled, so cpuidle has no
opportunity to execute a wfi.  If it is enabled, omap3_can_sleep() is
used in omap3_idle_bm_check() which is used in omap3_enter_idle_bm()
so the wfi won't be executed when omap3_enter_idle_bm() is called.
omap3_enter_idle() isn't called (in my testing--the code is very
different from current k.o.) so it doesn't execute the wfi either.

Therefore, you don't see an issue when running PSP code.

> Irrespective of the above problem being present in the h/w, I feel the approach
> of adding platform callbacks for blocking deeper idle states will create problems
> when this is required for multiple peripherals. I agree that the default behavior
> should be to support the deepest idle state based on the peripherals being used but
> IMO the user should have the flexibility to change this behavior if he wishes
> to do so. 

I agree but hopefully this doesn't become common.  The real issue is a
missing hardware feature that--again, hopefully--won't become common.

Mark
