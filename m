From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Mon, 28 Oct 2013 11:01:41 -0700
Message-ID: <526EA685.1030803@linux.intel.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com>   <20131025044027.GA27083@localhost>   <CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com>   <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>   <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>   <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>   <526AE0EB.4020602@linux.intel.com> <526AE1E2.9080909@linux.intel.com>   <1382819615.23829.16.camel@dvhart-mobl4.amr.corp.intel.com>  <1382822142.23829.46.camel@dvhart-mobl4.amr.corp.intel.com>  <526CA546.7040406@linux.intel.com> <1382918677.23829.92.camel@dvhart-mobl4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1382918677.23829.92.camel@dvhart-mobl4.amr.corp.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> 	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
>>> 				    "minnow_phy_reset");
>>> 	if (ret) {
>>> 		dev_err(&pdev->dev,
>>> 			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
>>>
>>> But deliberately does not about the probe because there is a chance
>>> things will work just fine. If they do not, the PHY detection code will
>>> print display errors about a failure to communicate over RGMII, and the
>>> device probe will fail from there.
>>>
>>> This still seems like the correct approach to me. Does anyone disagree?
>>
>> Considering this scenario it seems to be correct. But if
>> devm_gpio_request_one() may fail for "unfriendly" reasons too, then
>> it's incomplete.
>>
>>>
>>> (we still need to sort out the GPIOLIB and GPIO_SCH dependency though of
>>> course)
>>
>> Maybe if GPIOLIB has the static inline stubs returning -ENODEV we could
>> use a patch similar to the one attached here.
>>
>
> I think you may have inverted your logic on the return?
>
> +		dev_warn(&pdev->dev,
> +			 "ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> +		return ret == -ENODEV ? ret : 0;
>
> Did you mean:
>
> +		/*
> 		 * Things may still work if the GPIO driver wasn't
> 		 * compiled in
> 		 */

Actually I did mean what I sent, but I misunderstood the above case
where it may work without GPIO driver.
But anyway, "things *may* still work" IMO may create instability issue
by allowing an uncertain situation to go through. If PCH_GBE depends on
GPIOLIB in MinnowBoard case it should fail right away with a clear
message why.

If pch_gbe driver can detect what devm_gpio_request_one() returns from
the static inline stub then it can create a condition to gracefully
fail. So whoever is interested in MinnowBoard will spend less time
trying to identify this problem.

Br, David Cohen

> +		return ret == -ENODEV ? 0 : ret;
>
> The concern here of course would be someone added another GPIO
> controller over i2c over the expansion connector or something similar
> and did not enable the GPIO_SCH driver, then it could conceivably grab
> the wrong GPIO pin.... or would those never map to GPIO 13?
>

