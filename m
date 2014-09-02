From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git)] stmmac: fix and review whole driver locking
Date: Tue, 2 Sep 2014 08:05:37 +0200
Message-ID: <54055E31.5080205@st.com>
References: <1409637603-17347-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <bigeasy@linutronix.de>,
	<khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33203 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750752AbaIBGF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 02:05:58 -0400
In-Reply-To: <1409637603-17347-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

as discussed in the mailing list the driver had some known problems
on locking so I tried to collect all the fixes in this small patch
trying to finalize and fix them.

Let me know if you see some other issues and  welcome advice in case of
I missed something else.

On my side, no issue when proving locks so no warning anymore and
no issues while testing the driver.

br
peppe

On 9/2/2014 8:00 AM, Giuseppe Cavallaro wrote:
> This patch is to fix/review the whole lock protection inside the driver.
>
> Proving locks several warning were detected.
>
> The patch reviews the tx lock removing it because the driver
> claims the resource in NAPI context and, as designed, can run
> w/o any own extra lock (so just netif_tx_lock).
> This shows an impact on performances too.
>
> Then the patch removes useless lock in set_filter and resume
> functions.
> It finally fixes the concurrency in eee initialization.
> Prior this patch, the stmmac_eee_init could be called
> in several places as shown below:
>
> stmmac_open		stmmac_resume		   PHY Layer
>      |			   |				|
>      |___stmmac_hw_setup ___|			stmmac_adjust_link
> 	  |						|
> 	  |_________________ stmmac_eee_init ___________|
>
> The patch tries to solve problem just removing the stmmac_eee_init
> call inside the stmmac_hw_setup that is unnecessary. It is sufficient
> to call it in the stmmac_adjust_link to always guarantee that the EEE
> is configured. In fact, after the new link is adjusted then the driver
> can check the EEE capability and then eventually enable it at MAC level.
>
> Always on the adjust link, this patch removes the disable irq when
> not necessary because it should be just called by phy_change.
>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 -
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   28 +++++---------------
>   2 files changed, 7 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 58097c0..e8ebab2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -54,7 +54,6 @@ struct stmmac_priv {
>   	dma_addr_t dma_tx_phy;
>   	int tx_coalesce;
>   	int hwts_tx_en;
> -	spinlock_t tx_lock;
>   	bool tx_path_in_lpi_mode;
>   	struct timer_list txtimer;
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3d3db16..92db429 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -685,14 +685,13 @@ static void stmmac_adjust_link(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
>   	struct phy_device *phydev = priv->phydev;
> -	unsigned long flags;
>   	int new_state = 0;
>   	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
>
>   	if (phydev == NULL)
>   		return;
>
> -	spin_lock_irqsave(&priv->lock, flags);
> +	spin_lock(&priv->lock);
>
>   	if (phydev->link) {
>   		u32 ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
> @@ -760,12 +759,12 @@ static void stmmac_adjust_link(struct net_device *dev)
>   	if (new_state && netif_msg_link(priv))
>   		phy_print_status(phydev);
>
> +	spin_unlock(&priv->lock);
> +
>   	/* At this stage, it could be needed to setup the EEE or adjust some
>   	 * MAC related HW registers.
>   	 */
>   	priv->eee_enabled = stmmac_eee_init(priv);
> -
> -	spin_unlock_irqrestore(&priv->lock, flags);
>   }
>
>   /**
> @@ -1280,8 +1279,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   {
>   	unsigned int txsize = priv->dma_tx_size;
>
> -	spin_lock(&priv->tx_lock);
> -
>   	priv->xstats.tx_clean++;
>
>   	while (priv->dirty_tx != priv->cur_tx) {
> @@ -1359,7 +1356,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   		stmmac_enable_eee_mode(priv);
>   		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
>   	}
> -	spin_unlock(&priv->tx_lock);
>   }
>
>   static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
> @@ -1704,8 +1700,6 @@ static int stmmac_hw_setup(struct net_device *dev)
>   	}
>   	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
>
> -	priv->eee_enabled = stmmac_eee_init(priv);
> -
>   	stmmac_init_tx_coalesce(priv);
>
>   	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
> @@ -1881,6 +1875,8 @@ static int stmmac_release(struct net_device *dev)
>    *  Description : this is the tx entry point of the driver.
>    *  It programs the chain or the ring and supports oversized frames
>    *  and SG feature.
> + *  Transmit resources are claimed in napi context and currency is solved with
> + *  netif_tx_lock so no extra locks are needed.
>    */
>   static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
> @@ -1902,8 +1898,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   		return NETDEV_TX_BUSY;
>   	}
>
> -	spin_lock(&priv->tx_lock);
> -
>   	if (priv->tx_path_in_lpi_mode)
>   		stmmac_disable_eee_mode(priv);
>
> @@ -2020,7 +2014,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>
>   	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
>
> -	spin_unlock(&priv->tx_lock);
>   	return NETDEV_TX_OK;
>
>   dma_map_err:
> @@ -2280,9 +2273,7 @@ static void stmmac_set_rx_mode(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
>
> -	spin_lock(&priv->lock);
>   	priv->hw->mac->set_filter(priv->hw, dev);
> -	spin_unlock(&priv->lock);
>   }
>
>   /**
> @@ -2816,7 +2807,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>   	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
>
>   	spin_lock_init(&priv->lock);
> -	spin_lock_init(&priv->tx_lock);
>
>   	ret = register_netdev(ndev);
>   	if (ret) {
> @@ -2916,6 +2906,8 @@ int stmmac_suspend(struct net_device *ndev)
>
>   	stmmac_clear_descriptors(priv);
>
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
>   	/* Enable Power down mode by programming the PMT regs */
>   	if (device_may_wakeup(priv->device)) {
>   		priv->hw->mac->pmt(priv->hw, priv->wolopts);
> @@ -2926,7 +2918,6 @@ int stmmac_suspend(struct net_device *ndev)
>   		/* Disable clock in case of PWM is off */
>   		clk_disable_unprepare(priv->stmmac_clk);
>   	}
> -	spin_unlock_irqrestore(&priv->lock, flags);
>
>   	priv->oldlink = 0;
>   	priv->speed = 0;
> @@ -2937,13 +2928,10 @@ int stmmac_suspend(struct net_device *ndev)
>   int stmmac_resume(struct net_device *ndev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(ndev);
> -	unsigned long flags;
>
>   	if (!netif_running(ndev))
>   		return 0;
>
> -	spin_lock_irqsave(&priv->lock, flags);
> -
>   	/* Power Down bit, into the PM register, is cleared
>   	 * automatically as soon as a magic packet or a Wake-up frame
>   	 * is received. Anyway, it's better to manually clear
> @@ -2970,8 +2958,6 @@ int stmmac_resume(struct net_device *ndev)
>
>   	netif_start_queue(ndev);
>
> -	spin_unlock_irqrestore(&priv->lock, flags);
> -
>   	if (priv->phydev)
>   		phy_start(priv->phydev);
>
>
