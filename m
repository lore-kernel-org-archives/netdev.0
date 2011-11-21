From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net/macb: add DT support
Date: Mon, 21 Nov 2011 11:08:41 +0100
Message-ID: <4ECA2329.1000405@atmel.com>
References: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com> <20111118155824.GA9981@totoro> <20111120164740.GC21480@game.jcrosoft.org> <20111120171123.GA7845@gallagher>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss@ozlabs.org, netdev@vger.kernel.org
To: Jamie Iles <jamie@jamieiles.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:24550 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab1KUKI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 05:08:57 -0500
In-Reply-To: <20111120171123.GA7845@gallagher>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2011 06:11 PM, Jamie Iles :
> On Sun, Nov 20, 2011 at 05:47:40PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
>> On 15:58 Fri 18 Nov     , Jamie Iles wrote:
>>> Hi Jean-Christophe,
>>>
>>> On Fri, Nov 18, 2011 at 03:29:25PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>> allow the DT to pass the mac address and the phy mode
>>>>
>>>> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
>>>> Cc: Jamie Iles <jamie@jamieiles.com>
>>>> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
>>>
>>> This looks OK to me in principle.  I can't easily test this at the 
>>> moment, but as I don't have a DT platform that has the clk framework up 
>>> and running.  A couple of nits/questions inline, but thanks for doing 
>>> this!
>>>
>>> Jamie
>>>
>>>> ---
>>>>  Documentation/devicetree/bindings/net/macb.txt |   22 ++++++++
>>>>  drivers/net/ethernet/cadence/macb.c            |   65 +++++++++++++++++++++---
>>>>  drivers/net/ethernet/cadence/macb.h            |    2 +
>>>>  3 files changed, 81 insertions(+), 8 deletions(-)
>>>>  create mode 100644 Documentation/devicetree/bindings/net/macb.txt
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
>>>> new file mode 100644
>>>> index 0000000..2b727ec
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>>>> @@ -0,0 +1,22 @@
>>>> +* Cadence EMACB
>>>> +
>>>> +Implemeted on Atmel AT91 & AVR32 SoC
>>>
>>> I think something along the lines of "Binding for the Cadence MACB 
>>> Ethernet controller" rather than listing specific parts might be 
>>> clearer.
>> I prefer as we will have implementation detail in the binding
> 
> I can't see any Atmel specific implementation detail here though so lets 
> keep it generic for now.  There isn't a benefit to keeping a list of 
> SoC's that the device is implemented in here as it'll only become out of 
> date.  We need to make it easy for other vendors to reuse the binding + 
> driver.

Yes, now that Jamie has made the driver generic, we should not advertise
for specific SoC...

>>>> +		compatible = "atmel,macb";
>>>
>>> This should be "cdns,macb" as it isn't Atmel specific.  I believe cdns 
>>> is the correct stock ticker symbol for Cadence.
>> here I put "atmel,macb" on purpose to specify the difference of the IP between
>> the soc, in fact it should have been atmel-at91,macb

No, before comma means "manufacturer".

> Well if we really can't detect the difference from the revision register 
> then we should have "cdns,macb" *and* "atmel,at91-macb" at least then 
> where platforms could claim compatibility as:
> 
> 	compatible = "atmel,at91-macb", "cdns,macb";
> 
> If we consider that another vendor integrates the Cadence IP, then it 
> makes much more sense to claim compatibility with a Cadence string 
> rather than an Atmel one...

Yes, it seems that you manage to use the revision register to identify
the IP. So here again, maybe the generic compatible string is enough...


>>>
>>>> +		reg = <oxfffc4000 0x4000>;
>>>> +		interrupts = <21>;
>>>> +		phy-mode = "mii";
>>>> +	};
>>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
>>>> index a437b46..2c345bc 100644
>>>> --- a/drivers/net/ethernet/cadence/macb.c
>>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>>> @@ -20,6 +20,9 @@
>>>>  #include <linux/etherdevice.h>
>>>>  #include <linux/dma-mapping.h>
>>>>  #include <linux/platform_device.h>
>>>> +#include <linux/of.h>
>>>> +#include <linux/of_device.h>
>>>> +#include <linux/of_net.h>
>>>>  #include <linux/phy.h>
>>>>  
>>>>  #include <mach/board.h>
>>>> @@ -81,6 +84,20 @@ static void __init macb_get_hwaddr(struct macb *bp)
>>>>  	addr[4] = top & 0xff;
>>>>  	addr[5] = (top >> 8) & 0xff;
>>>>  
>>>> +#ifdef CONFIG_OF
>>>> +	/*
>>>> +	 * 2) from device tree data
>>>> +	 */
>>>> +	if (!is_valid_ether_addr(addr)) {
>>>> +		struct device_node *np = bp->pdev->dev.of_node;
>>>> +		if (np) {
>>>> +			const char *mac = of_get_mac_address(np);
>>>> +			if (mac)
>>>> +				memcpy(addr, mac, sizeof(addr));
>>>> +		}
>>>> +	}
>>>> +#endif
>>>
>>> I'm a bit conflicted here.  I think we should always use the MAC address 
>>> from the device tree if it is present even if the current MAC address is 
>>> valid.
>> if the mac is already programmed in the register we just keep it
>> I prefer this way if the bootloader set it we keep it
> 
> But I don't think that makes sense - if there is a MAC address in the 
> DT, which is an optional property then the DT author must want to set 
> the MAC address from the DT.  We should really prefer an explicit 
> assignment over an implicit one.

Yes, that seems sensible.

Best regards,
-- 
Nicolas Ferre
