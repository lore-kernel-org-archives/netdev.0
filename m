From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/3] ser_gigaset: fix deallocation of platform device
 structure
Date: Wed, 09 Dec 2015 00:12:01 +0100
Message-ID: <1449616321.2384.36.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
	 <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On di, 2015-12-08 at 12:00 +0100, Tilman Schmidt wrote:
> When shutting down the device, the struct ser_cardstate must not be
> kfree()d immediately after the call to platform_device_unregister()
> since the embedded struct platform_device is still in use.
> Move the kfree() call to the release method instead.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Fixes: 2869b23e4b95 ("drivers/isdn/gigaset: new M101 driver (v2)")
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  drivers/isdn/gigaset/ser-gigaset.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/ser-gigaset.c
> b/drivers/isdn/gigaset/ser-gigaset.c
> index d8771b5..2693cb2 100644
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -370,19 +370,23 @@ static void gigaset_freecshw(struct cardstate
> *cs)
>  	tasklet_kill(&cs->write_tasklet);
>  	if (!cs->hw.ser)
>  		return;
> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>  	platform_device_unregister(&cs->hw.ser->dev);
> -	kfree(cs->hw.ser);
> -	cs->hw.ser = NULL;
>  }
>  
>  static void gigaset_device_release(struct device *dev)
>  {
>  	struct platform_device *pdev = to_platform_device(dev);
> +	struct cardstate *cs = dev_get_drvdata(dev);
>  
>  	/* adapted from platform_device_release() in
> drivers/base/platform.c */
>  	kfree(dev->platform_data);
>  	kfree(pdev->resource);
> +
> +	if (!cs)
> +		return;
> +	dev_set_drvdata(dev, NULL);

dev equals cs->hw.ser->dev.dev, doesn't it? So what does setting
cs->hw.ser->dev.dev.driver_data to NULL just before freeing it buy us?

> +	kfree(cs->hw.ser);
> +	cs->hw.ser = NULL;

I might be missing something, but what does setting this to NULL buy us
here?

(I realize that I'm asking questions to code that isn't actually new but
only moved around, but I think that's still an opportunity to have
another look at that code.)

>  }
>  
>  /*

Thanks,


Paul Bolle
