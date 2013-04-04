From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Thu, 4 Apr 2013 16:41:18 +0530
Message-ID: <515D5FD6.4040909@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com> <1364993634-6378-2-git-send-email-kishon@ti.com> <515CA337.1010504@gmail.com> <515D462F.9050109@ti.com> <515D58F2.7030404@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <balbi@ti.com>, <gregkh@linuxfoundation.org>, <arnd@arndb.de>,
	<akpm@linux-foundation.org>, <swarren@wwwdotorg.org>,
	<rob@landley.net>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
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
To: Sylwester Nawrocki <s.nawrocki@samsung.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <515D58F2.7030404@samsung.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thursday 04 April 2013 04:11 PM, Sylwester Nawrocki wrote:
> Hi,
>
> On 04/04/2013 11:21 AM, Kishon Vijay Abraham I wrote:
>> On Thursday 04 April 2013 03:16 AM, Sylwester Nawrocki wrote:
>>> On 04/03/2013 02:53 PM, Kishon Vijay Abraham I wrote:
>
>>>> +4. Getting a reference to the PHY
>>>> +
>>>> +Before the controller can make use of the PHY, it has to get a
>>>> reference to
>>>> +it. This framework provides 6 APIs to get a reference to the PHY.
>>>> +
>>>> +struct phy *phy_get(struct device *dev, int index);
>>>> +struct phy *devm_phy_get(struct device *dev, int index);
>>>> +struct phy *of_phy_get(struct device *dev, const char *phandle, int
>>>> index);
>>>> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle,
>>>> int index);
>>>
>>> Why do we need separate functions for dt and non-dt ? Couldn't it be
>>> handled
>>> internally by the framework ? So the PHY users can use same calls for dt
>>> and non-dt, like in case of e.g. the regulators API ?
>>
>> yeah. Indeed it makes sense to do it that way.
>>
>>> Also signatures of some functions are different now:
>>>
>>> extern struct phy *phy_get(struct device *dev, int index);
>>> extern struct phy *devm_phy_get(struct device *dev, int index);
>>> extern struct phy *of_phy_get(struct device *dev, int index);
>>> extern struct phy *devm_of_phy_get(struct device *dev, int index);
>>
>> My bad :-(
>>
>>> BTW, I think "extern" could be dropped, does it have any significance in
>>> function declarations in header files ?
>>
>> it shouldn't have any effect I guess. It's harmless nevertheless.
>
> Yup.
>
>>>> +struct phy *of_phy_get_byname(struct device *dev, const char *string);
>>>> +struct phy *devm_of_phy_get_byname(struct device *dev, const char
>>>> *string);
>
>>>> --- /dev/null
>>>> +++ b/drivers/phy/phy-core.c
>>>> @@ -0,0 +1,616 @@
>>>
>>>> +static struct phy *of_phy_lookup(struct device_node *node)
>>>> +{
>>>> +    struct phy *phy;
>>>> +    struct device *dev;
>>>> +    struct class_dev_iter iter;
>>>> +
>>>> +    class_dev_iter_init(&iter, phy_class, NULL, NULL);
>>>
>>> There is currently nothing preventing a call to this function before
>>> phy_class is initialized. It happened during my tests, and the nice
>>> stack dump showed that it was the PHY user attempting to get the PHY
>>> before the framework got initialized. So either phy_core_init should
>>> be a subsys_initcall or we need a better protection against phy_class
>>> being NULL or ERR_PTR in more places.
>>
>> Whats the initcall used in your PHY user? Looks like more people prefer having
>
> It happened in a regular platform driver probe() callback.
>
>> module_init and any issue because of it should be fixed in PHY providers and
>> PHY users.
>
> OK. In fact this uncovered some issues in the MIPI DSI interface driver
> (some unexpected interrupts). But this should just be fixed in those drivers
> anyway. Now the DSI interface driver needs to wait for the PHY to be
> registered and ready, so the initialization will likely be changed regardless
> the framework initializes in module_init or earlier.
>
>>>> +    while ((dev = class_dev_iter_next(&iter))) {
>>>> +        phy = container_of(dev, struct phy, dev);
>>>> +        if (node != phy->of_node)
>>>> +            continue;
>>>> +
>>>> +        class_dev_iter_exit(&iter);
>>>> +        return phy;
>>>> +    }
>>>> +
>>>> +    class_dev_iter_exit(&iter);
>>>> +    return ERR_PTR(-EPROBE_DEFER);
>>>> +}
>>>
>>>> +/**
>>>> + * of_phy_get() - lookup and obtain a reference to a phy by phandle
>>>> + * @dev: device that requests this phy
>>>> + * @index: the index of the phy
>>>> + *
>>>> + * Returns the phy associated with the given phandle value,
>>>> + * after getting a refcount to it or -ENODEV if there is no such phy or
>>>> + * -EPROBE_DEFER if there is a phandle to the phy, but the device is
>>>> + * not yet loaded.
>>>> + */
>>>> +struct phy *of_phy_get(struct device *dev, int index)
>>>> +{
>>>> +    int ret;
>>>> +    struct phy *phy = NULL;
>>>> +    struct phy_bind *phy_map = NULL;
>>>> +    struct of_phandle_args args;
>>>> +    struct device_node *node;
>>>> +
>>>> +    if (!dev->of_node) {
>>>> +        dev_dbg(dev, "device does not have a device node entry\n");
>>>> +        return ERR_PTR(-EINVAL);
>>>> +    }
>>>> +
>>>> +    ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
>>>> +        index,&args);
>>>> +    if (ret) {
>>>> +        dev_dbg(dev, "failed to get phy in %s node\n",
>>>> +            dev->of_node->full_name);
>>>> +        return ERR_PTR(-ENODEV);
>>>> +    }
>>>> +
>>>> +    phy = of_phy_lookup(args.np);
>>>> +    if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
>>>> +        phy = ERR_PTR(-EPROBE_DEFER);
>>>> +        goto err0;
>>>> +    }
>>>> +
>>>> +    phy = phy->ops->of_xlate(phy,&args);
>>>> +    if (IS_ERR(phy))
>>>> +        goto err1;
>>>> +
>>>> +    phy_map = phy_bind(dev_name(dev), index, dev_name(&phy->dev));
>>>> +    if (!IS_ERR(phy_map)) {
>>>> +        phy_map->phy = phy;
>>>> +        phy_map->auto_bind = true;
>>>
>>> Shouldn't it be done with the phy_bind_mutex held ? I guess an unlocked
>>> version of the phy_bind functions is needed, so it can be used internally.
>>
>> The locking is done inside phy_bind function. I'm not sure but I vaguely
>> remember getting a dump stack (incorrect mutex ordering or something) when
>> trying to have phy_bind_mutex here. I can check it again.
>
> Yes, IIUC the locking needs to be reworked a bit so "phy_map" is not modified
> without the mutex held.
>
>>>> +    }
>>>> +
>>>> +    get_device(&phy->dev);
>>>> +
>>>> +err1:
>>>> +    module_put(phy->ops->owner);
>>>> +
>>>> +err0:
>>>> +    of_node_put(node);
>>>> +
>>>> +    return phy;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(of_phy_get);
>>>
>>>> +/**
>>>> + * phy_create() - create a new phy
>>>> + * @dev: device that is creating the new phy
>>>> + * @label: label given to phy
>>>> + * @of_node: device node of the phy
>>>> + * @type: specifies the phy type
>>>> + * @ops: function pointers for performing phy operations
>>>> + * @priv: private data from phy driver
>>>> + *
>>>> + * Called to create a phy using phy framework.
>>>> + */
>>>> +struct phy *phy_create(struct device *dev, const char *label,
>>>> +    struct device_node *of_node, int type, struct phy_ops *ops,
>>>> +    void *priv)
>>>> +{
>>>> +    int ret;
>>>> +    struct phy *phy;
>>>> +    struct phy_bind *phy_bind;
>>>> +    const char *devname = NULL;
>>>> +
>>>> +    if (!dev) {
>>>> +        dev_err(dev, "no device provided for PHY\n");
>>>> +        ret = -EINVAL;
>>>> +        goto err0;
>>>> +    }
>>>> +
>>>> +    if (!ops || !ops->of_xlate || !priv) {
>>>> +        dev_err(dev, "no PHY ops/PHY data provided\n");
>>>> +        ret = -EINVAL;
>>>> +        goto err0;
>>>> +    }
>>>> +
>>>> +    if (!phy_class)
>>>> +        phy_core_init();
>>>> +
>>>> +    phy = kzalloc(sizeof(*phy), GFP_KERNEL);
>>>> +    if (!phy) {
>>>> +        ret = -ENOMEM;
>>>> +        goto err0;
>>>> +    }
>>>> +
>>>> +    devname = dev_name(dev);
>>>
>>> OK, a sort of serious issue here is that you can't call phy_create()
>>> multiple times for same PHY provider device.
>>
>> Ah.. right.
>
> The other question I had was why we needed struct device object for each
> PHY. And if it wouldn't be enough to have only struct device * in
> struct phy, and the real device would be the PHY provider only. I might

IMO the PHY framework shouldn't be modifying the properties of device of 
some other driver. Consider the case where the PHY provider implements 
other functions also (in addition to acting as a PHY) in which case the 
PHY provider entirely doesn't come under *PHY class* but only a part of 
it. There might be other reasons as well.

Thanks
Kishon


