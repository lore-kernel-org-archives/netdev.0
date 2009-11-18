From: Troy Kisky <troy.kisky-Q5RJGjKts06CY9SHAMCTRUEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 2/3] TI Davinci EMAC : add platform specific interrupt
	enable/disable logic.
Date: Wed, 18 Nov 2009 12:08:24 -0700
Message-ID: <4B044628.9030701@boundarydevices.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>	<1258537328-31527-2-git-send-email-srk@ti.com>
	<1258537328-31527-3-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1258537328-31527-3-git-send-email-srk-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Sriramakrishnan wrote:
> On certain SOCs, the EMAC controller is interfaced with a wrapper logic
> for handling interrupts. This  patch implements a platform
> specific hook to cater to platforms that require custom interrupt
> handling logic
> 
> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
> Acked-by: Chaithrika U S <chaithrika-l0cyMroinI0@public.gmane.org>
> ---
>  drivers/net/davinci_emac.c   |   11 +++++++++++
>  include/linux/davinci_emac.h |    2 ++
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 6aec8f5..81931f8 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -487,6 +487,9 @@ struct emac_priv {
>  	struct mii_bus *mii_bus;
>  	struct phy_device *phydev;
>  	spinlock_t lock;
> +	/*platform specific members*/
> +	void (*wrapper_int_enable) (void);
> +	void (*wrapper_int_disable) (void);

Would platform_int_enable be more appropriate then wrapper_int_enable ?

>  };
>  
>  /* clock frequency for EMAC */
> @@ -1001,6 +1004,8 @@ static void emac_int_disable(struct emac_priv *priv)
>  		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0x0);
>  		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0x0);
>  		/* NOTE: Rx Threshold and Misc interrupts are not disabled */
> +		if (priv->wrapper_int_disable)
> +			priv->wrapper_int_disable();
>  
>  		local_irq_restore(flags);
>  
> @@ -1020,6 +1025,9 @@ static void emac_int_disable(struct emac_priv *priv)
>  static void emac_int_enable(struct emac_priv *priv)
>  {
>  	if (priv->version == EMAC_VERSION_2) {
> +		if (priv->wrapper_int_enable)
> +			priv->wrapper_int_enable();
> +
>  		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0xff);
>  		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0xff);
>  
> @@ -2662,6 +2670,9 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>  	priv->phy_mask = pdata->phy_mask;
>  	priv->rmii_en = pdata->rmii_en;
>  	priv->version = pdata->version;
> +	priv->wrapper_int_enable = pdata->wrapper_interrupt_enable;
> +	priv->wrapper_int_disable = pdata->wrapper_interrupt_disable;
> +
>  	emac_dev = &ndev->dev;
>  	/* Get EMAC platform data */
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
> index ff55487..eb24dc0 100644
> --- a/include/linux/davinci_emac.h
> +++ b/include/linux/davinci_emac.h
> @@ -25,6 +25,8 @@ struct emac_platform_data {
>  	u32 mdio_max_freq;
>  	u8 rmii_en;
>  	u8 version;
> +	void (*wrapper_interrupt_enable) (void);
> +	void (*wrapper_interrupt_disable) (void);
>  };
>  
>  enum {
