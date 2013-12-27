From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/38] net: iucv: add missing put_device call
Date: Fri, 27 Dec 2013 12:41:50 -0500 (EST)
Message-ID: <20131227.124150.654187539741639427.davem@davemloft.net>
References: <1387465429-3568-2-git-send-email-levex@linux.com>
	<1387465429-3568-21-git-send-email-levex@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ursula.braun@de.ibm.com,
	linux390@de.ibm.com, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: levex@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387465429-3568-21-git-send-email-levex@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Levente Kurusa <levex@linux.com>
Date: Thu, 19 Dec 2013 16:03:31 +0100

> This is required so that we give up the last reference to the device.
> 
> Signed-off-by: Levente Kurusa <levex@linux.com>
 ...
> @@ -2377,8 +2377,10 @@ static int afiucv_iucv_init(void)
>  	af_iucv_dev->release = (void (*)(struct device *))kfree;
>  	af_iucv_dev->driver = &af_iucv_driver;
>  	err = device_register(af_iucv_dev);
> -	if (err)
> +	if (err) {
> +		put_device(af_iucv_dev);
>  		goto out_driver;
> +	}

This has the same problem as the ATM patch, there is no reference held on
af_iucv_dev, I mean look at where it comes from:

	af_iucv_dev = kzalloc(sizeof(struct device), GFP_KERNEL);
 ...
	dev_set_name(af_iucv_dev, "af_iucv");
	af_iucv_dev->bus = pr_iucv->bus;
	af_iucv_dev->parent = pr_iucv->root;
	af_iucv_dev->release = (void (*)(struct device *))kfree;
	af_iucv_dev->driver = &af_iucv_driver;

No reference count is incremented or set to one for af_iucv_dev.

Please study these code paths more carefully, thank you.
