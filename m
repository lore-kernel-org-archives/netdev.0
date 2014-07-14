From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/8] net: ethernet driver: Fujitsu OGMA
Date: Mon, 14 Jul 2014 15:50:52 +0200
Message-ID: <18609483.Jzi9Hxcq2r@wuerfel>
References: <1405233107-4762-1-git-send-email-mollie.wu@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Mollie Wu <mollie.wu@linaro.org>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, mark.rutland@arm.com,
	Tetsuya Takinishi <t.takinishi@jp.fujitsu.com>,
	andy.green@linaro.org, linux@arm.linux.org.uk, pawel.moll@arm.com,
	patches@linaro.org, stephen@networkplumber.org,
	jaswinder.singh@linaro.org, robh+dt@kernel.org,
	romieu@fr.zoreil.com, olof@lixom.net, f.fainelli@gmail.com,
	davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:61929 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbaGNNvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 09:51:07 -0400
In-Reply-To: <1405233107-4762-1-git-send-email-mollie.wu@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 13 July 2014 14:31:47 Mollie Wu wrote:
> +
> +Example:
> +	eth0: f_taiki {
> +                compatible = "fujitsu,ogma";
> +		reg = <0 0x31600000 0x10000>, <0 0x31618000 0x4000>, <0 0x3161c000 0x4000>;
> +		interrupts = <0 163 0x4>;
> +		clocks = <&clk_alw_0_8>;
> +		phy-mode = "rgmii";
> +		max-speed = <1000>;
> +		max-frame-size = <9000>;
> +		local-mac-address = [ a4 17 31 00 00 ed ];
> +		phy-handle = <&ethphy0>;
> +
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		ethphy0: ethernet-phy@1 {
> +			device_type = "ethernet-phy";
> +			compatible = "ethernet-phy-ieee802.3-c22";
> +			reg = <1>;
> +		};
> +	};

The name of the device should be "ethernet" rather than "f_taiki".

For the compatible string, it would be good to have a version number included.
If you cannot find out the version of the ogma hardware, add the identifier for
the soc it is used in, e.g.

	compatible = "fujitsu,mb86s73-ogma", "fujitsu,ogma";

The driver only needs to match the generic string, but it's better
to be prepared for the case where we have to support slightly different
variants.

> +static inline void ogma_writel(struct ogma_priv *priv, u32 reg_addr, u32 val)
> +{
> +	writel(val, priv->ioaddr + (reg_addr << 2));
> +}
> +
> +static inline u32 ogma_readl(struct ogma_priv *priv, u32 reg_addr)
> +{
> +	return readl(priv->ioaddr + (reg_addr << 2));
> +}
for best performance, it may be better to use readl_relaxed() by default
and only use the nonrelaxed accesses in the cases where you have to
synchronize with DMA transfers.

> +
> +#define TIMEOUT_SPINS_MAC 1000000
> +
> +static u32 ogma_clk_type(u32 freq)
> +{
> +	if (freq < 35 * OGMA_CLK_MHZ)
> +		return OGMA_GMAC_GAR_REG_CR_25_35_MHZ;
> +	if (freq < 60 * OGMA_CLK_MHZ)
> +		return OGMA_GMAC_GAR_REG_CR_35_60_MHZ;
> +	if (freq < 100 * OGMA_CLK_MHZ)
> +		return OGMA_GMAC_GAR_REG_CR_60_100_MHZ;
> +	if (freq < 150 * OGMA_CLK_MHZ)
> +		return OGMA_GMAC_GAR_REG_CR_100_150_MHZ;
> +	if (freq < 250 * OGMA_CLK_MHZ)
> +		return OGMA_GMAC_GAR_REG_CR_150_250_MHZ;
> +
> +	return OGMA_GMAC_GAR_REG_CR_250_300_MHZ;
> +}
> +
> +static int ogma_wait_while_busy(struct ogma_priv *priv, u32 addr, u32 mask)
> +{
> +	u32 timeout = TIMEOUT_SPINS_MAC;
> +
> +	while (--timeout && ogma_readl(priv, addr) & mask)
> +		;
> +	if (!timeout) {
> +		netdev_WARN(priv->net_device, "%s: timeout\n", __func__);
> +		return -ETIMEDOUT;
> +	}
> +
> +	return 0;
> +}

The callers of this function seem to all be from non-atomic context, so it
would be good to occasionally msleep() here, either after each try, or
after initially spinning for as long as it takes to succeed most of the
time.

> +
> +static void ogma_napi_tx_processing(struct napi_struct *napi_p)
> +{
> +	struct ogma_priv *priv = container_of(napi_p, struct ogma_priv, napi);
> +
> +	ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +	ogma_clean_tx_desc_ring(priv);
> +
> +	if (netif_queue_stopped(priv->net_device) &&
> +	    ogma_get_tx_avail_num(priv) >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX)
> +		netif_wake_queue(priv->net_device);
> +}

You should probably call netdev_tx_completed_queue() here and 
netdev_tx_sent_queue() when sending the frame. See http://lwn.net/Articles/454390/
for a description of the API.

	Arnd
