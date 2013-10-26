From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to
 `devm_gpio_request_one'
Date: Sat, 26 Oct 2013 22:15:42 +0100
Message-ID: <1382822142.23829.46.camel@dvhart-mobl4.amr.corp.intel.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com>
	 <20131025044027.GA27083@localhost>
	 <CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com>
	 <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>
	 <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>
	 <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>
	 <526AE0EB.4020602@linux.intel.com> <526AE1E2.9080909@linux.intel.com>
	 <1382819615.23829.16.camel@dvhart-mobl4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: David Cohen <david.a.cohen@linux.intel.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1382819615.23829.16.camel@dvhart-mobl4.amr.corp.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 21:33 +0100, Darren Hart wrote:
> On Fri, 2013-10-25 at 14:25 -0700, David Cohen wrote:
> > On 10/25/2013 02:21 PM, David Cohen wrote:
> > > Hi Linus,
> > >
> > > On 10/25/2013 03:49 AM, Linus Walleij wrote:
> > >> On Fri, Oct 25, 2013 at 12:41 PM, Linus Walleij
> > >> <linus.walleij@linaro.org> wrote:
> > >>
> > >>>> I wouldn't object to adding a dependency to GPIO_PCH and GPIOLIB
> > >>>> unconditionally for PCH_GBE as GPIO_PCH is the same chip... but I don't
> > >>>> know if David Miller would be amenable to that.
> > >>>
> > >>> Well we should probably just stick a dependency to GPIOLIB in there.
> > >>>
> > >>> - It #includes <linux/gpio.h>
> > >>> - It uses gpiolib functions to do something vital
> > >>>
> > >>> It was just happy that dummy versions were slotted in until now.
> > >>
> > >> ...or maybe I'm just confused now?
> > >>
> > >> Should we just add a static inline stub of devm_gpio_request_one()?
> > >
> > > I am not familiar with the HW. But checking the code, platform
> > > initialization should fail with a dummy devm_gpio_request_one()
> > > implementation. IMO it makes more sense to depend on GPIOLIB.
> > 
> > Actually, forget about it. Despite driver_data->platform_init() may
> > return error, probe() never checks for it. I think the driver must be
> > fixed, but in meanwhile a static inline stub seems reasonable.
> > 
> 
> Ah, that's a problem, and one I created :/ I'm traveling a bit through
> Europe atm for the conferences. I will try and have a look on the planes
> and add a check.

Ah, now I remember. The situation is this. If there is a cable plugged
into the jack, the PHY will not go to sleep. If there isn't, there is a
good chance it will go to sleep before the driver initializes. If it is
asleep, the scan for the PHY will fail. If it isn't, the scan will work
correctly and the device will be properly setup. The code currently
displays a dev error:

	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
				    "minnow_phy_reset");
	if (ret) {
		dev_err(&pdev->dev,
			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);

But deliberately does not about the probe because there is a chance
things will work just fine. If they do not, the PHY detection code will
print display errors about a failure to communicate over RGMII, and the
device probe will fail from there.

This still seems like the correct approach to me. Does anyone disagree?

(we still need to sort out the GPIOLIB and GPIO_SCH dependency though of
course)

Thanks,

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel


