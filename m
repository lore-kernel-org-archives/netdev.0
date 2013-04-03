From: Sylwester Nawrocki <sylvester.nawrocki@gmail.com>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 03 Apr 2013 23:46:31 +0200
Message-ID: <515CA337.1010504@gmail.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com> <1364993634-6378-2-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, gregkh@linuxfoundation.org, arnd@arndb.de,
	akpm@linux-foundation.org, swarren@wwwdotorg.org, rob@landley.net,
	netdev@vger.kernel.org, davem@davemloft.net, cesarb@cesarb.net,
	linux-usb@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-kernel@vger.kernel.org, tony@atomide.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	b-cousson@ti.com, linux@arm.linux.org.uk, eballetbo@gmail.com,
	javier@dowhile0.org, mchehab@redhat.com, santosh.shilimkar@ti.com,
	broonie@opensource.wolfsonmicro.com, swarren@nvidia.com,
	linux-doc@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:54984 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760985Ab3DCVqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 17:46:39 -0400
In-Reply-To: <1364993634-6378-2-git-send-email-kishon@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2013 02:53 PM, Kishon Vijay Abraham I wrote:
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/phy/phy-bindings.txt
> @@ -0,0 +1,67 @@
> +This document explains only the dt data binding. For general information about

s/dt data/device tree ?

> +PHY subsystem refer Documentation/phy.txt

s/refer/refer to ?

> +
> +PHY device node
> +===============
> +
> +Required Properties:
> +#phy-cells:	Number of cells in a PHY specifier;  The meaning of all those
> +		cells is defined by the binding for the phy node. The PHY
> +		provider can use the values in cells to find the appropriate
> +		PHY.
> +
> +For example:
> +
> +phys: phy {
> +    compatible = "xxx";
> +    reg =<...>;
> +    .
> +    .
> +    #phy-cells =<1>;
> +    .
> +    .
> +};
> +
> +That node describes an IP block that implements 2 different PHYs. In order to
> +differentiate between these 2 PHYs, an additonal specifier should be given
> +while trying to get a reference to it.
> +
> +PHY user node
> +=============
> +
> +Required Properties:
> +phys : the phandle for the PHY device (used by the PHY subsystem)
> +
> +Optional properties:
> +phy-names : the names of the PHY corresponding to the PHYs present in the
> +	    *phys* phandle
> +
> +Example 1:
> +usb1: usb_otg_ss@xxx {
> +    compatible = "xxx";
> +    reg =<xxx>;
> +    .
> +    .
> +    phys =<&usb2_phy>,<&usb3_phy>;
> +    phy-names = "usb2phy", "usb3phy";
> +    .
> +    .
> +};
> +
> +This node represents a controller that uses two PHYs one for usb2 and one for

s/PHYs/PHYs,  ?

> +usb3.
> +
> +Example 2:
> +usb2: usb_otg_ss@xxx {
> +    compatible = "xxx";
> +    reg =<xxx>;
> +    .
> +    .
> +    phys =<&phys 1>;
> +    .
> +    .
> +};
> +
> +This node represents a controller that uses one of the PHYs which is defined
> +previously. Note that the phy handle has an additional specifier "1" to

I find it a bit difficult to parse. Perhaps

"This node represents a controller that uses one of the PHYs of the PHY 
provider
device defined previously. ..."

or something similar ?

> +differentiate between the two PHYs.

s/the two/the two available  ?

> diff --git a/Documentation/phy.txt b/Documentation/phy.txt
> new file mode 100644
> index 0000000..7785ec0
> --- /dev/null
> +++ b/Documentation/phy.txt
> @@ -0,0 +1,113 @@
> +			    PHY SUBSYSTEM
> +		  Kishon Vijay Abraham I<kishon@ti.com>
> +
> +This document explains the Generic PHY Framework along with the APIs provided,
> +and how-to-use.
> +
> +1. Introduction
> +
> +*PHY* is the abbreviation for physical layer. It is used to connect a device
> +to the physical medium e.g., the USB controller has a PHY to provide functions

Shouldn't it be "...medium, e.g. the USB..." ?

> +such as serialization, de-serialization, encoding, decoding and is responsible
> +for obtaining the required data transmission rate. Note that some USB
> +controller has PHY functionality embedded into it and others use an external

"controllers have PHY functionality embedded into them" ?

> +PHY. Other peripherals that uses a PHY include Wireless LAN, Ethernet,

s/uses/use ?

> +SATA etc.
> +
> +The intention of creating this framework is to bring the phy drivers spread
> +all over the Linux kernel to drivers/phy to increase code re-use and to
> +increase code maintainability.
> +
> +This framework will be of use only to devices that uses external PHY (PHY

s/uses/use ?

> +functionality is not embedded within the controller).
> +
> +2. Creating the PHY
> +
> +The PHY driver should create the PHY in order for other peripheral controllers
> +to make use of it. The PHY framework provides 2 APIs to create the PHY.
> +
> +struct phy *phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv);
> +struct phy *devm_phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv);
> +
> +The PHY drivers can use one of the above 2 APIs to create the PHY by passing
> +the device pointer, label, device node, type, phy ops and a driver data.
> +phy_ops is a set of function pointers for performing PHY operations such as
> +init, exit, suspend, resume, power_on and power_off.
> +
> +3. Binding the PHY to the controller
> +
> +The framework provides an API for binding the controller to the PHY in the
> +case of non dt boot.
> +
> +struct phy_bind *phy_bind(const char *dev_name, int index,
> +				const char *phy_dev_name);
> +
> +The API fills the phy_bind structure with the dev_name (device name of the
> +controller), index and phy_dev_name (device name of the PHY). This will
> +be used when the controller requests this phy. This API should be used by
> +platform specific initialization code (board file).
> +
> +In the case of dt boot, the binding information should be added in the dt
> +data of the controller.

s/in the dt data of/in the device tree node of ?

> +4. Getting a reference to the PHY
> +
> +Before the controller can make use of the PHY, it has to get a reference to
> +it. This framework provides 6 APIs to get a reference to the PHY.
> +
> +struct phy *phy_get(struct device *dev, int index);
> +struct phy *devm_phy_get(struct device *dev, int index);
> +struct phy *of_phy_get(struct device *dev, const char *phandle, int index);
> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle, int index);

Why do we need separate functions for dt and non-dt ? Couldn't it be handled
internally by the framework ? So the PHY users can use same calls for dt
and non-dt, like in case of e.g. the regulators API ?

Also signatures of some functions are different now:

extern struct phy *phy_get(struct device *dev, int index);
extern struct phy *devm_phy_get(struct device *dev, int index);
extern struct phy *of_phy_get(struct device *dev, int index);
extern struct phy *devm_of_phy_get(struct device *dev, int index);

BTW, I think "extern" could be dropped, does it have any significance in
function declarations in header files ?

> +struct phy *of_phy_get_byname(struct device *dev, const char *string);
> +struct phy *devm_of_phy_get_byname(struct device *dev, const char *string);
> +
> +phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This API
> +uses the binding information added using the phy_bind API to find and return
> +the appropriate PHY. The only difference between the two APIs is that
> +devm_phy_get associates the device with the PHY using devres on successful PHY
> +get. On driver detach, release function is invoked on the the devres data and

s/the the/the

> +devres data is freed.
> +
> +of_phy_get and devm_of_phy_get can be used to get the PHY in dt boot. These
> +APIs take the phandle and index to get a reference to the PHY. The only
> +difference between the two APIs is that devm_of_phy_get associates the device
> +with the PHY using devres on successful phy get. On driver detach, release
> +function is invoked on the devres data and it is freed.
> +
> +of_phy_get_byname and devm_of_phy_get_byname can also be used to get the PHY
> +in dt boot. It is same as the above API except that the user has to pass the
> +phy name as filled in "phy-names" phandle in dt data and the framework will

s/phandle/property ?

> +find the index and get the PHY.
> +
> +5. Releasing a reference to the PHY
> +
> +When the controller no longer needs the PHY, it has to release the reference
> +to the PHY it has obtained using the APIs mentioned in the above section. The
> +PHY framework provides 2 APIS to release a reference to the PHY.

s/APIS/APIs ?

> +
> +void phy_put(struct phy *phy);
> +void devm_phy_put(struct device *dev, struct phy *phy);
> +
> +Both these APIs are used to release a reference to the PHY and devm_phy_put
> +destroys the devres associated with this PHY.
> +
> +6. Destroying the PHY
> +
> +When the driver that created the PHY is unloaded, it should destroy the PHY it
> +created using one of the following 2 APIs.
> +
> +void phy_destroy(struct phy *phy);
> +void devm_phy_destroy(struct device *dev, struct phy *phy);
> +
> +Both these APIs destroys the PHY and devm_phy_destroy destroys the devres

s/APIs destroys/APIs destroy ?

> +associated with this PHY.
> +
> +7. DeviceTree Binding
> +
> +The documentation for PHY dt binding can be found @
> +Documentation/devicetree/bindings/phy/phy-bindings.txt

> --- /dev/null
> +++ b/drivers/phy/phy-core.c
> @@ -0,0 +1,616 @@

> +static struct phy *of_phy_lookup(struct device_node *node)
> +{
> +	struct phy *phy;
> +	struct device *dev;
> +	struct class_dev_iter iter;
> +
> +	class_dev_iter_init(&iter, phy_class, NULL, NULL);

There is currently nothing preventing a call to this function before
phy_class is initialized. It happened during my tests, and the nice
stack dump showed that it was the PHY user attempting to get the PHY
before the framework got initialized. So either phy_core_init should
be a subsys_initcall or we need a better protection against phy_class
being NULL or ERR_PTR in more places.

> +	while ((dev = class_dev_iter_next(&iter))) {
> +		phy = container_of(dev, struct phy, dev);
> +		if (node != phy->of_node)
> +			continue;
> +
> +		class_dev_iter_exit(&iter);
> +		return phy;
> +	}
> +
> +	class_dev_iter_exit(&iter);
> +	return ERR_PTR(-EPROBE_DEFER);
> +}

> +/**
> + * of_phy_get() - lookup and obtain a reference to a phy by phandle
> + * @dev: device that requests this phy
> + * @index: the index of the phy
> + *
> + * Returns the phy associated with the given phandle value,
> + * after getting a refcount to it or -ENODEV if there is no such phy or
> + * -EPROBE_DEFER if there is a phandle to the phy, but the device is
> + * not yet loaded.
> + */
> +struct phy *of_phy_get(struct device *dev, int index)
> +{
> +	int ret;
> +	struct phy *phy = NULL;
> +	struct phy_bind *phy_map = NULL;
> +	struct of_phandle_args args;
> +	struct device_node *node;
> +
> +	if (!dev->of_node) {
> +		dev_dbg(dev, "device does not have a device node entry\n");
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
> +		index,&args);
> +	if (ret) {
> +		dev_dbg(dev, "failed to get phy in %s node\n",
> +			dev->of_node->full_name);
> +		return ERR_PTR(-ENODEV);
> +	}
> +
> +	phy = of_phy_lookup(args.np);
> +	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
> +		phy = ERR_PTR(-EPROBE_DEFER);
> +		goto err0;
> +	}
> +
> +	phy = phy->ops->of_xlate(phy,&args);
> +	if (IS_ERR(phy))
> +		goto err1;
> +
> +	phy_map = phy_bind(dev_name(dev), index, dev_name(&phy->dev));
> +	if (!IS_ERR(phy_map)) {
> +		phy_map->phy = phy;
> +		phy_map->auto_bind = true;

Shouldn't it be done with the phy_bind_mutex held ? I guess an unlocked
version of the phy_bind functions is needed, so it can be used internally.

> +	}
> +
> +	get_device(&phy->dev);
> +
> +err1:
> +	module_put(phy->ops->owner);
> +
> +err0:
> +	of_node_put(node);
> +
> +	return phy;
> +}
> +EXPORT_SYMBOL_GPL(of_phy_get);

> +/**
> + * phy_create() - create a new phy
> + * @dev: device that is creating the new phy
> + * @label: label given to phy
> + * @of_node: device node of the phy
> + * @type: specifies the phy type
> + * @ops: function pointers for performing phy operations
> + * @priv: private data from phy driver
> + *
> + * Called to create a phy using phy framework.
> + */
> +struct phy *phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv)
> +{
> +	int ret;
> +	struct phy *phy;
> +	struct phy_bind *phy_bind;
> +	const char *devname = NULL;
> +
> +	if (!dev) {
> +		dev_err(dev, "no device provided for PHY\n");
> +		ret = -EINVAL;
> +		goto err0;
> +	}
> +
> +	if (!ops || !ops->of_xlate || !priv) {
> +		dev_err(dev, "no PHY ops/PHY data provided\n");
> +		ret = -EINVAL;
> +		goto err0;
> +	}
> +
> +	if (!phy_class)
> +		phy_core_init();
> +
> +	phy = kzalloc(sizeof(*phy), GFP_KERNEL);
> +	if (!phy) {
> +		ret = -ENOMEM;
> +		goto err0;
> +	}
> +
> +	devname = dev_name(dev);

OK, a sort of serious issue here is that you can't call phy_create()
multiple times for same PHY provider device.

device_add() further will fail as sysfs won't let you create multiple
objects with same name. So I would assume we need to add a new argument
to phy_create() or rename @type to e.g. @phy_id, which could be
concatenated with dev_name(dev) to create a unique name of the phy
device.

And how is the PHY provider supposed to identify a PHY in its common PHY
ops, now when the struct phy port field is removed ? I have temporarily
(ab)used the type field in order to select proper registers within the
phy ops.

> +	device_initialize(&phy->dev);
> +
> +	phy->dev.class = phy_class;
> +	phy->dev.parent = dev;
> +	phy->label = label;

What about duplicating the string here ? That would make the API a bit
more convenient and the callers wouldn't be required to keep all the
labels around.

> +	phy->of_node = of_node;
> +	phy->type = type;
> +	phy->ops = ops;
> +
> +	dev_set_drvdata(&phy->dev, priv);
> +
> +	ret = dev_set_name(&phy->dev, "%s", devname);
> +	if (ret)
> +		goto err1;
> +
> +	mutex_lock(&phy_bind_mutex);
> +	list_for_each_entry(phy_bind,&phy_bind_list, list)
> +		if (!(strcmp(phy_bind->phy_dev_name, devname)))
> +			phy_bind->phy = phy;
> +	mutex_unlock(&phy_bind_mutex);
> +
> +	ret = device_add(&phy->dev);
> +	if (ret)
> +		goto err2;
> +
> +	return phy;
> +
> +err2:
> +	phy_bind->phy = NULL;
> +
> +err1:
> +	put_device(&phy->dev);
> +	kfree(phy);
> +
> +err0:
> +	return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL_GPL(phy_create);

> +/**
> + * devm_phy_create() - create a new phy
> + * @dev: device that is creating the new phy
> + * @dev: device that is creating the new phy

Duplicated line.

> + * @label: label given to phy
> + * @of_node: device node of the phy
> + * @type: specifies the phy type
> + * @ops: function pointers for performing phy operations
> + * @priv: private data from phy driver
> + *
> + * Creates a new PHY device adding it to the PHY class.
> + * While at that, it also associates the device with the phy using devres.
> + * On driver detach, release function is invoked on the devres data,
> + * then, devres data is freed.
> + */

> +/**
> + * phy_bind() - bind the phy and the controller that uses the phy
> + * @dev_name: the device name of the device that will bind to the phy
> + * @index: index to specify the port number
> + * @phy_dev_name: the device name of the phy
> + *
> + * Fills the phy_bind structure with the dev_name and phy_dev_name. This will
> + * be used when the phy driver registers the phy and when the controller
> + * requests this phy.
> + *
> + * To be used by platform specific initialization code.
> + */
> +struct phy_bind *phy_bind(const char *dev_name, int index,
> +				const char *phy_dev_name)
> +{
> +	struct phy_bind *phy_bind;
> +
> +	mutex_lock(&phy_bind_mutex);
> +	list_for_each_entry(phy_bind,&phy_bind_list, list) {
> +		if (!strcmp(phy_bind->dev_name, dev_name)&&  phy_bind->index ==
> +			index) {
> +			phy_bind->phy_dev_name = phy_dev_name;
> +			goto ret0;
> +		}
> +	}
> +
> +	phy_bind = kzalloc(sizeof(*phy_bind), GFP_KERNEL);
> +	if (!phy_bind) {
> +		phy_bind = ERR_PTR(-ENOMEM);
> +		goto ret0;
> +	}
> +
> +	phy_bind->dev_name = dev_name;
> +	phy_bind->phy_dev_name = phy_dev_name;
> +	phy_bind->index = index;
> +	phy_bind->auto_bind = false;
> +
> +	list_add_tail(&phy_bind->list,&phy_bind_list);
> +
> +ret0:
> +	mutex_unlock(&phy_bind_mutex);
> +	return phy_bind;
> +}
> +EXPORT_SYMBOL_GPL(phy_bind);

> +static ssize_t phy_bind_show(struct device *dev,
> +			     struct device_attribute *attr, char *buf)
> +{
> +	struct phy_bind *phy_bind;
> +	struct phy *phy;
> +	char *p = buf;
> +	int len;
> +
> +	phy = container_of(dev, struct phy, dev);
> +

Shouldn't this iteration also be protected with the phy_bind_mutex ?

> +	list_for_each_entry(phy_bind,&phy_bind_list, list)
> +		if (phy_bind->phy == phy)
> +			p += sprintf(p, "%s %d %s\n", phy_bind->dev_name,
> +				phy_bind->index, phy_bind->phy_dev_name);
> +	len = (p - buf);
> +
> +	return len;
> +}

> +static int phy_core_init(void)
> +{
> +	if (phy_class)
> +		return 0;
> +
> +	phy_class = class_create(THIS_MODULE, "phy");
> +	if (IS_ERR(phy_class)) {
> +		pr_err("failed to create phy class -->  %ld\n",
> +			PTR_ERR(phy_class));
> +		return PTR_ERR(phy_class);
> +	}
> +
> +	phy_class->dev_release = phy_release;
> +	phy_class->dev_attrs = phy_dev_attrs;
> +
> +	return 0;
> +}
> +module_init(phy_core_init);

Having this framework initialized before the PHY provider and consumer
drivers could save some unnecessary probe deferrals. I was wondering,
what is really an advantage of having it as module_init(), rather than
subsys_initcall() ?

> +static void __exit phy_core_exit(void)
> +{
> +	class_destroy(phy_class);
> +}
> +module_exit(phy_core_exit);
> +
> +MODULE_DESCRIPTION("Generic PHY Framework");
> +MODULE_AUTHOR("Kishon Vijay Abraham I<kishon@ti.com>");
> +MODULE_LICENSE("GPL v2");
> diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
> new file mode 100644
> index 0000000..97a48bd
> --- /dev/null
> +++ b/include/linux/phy/phy.h
> @@ -0,0 +1,228 @@
> +/*
> + * phy.h -- generic phy header file
> + *

> +/**
> + * struct phy - represent the phy device
> + * @dev: phy device
> + * @label: label given to phy
> + * @type: specifies the phy type
> + * @of_node: device node of the phy
> + * @ops: function pointers for performing phy operations
> + */
> +struct phy {
> +	struct device		dev;
> +	const char		*label;
> +	int			type;
> +	struct device_node	*of_node;
> +	struct phy_ops		*ops;

Something in this structure that would identify a PHY when a PHY provider
supports multiple PHYs is probably needed.

> +};
> +
> +/**
> + * struct phy_bind - represent the binding for the phy
> + * @dev_name: the device name of the device that will bind to the phy
> + * @phy_dev_name: the device name of the phy
> + * @index: used if a single controller uses multiple phys
> + * @auto_bind: tells if the binding is done explicitly from board file or not
> + * @phy: reference to the phy
> + * @list: to maintain a linked list of the binding information
> + */
> +struct phy_bind {
> +	const char	*dev_name;
> +	const char	*phy_dev_name;
> +	int		index;
> +	int		auto_bind:1;
> +	struct phy	*phy;
> +	struct list_head list;
> +};
> +
> +static inline int phy_poweron(struct phy *phy)

phy_power_on ? Just a humble suggestion...

> +{
> +	if (phy->ops->power_on)
> +		return phy->ops->power_on(phy);
> +
> +	return -EINVAL;
> +}
> +
> +static inline int phy_poweroff(struct phy *phy)

and phy_power_off ? :-)

> +{
> +	if (phy->ops->power_off)
> +		return phy->ops->power_off(phy);
> +
> +	return -EINVAL;
> +}
> +#endif /* __DRIVERS_PHY_H */

Thanks,
Sylwester
