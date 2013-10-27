From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Sat, 26 Oct 2013 22:31:50 -0700
Message-ID: <526CA546.7040406@linux.intel.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com>  <20131025044027.GA27083@localhost>  <CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com>  <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>  <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>  <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>  <526AE0EB.4020602@linux.intel.com> <526AE1E2.9080909@linux.intel.com>  <1382819615.23829.16.camel@dvhart-mobl4.amr.corp.intel.com> <1382822142.23829.46.camel@dvhart-mobl4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040708000707010609030007"
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1382822142.23829.46.camel@dvhart-mobl4.amr.corp.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040708000707010609030007
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 10/26/2013 02:15 PM, Darren Hart wrote:
> On Sat, 2013-10-26 at 21:33 +0100, Darren Hart wrote:
>> On Fri, 2013-10-25 at 14:25 -0700, David Cohen wrote:
>>> On 10/25/2013 02:21 PM, David Cohen wrote:
>>>> Hi Linus,
>>>>
>>>> On 10/25/2013 03:49 AM, Linus Walleij wrote:
>>>>> On Fri, Oct 25, 2013 at 12:41 PM, Linus Walleij
>>>>> <linus.walleij@linaro.org> wrote:
>>>>>
>>>>>>> I wouldn't object to adding a dependency to GPIO_PCH and GPIOLIB
>>>>>>> unconditionally for PCH_GBE as GPIO_PCH is the same chip... but I don't
>>>>>>> know if David Miller would be amenable to that.
>>>>>>
>>>>>> Well we should probably just stick a dependency to GPIOLIB in there.
>>>>>>
>>>>>> - It #includes <linux/gpio.h>
>>>>>> - It uses gpiolib functions to do something vital
>>>>>>
>>>>>> It was just happy that dummy versions were slotted in until now.
>>>>>
>>>>> ...or maybe I'm just confused now?
>>>>>
>>>>> Should we just add a static inline stub of devm_gpio_request_one()?
>>>>
>>>> I am not familiar with the HW. But checking the code, platform
>>>> initialization should fail with a dummy devm_gpio_request_one()
>>>> implementation. IMO it makes more sense to depend on GPIOLIB.
>>>
>>> Actually, forget about it. Despite driver_data->platform_init() may
>>> return error, probe() never checks for it. I think the driver must be
>>> fixed, but in meanwhile a static inline stub seems reasonable.
>>>
>>
>> Ah, that's a problem, and one I created :/ I'm traveling a bit through
>> Europe atm for the conferences. I will try and have a look on the planes
>> and add a check.
> 
> Ah, now I remember. The situation is this. If there is a cable plugged
> into the jack, the PHY will not go to sleep. If there isn't, there is a
> good chance it will go to sleep before the driver initializes. If it is
> asleep, the scan for the PHY will fail. If it isn't, the scan will work
> correctly and the device will be properly setup. The code currently
> displays a dev error:
> 
> 	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
> 				    "minnow_phy_reset");
> 	if (ret) {
> 		dev_err(&pdev->dev,
> 			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> 
> But deliberately does not about the probe because there is a chance
> things will work just fine. If they do not, the PHY detection code will
> print display errors about a failure to communicate over RGMII, and the
> device probe will fail from there.
> 
> This still seems like the correct approach to me. Does anyone disagree?

Considering this scenario it seems to be correct. But if
devm_gpio_request_one() may fail for "unfriendly" reasons too, then
it's incomplete.

> 
> (we still need to sort out the GPIOLIB and GPIO_SCH dependency though of
> course)

Maybe if GPIOLIB has the static inline stubs returning -ENODEV we could
use a patch similar to the one attached here.

Br, David

--------------040708000707010609030007
Content-Type: text/x-patch;
 name="pch_gbe_main.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pch_gbe_main.patch"

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 5a0f04c..4702876 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2637,8 +2637,11 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	adapter->hw.back = adapter;
 	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
 	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
-	if (adapter->pdata && adapter->pdata->platform_init)
-		adapter->pdata->platform_init(pdev);
+	if (adapter->pdata && adapter->pdata->platform_init) {
+		ret = adapter->pdata->platform_init(pdev);
+		if (ret)
+			goto err_free_netdev;
+	}
 
 	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
 					       PCI_DEVFN(12, 4));
@@ -2740,9 +2743,9 @@ static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
 	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
 				    "minnow_phy_reset");
 	if (ret) {
-		dev_err(&pdev->dev,
-			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
-		return ret;
+		dev_warn(&pdev->dev,
+			 "ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
+		return ret == -ENODEV ? ret : 0;
 	}
 
 	gpio_set_value(gpio, 0);

--------------040708000707010609030007--
