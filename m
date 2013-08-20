From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700 Device
 Driver into the Linux Kernel
Date: Tue, 20 Aug 2013 14:36:41 +0100
Message-ID: <1377005801.1862.10.camel@bwh-desktop.uk.level5networks.com>
References: <201308201850095789331@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh <gregkh@linuxfoundation.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	sunhecheng <sunhecheng@vip.126.com>
To: liujunliang_ljl <liujunliang_ljl@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201308201850095789331@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-20 at 18:50 +0800, liujunliang_ljl wrote:
> Dear Gregkh & all :
> 
> 		I am the software engineer Liu Junliang from ShenZhen CoreChips high technology company, on the market of SR9700 chip is designed and owned by us. 
>         SR9700 is a type of USB to Ethernet Converter and is compatible with USB 1.1 protocol, We want to merge SR9700 device driver into the Linux Kernel. The following is the Linux 3.10.7 version patch for SR9700, Please give us the assessment and support.
>         Thanks a lot.

As this is a net driver, the relevant maintainer is David Miller and not
Greg.

There are some style errors here which can be found using
scripts/checkpatch.pl.  You'll need to fix those and re-submit.  I'll
point out some more problems inline.

> --- /dev/null
> +++ b/drivers/net/usb/sr9700.c
[...]
> +static int sr9700_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom, u8 * data)
> +{
> +	struct usbnet *dev = netdev_priv(net);
> +	__le16 *ebuf = (__le16 *) data;
> +	int i;
> +
> +	/* access is 16bit */
> +	if ((eeprom->offset % 2) || (eeprom->len % 2))
> +		return -EINVAL;

You're really supposed to handle these cases by shifting as necessary.

> +	for (i = 0; i < eeprom->len / 2; i++) {
> +		if (sr_read_eeprom_word(dev, eeprom->offset / 2 + i, &ebuf[i]) < 0)
> +			return -EINVAL;

You should pass up the error code, not substitute -EINVAL.

[...]
> +static void sr9700_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
> +{
> +	/* Inherit standard device info */
> +	usbnet_get_drvinfo(net, info);
> +	info->eedump_len = SR_EEPROM_LEN;

You don't need to set eedump_len; the ethtool core will set it after
calling sr9700_get_eeprom_len().  So you don't need your own
implementation of get_drvinfo at all.

[...]
> +static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
[...]
> +	/* read MAC */
> +	if (sr_read(dev, PAR, ETH_ALEN, dev->net->dev_addr) < 0) {
> +		printk(KERN_ERR "Error reading MAC address\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
[...]

I think this should read the MAC address from EEPROM and copy it to both
dev_addr to perm_addr.  MAC address changes should not persist if the
driver is reloaded.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
