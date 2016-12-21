From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO
 voltage
Date: Tue, 20 Dec 2016 19:23:47 -0700
Message-ID: <20161221022347.GB5444@animalcreek.com>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
 <1482250592-4268-2-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        justin@kuvee.com
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482250592-4268-2-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 11:16:31AM -0500, Geoff Lansberry wrote:
> From: Geoff Lansberry <geoff@kuvee.com>
> 
> The TRF7970A has configuration options for supporting hardware designs
> with 1.8 Volt or 3.3 Volt IO.   This commit adds a device tree option,
> using a fixed regulator binding, for setting the io voltage to match
> the hardware configuration. If no option is supplied it defaults to
> 3.3 volt configuration.

Sign-off ??  Same comment for you other patches.

<time passes>

Okay I see you have it at the end of the patch.  It should be here.
'git commit -s' is your friend.

> ---
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
>  drivers/nfc/trf7970a.c                             | 28 +++++++++++++++++++++-
>  2 files changed, 29 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> index e262ac1..b5777d8 100644
> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> @@ -21,9 +21,9 @@ Optional SoC Specific Properties:
>  - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
>    where an extra byte is returned by Read Multiple Block commands issued
>    to Type 5 tags.
> +- vdd-io-supply: Regulator specifying voltage for vdd-io
>  - clock-frequency: Set to specify that the input frequency to the trf7970a is 13560000Hz or 27120000Hz
>  
> -
>  Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>  
>  &spi1 {
> @@ -41,11 +41,11 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>  				  <&gpio2 5 GPIO_ACTIVE_LOW>;
>  		vin-supply = <&ldo3_reg>;
>  		vin-voltage-override = <5000000>;
> +		vdd-io-supply = <&ldo2_reg>;
>  		autosuspend-delay = <30000>;
>  		irq-status-read-quirk;
>  		en2-rf-quirk;
>  		t5t-rmb-extra-byte-quirk;
> -		vdd_io_1v8;

It was already mentioned but this shouldn't have been added in the
previous patch so it shouldn't be here now.

>  		clock-frequency = <27120000>;
>  		status = "okay";
>  	};
> diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
> index 4e051e9..8a88195 100644
> --- a/drivers/nfc/trf7970a.c
> +++ b/drivers/nfc/trf7970a.c

> @@ -2062,6 +2068,7 @@ static int trf7970a_probe(struct spi_device *spi)
>  		return ret;
>  	}
>  
> +

Please don't add an extra blank line.

>  	of_property_read_u32(np, "clock-frequency", &clk_freq);
>  	if ((clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY) ||
>  		(clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY)) {
> @@ -2105,6 +2112,25 @@ static int trf7970a_probe(struct spi_device *spi)
>  	if (uvolts > 4000000)
>  		trf->chip_status_ctrl = TRF7970A_CHIP_STATUS_VRS5_3;
>  
> +	trf->regulator = devm_regulator_get(&spi->dev, "vdd-io");
> +	if (IS_ERR(trf->regulator)) {
> +		ret = PTR_ERR(trf->regulator);
> +		dev_err(trf->dev, "Can't get VDD_IO regulator: %d\n", ret);
> +		goto err_destroy_lock;
> +	}
> +
> +	ret = regulator_enable(trf->regulator);
> +	if (ret) {
> +		dev_err(trf->dev, "Can't enable VDD_IO: %d\n", ret);
> +		goto err_destroy_lock;
> +	}
> +
> +

Please don't add an extra blank line.

> +	if (regulator_get_voltage(trf->regulator) == 1800000) {
> +		trf->io_ctrl = TRF7970A_REG_IO_CTRL_IO_LOW;
> +		dev_dbg(trf->dev, "trf7970a config vdd_io to 1.8V\n");
> +	}
> +
>  	trf->ddev = nfc_digital_allocate_device(&trf7970a_nfc_ops,
>  			TRF7970A_SUPPORTED_PROTOCOLS,
>  			NFC_DIGITAL_DRV_CAPS_IN_CRC |
> -- 
> Signed-off-by: Geoff Lansberry <geoff@kuvee.com>

Your 'Signed-off-by:' goes at the end of the commit description not here.

Overall, I think you did the right thing (unless someone disagrees).
Just some minor issues.

Mark
--
