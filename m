From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
	synchronization, v5
Date: Fri, 5 Jun 2009 10:58:16 -0700
Message-ID: <20090605175816.GB18688@cuplxvomd02.corp.sa.net>
References: <Pine.LNX.4.44L0.0905041100500.3092-100000@iolanthe.rowland.org> <20090505234725.5ab247db@linux-lm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Arjan van de Ven <arjan@infradead.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090505234725.5ab247db@linux-lm>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 05, 2009 at 11:47:25AM -0400, Ming Lei wrote:
> On Mon, 4 May 2009 11:07:52 -0400 (EDT)
> Alan Stern <stern@rowland.harvard.edu> wrote:
> 
> > On Mon, 4 May 2009, Arjan van de Ven wrote:
...
> > Isn't there still something missing?  The wait_for_device_probe()  
> > routine would wait until all attached devices had been probed.  But
> > why should prepare_namespace() have to wait that long?  Wouldn't it be
> > better to wait only until the root device has been registered?
> 
> Yes, maybe David should merge the following patch into the patch
> No.5(initdev:kernel: USB and SCSI block init device notification, v3).
> 
> Right?
> 
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index dd7ee5f..22fd773 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -358,6 +358,12 @@ void __init mount_root(void)
>  #endif
>  }
>  
> +static int root_dev_done()
> +{
> +	return !!(ROOT_DEV = name_to_dev_t(saved_root_name));
> +}
> +
> +
>  /*
>   * Prepare the namespace - decide what/where to mount, load ramdisks,
> etc. */
> @@ -398,12 +404,12 @@ void __init prepare_namespace(void)
>  		goto out;
>  
>  	/* wait for any asynchronous scanning to complete */
> -	if ((ROOT_DEV == 0) && root_wait) {
> +	if (ROOT_DEV == 0 && root_wait) {
>  		printk(KERN_INFO "Waiting for root device %s...\n",
>  			saved_root_name);
> -		while (driver_probe_done() != 0 ||
> -			(ROOT_DEV = name_to_dev_t(saved_root_name)) ==
> 0)
> -			msleep(100);
> +		do {
> +			initdev_wait(BOOTDEV_BLOCK, root_dev_done);
> +		} while (!ROOT_DEV);
>  		async_synchronize_full();
>  	}

I have something very similar. I'm not completely comfortable with discarding
the rootwait flag, though it should be very rarely used once the initdev
infrastructure is in place.

> Lei Ming

David VomLehn
