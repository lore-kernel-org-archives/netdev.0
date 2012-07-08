From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Sun, 8 Jul 2012 19:56:47 +0530
Message-ID: <4FF998A7.50309@ti.com>
References: <1338373143-7467-1-git-send-email-hs@denx.de>
 <1338373143-7467-5-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Anatoly Sivov <mm05-JGs/UdohzUI@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1338373143-7467-5-git-send-email-hs-ynQEQJNshbs@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Heiko,

On 5/30/2012 3:49 PM, Heiko Schocher wrote:
> add of support for the davinci_emac driver.
> 
> Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
> Cc: Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>
> Cc: Anatoly Sivov <mm05-JGs/UdohzUI@public.gmane.org>
> 
> ---

> +#ifdef CONFIG_OF
> +static struct emac_platform_data
> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
> +	struct emac_priv *priv)
> +{
> +	struct device_node *np;
> +	struct emac_platform_data *pdata = NULL;
> +	const u8 *mac_addr;
> +	u32 data;
> +	int ret;
> +
> +	pdata = pdev->dev.platform_data;
> +	if (!pdata) {
> +		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
> +		if (!pdata)
> +			goto nodata;
> +	}
> +
> +	np = pdev->dev.of_node;
> +	if (!np)
> +		goto nodata;
> +	else
> +		pdata->version = EMAC_VERSION_2;
> +
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);

I suspect that even in the DT case, many boards will continue to
read mac address from on-board EEPROMs or from an on-chip eFUSE.
To take care of such cases, I propose use mac address in DT data
only if no valid address is passed through platform data. The
attached patch does this change.

If you are OK with this modification, can you please merge it and
repost just this patch for review? Please CC David Miller
(davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org) on your next post as he is the netdev maintainer
and this patch needs to be merged through him or at least needs his ack.

With this modification, you can add my:

Acked-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>

Thanks,
Sekhar

---8<----
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 645618d..6b4b0fe 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1795,9 +1795,11 @@ static struct emac_platform_data
 	else
 		pdata->version = EMAC_VERSION_2;
 
-	mac_addr = of_get_mac_address(np);
-	if (mac_addr)
-		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+	if (!is_valid_ether_addr(pdata->mac_addr)) {
+		mac_addr = of_get_mac_address(np);
+		if (mac_addr)
+			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+	}
 
 	ret = of_property_read_u32(np, "ti,davinci-ctrl-reg-offset", &data);
 	if (!ret)
