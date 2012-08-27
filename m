From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv3 1/4] modem_shm: Add Modem Access Framework
Date: Sun, 26 Aug 2012 23:49:20 -0700
Message-ID: <20120827064920.GA5170@kroah.com>
References: <1346046569-8050-1-git-send-email-arun.murthy@stericsson.com>
 <1346046569-8050-2-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Arun Murthy <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346046569-8050-2-git-send-email-arun.murthy@stericsson.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 27, 2012 at 11:19:26AM +0530, Arun Murthy wrote:
> +struct modem {
> +	struct device *dev;

No, this needs to be:
	struct device dev;

Please fix it up to be like that, otherwise you are not using the driver
model properly at all.

> +/**
> + * modem_register - register a modem
> + * @modem_desc: - description for modem
> + * @dev:        - device
> + * @driver_data:- driver specific data
> + *
> + * Register a modem with the modem access framework, so that
> + * it could be used by client drivers for accessing the
> + * modem.
> + */
> +struct modem_dev *modem_register(struct modem_desc *modem_desc,
> +		struct device *dev,
> +		void *driver_data)
> +{
> +	static atomic_t modem_no = ATOMIC_INIT(0);
> +	struct modem_dev *mdev;
> +	int ret;
> +
> +	if (modem_desc == NULL)
> +		return ERR_PTR(-EINVAL);
> +
> +	if (modem_desc->name == NULL || modem_desc->ops == NULL)
> +		return ERR_PTR(-EINVAL);
> +
> +	mdev = kzalloc(sizeof(struct modem_dev), GFP_KERNEL);
> +	if (mdev == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	mutex_lock(&modem_list_mutex);
> +
> +	mutex_init(&mdev->mutex);
> +	mdev->modem_data = driver_data;
> +	mdev->owner = modem_desc->owner;
> +	mdev->desc = modem_desc;
> +	INIT_LIST_HEAD(&mdev->client_list);
> +	INIT_LIST_HEAD(&mdev->modem_list);
> +	BLOCKING_INIT_NOTIFIER_HEAD(&mdev->notifier);
> +
> +	/* mdev->dev.class = &modem_class;*/
> +	mdev->dev.parent = dev;
> +	dev_set_name(&mdev->dev, "modem.%d", atomic_inc_return(&modem_no) - 1);

Use the idr interface instead please.

> +	ret = device_register(&mdev->dev);
> +	if (ret != 0)
> +		goto clean;
> +
> +	dev_set_drvdata(&mdev->dev, mdev);
> +
> +	ret = add_modem_attributes(mdev);
> +	if (ret < 0)
> +		goto backoff;
> +
> +	list_add(&mdev->modem_list, &modem_list);

Hint, you don't need such a list if you use the driver model properly...

> +out:
> +	mutex_unlock(&modem_list_mutex);
> +	return mdev;
> +
> +backoff:
> +	device_unregister(&mdev->dev);
> +	mdev = ERR_PTR(ret);
> +	goto out;
> +
> +clean:
> +	kfree(mdev);
> +	mdev = ERR_PTR(ret);
> +	goto out;
> +}
> +EXPORT_SYMBOL_GPL(modem_register);

You have no "modem_unregister()" call, which, if you did, and actually
tested it out, would show you the problem in the code above (hint, you
really didn't read the documentation I pointed you at previously.)

You are also racing userspace with your device creation, and I can't
tell the difference between a modem_dev and a modem, why have two
different things?

This whole thing needs to be totally reworked, start with the above
comments, and you will see whole sections of this patch just disappear,
as you properly start to use the driver model.

greg k-h
