From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] ucode debug status via sysfs for wireless-2.6
Date: Thu, 7 Sep 2006 10:33:51 +0200
Message-ID: <200609071033.52258.mb@bu3sch.de>
References: <20060904205340.GB3726@tuba> <20060905181232.GA4733@tuba>
	<44FF772A.5000301@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <44FF772A.5000301-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 07 September 2006 03:34, Larry Finger wrote:
> John,
> 
> Please apply this patch by Martin Langer to wireless-2.6. It must follow the patch to "Add firmware 
> version printout to wireless-2.6 (bcm43xx-softmac)". As originally submitted, the patch was 
> appropriate for an obsolete version of bcm43xx-softmac, but I have updated and tested.
> 
> Thanks,
> 
> Larry
> 
> This patch prints out the ucode debug status to sysfs. So, users can
> watch the microcode status of their hardware.
> 
> Signed-off-by: Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> 
> =========================================
> 
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
> index 62fd7e2..7c2163e 100644
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
> @@ -311,6 +311,7 @@
>   #define BCM43xx_UCODE_PATCHLEVEL        0x0002
>   #define BCM43xx_UCODE_DATE              0x0004
>   #define BCM43xx_UCODE_TIME              0x0006
> +#define BCM43xx_UCODE_STATUS            0x0040
> 
>   /* MicrocodeFlagsBitfield (addr + lo-word values?)*/
>   #define BCM43xx_UCODEFLAGS_OFFSET	0x005E
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
> @@ -373,6 +373,56 @@ static DEVICE_ATTR(phymode, 0644,
>   		   bcm43xx_attr_phymode_show,
>   		   bcm43xx_attr_phymode_store);
> 
> +static ssize_t bcm43xx_attr_microcode_show(struct device *dev,
> +					   struct device_attribute *attr,
> +					   char *buf)
> +{
> +	struct bcm43xx_private *bcm = dev_to_bcm(dev);
> +	ssize_t count = 0;
> +	u16 status;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +

you want to take the spinlock lock here, too.

> +	mutex_lock(&(bcm)->mutex);
> +	status = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				    BCM43xx_UCODE_STATUS);

can unlock both here.

> +	switch (status) {
> +	case 0x0000:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (invalid)\n",
> +				 status);
> +		break;
> +	case 0x0001:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (init)\n",
> +				 status);
> +		break;
> +	case 0x0002:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (active)\n",
> +				 status);
> +		break;
> +	case 0x0003:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (suspended)\n",
> +				 status);
> +		break;
> +	case 0x0004:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (asleep)\n",
> +				 status);
> +		break;
> +	default:
> +		count = snprintf(buf, PAGE_SIZE, "0x%.4x (unknown)\n",
> +				 status);
> +		break;
> +	}
> +	mutex_unlock(&(bcm)->mutex);
> +
> +	return count;
> +}
> +
> +static DEVICE_ATTR(microcodestatus, 0444,
> +		   bcm43xx_attr_microcode_show,
> +		   NULL);
> +
>   int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
>   {
>   	struct device *dev = &bcm->pci_dev->dev;
> @@ -392,9 +442,14 @@ int bcm43xx_sysfs_register(struct bcm43x
>   	err = device_create_file(dev, &dev_attr_phymode);
>   	if (err)
>   		goto err_remove_shortpreamble;
> +	err = device_create_file(dev, &dev_attr_microcodestatus);
> +	if (err)
> +		goto err_remove_phymode;
> 
>   out:
>   	return err;
> +err_remove_phymode:
> +	device_remove_file(dev, &dev_attr_phymode);
>   err_remove_shortpreamble:
>   	device_remove_file(dev, &dev_attr_shortpreamble);
>   err_remove_interfmode:
> @@ -408,6 +463,7 @@ void bcm43xx_sysfs_unregister(struct bcm
>   {
>   	struct device *dev = &bcm->pci_dev->dev;
> 
> +	device_remove_file(dev, &dev_attr_microcodestatus);
>   	device_remove_file(dev, &dev_attr_phymode);
>   	device_remove_file(dev, &dev_attr_shortpreamble);
>   	device_remove_file(dev, &dev_attr_interference);
> 
> 
> 
> ===========
> 

-- 
Greetings Michael.
