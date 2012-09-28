From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Fri, 28 Sep 2012 09:00:45 -0700
Message-ID: <20120928160045.GD2625@kroah.com>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
 <1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Arun Murthy <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/err.h>
> +#include <linux/printk.h>
> +#include <linux/modem_shm/modem.h>
> +
> +static struct class *modem_class;

What's wrong with a bus_type instead?

> +static int __modem_is_requested(struct device *dev, void *data)
> +{
> +	struct modem_desc *mdesc = (struct modem_desc *)data;
> +
> +	if (!mdesc->mclients) {
> +		printk(KERN_ERR "modem_access: modem description is NULL\n");
> +		return 0;
> +	}
> +	return atomic_read(&mdesc->mclients->cnt);
> +}
> +
> +int modem_is_requested(struct modem_desc *mdesc)
> +{
> +	return class_for_each_device(modem_class, NULL, (void *)mdesc, __modem_is_requested);
> +}

Where is the documentation for your public api functions like this?

> +
> +int modem_release(struct modem_desc *mdesc)
> +{
> +	if (!mdesc->release)
> +		return -EFAULT;
> +
> +	if (modem_is_requested(mdesc)) {
> +		atomic_dec(&mdesc->mclients->cnt);
> +		if (atomic_read(&mdesc->use_cnt) == 1) {
> +			mdesc->release(mdesc);
> +			atomic_dec(&mdesc->use_cnt);
> +		}

Eeek, why aren't you using the built-in reference counting that the
struct device provided to you, and instead are rolling your own?  This
happens in many places, why?

greg k-h
