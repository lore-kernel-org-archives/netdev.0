From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 07/16] net: fec: set cbd_sc without relying on
 previous value
Date: Fri, 4 Mar 2016 09:29:52 +0000
Message-ID: <VI1PR0401MB18552747CE0E0FF2C7E0E4C5FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-8-git-send-email-troy.kisky@boundarydevices.com>
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
In-Reply-To: <1456360619-24390-8-git-send-email-troy.kisky@boundarydevices.com>
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

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 07/16] net: fec: set cbd_sc without relying on
> previous value
> 
> Relying on the wrap bit to stay valid once initialized when the controller also
> writes to this byte seems undesirable since we can easily know what the value
> should be.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 38 +++++++++----------------------
>  1 file changed, 11 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 791f385..6ceb5f9 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -340,9 +340,8 @@ fec_enet_txq_submit_frag_skb(struct
> fec_enet_priv_tx_q *txq,
>  		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
>  		ebdp = (struct bufdesc_ex *)bdp;
> 
> -		status = fec16_to_cpu(bdp->cbd_sc);
> -		status &= ~BD_ENET_TX_STATS;
> -		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
> +		status = BD_ENET_TX_TC | BD_ENET_TX_READY |
> +				((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
>  		frag_len = skb_shinfo(skb)->frags[frag].size;
> 
>  		/* Handle the last BD specially */
> @@ -436,8 +435,6 @@ static int fec_enet_txq_submit_skb(struct
> fec_enet_priv_tx_q *txq,
>  	/* Fill in a Tx ring entry */
>  	bdp = txq->bd.cur;
>  	last_bdp = bdp;
> -	status = fec16_to_cpu(bdp->cbd_sc);
> -	status &= ~BD_ENET_TX_STATS;
> 
>  	/* Set buffer length and buffer pointer */
>  	bufaddr = skb->data;
> @@ -462,6 +459,8 @@ static int fec_enet_txq_submit_skb(struct
> fec_enet_priv_tx_q *txq,
>  		return NETDEV_TX_OK;
>  	}
> 
> +	status = BD_ENET_TX_TC | BD_ENET_TX_READY |
> +			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
>  	if (nr_frags) {
>  		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
>  		if (IS_ERR(last_bdp)) {
> @@ -512,7 +511,6 @@ static int fec_enet_txq_submit_skb(struct
> fec_enet_priv_tx_q *txq,
>  	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
>  	 * it's the last BD of the frame, and to put the CRC on the end.
>  	 */
> -	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);

This is completely error.  We have to prepare all BDs for frag skb, and then enable "READY" and "TC" bit for the first BD, otherwise uDMA copy un-correct data to fifo.

<snip>
