From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/7] uio: Allow to create custom UIO attributes
Date: Tue, 13 Aug 2013 10:54:36 -0700
Message-ID: <20130813175436.GF4098@kroah.com>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-4-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38808 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355Ab3HMRyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:54:37 -0400
Content-Disposition: inline
In-Reply-To: <1376384922-8519-4-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 11:08:37AM +0200, Benedikt Spranger wrote:
> This patch the struct uio_attribute which represents a custom UIO
> attribute. The non-standard attributes are stored in a "attr" directory.
> This will be used by the flexcard driver which creates a UIO device that
> is using the "uio_pdrv" and requires one additional value to be read /
> written by the user.
> 
> Cc: "Hans J. Koch" <hjk@hansjkoch.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> Signed-off-by: Holger Dengler <dengler@linutronix.de>
> ---
>  drivers/uio/uio.c          | 106 ++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/uio_driver.h |  36 +++++++++++----
>  2 files changed, 133 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
> index 9a95220..d66784a 100644
> --- a/drivers/uio/uio.c
> +++ b/drivers/uio/uio.c
> @@ -39,6 +39,7 @@ struct uio_device {
>  	struct uio_info		*info;
>  	struct kobject		*map_dir;
>  	struct kobject		*portio_dir;
> +	struct kobject		attr_dir;

If you embed a kobject into a structure, it is now in charge of the
memory reference counting for that object.

Which you did not do correctly:

> +static struct kobj_type uio_attr_type = {
> +	.sysfs_ops	= &uio_sysfs_ops,
> +};

As per the documentation in the kernel, I now get to make fun of the
fact that you obviously didn't test this code (hint, the kernel would
have told you bad things happened if you did...)

But I don't understand your main goal of a new kobject for attributes,
why?  What problem are you trying to solve here that a new kobject, and
new sysfs files attached to the UIO object are going to solve?

>  /**
> + * uio_add_user_attributes - add an extra UIO attribute
> + * @info: UIO device capabilities
> + */
> +static int uio_add_user_attributes(struct uio_info *info)
> +{
> +	struct uio_device *idev = info->uio_dev;
> +	const struct uio_attribute **uio_attr;
> +	int i;
> +	int ret = 0;
> +
> +	uio_attr = info->attributes;
> +	if (!uio_attr)
> +		return 0;
> +
> +	for (i = 0; uio_attr[i]; i++) {
> +
> +		ret = sysfs_create_file(&idev->attr_dir, &uio_attr[i]->attr);
> +		if (ret)
> +			break;
> +	}
> +	if (ret) {
> +		while (--i >= 0)
> +			sysfs_remove_file(&idev->attr_dir, &uio_attr[i]->attr);
> +	}
> +	return ret;
> +}

Ick, you just raced with userspace and blew up any tool that was wanting
to watch for your new kobject to be created with the attributes attached
to it :(

Sending code that doesn't work is fine, for review if you have questions
about things, but please, mark it with a big "I HAVEN'T TESTED THIS"
statement somewhere.

greg k-h
