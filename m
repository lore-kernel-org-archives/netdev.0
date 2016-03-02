From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 03/16] net: fec: pass txq to fec_enet_tx_queue
 instead of queue_id
Date: Wed, 2 Mar 2016 15:16:25 +0000
Message-ID: <VI1PR0401MB18555F637F86F38461B3442BFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-4-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
 "andrew@lunn.ch" <andrew@lunn.ch>,
 "stillcompiling@gmail.com" <stillcompiling@gmail.com>,
 "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "sergei.shtylyov@cogentembedded.com" <sergei.shtylyov@cogentembedded.com>,
 "laci@boundarydevices.com" <laci@boundarydevices.com>,
 "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
 "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
 "shawnguo@kernel.org" <shawnguo@kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "tremyfr@gmail.com" <tremyfr@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "b38611@freescale.com" <b38611@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456360619-24390-4-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
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

From: Troy Kisky <troy.kisky@boundarydevices.com>  Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 03/16] net: fec: pass txq to fec_enet_tx_queue
> instead of queue_id
> 
> queue_id is the qid member of struct bufdesc_prop.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 9619b9e..c517194 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1156,25 +1156,18 @@ fec_enet_hwtstamp(struct fec_enet_private *fep,
> unsigned ts,
>  	hwtstamps->hwtstamp = ns_to_ktime(ns);  }
> 
> -static void
> -fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
> +static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
> +		    struct fec_enet_priv_tx_q *txq)
>  {
> -	struct	fec_enet_private *fep;
>  	struct bufdesc *bdp;
>  	unsigned short status;
>  	struct	sk_buff	*skb;
> -	struct fec_enet_priv_tx_q *txq;
>  	struct netdev_queue *nq;
>  	int	index = 0;
>  	int	entries_free;
> 
> -	fep = netdev_priv(ndev);
> -
> -	queue_id = FEC_ENET_GET_QUQUE(queue_id);
> -
> -	txq = fep->tx_queue[queue_id];
>  	/* get next bdp of dirty_tx */
> -	nq = netdev_get_tx_queue(ndev, queue_id);
> +	nq = netdev_get_tx_queue(ndev, txq->bd.qid);
>  	bdp = txq->dirty_tx;
> 
>  	/* get next bdp of dirty_tx */
> @@ -1268,11 +1261,13 @@ static void
>  fec_enet_tx(struct net_device *ndev)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
> +	struct fec_enet_priv_tx_q *txq;
>  	u16 queue_id;
>  	/* First process class A queue, then Class B and Best Effort queue */
>  	for_each_set_bit(queue_id, &fep->work_tx, FEC_ENET_MAX_TX_QS)
> {
>  		clear_bit(queue_id, &fep->work_tx);
> -		fec_enet_tx_queue(ndev, queue_id);
> +		txq = fep->tx_queue[FEC_ENET_GET_QUQUE(queue_id)];
> +		fec_txq(ndev, fep, txq);
>  	}
>  	return;
>  }
> --
> 2.5.0

The patch should merge with patch#1.
