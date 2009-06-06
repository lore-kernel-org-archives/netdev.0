From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 7/7] initdev:kernel:Await block device discovery
Date: Sat, 06 Jun 2009 12:04:38 +0200
Message-ID: <4A2A3F36.4070408@s5r6.in-berlin.de>
References: <20090606023416.GA5798@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090606023416.GA5798@cuplxvomd02.corp.sa.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David VomLehn wrote:
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -358,6 +358,18 @@ void __init mount_root(void)
>  #endif
>  }
>  
> +/**
> + * root_present - determine whether the root device is available yet
> + *
> + * Returns true if the root device is available, false if not. The check to
> + * see if the root device is available is done by check to see whether it
> + * has been assigned a major/minor device number.
> + */
> +static bool root_present(void)
> +{
> +	return name_to_dev_t(saved_root_name) != 0;
> +}
> +
>  /*
>   * Prepare the namespace - decide what/where to mount, load ramdisks, etc.
>   */
> @@ -398,12 +410,21 @@ void __init prepare_namespace(void)
>  		goto out;
>  
>  	/* wait for any asynchronous scanning to complete */
> -	if ((ROOT_DEV == 0) && root_wait) {
> +	if (ROOT_DEV == 0) {
>  		printk(KERN_INFO "Waiting for root device %s...\n",
>  			saved_root_name);
> -		while (driver_probe_done() != 0 ||
> -			(ROOT_DEV = name_to_dev_t(saved_root_name)) == 0)
> -			msleep(100);
> +		if (root_wait) {
> +			while (driver_probe_done() != 0 ||
> +				(ROOT_DEV = name_to_dev_t(saved_root_name)) ==
> +					0)
> +				msleep(100);
> +		}
> +
> +		else {
> +			initdev_wait(INITDEV_BLOCK_TYPE, root_present);
> +			ROOT_DEV = name_to_dev_t(saved_root_name);
> +		}
> +
>  		async_synchronize_full();
>  	}
>  

This together with 1/7, 5/7, 6/7 looks seriously flawed, if not broken.

1.)  It depends on the rootdelay so big that it is guaranteed that one 
or more initdev_found() have been called before prepare_namespace()'s 
ssleep(root_delay) is over.  This is because initdev_wait() does not 
wait at all if called when the number of pending initdevs is 0.

Hence the whole thing, as currently implemented, is quite useless:  The 
user/admin has to guess what a safe rootdelay value is, and then the 
kernel will always be delayed for >= rootdelay.

2.)  The fact that initdev_wait() does not wait at all when there are no 
pending initdevs causes another failure.  If there are sequences of the 
following type:

	initdev_found(INITDEV_BLOCK_TYPE);
	initdev_probe_done(INITDEV_BLOCK_TYPE); /* found other dev */
	initdev_found(INITDEV_BLOCK_TYPE);
	initdev_probe_done(INITDEV_BLOCK_TYPE); /* found root dev */

then prepare_namespace() will fall through without ROOT_DEV found and 
booting will fail, won't it?

I suspect that there are similar problems with the console and 
networking parts of the patch series.
-- 
Stefan Richter
-=====-==--= -==- --==-
http://arcgraph.de/sr/
