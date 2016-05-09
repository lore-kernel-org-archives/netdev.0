From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net 1/1] net: fec: update dirty_tx even if no skb
Date: Mon, 9 May 2016 02:00:37 +0000
Message-ID: <VI1PR0401MB18554C917BB5BEA7807D9DFAFF700@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1461290434-18462-1-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18558325A80D252D2EC64A7BFF6F0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <0288eea6-9669-d763-4bd8-9438ce0c1f94@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"gerg@uclinux.org" <gerg@uclinux.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"holgerschurig@gmail.com" <holgerschurig@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0076.outbound.protection.outlook.com ([157.56.112.76]:50144
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750910AbcEICAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 22:00:42 -0400
In-Reply-To: <0288eea6-9669-d763-4bd8-9438ce0c1f94@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Sunday, May 08, 2016 2:57 AM
> To: Fugang Duan <fugang.duan@nxp.com>; netdev@vger.kernel.org;
> davem@davemloft.net; lznuaa@gmail.com
> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
> kernel@lists.infradead.org; johannes@sipsolutions.net;
> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> arnd@arndb.de; holgerschurig@gmail.com
> Subject: Re: [PATCH net 1/1] net: fec: update dirty_tx even if no skb
> 
> On 4/21/2016 10:59 PM, Fugang Duan wrote:
> > From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Friday, April
> > 22, 2016 10:01 AM
> >> To: netdev@vger.kernel.org; davem@davemloft.net; Fugang Duan
> >> <fugang.duan@nxp.com>; lznuaa@gmail.com
> >> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
> >> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
> >> kernel@lists.infradead.org; johannes@sipsolutions.net;
> >> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> >> arnd@arndb.de; holgerschurig@gmail.com; Troy Kisky
> >> <troy.kisky@boundarydevices.com>
> >> Subject: [PATCH net 1/1] net: fec: update dirty_tx even if no skb
> >>
> >> If dirty_tx isn't updated, then dma_unmap_single will be called twice.
> >>
> >> This fixes a
> >> [   58.420980] ------------[ cut here ]------------
> >> [   58.425667] WARNING: CPU: 0 PID: 377 at /home/schurig/d/mkarm/linux-
> >> 4.5/lib/dma-debug.c:1096 check_unmap+0x9d0/0xab8()
> >> [   58.436405] fec 2188000.ethernet: DMA-API: device driver tries to free
> DMA
> >> memory it has not allocated [device address=0x0000000000000000]
> >> [size=66 bytes]
> >>
> >> encountered by Holger
> >>
> >> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> >> Tested-by: <holgerschurig@gmail.com>
> >> ---
> >>  drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
> >>  1 file changed, 3 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> >> b/drivers/net/ethernet/freescale/fec_main.c
> >> index 08243c2..b71654c 100644
> >> --- a/drivers/net/ethernet/freescale/fec_main.c
> >> +++ b/drivers/net/ethernet/freescale/fec_main.c
> >> @@ -1197,10 +1197,8 @@ fec_enet_tx_queue(struct net_device *ndev,
> u16
> >> queue_id)
> >>  					 fec16_to_cpu(bdp->cbd_datlen),
> >>  					 DMA_TO_DEVICE);
> >>  		bdp->cbd_bufaddr = cpu_to_fec32(0);
> >> -		if (!skb) {
> >> -			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
> >> -			continue;
> >> -		}
> >> +		if (!skb)
> >> +			goto skb_done;
> >>
> >>  		/* Check for errors. */
> >>  		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC | @@ -1239,7
> >> +1237,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
> >>
> >>  		/* Free the sk buffer associated with this last transmit */
> >>  		dev_kfree_skb_any(skb);
> >> -
> >> +skb_done:
> >>  		/* Make sure the update to bdp and tx_skbuff are performed
> >>  		 * before dirty_tx
> >>  		 */
> >> --
> >> 2.5.0
> >
> > The patch is fine for me.
> > Can you review below patch that also fix the issue. It can take much
> > effort due to less rmb() and READ_ONCE() operation that is very
> > sensitive for duplex Gbps test for i.MX6SX/i.MX7d SOC. (i.MX6SX can
> > reach at 1.4Gbps, i.MX7D can reach at 1.8Gbps.)
> >
> 
> 
> Am I supposed to do anything else to get this patch into net ?

I will ack your patch that is fine into net tree.
