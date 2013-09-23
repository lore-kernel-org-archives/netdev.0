From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 36/51] DMA-API: usb: use dma_set_coherent_mask()
Date: Mon, 23 Sep 2013 14:27:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1309231418030.1348-100000@iolanthe.rowland.org>
References: <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 b43-dev@lists.infradead.org, linux-media@vger.kernel.org,
 devicetree@vger.kernel.org, Stephen Warren <swarren@wwwdotorg.org>,
 Kukjin Kim <kgene.kim@samsung.com>, dri-devel@lists.freedesktop.org,
 linux-tegra@vger.kernel.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
 linux-crypto@vger.kernel.org, Greg Kroah-Hartman <gregkh@linu
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <E1VMmHX-0007jq-Cj@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Sep 2013, Russell King wrote:

> The correct way for a driver to specify the coherent DMA mask is
> not to directly access the field in the struct device, but to use
> dma_set_coherent_mask().  Only arch and bus code should access this
> member directly.
> 
> Convert all direct write accesses to using the correct API.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

> diff --git a/drivers/usb/host/ehci-platform.c b/drivers/usb/host/ehci-platform.c
> index f6b790c..5b0cd2d 100644
> --- a/drivers/usb/host/ehci-platform.c
> +++ b/drivers/usb/host/ehci-platform.c

> @@ -91,8 +91,9 @@ static int ehci_platform_probe(struct platform_device *dev)
>  		dev->dev.platform_data = &ehci_platform_defaults;
>  	if (!dev->dev.dma_mask)
>  		dev->dev.dma_mask = &dev->dev.coherent_dma_mask;
> -	if (!dev->dev.coherent_dma_mask)
> -		dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
> +	err = dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
> +	if (err)
> +		return err;
>  
>  	pdata = dev_get_platdata(&dev->dev);

ehci-platform.c is a generic file, intended for use by multiple
platforms.  Is it not possible that on some platforms, the arch or bus
code may already have initialized the DMA masks?  Isn't something like 
this (i.e., DMA bindings) planned for Device Tree?

By eliminating the tests above and calling dma_set_coherent_mask or
dma_coerce_mask_and_coherent unconditionally, this patch (and the next)
would overwrite those initial settings.

I don't know to what extent the same may be true for the other,
platform-specific, drivers changed by this patch.  But it's something 
to be aware of.

Alan Stern
