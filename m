From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] davinci_emac: Add cpu_freq support
Date: Mon, 9 Apr 2012 15:29:52 +0400
Message-ID: <4F82C830.1020100@mvista.com>
References: <1333968549-3282-1-git-send-email-prakash.pm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Manjunathappa, Prakash" <prakash.pm-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1333968549-3282-1-git-send-email-prakash.pm-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 09-04-2012 14:49, Manjunathappa, Prakash wrote:

> Reconfigure interrupt coalesce parameter for changed emac bus_freq
> due to DVFS.

> Signed-off-by: Manjunathappa, Prakash<prakash.pm-l0cyMroinI0@public.gmane.org>
> ---
>   drivers/net/ethernet/ti/davinci_emac.c |   60 ++++++++++++++++++++++++++++++++
>   1 files changed, 60 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index 174a334..11d3bd7 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
[...]
> @@ -1761,6 +1765,46 @@ static const struct net_device_ops emac_netdev_ops = {
>   #endif
>   };
>
> +#ifdef CONFIG_CPU_FREQ
> +static int davinci_emac_cpufreq_transition(struct notifier_block *nb,
> +				     unsigned long val, void *data)
> +{
> +	int ret = 0;
> +	struct emac_priv *priv;
> +
> +	priv = container_of(nb, struct emac_priv, freq_transition);
> +	if (priv->coal_intvl != 0) {
> +		if (val == CPUFREQ_POSTCHANGE) {
> +			if (emac_bus_frequency != clk_get_rate(emac_clk)) {

    These 3 *if*s could be collapsed into one, and so indentation level 
lowered significantly.

> +				struct ethtool_coalesce coal;
> +
> +				emac_bus_frequency = clk_get_rate(emac_clk);
> +
> +				priv->bus_freq_mhz = (u32)(emac_bus_frequency /
> +						1000000);
> +				coal.rx_coalesce_usecs = (priv->coal_intvl
> +						<<  4);
> +				ret = emac_set_coalesce(priv->ndev,&coal);
> +			}
> +		}
> +	}
> +	return ret;
> +}
> +
> +static inline int davinci_emac_cpufreq_register(struct emac_priv *priv)
> +{
> +	priv->freq_transition.notifier_call = davinci_emac_cpufreq_transition;
> +	return cpufreq_register_notifier(&priv->freq_transition,
> +					 CPUFREQ_TRANSITION_NOTIFIER);
> +}
> +
> +static inline void davinci_emac_cpufreq_deregister(struct emac_priv *priv)
> +{
> +	cpufreq_unregister_notifier(&priv->freq_transition,
> +				    CPUFREQ_TRANSITION_NOTIFIER);
> +}
> +#endif
> +
>   /**
>    * davinci_emac_probe: EMAC device probe
>    * @pdev: The DaVinci EMAC device that we are removing
> @@ -1925,8 +1969,21 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>   			   "(regs: %p, irq: %d)\n",
>   			   (void *)priv->emac_base_phys, ndev->irq);
>   	}
> +
> +#ifdef CONFIG_CPU_FREQ
> +	rc = davinci_emac_cpufreq_register(priv);
> +	if (rc) {
> +		dev_err(&pdev->dev, "error in register_netdev\n");

    Really?

> +		rc = -ENODEV;
> +		goto cpufreq_reg_err;
> +	}
> +#endif
>   	return 0;
>
> +#ifdef CONFIG_CPU_FREQ
> +cpufreq_reg_err:
> +	unregister_netdev(ndev);
> +#endif
>   netdev_reg_err:
>   	clk_disable(emac_clk);
>   no_irq_res:
> @@ -1973,6 +2030,9 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
>
>   	release_mem_region(res->start, resource_size(res));
>
> +#ifdef CONFIG_CPU_FREQ
> +	davinci_emac_cpufreq_deregister(priv);
> +#endif

    This is considered a bad practice to use #ifdef in the body of function.
Define the faunction you call here as empty inline in case CONFIG_CPU_FREQ is 
not defined instead. The same about davinci_emac_cpufreq_register().

WBR, Sergei
