From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Wed, 29 Mar 2017 07:52:33 -0700
Message-ID: <1490799153.24891.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Elad Kanfi <eladkan@mellanox.com>,
        Noam Camus <noamca@mellanox.com>, linux-kernel@vger.kernel.org,
        linux-snps-arc@lists.infradead.org
To: Vlad Zakharov <Vladislav.Zakharov@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-03-29 at 13:41 +0300, Vlad Zakharov wrote:
> After a new NAPI_STATE_MISSED state was added to NAPI we can get into
> this state and in such case we have to reschedule NAPI as some work is
> still pending and we have to process it. napi_complete_done() function
> returns false if we have to reschedule something (e.g. in case we were
> in MISSED state) as current polling have not been completed yet.
> 
> nps_enet driver hasn't been verifying the return value of
> napi_complete_done() and has been forcibly enabling interrupts. That is
> not correct as we should not enable interrupts before we have processed
> all scheduled work. As a result we were getting trapped in interrupt
> hanlder chain as we had never been able to disabale ethernet
> interrupts again.
> 
> So this patch makes nps_enet_poll() func verify return value of
> napi_complete_done() and enable interrupts only in case all scheduled
> work has been completed.
> 
> Signed-off-by: Vlad Zakharov <vzakhar@synopsys.com>
> ---
>  drivers/net/ethernet/ezchip/nps_enet.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
> index 992ebe9..f819843 100644
> --- a/drivers/net/ethernet/ezchip/nps_enet.c
> +++ b/drivers/net/ethernet/ezchip/nps_enet.c
> @@ -189,11 +189,9 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
>  
>  	nps_enet_tx_handler(ndev);
>  	work_done = nps_enet_rx_handler(ndev);
> -	if (work_done < budget) {
> +	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
>  		u32 buf_int_enable_value = 0;
>  
> -		napi_complete_done(napi, work_done);
> -
>  		/* set tx_done and rx_rdy bits */
>  		buf_int_enable_value |= NPS_ENET_ENABLE << RX_RDY_SHIFT;
>  		buf_int_enable_value |= NPS_ENET_ENABLE << TX_DONE_SHIFT;

Seems fine, but looking at this driver, it looks it has some races,
trying to be a bit too smart.

nps_enet_irq_handler() really should be simpler, or the risk of missing
an interrupt might be high.

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 992ebe973d25bfbccff7b5c42dc1801ea41fc9ea..03885ac0c0f845805eadb4659302b5c11bb250f6 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -233,14 +233,11 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	u32 rx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
-	u32 rx_ctrl_cr = (rx_ctrl_value & RX_CTL_CR_MASK) >> RX_CTL_CR_SHIFT;
 
-	if (nps_enet_is_tx_pending(priv) || rx_ctrl_cr)
-		if (likely(napi_schedule_prep(&priv->napi))) {
-			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
-			__napi_schedule(&priv->napi);
-		}
+	if (likely(napi_schedule_prep(&priv->napi))) {
+		nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
+		__napi_schedule(&priv->napi);
+	}
 
 	return IRQ_HANDLED;
 }
