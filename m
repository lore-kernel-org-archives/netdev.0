From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 07/16] net: fec: set cbd_sc without relying on
 previous value
Date: Sat, 5 Mar 2016 23:55:05 +0000
Message-ID: <HE1PR0401MB18493D58257B539E298B3910FFBF0@HE1PR0401MB1849.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-8-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18552747CE0E0FF2C7E0E4C5FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <56D9B2E7.6050000@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0076.outbound.protection.outlook.com ([157.55.234.76]:35088
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751099AbcCEXzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 18:55:11 -0500
In-Reply-To: <56D9B2E7.6050000@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Saturday, March 05, 2016 12:08 AM
> To: Fugang Duan <fugang.duan@nxp.com>; netdev@vger.kernel.org;
> davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de
> Subject: Re: [PATCH net-next V2 07/16] net: fec: set cbd_sc without relying on
> previous value
> 
> On 3/4/2016 2:29 AM, Fugang Duan wrote:
> > From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday,
> > February 25, 2016 8:37 AM
> >> To: netdev@vger.kernel.org; davem@davemloft.net;
> b38611@freescale.com
> >> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de;
> >> andrew@lunn.ch; tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> >> kernel@lists.infradead.org; laci@boundarydevices.com;
> >> shawnguo@kernel.org; johannes@sipsolutions.net;
> >> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> >> arnd@arndb.de; Troy Kisky <troy.kisky@boundarydevices.com>
> >> Subject: [PATCH net-next V2 07/16] net: fec: set cbd_sc without
> >> relying on previous value
> >>
> >> Relying on the wrap bit to stay valid once initialized when the
> >> controller also writes to this byte seems undesirable since we can
> >> easily know what the value should be.
> >>
> >> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> >> ---
> >>  drivers/net/ethernet/freescale/fec_main.c | 38
> >> +++++++++----------------------
> >>  1 file changed, 11 insertions(+), 27 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> >> b/drivers/net/ethernet/freescale/fec_main.c
> >> index 791f385..6ceb5f9 100644
> >> --- a/drivers/net/ethernet/freescale/fec_main.c
> >> +++ b/drivers/net/ethernet/freescale/fec_main.c
> >> @@ -340,9 +340,8 @@ fec_enet_txq_submit_frag_skb(struct
> >> fec_enet_priv_tx_q *txq,
> >>  		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
> >>  		ebdp = (struct bufdesc_ex *)bdp;
> >>
> >> -		status = fec16_to_cpu(bdp->cbd_sc);
> >> -		status &= ~BD_ENET_TX_STATS;
> >> -		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
> >> +		status = BD_ENET_TX_TC | BD_ENET_TX_READY |
> >> +				((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
> >>  		frag_len = skb_shinfo(skb)->frags[frag].size;
> >>
> >>  		/* Handle the last BD specially */ @@ -436,8 +435,6 @@ static
> int
> >> fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
> >>  	/* Fill in a Tx ring entry */
> >>  	bdp = txq->bd.cur;
> >>  	last_bdp = bdp;
> >> -	status = fec16_to_cpu(bdp->cbd_sc);
> >> -	status &= ~BD_ENET_TX_STATS;
> >>
> >>  	/* Set buffer length and buffer pointer */
> >>  	bufaddr = skb->data;
> >> @@ -462,6 +459,8 @@ static int fec_enet_txq_submit_skb(struct
> >> fec_enet_priv_tx_q *txq,
> >>  		return NETDEV_TX_OK;
> >>  	}
> >>
> >> +	status = BD_ENET_TX_TC | BD_ENET_TX_READY |
> >> +			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
> >>  	if (nr_frags) {
> >>  		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
> >>  		if (IS_ERR(last_bdp)) {
> >> @@ -512,7 +511,6 @@ static int fec_enet_txq_submit_skb(struct
> >> fec_enet_priv_tx_q *txq,
> >>  	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
> >>  	 * it's the last BD of the frame, and to put the CRC on the end.
> >>  	 */
> >> -	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
> >
> > This is completely error.  We have to prepare all BDs for frag skb, and then
> enable "READY" and "TC" bit for the first BD, otherwise uDMA copy un-correct
> data to fifo.
> >
> 
> 
> 
> 
> I don't follow. Please read patch again.
> 
Understand, sorry, I take one mistake.  The patch is fine for me.
