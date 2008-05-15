From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/3] sysfs: remove error messages for -EEXIST case
Date: Thu, 15 May 2008 09:52:46 +0200
Message-ID: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com>
References: <20080514170316.672f809d@extreme>
	<20080514181257.74fbb5aa@extreme>
	<20080514181603.411e834f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:38501 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093AbYEOHxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 03:53:08 -0400
In-Reply-To: <20080514181603.411e834f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 18:16:03 -0700,
Stephen Hemminger <shemminger@vyatta.com> wrote:

> --- a/drivers/base/core.c	2008-05-14 17:56:36.000000000 -0700
> +++ b/drivers/base/core.c	2008-05-14 17:56:40.000000000 -0700
> @@ -1218,13 +1218,11 @@ int device_rename(struct device *dev, ch
>  	}
>  #else
>  	if (dev->class) {
> -		sysfs_remove_link(&dev->class->subsys.kobj, old_device_name);
>  		error = sysfs_create_link(&dev->class->subsys.kobj, &dev->kobj,
>  					  dev->bus_id);
> -		if (error) {
> -			dev_err(dev, "%s: sysfs_create_symlink failed (%d)\n",
> -				__func__, error);
> -		}
> +		if (error)
> +			goto out;
> +		sysfs_remove_link(&dev->class->subsys.kobj, old_device_name);
>  	}
>  #endif
> 

This looks reasonable...

> --- a/fs/sysfs/dir.c	2008-05-14 17:56:36.000000000 -0700
> +++ b/fs/sysfs/dir.c	2008-05-14 17:56:40.000000000 -0700
> @@ -419,12 +419,8 @@ void sysfs_addrm_start(struct sysfs_addr
>   */
>  int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
>  {
> -	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name)) {
> -		printk(KERN_WARNING "sysfs: duplicate filename '%s' "
> -		       "can not be created\n", sd->s_name);
> -		WARN_ON(1);
> +	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name))
>  		return -EEXIST;
> -	}
> 
>  	sd->s_parent = sysfs_get(acxt->parent_sd);

...but this will cause many useful warnings to disappear.

What to do here?

- Rely on people checking all __must_check stuff and printing a warning
when desired. Not everyone seems to like that (see, for example,
http://marc.info/?l=linux-kernel&m=121012176111154&w=2).
- Put the burden unto the callers of sysfs_add_one() (or maybe even
further up). They should hopefully know whether -EEXIST is "might
happen" or "argh, we've messed up" (and print a warning in the latter
case so that it gets reported).
- Make this a debugging thing. Unfortunately then we won't neccessarily
get reports when things are busted.
