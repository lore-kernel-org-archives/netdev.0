From: kishon <kishon@ti.com>
Subject: Re: [PATCH v2 1/5] drivers: phy: add generic PHY framework
Date: Tue, 19 Feb 2013 19:26:21 +0530
Message-ID: <51238485.1020408@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com> <1361253198-7401-2-git-send-email-kishon@ti.com> <201302191256.24557.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <balbi@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201302191256.24557.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 19 February 2013 06:26 PM, Arnd Bergmann wrote:
> On Tuesday 19 February 2013, Kishon Vijay Abraham I wrote:
>> +static struct class *phy_class;
>> +static LIST_HEAD(phy_list);
>> +static DEFINE_MUTEX(phy_list_mutex);
>> +static LIST_HEAD(phy_bind_list);
>
> Hmm, so you actually do have a 'class'. There is a GregKH mandated ban on
> new classes, meaning that one should be converted to a bus_type instead.
>
> Also, you really should not need the global phy_list, phy_list_mutex
> and phy_bind_list variables, since the driver core already provides
> you with ways to iterate through devices on a class or bus.

ok.

>
>> +/**
>> + * of_phy_get - lookup and obtain a reference to a phy by phandle
>> + * @dev: device that requests this phy
>> + * @phandle: name of the property holding the phy phandle value
>> + * @index - the index of the phy
>> + *
>> + * Returns the phy associated with the given phandle value,
>> + * after getting a refcount to it or -ENODEV if there is no such phy or
>> + * -EPROBE_DEFER if there is a phandle to the phy, but the device is
>> + * not yet loaded.
>> + */
>> +struct phy *of_phy_get(struct device *dev, const char *phandle, u8 index)
>> +{
>> +	struct phy *phy = NULL;
>> +	struct phy_bind *phy_map = NULL;
>> +	struct device_node *node;
>> +
>> +	if (!dev->of_node) {
>> +		dev_dbg(dev, "device does not have a device node entry\n");
>> +		return ERR_PTR(-EINVAL);
>> +	}
>> +
>> +	node = of_parse_phandle(dev->of_node, phandle, index);
>> +	if (!node) {
>> +		dev_dbg(dev, "failed to get %s phandle in %s node\n", phandle,
>> +			dev->of_node->full_name);
>> +		return ERR_PTR(-ENODEV);
>> +	}
>
> I wonder whether this one should be of_parse_phandle_with_args() instead,
> so you can have client-specific configuration in the property. Basically
> instead of
>
> 	phy = <&usbphy0 &usbphy1>;
>
> you can pass an arbitrary number of arguments along with this, as
> determined by some property in the phy node:
>
> 	usbphy0: phy@10000 {
> 		#phy-cells = <1>;
> 	};
>
> 	ehci@20000 {
> 		phy = <&usbphy0 23>;
> 	};
>
> Which in turn leads to the argument (23) being passed into a phy_bind().
>
> I also wonder if you should allow arbitrary names for the property.
> Can't this always be called 'phy'? If you allow named phys, it would
> more more consistent with other bindings to have a list of phy handles
> in a property called "phy", and a second property called "phy-names"
> that contains the named strings.

Ok. Makes sense. We should make both *phy* and *phy-cells* standard here.
>
>
>> +/**
>> + * phy_create - create a new phy
>> + * @dev: device that is creating the new phy
>> + * @desc: descriptor of the phy
>> + *
>> + * Called to create a phy using phy framework.
>> + */
>> +struct phy *phy_create(struct device *dev, struct phy_descriptor *desc)
>> +{
>> +	int ret;
>> +	struct phy *phy;
>> +	struct phy_bind *phy_bind;
>> +	const char *devname = NULL;
>> ...
>> +
>> +	devname = dev_name(dev);
>> +	device_initialize(&phy->dev);
>> +	phy->desc = desc;
>> +	phy->dev.class = phy_class;
>> +	phy->dev.parent = dev;
>> +	phy->dev.bus = desc->bus;
>> +	ret = dev_set_name(&phy->dev, "%s", devname);
>
>
> Passing a bus_type through the descriptor seems misplaced. What is this for?

I thought if we are adding ethernet phys here (say drivers/phy/net), we 
can make phy_device_create() (currently in drivers/net/phy/phy_device.c) 
call phy_create with bus_type set to mdio_bus_type. Then we can have all 
the PHYs showing up in /sys/class/phy/ and ethernet can continue to use 
its own phy abstraction layer.
>
> Why is this function not just:
>
> struct phy *phy_create(struct device *dev, const char *label, int type,
> 			struct phy_ops *ops);

since while calling the callback functions using ops, there wont be 
anyway to get back the device specific structure pointer.

struct phy_dev {
  	.
         .
	struct phy_descriptor	desc;
	void __iomem		*base;
	.
	.
};

static int phy_resume(struct phy_descriptor *desc)
{

//if we dont pass a member of phy_dev while *phy_create* we can't get 
back phy_dev from callback functions as used below.
	struct phy_dev *phy = desc_to_omapusb(desc);

	return 0;
}

static struct phy_ops ops = {
	.resume		= phy_resume,
	.owner		= THIS_MODULE,
};

>
> Passing a structure like you do here seems dangerous because when someone
> decides to add members to the structure, existing code will not give a
> build error but silently break.

Not sure I understood this point. Care to explain?
>
>> +/**
>> + * struct phy_ops - set of function pointers for performing phy operations
>> + * @init: operation to be performed for initializing phy
>> + * @exit: operation to be performed while exiting
>> + * @suspend: suspending the phy
>> + * @resume: resuming the phy
>> + * @poweron: powering on the phy
>> + * @shutdown: shutting down the phy
>> + * @owner: the module owner containing the ops
>> + */
>> +struct phy_ops {
>> +	int	(*init)(struct phy_descriptor *desc);
>> +	int	(*exit)(struct phy_descriptor *desc);
>> +	int	(*suspend)(struct phy_descriptor *desc);
>> +	int	(*resume)(struct phy_descriptor *desc);
>> +	int	(*poweron)(struct phy_descriptor *desc);
>> +	int	(*shutdown)(struct phy_descriptor *desc);
>> +	struct module *owner;
>> +};
>
> Shouldn't these take the 'struct phy' as an argument? struct phy_descriptor is
> not even based on a 'struct device'.

I actually used struct phy_descriptor for the reason mentioned above.

Thanks a lot for reviewing.

Regards
Kishon
