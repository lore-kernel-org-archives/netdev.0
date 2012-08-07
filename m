From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv2 1/4] modem_shm: Add Modem Access Framework
Date: Tue, 7 Aug 2012 11:38:09 -0700
Message-ID: <20120807183809.GC26990@kroah.com>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
 <1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, sjur.brandeland@stericsson.com
To: Arun Murthy <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344322471-3640-2-git-send-email-arun.murthy@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2012 at 12:24:28PM +0530, Arun Murthy wrote:
> Adds Modem Access Framework, which allows for registering platform specific
> modem access mechanisms. The framework also exposes APIs for client drivers
> for getting and releasing access to modem, regardless of the underlying
> platform specific access mechanism.

The term "modems" here has a lot of legacy connotations.  First of which
is, userspace handles this today as tty devices, why aren't you doing
the same here?  Why does this have to be something "special"?

> 
> Signed-off-by: Arun Murthy <arun.murthy@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>
> ---
>  drivers/Kconfig                        |    2 +
>  drivers/Makefile                       |    1 +
>  drivers/modem_shm/Kconfig              |    9 +
>  drivers/modem_shm/Makefile             |    1 +
>  drivers/modem_shm/modem_access.c       |  419 ++++++++++++++++++++++++++++++++

Any reason why this can't be under drivers/tty/ ?

>  include/linux/modem_shm/modem.h        |   64 +++++
>  include/linux/modem_shm/modem_client.h |   55 +++++

Why are both of these "public" like this?  Why not just make one file?
Would someone ever only need to include one of these?

> +config MODEM_SHM
> +        bool "Modem Access Framework"
> +        default y

Unless it is needed to boot your machine, NEVER make the default y.

> +struct modem {
> +	struct device *dev;
> +	struct list_head list;
> +	char *modem_name;

You already have a name in the struct device, why do you need another
one?

> +	struct device_attribute dev_attr;

Why is this in the structure?

> +	struct modem_dev *mdev;
> +	atomic_t use;

What is this variable for?

Why isn't this a 'struct device' itself?

> +/**
> + * modem_is_requested - check if modem access is requested
> + * @modem: modem device
> + *
> + * Checks whether modem is accessed or not by querying
> + * the underlying platform specific modem access
> + * implementation.
> + */
> +int modem_is_requested(struct modem *modem)
> +{
> +	int ret;
> +
> +	mutex_lock(&modem->mdev->mutex);
> +	ret = _modem_is_requested(modem->mdev);
> +	mutex_unlock(&modem->mdev->mutex);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(modem_is_requested);

EXPORT_SYMBOL_GPL() for this, and the other apis perhaps?

> +static struct modem *_modem_get(struct device *dev, const char *id,
> +		int exclusive)
> +{
> +	struct modem_dev *mdev_ptr;
> +	struct modem *modem = ERR_PTR(-ENODEV);
> +	int ret;
> +
> +	if (id == NULL) {
> +		pr_err("modem_get with no identifier\n");
> +		return modem;
> +	}
> +
> +	mutex_lock(&modem_list_mutex);
> +	list_for_each_entry(mdev_ptr, &modem_list, modem_list) {
> +		if (strcmp(mdev_get_name(mdev_ptr), id) == 0)
> +			goto found;
> +	}
> +
> +	goto out;
> +
> +found:
> +	if (!try_module_get(mdev_ptr->owner))
> +		goto out;
> +
> +	modem = create_modem(mdev_ptr, dev, id);
> +	if (modem == NULL) {
> +		modem = ERR_PTR(-ENOMEM);
> +		module_put(mdev_ptr->owner);
> +	}
> +
> +	mdev_ptr->open_count++;
> +	ret = _modem_is_requested(mdev_ptr);
> +	if (ret)
> +		mdev_ptr->use_count = 1;
> +	else
> +		mdev_ptr->use_count = 0;
> +
> +out:
> +	mutex_unlock(&modem_list_mutex);
> +	return modem;
> +
> +}

Calling this function does a lot more than just incrementing the
reference count of an object.  It sets it up, and creates things.  That
should be way more documented than this one line says:

> +/**
> + * modem_get - Get reference to a particular platform specific modem
> + * @dev: device
> + * @id: modem device name
> + *
> + * Get reference to a particular modem device.
> + */

See, that's really not true.

> +static ssize_t modem_print_state(char *buf, int state)
> +{
> +	if (state > 0)
> +		return sprintf(buf, "accessed\n");
> +	else if (state == 0)
> +		return sprintf(buf, "released\n");
> +	else
> +		return sprintf(buf, "unknown\n");
> +}

Why not use an enumerated type for your state, to make it easier to
understand than 0, -, and +?

> +static ssize_t modem_state_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct modem_dev *mdev = dev_get_drvdata(dev);
> +	ssize_t ret;
> +
> +	mutex_lock(&mdev->mutex);
> +	ret = modem_print_state(buf, _modem_is_requested(mdev));

Why not just embed the function here?  It's only ever called once.

> +	mutex_unlock(&mdev->mutex);
> +
> +	return ret;
> +}
> +static DEVICE_ATTR(state, 0444, modem_state_show, NULL);
> +
> +static ssize_t modem_use_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct modem_dev *mdev = dev_get_drvdata(dev);
> +	struct modem *mod;
> +	size_t size = 0;
> +
> +	list_for_each_entry(mod, &mdev->client_list, list) {
> +		if (mod->dev != NULL)
> +			size += sprintf((buf + size), "%s (%d)\n",
> +				dev_name(mod->dev), atomic_read(&mod->use));
> +		else
> +			size += sprintf((buf + size), "unknown (%d)\n",
> +				atomic_read(&mod->use));
> +	}
> +	size += sprintf((buf + size), "\n");
> +
> +	return size;
> +}
> +static DEVICE_ATTR(use, 0444, modem_use_show, NULL);

You have sysfs files with no matching Documentation/ABI entries showing
how they are to be used, and what they contain, in this patch.  Please
fix this.

And why are you reporting an atomic value, that's 2 values per sysfs
file, not acceptable.

> +static ssize_t modem_name_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct modem_dev *mdev = dev_get_drvdata(dev);
> +
> +	return sprintf(buf, "%s\n", mdev_get_name(mdev));
> +}
> +static DEVICE_ATTR(name, 0444, modem_name_show, NULL);

The name is in the struct device, which is the directory in sysfs, don't
include it again in a sysfs file, that's redundant.

> +static int add_modem_attributes(struct modem_dev *mdev)
> +{
> +	struct device      *dev = &mdev->dev;
> +	struct modem_ops   *ops = mdev->desc->ops;
> +	int                status = 0;
> +
> +	status = device_create_file(dev, &dev_attr_use);
> +	if (status < 0)
> +		return status;
> +
> +	status = device_create_file(dev, &dev_attr_name);
> +	if (status < 0)
> +		return status;
> +
> +	status = device_create_file(dev, &dev_attr_num_active_users);
> +	if (status < 0)
> +		return status;
> +
> +	if (ops->is_requested) {
> +		status = device_create_file(dev, &dev_attr_state);
> +		if (status < 0)
> +			return status;
> +	}
> +
> +	return 0;
> +}

Please use a default attribute group, as you just raced with userspace,
and now userspace tried to look for these files when the device was
created, yet they were not present yet, causing all sorts of problems
with your tools.  This must be fixed.

that's enough for now...

greg k-h
