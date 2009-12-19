From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Sat, 19 Dec 2009 02:19:09 +0000
Message-ID: <1261189149.2418.82.camel@localhost>
References: <200912190128.nBJ1SZBw015434@blc-10-2.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Debashis Dutt <ddutt@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14221 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755592AbZLSCTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 21:19:14 -0500
In-Reply-To: <200912190128.nBJ1SZBw015434@blc-10-2.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 17:28 -0800, Debashis Dutt wrote:
[...]
> diff -ruP net-next-2.6-orig/drivers/net/bna/bfad_fwimg.c net-next-2.6-mod/drivers/net/bna/bfad_fwimg.c
> --- net-next-2.6-orig/drivers/net/bna/bfad_fwimg.c      1969-12-31 16:00:00.000000000 -0800
> +++ net-next-2.6-mod/drivers/net/bna/bfad_fwimg.c       2009-12-18 16:53:40.000000000 -0800
[...]
> +u32 bfi_image_ct_size;
> +u32 bfi_image_cb_size;
> +u32 *bfi_image_ct;
> +u32 *bfi_image_cb;
> +
> +#define	BFAD_FW_FILE_CT	"ctfw.bin"
> +#define	BFAD_FW_FILE_CB	"cbfw.bin"

You should also use the MODULE_FIRMWARE() macro to add references to
these files in the module.  That enables distribution scripts to tell
which firmware files need to be installed on the system or included in
an initramfs.

> +u32 *
> +bfad_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
> +			u32 *bfi_image_size, char *fw_name)
> +{
> +	const struct firmware *fw;
> +
> +	if (request_firmware(&fw, fw_name, &pdev->dev)) {
> +		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
> +		goto error;
> +	}
> +
> +	*bfi_image = vmalloc(fw->size);
> +	if (NULL == *bfi_image) {
> +		printk(KERN_ALERT "Fail to allocate buffer for fw image "
> +			"size=%x!\n", (u32) fw->size);
> +		goto error;
> +	}
> +
> +	memcpy(*bfi_image, fw->data, fw->size);

What is the point of making a copy?

> +	*bfi_image_size = fw->size/sizeof(u32);
> +
> +	return *bfi_image;
> +
> +error:
> +	return NULL;
> +}

Are you ever going to free any of these firmware images?

> +u32 *
> +bfad_get_firmware_buf(struct pci_dev *pdev)
> +{
> +	if (pdev->device == BFA_PCI_DEVICE_ID_CT) {
> +		if (bfi_image_ct_size == 0)
> +			bfad_read_firmware(pdev, &bfi_image_ct,
> +				&bfi_image_ct_size, BFAD_FW_FILE_CT);
> +		return bfi_image_ct;
> +	} else {
> +		if (bfi_image_cb_size == 0)
> +			bfad_read_firmware(pdev, &bfi_image_cb,
> +				&bfi_image_cb_size, BFAD_FW_FILE_CB);
> +		return bfi_image_cb;
> +	}
> +}
[...]

PCI devices can be probed in parallel, so this must use a mutex.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

