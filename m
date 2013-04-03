From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 20:02:52 +0530
Message-ID: <515C3D94.1060000@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com> <1364993634-6378-2-git-send-email-kishon@ti.com> <20130403134102.GC14680@arwen.pp.htv.fi> <515C3A42.4020404@ti.com> <20130403142747.GK14680@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <arnd@arndb.de>,
	<akpm@linux-foundation.org>, <swarren@wwwdotorg.org>,
	<sylvester.nawrocki@gmail.com>, <rob@landley.net>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<cesarb@cesarb.net>, <linux-usb@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tony@atomide.com>, <grant.likely@secretlab.ca>,
	<rob.herring@calxeda.com>, <b-cousson@ti.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <mchehab@redhat.com>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <balbi@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130403142747.GK14680@arwen.pp.htv.fi>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wednesday 03 April 2013 07:57 PM, Felipe Balbi wrote:
> hi,
>
> On Wed, Apr 03, 2013 at 07:48:42PM +0530, Kishon Vijay Abraham I wrote:
>>>> +struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args)
>>>> +{
>>>> +	return phy;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(of_phy_xlate);
>>>
>>> so you get a PHY and just return it ? What gives ?? (maybe I skipped
>>> some of the discussion...)
>>
>> hmm.. this is for the common case where the PHY provider implements
>> only one PHY. And both phy provider and phy_instance is represented
>> by struct phy *.
>>
>> For the case where PHY provider implements multiple PHYs (here it
>> will have a single dt node), the PHY provider will implement it's own
>> version of of_xlate that takes *of_phandle_args* as argument and
>> finds the appropriate PHY.
>
> got it.
>
>>>> +struct phy *of_phy_get(struct device *dev, int index)
>>>> +{
>>>> +	int ret;
>>>> +	struct phy *phy = NULL;
>>>> +	struct phy_bind *phy_map = NULL;
>>>> +	struct of_phandle_args args;
>>>> +	struct device_node *node;
>>>> +
>>>> +	if (!dev->of_node) {
>>>> +		dev_dbg(dev, "device does not have a device node entry\n");
>>>> +		return ERR_PTR(-EINVAL);
>>>> +	}
>>>> +
>>>> +	ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
>>>> +		index, &args);
>>>> +	if (ret) {
>>>> +		dev_dbg(dev, "failed to get phy in %s node\n",
>>>> +			dev->of_node->full_name);
>>>> +		return ERR_PTR(-ENODEV);
>>>> +	}
>>>> +
>>>> +	phy = of_phy_lookup(args.np);
>>>> +	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
>>>> +		phy = ERR_PTR(-EPROBE_DEFER);
>>>> +		goto err0;
>>>> +	}
>>>> +
>>>> +	phy = phy->ops->of_xlate(phy, &args);
>>>
>>> alright, so of_xlate() is optional, am I right ? How about not
>>
>> Not really. of_xlate is mandatory (it's even checked in phy_create).
>> Either the PHY provider can implement it's own version or use the
>> implementation above (by filling the function pointer).
>
> alright.
>
>>> implementing the above and have a check for of_xlate() being a valid
>>> pointer here ?
>>
>> Having the way it is actually mandates the PHY providers to always
>> provide of_xlate which IMO is better since some PHY providers wont
>> accidentally be using the default implementation.
>
> ok cool, thanks for clarifying.
>
>>>> +		ret = -EINVAL;
>>>> +		goto err0;
>>>> +	}
>>>> +
>>>> +	if (!phy_class)
>>>> +		phy_core_init();
>>>
>>> why don't you setup the class on module_init ? Then this would be a
>>> terrible error condition here :-)
>>
>> This is for the case where the PHY driver gets loaded before the PHY
>> framework. I could have returned EPROBE_DEFER here instead I thought
>> will have it this way.
>
> looks a bit weird IMO. Is it really possible for PHY to load before ?

yeah. it actually happened when I tried with beagle and had all the 
modules as built-in. Because twl4030 has subsys_initcall(), it loads 
before PHY framework.

Thanks
Kishon
