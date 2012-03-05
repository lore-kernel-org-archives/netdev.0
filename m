From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Mon, 05 Mar 2012 16:05:15 +0100
Message-ID: <4F54D62B.2080502@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org
To: Deepak Sikri <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:48711 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932150Ab2CEPFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 10:05:52 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B53FE5B5
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 15:05:49 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 00EE525B1
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 15:05:48 +0000 (GMT)
In-Reply-To: <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2012 1:55 PM, Deepak Sikri wrote:
> This patch adds in the support for CPU freq notifiers. In case the system freq
> is changed using the CPU freq governors, the CSR input clock is also affected.
> 
> To maintain the CSR mdio clock within the limits of 1-2.5 Mhz the input clock
> has to be properly scaled using the appropriate scaling factors.
> This patch looks into the input clock frequency changes and selects the apt
> scaling factor once a notifier alert is received.
> Additionally the stmmac clock has been defined to support cpu freq notifiers.

Hello Deepak

this patch doesn't apply on net.git.

Concerning the stmmac_clk_csr_set it should treat all the other divisor
values as I've just told you in the email #2.

All the defines from the patch #2:

+/* CSR Frequency Access Defines*/
+#define CSR_F_20M	20000000
+#define CSR_F_35M	35000000
+#define CSR_F_60M	60000000
+#define CSR_F_100M	100000000
+#define CSR_F_150M	150000000
+#define CSR_F_250M	50000000
+#define CSR_F_300M	300000000


should be moved from linux/stmmac.h to stmicro/stmmac/common.h

In the end, I kindly ask you to try to remove some of not necessary
#ifdef CONFIG_HAVE_CLK  inside the C file.

Indeed stmmac_clk is be null in case of there is not this support.

Also I wonder if stmmac_clk could be renamed as: stmmac_csr_clk.

Pls, resend the patch against net-git so i'll be happy to continue the
review ;-)

Peppe

> 
> Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   10 ++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  124 ++++++++++++++++++++-
>  2 files changed, 130 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 1207400..67b9757 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -22,6 +22,10 @@
>  
>  #define STMMAC_RESOURCE_NAME   "stmmaceth"
>  #define DRV_MODULE_VERSION	"Dec_2011"
> +
> +#ifdef CONFIG_HAVE_CLK
> +#include <linux/clk.h>
> +#endif
>  #include <linux/stmmac.h>
>  #include <linux/phy.h>
>  #include "common.h"
> @@ -81,6 +85,12 @@ struct stmmac_priv {
>  	struct stmmac_counters mmc;
>  	struct dma_features dma_cap;
>  	int hw_cap_support;
> +#ifdef CONFIG_CPU_FREQ
> +	struct notifier_block freq_transition;
> +#endif
> +#ifdef CONFIG_HAVE_CLK
> +	struct clk *stmmac_clk;
> +#endif
>  };
>  
>  extern int phyaddr;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 96fa2da..001b8f3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -35,6 +35,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/ethtool.h>
>  #include <linux/if_ether.h>
> +#include <linux/cpufreq.h>
>  #include <linux/crc32.h>
>  #include <linux/mii.h>
>  #include <linux/if.h>
> @@ -180,6 +181,92 @@ static void print_pkt(unsigned char *buf, int len)
>  /* minimum number of free TX descriptors required to wake up TX process */
>  #define STMMAC_TX_THRESH(x)	(x->dma_tx_size/4)
>  
> +#ifdef CONFIG_CPU_FREQ
> +static inline void stmmac_clk_csr_set(struct stmmac_priv *priv, int clk_rate)
> +{
> +
> +	if ((clk_rate >= CSR_F_20M) && (clk_rate < CSR_F_35M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_20_35M;
> +	else if ((clk_rate >= CSR_F_35M) && (clk_rate < CSR_F_60M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_35_60M;
> +	else if ((clk_rate >= CSR_F_60M) && (clk_rate < CSR_F_100M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_60_100M;
> +	else if ((clk_rate >= CSR_F_100M) && (clk_rate < CSR_F_150M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_100_150M;
> +	else if ((clk_rate >= CSR_F_150M) && (clk_rate < CSR_F_250M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
> +	else if ((clk_rate >= CSR_F_250M) && (clk_rate < CSR_F_300M))
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_250_300M;
> +	else
> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
> +
> +}
> +
> +static int stmmac_cpufreq_transition(struct notifier_block *nb,
> +		unsigned long val, void *data)
> +{
> +	struct stmmac_priv *priv;
> +	u32 clk_rate;
> +
> +	priv = container_of(nb, struct stmmac_priv, freq_transition);
> +
> +	if (val == CPUFREQ_PRECHANGE) {
> +		/* Stop TX/RX DMA */
> +		priv->hw->dma->stop_tx(priv->ioaddr);
> +		priv->hw->dma->stop_rx(priv->ioaddr);
> +
> +	} else if (val == CPUFREQ_POSTCHANGE) {
> +		/* Start DMA Tx/Rx */
> +		priv->hw->dma->start_tx(priv->ioaddr);
> +		priv->hw->dma->start_rx(priv->ioaddr);
> +		priv->hw->dma->enable_dma_transmission(priv->ioaddr);
> +
> +		if (priv->stmmac_clk) {
> +			/*
> +			 * Decide on the MDC clock dynamically based on the
> +			 * csr clock input.
> +			 * This is helpfull in case the cpu frequency is changed
> +			 * on the run using the cpu freq framework, and based
> +			 * on that the bus frequency is also changed.
> +			 * In case the clock framework is not established for an
> +			 * architecture, use the default value that has to be
> +			 * set through the platform.
> +			 */
> +			clk_rate = clk_get_rate(priv->stmmac_clk);
> +			stmmac_clk_csr_set(priv, clk_rate);
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static inline void stmmac_cpufreq_register(struct stmmac_priv *priv)
> +{
> +	priv->freq_transition.notifier_call = stmmac_cpufreq_transition;
> +	cpufreq_register_notifier(&priv->freq_transition,
> +			CPUFREQ_TRANSITION_NOTIFIER);
> +}
> +
> +static inline void stmmac_cpufreq_deregister(struct stmmac_priv *priv)
> +{
> +
> +	cpufreq_unregister_notifier(&priv->freq_transition,
> +			CPUFREQ_TRANSITION_NOTIFIER);
> +}
> +
> +#else
> +
> +static inline void stmmac_cpufreq_register(struct stmmac_priv *priv)
> +{
> +	return 0;
> +}
> +
> +static inline void stmmac_cpufreq_deregister(struct stmmac_priv *priv)
> +{
> +}
> +
> +#endif
> +
>  static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
>  {
>  	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
> @@ -930,10 +1017,14 @@ static int stmmac_open(struct net_device *dev)
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  	int ret;
>  
> +#ifdef CONFIG_HAVE_CLK
> +	if (priv->stmmac_clk)
> +		clk_enable(priv->stmmac_clk);
> +#endif
>  	/* MAC HW device setup */
>  	ret = stmmac_mac_device_setup(dev);
>  	if (ret < 0)
> -		return ret;
> +		goto open_clk_dis;
>  
>  	stmmac_check_ether_addr(priv);
>  
> @@ -949,14 +1040,15 @@ static int stmmac_open(struct net_device *dev)
>  	if (ret < 0) {
>  		pr_debug("%s: MDIO bus (id: %d) registration failed",
>  			 __func__, priv->plat->bus_id);
> -		return ret;
> +		goto open_clk_dis;
>  	}
>  
>  #ifdef CONFIG_STMMAC_TIMER
>  	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
>  	if (unlikely(priv->tm == NULL)) {
>  		pr_err("%s: ERROR: timer memory alloc failed\n", __func__);
> -		return -ENOMEM;
> +		ret = -ENOMEM;
> +		goto open_clk_dis;
>  	}
>  	priv->tm->freq = tmrate;
>  
> @@ -1093,7 +1185,11 @@ open_error:
>  #endif
>  	if (priv->phydev)
>  		phy_disconnect(priv->phydev);
> -
> +open_clk_dis:
> +#ifdef CONFIG_HAVE_CLK
> +	if (priv->stmmac_clk)
> +		clk_disable(priv->stmmac_clk);
> +#endif
>  	return ret;
>  }
>  
> @@ -1145,6 +1241,11 @@ static int stmmac_release(struct net_device *dev)
>  #endif
>  	stmmac_mdio_unregister(dev);
>  
> +#ifdef CONFIG_HAVE_CLK
> +	if (priv->stmmac_clk)
> +		clk_disable(priv->stmmac_clk);
> +#endif
> +
>  	return 0;
>  }
>  
> @@ -1844,6 +1945,16 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>  		goto error;
>  	}
>  
> +#ifdef CONFIG_HAVE_CLK
> +	priv->stmmac_clk = clk_get(device, NULL);
> +	if (IS_ERR(priv->stmmac_clk)) {
> +		ret = PTR_ERR(priv->stmmac_clk);
> +		pr_err("%s: ERROR %i clock get \n", __func__, ret);
> +		goto error;
> +	}
> +#endif
> +	stmmac_cpufreq_register(priv);
> +
>  	DBG(probe, DEBUG, "%s: Scatter/Gather: %s - HW checksums: %s\n",
>  	    ndev->name, (ndev->features & NETIF_F_SG) ? "on" : "off",
>  	    (ndev->features & NETIF_F_IP_CSUM) ? "on" : "off");
> @@ -1875,6 +1986,11 @@ int stmmac_dvr_remove(struct net_device *ndev)
>  	priv->hw->dma->stop_tx(priv->ioaddr);
>  
>  	stmmac_set_mac(priv->ioaddr, false);
> +	stmmac_cpufreq_deregister(priv);
> +#ifdef CONFIG_HAVE_CLK
> +	if (priv->stmmac_clk)
> +		clk_put(priv->stmmac_clk);
> +#endif
>  	netif_carrier_off(ndev);
>  	unregister_netdev(ndev);
>  	free_netdev(ndev);
