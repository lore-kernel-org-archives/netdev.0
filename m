From: Kevin Hilman <khilman@ti.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform callbacks
Date: Thu, 03 May 2012 14:32:16 -0700
Message-ID: <87ehr1gdcv.fsf@ti.com>
References: <20120502234718.GA5432@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	<20120503160917.GA11310@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
	<20120503184632.GA28089@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
	<1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bedia\, Vaibhav" <vaibhav.bedia@ti.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Thu, 3 May 2012 21:22:22 +0100")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Thu, 2012-05-03 at 19:25 +0000, Bedia, Vaibhav wrote:
>> On Fri, May 04, 2012 at 00:16:32, Mark A. Greer wrote:
>> [...]
>> > > 
>> > > So, if I understood this correctly, it's effectively like blocking a low power
>> > > state transition (here wfi execution) when EMAC is active?
>> > 
>> > Assuming "it" is my patch, correct.
>> > 
>> 
>> Recently I was thinking about how to get certain drivers to disallow some or all
>> low power states and to me this also seems to fall in a similar category.
>> 
>> One of the suggestions that I got was to check if the 'wakeup' entry associated with
>> the device under sysfs could be leveraged for this. The PM code could maintain
>> a whitelist (or blacklist) of devices and it decides the low power state to enter
>> based on the 'wakeup' entries associated with these devices. In this particular case,
>> maybe the driver could simply set this entry to non-wakeup capable when necessary and
>> then let the PM code take care of skipping the wfi execution.
>> 
>> Thoughts/brickbats welcome :)
>
> You can maybe (ab)use the pm_qos mechanism for this.

I thought of using this too, but it doesn't actually solve the problem:

Using PM QoS, you can avoid hitting the deeper idle states by setting a
very low wakeup latency.  However, on ARM platforms, even the shallowest
idle states use the WFI instruction, and the EMAC would still not be
able to wake the system from WFI.  A possibility would be define the
shallowest idle state to be one that doesn't call WFI and just does
cpu_relax().  However, that would only work for CPUidle since PM QoS
constraints are only checked by CPUidle.  So, a non-CPUidle kernel would
still have this bug. :(

Ultimately, this is just broken HW.  This network HW was bolted onto an
existing SoC without consideration for wakeup capabilities.  The result
is that any use of this device with networking has to completely disable
SoC power management.

Kevin
