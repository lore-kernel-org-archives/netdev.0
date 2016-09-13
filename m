From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: mvneta: add xmit_more support
Date: Tue, 13 Sep 2016 07:33:02 -0700
Message-ID: <1473777182.18970.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473750006-21199-1-git-send-email-mw@semihalf.com>
         <1473750006-21199-2-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, davem@davemloft.net,
        linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
        andrew@lunn.ch, jason@lakedaemon.net,
        thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        alior@marvell.com, simon.guinot@sequanux.org, nitroshift@yahoo.com,
        jaz@semihalf.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473750006-21199-2-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-13 at 09:00 +0200, Marcin Wojtas wrote:
> From: Simon Guinot <simon.guinot@sequanux.org>
> 
> Basing on xmit_more flag of the skb, TX descriptors can be concatenated
> before flushing. This commit delay Tx descriptor flush if the queue is
> running and if there is more skb's to send.
> 
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index d41c28d..b9dccea 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -512,6 +512,7 @@ struct mvneta_tx_queue {
>  	 * descriptor ring
>  	 */
>  	int count;
> +	int pending;
>  	int tx_stop_threshold;
>  	int tx_wake_threshold;
>  
> @@ -802,8 +803,9 @@ static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
>  	/* Only 255 descriptors can be added at once ; Assume caller
>  	 * process TX desriptors in quanta less than 256
>  	 */

Hi Marcin

Well, given the above comment, and fact that MVNETA_MAX_TXD == 532, it
looks like you might add a bug if more than 256 skb are given to your
ndo_start_xmit() with skb->xmit_more = 1

I therefore suggest you make sure it does not happen.

txq->pending += frags;
if (!skb->xmit_more ||
    txq->pending > 256 - MVNETA_MAX_SKB_DESCS ||
    netif_xmit_stopped(nq))
	mvneta_txq_pend_desc_add(pp, txq)
