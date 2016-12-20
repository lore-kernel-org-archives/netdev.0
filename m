From: Jones Desougi <jones.desougi-LdkkVD/qVyw@public.gmane.org>
Subject: Re: [PATCH 1/3] NFC: trf7970a: add device tree option for 27MHz clock
Date: Tue, 20 Dec 2016 18:58:58 +0100
Message-ID: <d498d00a-8966-e282-08a0-e9c554fad66b@27m.se>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482250592-4268-1-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016-12-20 17:16, Geoff Lansberry wrote:
> From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
> 
> The TRF7970A has configuration options to support hardware designs
> which use a 27.12MHz clock. This commit adds a device tree option
> 'clock-frequency' to support configuring the this chip for default
> 13.56MHz clock or the optional 27.12MHz clock.
> ---
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++
>  drivers/nfc/trf7970a.c                             | 50 +++++++++++++++++-----
>  2 files changed, 43 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> index 32b35a0..e262ac1 100644
> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> @@ -21,6 +21,8 @@ Optional SoC Specific Properties:
>  - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
>    where an extra byte is returned by Read Multiple Block commands issued
>    to Type 5 tags.
> +- clock-frequency: Set to specify that the input frequency to the trf7970a is 13560000Hz or 27120000Hz
> +
You're adding an empty line here that is removed in the next patch.

>  
>  Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>  
> @@ -43,6 +45,8 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>  		irq-status-read-quirk;
>  		en2-rf-quirk;
>  		t5t-rmb-extra-byte-quirk;
> +		vdd_io_1v8;
This does not belong here, and so no need to remove in the next patch.

> +		clock-frequency = <27120000>;
>  		status = "okay";
>  	};
>  };
> diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
> index 26c9dbb..4e051e9 100644
> --- a/drivers/nfc/trf7970a.c
> +++ b/drivers/nfc/trf7970a.c
> @@ -124,6 +124,9 @@
>  		 NFC_PROTO_ISO15693_MASK | NFC_PROTO_NFC_DEP_MASK)
>  
>  #define TRF7970A_AUTOSUSPEND_DELAY		30000 /* 30 seconds */
> +#define TRF7970A_13MHZ_CLOCK_FREQUENCY		13560000
> +#define TRF7970A_27MHZ_CLOCK_FREQUENCY		27120000
> +
>  
>  #define TRF7970A_RX_SKB_ALLOC_SIZE		256
>  
> @@ -1056,12 +1059,11 @@ static int trf7970a_init(struct trf7970a *trf)
>  
>  	trf->chip_status_ctrl &= ~TRF7970A_CHIP_STATUS_RF_ON;
>  
> -	ret = trf7970a_write(trf, TRF7970A_MODULATOR_SYS_CLK_CTRL, 0);
> +	ret = trf7970a_write(trf, TRF7970A_MODULATOR_SYS_CLK_CTRL,
> +			trf->modulator_sys_clk_ctrl);
>  	if (ret)
>  		goto err_out;
>  
> -	trf->modulator_sys_clk_ctrl = 0;
> -
>  	ret = trf7970a_write(trf, TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS,
>  			TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS_WLH_96 |
>  			TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS_WLL_32);
> @@ -1181,27 +1183,37 @@ static int trf7970a_in_config_rf_tech(struct trf7970a *trf, int tech)
>  	switch (tech) {
>  	case NFC_DIGITAL_RF_TECH_106A:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_14443A_106;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_OOK;
>  		trf->guard_time = TRF7970A_GUARD_TIME_NFCA;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_106B:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_14443B_106;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_ASK10;
>  		trf->guard_time = TRF7970A_GUARD_TIME_NFCB;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_212F:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_FELICA_212;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_ASK10;
>  		trf->guard_time = TRF7970A_GUARD_TIME_NFCF;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_424F:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_FELICA_424;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_ASK10;
>  		trf->guard_time = TRF7970A_GUARD_TIME_NFCF;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_ISO15693:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_15693_SGL_1OF4_2648;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_OOK;
>  		trf->guard_time = TRF7970A_GUARD_TIME_15693;
>  		break;
>  	default:
> @@ -1571,17 +1583,23 @@ static int trf7970a_tg_config_rf_tech(struct trf7970a *trf, int tech)
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
>  			TRF7970A_ISO_CTRL_NFC_CE |
>  			TRF7970A_ISO_CTRL_NFC_CE_14443A;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_OOK;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_212F:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
>  			TRF7970A_ISO_CTRL_NFC_NFCF_212;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_ASK10;
>  		break;
>  	case NFC_DIGITAL_RF_TECH_424F:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
>  			TRF7970A_ISO_CTRL_NFC_NFCF_424;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |
> +			TRF7970A_MODULATOR_DEPTH_ASK10;
>  		break;
>  	default:
>  		dev_dbg(trf->dev, "Unsupported rf technology: %d\n", tech);
> @@ -1987,6 +2005,7 @@ static int trf7970a_probe(struct spi_device *spi)
>  	struct device_node *np = spi->dev.of_node;
>  	struct trf7970a *trf;
>  	int uvolts, autosuspend_delay, ret;
> +	u32 clk_freq = 13560000;
Use TRF7970A_13MHZ_CLOCK_FREQUENCY here?

>  
>  	if (!np) {
>  		dev_err(&spi->dev, "No Device Tree entry\n");
> @@ -2043,6 +2062,15 @@ static int trf7970a_probe(struct spi_device *spi)
>  		return ret;
>  	}
>  
> +	of_property_read_u32(np, "clock-frequency", &clk_freq);
> +	if ((clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY) ||
> +		(clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY)) {
Two comparisons with 27MHz, missing 13MHz.

> +		dev_err(trf->dev,
> +			"clock-frequency (%u Hz) unsupported\n",
> +			clk_freq);
> +		return -EINVAL;
> +	}
> +
>  	if (of_property_read_bool(np, "en2-rf-quirk"))
>  		trf->quirks |= TRF7970A_QUIRK_EN2_MUST_STAY_LOW;
>  
> 

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
