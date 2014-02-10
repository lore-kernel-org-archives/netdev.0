From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v3 1/2] ASoC: atmel_ssc_dai: make option to choose clock
Date: Mon, 10 Feb 2014 10:22:27 +0100
Message-ID: <52F89A53.4090402@atmel.com>
References: <1392012586-30790-1-git-send-email-voice.shen@atmel.com> <1392012586-30790-2-git-send-email-voice.shen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <plagnioj@jcrosoft.com>, <linux-sound@vger.kernel.org>,
	<alsa-devel@alsa-project.org>,
	<linux-arm-kernel@lists.infradead.org>,
	"Arnd Bergmann" <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Liam Girdwood <lgirdwood@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>,
	"Lars-Peter Clausen" <lars@metafoo.de>,
	<linux-kernel@vger.kernel.org>,
	<linux-atm-general@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: Bo Shen <voice.shen@atmel.com>, <broonie@kernel.org>
Return-path: <linux-sound-owner@vger.kernel.org>
In-Reply-To: <1392012586-30790-2-git-send-email-voice.shen@atmel.com>
Sender: linux-sound-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2014 07:09, Bo Shen :
> When SSC works in slave mode, according to the hardware design, the
> clock can get from TK pin, also can get from RK pin. So, add one
> parameter to choose where the clock from.
> 
> Signed-off-by: Bo Shen <voice.shen@atmel.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
> Changes in v3:
>   - New, move clk-from-rk-pin property from card to ssc device
> 
>  drivers/misc/atmel-ssc.c        |  6 ++++++
>  include/linux/atmel-ssc.h       |  1 +
>  sound/soc/atmel/atmel_ssc_dai.c | 13 +++++++++----
>  3 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/misc/atmel-ssc.c b/drivers/misc/atmel-ssc.c
> index 5be80840..22de137 100644
> --- a/drivers/misc/atmel-ssc.c
> +++ b/drivers/misc/atmel-ssc.c
> @@ -150,6 +150,12 @@ static int ssc_probe(struct platform_device *pdev)
>  		return -ENODEV;
>  	ssc->pdata = (struct atmel_ssc_platform_data *)plat_dat;
>  
> +	if (pdev->dev.of_node) {
> +		struct device_node *np = pdev->dev.of_node;
> +		ssc->clk_from_rk_pin =
> +			of_property_read_bool(np, "atmel,clk-from-rk-pin");
> +	}
> +
>  	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	ssc->regs = devm_ioremap_resource(&pdev->dev, regs);
>  	if (IS_ERR(ssc->regs))
> diff --git a/include/linux/atmel-ssc.h b/include/linux/atmel-ssc.h
> index 66a0e53..571a12e 100644
> --- a/include/linux/atmel-ssc.h
> +++ b/include/linux/atmel-ssc.h
> @@ -18,6 +18,7 @@ struct ssc_device {
>  	struct clk		*clk;
>  	int			user;
>  	int			irq;
> +	bool			clk_from_rk_pin;
>  };
>  
>  struct ssc_device * __must_check ssc_request(unsigned int ssc_num);
> diff --git a/sound/soc/atmel/atmel_ssc_dai.c b/sound/soc/atmel/atmel_ssc_dai.c
> index 8697ced..ca1d8a3 100644
> --- a/sound/soc/atmel/atmel_ssc_dai.c
> +++ b/sound/soc/atmel/atmel_ssc_dai.c
> @@ -341,6 +341,7 @@ static int atmel_ssc_hw_params(struct snd_pcm_substream *substream,
>  {
>  	int id = dai->id;
>  	struct atmel_ssc_info *ssc_p = &ssc_info[id];
> +	struct ssc_device *ssc = ssc_p->ssc;
>  	struct atmel_pcm_dma_params *dma_params;
>  	int dir, channels, bits;
>  	u32 tfmr, rfmr, tcmr, rcmr;
> @@ -466,7 +467,8 @@ static int atmel_ssc_hw_params(struct snd_pcm_substream *substream,
>  			| SSC_BF(RCMR_START, start_event)
>  			| SSC_BF(RCMR_CKI, SSC_CKI_RISING)
>  			| SSC_BF(RCMR_CKO, SSC_CKO_NONE)
> -			| SSC_BF(RCMR_CKS, SSC_CKS_CLOCK);
> +			| SSC_BF(RCMR_CKS, ssc->clk_from_rk_pin ?
> +					   SSC_CKS_PIN : SSC_CKS_CLOCK);
>  
>  		rfmr =	  SSC_BF(RFMR_FSEDGE, SSC_FSEDGE_POSITIVE)
>  			| SSC_BF(RFMR_FSOS, SSC_FSOS_NONE)
> @@ -481,7 +483,8 @@ static int atmel_ssc_hw_params(struct snd_pcm_substream *substream,
>  			| SSC_BF(TCMR_START, start_event)
>  			| SSC_BF(TCMR_CKI, SSC_CKI_FALLING)
>  			| SSC_BF(TCMR_CKO, SSC_CKO_NONE)
> -			| SSC_BF(TCMR_CKS, SSC_CKS_PIN);
> +			| SSC_BF(TCMR_CKS, ssc->clk_from_rk_pin ?
> +					   SSC_CKS_CLOCK : SSC_CKS_PIN);
>  
>  		tfmr =	  SSC_BF(TFMR_FSEDGE, SSC_FSEDGE_POSITIVE)
>  			| SSC_BF(TFMR_FSDEN, 0)
> @@ -550,7 +553,8 @@ static int atmel_ssc_hw_params(struct snd_pcm_substream *substream,
>  			| SSC_BF(RCMR_START, SSC_START_RISING_RF)
>  			| SSC_BF(RCMR_CKI, SSC_CKI_RISING)
>  			| SSC_BF(RCMR_CKO, SSC_CKO_NONE)
> -			| SSC_BF(RCMR_CKS, SSC_CKS_PIN);
> +			| SSC_BF(RCMR_CKS, ssc->clk_from_rk_pin ?
> +					   SSC_CKS_PIN : SSC_CKS_CLOCK);
>  
>  		rfmr =	  SSC_BF(RFMR_FSEDGE, SSC_FSEDGE_POSITIVE)
>  			| SSC_BF(RFMR_FSOS, SSC_FSOS_NONE)
> @@ -565,7 +569,8 @@ static int atmel_ssc_hw_params(struct snd_pcm_substream *substream,
>  			| SSC_BF(TCMR_START, SSC_START_RISING_RF)
>  			| SSC_BF(TCMR_CKI, SSC_CKI_FALLING)
>  			| SSC_BF(TCMR_CKO, SSC_CKO_NONE)
> -			| SSC_BF(TCMR_CKS, SSC_CKS_PIN);
> +			| SSC_BF(RCMR_CKS, ssc->clk_from_rk_pin ?
> +					   SSC_CKS_CLOCK : SSC_CKS_PIN);
>  
>  		tfmr =	  SSC_BF(TFMR_FSEDGE, SSC_FSEDGE_POSITIVE)
>  			| SSC_BF(TFMR_FSDEN, 0)
> 


-- 
Nicolas Ferre
