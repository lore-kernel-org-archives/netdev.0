From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/4] r8169: explicit firmware format check.
Date: Fri, 17 Jun 2011 22:13:20 +0100
Message-ID: <1308345200.2831.31.camel@bwh-desktop>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
	 <20110617193105.GB2287@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3746 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757651Ab1FQVNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:13:24 -0400
In-Reply-To: <20110617193105.GB2287@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 21:31 +0200, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |   54 +++++++++++++++++++++++++++++++++++++++-----------
>  1 files changed, 42 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 3eeefe4..452db86 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -669,6 +669,15 @@ struct rtl8169_private {
>  
>  	struct rtl_fw {
>  		const struct firmware *fw;
> +
> +#define RTL_VER_SIZE		32
> +
> +		char version[RTL_VER_SIZE];
> +
> +		struct rtl_fw_phy_action {
> +			__le32 *code;
> +			size_t size;
> +		} phy_action;
>  	} *rtl_fw;
>  #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
>  };
> @@ -1230,7 +1239,7 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
>  	strcpy(info->version, RTL8169_VERSION);
>  	strcpy(info->bus_info, pci_name(tp->pci_dev));
>  	strncpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
> -		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
> +		rtl_fw->version, RTL_VER_SIZE);

You appear to ensure that rtl_fw->version is properly terminated, so I
would suggest:

	BUILD_BUG_ON(sizeof(info->fw_version) < sizeof(rtl_fw->version));
	strcpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" : rtl_fw->version);

>  }
>  
>  static int rtl8169_get_regs_len(struct net_device *dev)
> @@ -1744,21 +1753,42 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
>  #define PHY_DELAY_MS		0xe0000000
>  #define PHY_WRITE_ERI_WORD	0xf0000000
>  
> -static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
> +#define FW_OPCODE_SIZE	sizeof(typeof(*((struct rtl_fw_phy_action *)0)->code))
> +
> +static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
>  {
>  	const struct firmware *fw = rtl_fw->fw;
> -	__le32 *phytable = (__le32 *)fw->data;
> +	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
> +	bool rc = false;
> +
> +	if (!(fw->size % FW_OPCODE_SIZE)) {
> +		snprintf(rtl_fw->version, RTL_VER_SIZE, "%s",
> +			 rtl_lookup_firmware_name(tp));

strlcpy()

> +		pa->code = (__le32 *)fw->data;
> +		pa->size = fw->size / FW_OPCODE_SIZE;
> +	}
> +	rtl_fw->version[RTL_VER_SIZE - 1] = 0;
> +
> +	rc = true;
> +
> +	return rc;
> +}
[...]

This function is doing rather more than what its name suggests.  And it
always returns true, so it doesn't actually do what its name suggests at
all.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

