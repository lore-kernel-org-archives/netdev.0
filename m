From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [Patch net-next 4/4] net: fec: Workaround for imx6sx enet tx
 hang when enable three queues
Date: Tue, 16 Sep 2014 08:52:06 +0800
Message-ID: <20140916005204.GA23482@dragon>
References: <1410801177-15872-1-git-send-email-Frank.Li@freescale.com>
 <1410801177-15872-5-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, netdev@vger.kernel.org, b38611@freescale.com,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: <Frank.Li@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1410801177-15872-5-git-send-email-Frank.Li@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2014 at 01:12:57AM +0800, Frank.Li@freescale.com wrote:
> From: Fugang Duan <B38611@freescale.com>
> 
> When enable three queues on imx6sx enet, and then do tx performance
> test with iperf tool, after some time running, tx hang.
> 
> Found that:
> 	If uDMA is running, software set TDAR may cause tx hang.
> 	If uDMA is in idle, software set TDAR don't cause tx hang.
> 
> There is a TDAR race condition for mutliQ when the software sets TDAR
> and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
> This will cause the udma_tx and udma_tx_arbiter state machines to hang.
> The issue exist at i.MX6SX enet IP.
> 
> So, the Workaround is checking TDAR status four time, if TDAR cleared by
> hardware and then write TDAR, otherwise don't set TDAR.
> 
> The patch is only one Workaround for the issue TKT210582.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 524ddbe..452e576 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -111,6 +111,13 @@ static void fec_enet_itr_coal_init(struct net_device *ndev);
>   *   independent rings
>   */
>  #define FEC_QUIRK_HAS_AVB		(1 << 8)
> +/*
> + * There is a TDAR race condition for mutliQ when the software sets TDAR
> + * and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
> + * This will cause the udma_tx and udma_tx_arbiter state machines to hang.
> + * The issue exist at i.MX6SX enet IP.
> + */
> +#define FEC_QUIRK_TKT210582		(1 << 9)

I think TKTxxx number is used by Freescale design team to track issues
internally, and there should be a corresponding errata number like
ERRxxx which should be accessible by external people in errata document?

Shawn

>  
>  static struct platform_device_id fec_devtype[] = {
>  	{
> @@ -139,7 +146,7 @@ static struct platform_device_id fec_devtype[] = {
>  		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
>  				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
>  				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358 |
> -				FEC_QUIRK_HAS_AVB,
> +				FEC_QUIRK_HAS_AVB | FEC_QUIRK_TKT210582,
>  	}, {
>  		/* sentinel */
>  	}
> @@ -709,6 +716,8 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
>  	struct tso_t tso;
>  	unsigned int index = 0;
>  	int ret;
> +	const struct platform_device_id *id_entry =
> +				platform_get_device_id(fep->pdev);
>  
>  	if (tso_count_descs(skb) >= fec_enet_get_free_txdesc_num(fep, txq)) {
>  		dev_kfree_skb_any(skb);
> @@ -770,7 +779,12 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
>  	txq->cur_tx = bdp;
>  
>  	/* Trigger transmission start */
> -	writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
> +	if (!(id_entry->driver_data & FEC_QUIRK_TKT210582) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)))
> +		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
>  
>  	return 0;
>  
> -- 
> 1.9.1
> 
