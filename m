From: Scott Wood <oss@buserror.net>
Subject: Re: [PATCH 3/4] mmc: sdhci-of-esdhc: fix host version for
 T4240-R1.0-R2.0
Date: Wed, 01 Jun 2016 20:11:14 -0500
Message-ID: <1464829874.16584.163.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com>
	 <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
	 <6110875.0k1HlSKhzn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"iommu
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.buserror.net ([209.198.135.123]:58196 "EHLO
	host.buserror.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbcFBBLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:11:37 -0400
In-Reply-To: <6110875.0k1HlSKhzn@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-30 at 15:16 +0200, Arnd Bergmann wrote:
> This is a rewrite of an earlier patch from Yangbo Lu, adding a quirk
> for the NXP QorIQ T4240 in the detection of the host device version.
> 
> Unfortunately, this device cannot be detected using the compatible
> string, as we have to support existing DTS files that use the generic
> "fsl,t4240-esdhc" identifier but that have other host versions that
> are correctly detected.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> diff --git a/drivers/mmc/host/sdhci-of-esdhc.c b/drivers/mmc/host/sdhci-of
> -esdhc.c
> index 3f34d354f1fc..1d4814fe4cb2 100644
> --- a/drivers/mmc/host/sdhci-of-esdhc.c
> +++ b/drivers/mmc/host/sdhci-of-esdhc.c
> @@ -73,14 +73,16 @@ static u32 esdhc_readl_fixup(struct sdhci_host *host,
>  static u16 esdhc_readw_fixup(struct sdhci_host *host,
>  				     int spec_reg, u32 value)
>  {
> +	struct sdhci_pltfm_host *pltfm_host = sdhci_priv(host);
> +	struct sdhci_esdhc *esdhc = sdhci_pltfm_priv(pltfm_host);
>  	u16 ret;
>  	int shift = (spec_reg & 0x2) * 8;
>  
>  	if (spec_reg == SDHCI_HOST_VERSION)
> -		ret = value & 0xffff;
> -	else
> -		ret = (value >> shift) & 0xffff;
> -	return ret;
> +		return esdhc->vendor_ver << SDHCI_VENDOR_VER_SHIFT |
> +		       esdhc->spec_ver;
> +
> +	return (value >> shift) & 0xffff;
>  }
>  
>  static u8 esdhc_readb_fixup(struct sdhci_host *host,
> @@ -562,16 +564,32 @@ static const struct sdhci_pltfm_data
> sdhci_esdhc_le_pdata = {
>  	.ops = &sdhci_esdhc_le_ops,
>  };
>  
> +#define T4240_HOST_VER ((VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) |
> SDHCI_SPEC_200)
> +static const struct soc_device_attribute esdhc_t4240_quirk = {
> +	/* T4240 revision < 0x20 uses vendor version 23, SDHCI version 200
> */
> +	{ .soc_id = "T4*(0x824000)", .revision = "0x[01]?",
> +	  .data = (void *)(uintptr_t)(T4240_HOST_VER) },

Why should this code need to care that the string begins with "T4"?  This
creates dual maintenance if that were to change.  It's also broken because
T4240 has compatible = "fsl,t4240-device-config", "fsl,qoriq-device-config
-2.0" and thus with these patches it would incorrectly show up as "P series
(0x824000)".  The compatible string of this node was never meant to be a key
for choosing a string to describe the system to userspace.

0x824000 is a magic number which should be represented symbolically.

If T4240 is affected, then so are the reduced-core variants T4160 and T4080,
but 0x824000 doesn't match them (Yangbo's patch had the same problem).  And
please don't respond with "0x824*"

You also didn't strip out the E bit of SVR which indicates encryption
capability and nothing else (Yangbo's patch did not have this problem because
it used SVR_SOC_VER).

What happens if the revision condition is more complicated, such as <= 0x20
with 0x21 being fine?  Multiple quirk entries where before we had as simple
comparison?

I fail to see how this approach is an improvement (much less one that needs to
hold up a patchset that is fixing a problem and is not touching any generic
code).  Why does this need to be a string?

-Scott
