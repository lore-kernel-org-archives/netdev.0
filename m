From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 04/16] net: fec: reduce interrupts
Date: Wed, 2 Mar 2016 09:12:27 -0700
Message-ID: <56D710EB.5000201@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-5-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18558A7D0A57FA8EDBAD5EABFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
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
To: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34346 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323AbcCBQM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:12:29 -0500
Received: by mail-pf0-f175.google.com with SMTP id 4so57905246pfd.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 08:12:29 -0800 (PST)
In-Reply-To: <VI1PR0401MB18558A7D0A57FA8EDBAD5EABFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2016 8:13 AM, Fugang Duan wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
>> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
>> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
>> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
>> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
>> johannes@sipsolutions.net; stillcompiling@gmail.com;
>> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
>> <troy.kisky@boundarydevices.com>
>> Subject: [PATCH net-next V2 04/16] net: fec: reduce interrupts
>>
>> By clearing the NAPI interrupts in the NAPI routine and not in the interrupt
>> handler, we can reduce the number of interrupts. We also don't need any
>> status variables as the registers are still valid.
>>
>> Also, notice that if budget pkts are received, the next call to fec_enet_rx_napi
>> will now continue to receive the previously pending packets.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  drivers/net/ethernet/freescale/fec.h      |   6 +-
>>  drivers/net/ethernet/freescale/fec_main.c | 127 ++++++++++++----------------
>> --
>>  2 files changed, 50 insertions(+), 83 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.h
>> b/drivers/net/ethernet/freescale/fec.h
>> index 195122e..001200b 100644
>> --- a/drivers/net/ethernet/freescale/fec.h
>> +++ b/drivers/net/ethernet/freescale/fec.h
>> @@ -505,11 +505,7 @@ struct fec_enet_private {
>>
>>  	unsigned int total_tx_ring_size;
>>  	unsigned int total_rx_ring_size;
>> -
>> -	unsigned long work_tx;
>> -	unsigned long work_rx;
>> -	unsigned long work_ts;
>> -	unsigned long work_mdio;
>> +	uint	events;
>>
>>  	struct	platform_device *pdev;
>>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index c517194..4a218b9 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -70,8 +70,6 @@ static void fec_enet_itr_coal_init(struct net_device
>> *ndev);
>>
>>  #define DRIVER_NAME	"fec"
>>
>> -#define FEC_ENET_GET_QUQUE(_x) ((_x == 0) ? 1 : ((_x == 1) ? 2 : 0))
>> -
>>  /* Pause frame feild and FIFO threshold */
>>  #define FEC_ENET_FCE	(1 << 5)
>>  #define FEC_ENET_RSEM_V	0x84
>> @@ -1257,21 +1255,6 @@ static void fec_txq(struct net_device *ndev, struct
>> fec_enet_private *fep,
>>  		writel(0, txq->bd.reg_desc_active);
>>  }
>>
>> -static void
>> -fec_enet_tx(struct net_device *ndev)
>> -{
>> -	struct fec_enet_private *fep = netdev_priv(ndev);
>> -	struct fec_enet_priv_tx_q *txq;
>> -	u16 queue_id;
>> -	/* First process class A queue, then Class B and Best Effort queue */
>> -	for_each_set_bit(queue_id, &fep->work_tx, FEC_ENET_MAX_TX_QS)
>> {
>> -		clear_bit(queue_id, &fep->work_tx);
>> -		txq = fep->tx_queue[FEC_ENET_GET_QUQUE(queue_id)];
>> -		fec_txq(ndev, fep, txq);
>> -	}
>> -	return;
>> -}
>> -
>>  static int
>>  fec_enet_new_rxbdp(struct net_device *ndev, struct bufdesc *bdp, struct
>> sk_buff *skb)  { @@ -1504,92 +1487,80 @@ rx_processing_done:
>>  	return pkt_received;
>>  }
>>
>> -static int
>> -fec_enet_rx(struct net_device *ndev, int budget) -{
>> -	int     pkt_received = 0;
>> -	u16	queue_id;
>> -	struct fec_enet_private *fep = netdev_priv(ndev);
>> -	struct fec_enet_priv_rx_q *rxq;
>> -
>> -	for_each_set_bit(queue_id, &fep->work_rx, FEC_ENET_MAX_RX_QS)
>> {
>> -		clear_bit(queue_id, &fep->work_rx);
>> -		rxq = fep->rx_queue[FEC_ENET_GET_QUQUE(queue_id)];
>> -		pkt_received += fec_rxq(ndev, fep, rxq, budget -
>> pkt_received);
>> -	}
>> -	return pkt_received;
>> -}
>> -
>> -static bool
>> -fec_enet_collect_events(struct fec_enet_private *fep, uint int_events) -{
>> -	if (int_events == 0)
>> -		return false;
>> -
>> -	if (int_events & FEC_ENET_RXF_0)
>> -		fep->work_rx |= (1 << 2);
>> -	if (int_events & FEC_ENET_RXF_1)
>> -		fep->work_rx |= (1 << 0);
>> -	if (int_events & FEC_ENET_RXF_2)
>> -		fep->work_rx |= (1 << 1);
>> -
>> -	if (int_events & FEC_ENET_TXF_0)
>> -		fep->work_tx |= (1 << 2);
>> -	if (int_events & FEC_ENET_TXF_1)
>> -		fep->work_tx |= (1 << 0);
>> -	if (int_events & FEC_ENET_TXF_2)
>> -		fep->work_tx |= (1 << 1);
>> -
>> -	return true;
>> -}
>> -
>>  static irqreturn_t
>>  fec_enet_interrupt(int irq, void *dev_id)  {
>>  	struct net_device *ndev = dev_id;
>>  	struct fec_enet_private *fep = netdev_priv(ndev);
>> -	uint int_events;
>> -	irqreturn_t ret = IRQ_NONE;
>> +	uint eir = readl(fep->hwp + FEC_IEVENT);
>> +	uint int_events = eir & readl(fep->hwp + FEC_IMASK);
>>
>> -	int_events = readl(fep->hwp + FEC_IEVENT);
>> -	writel(int_events, fep->hwp + FEC_IEVENT);
>> -	fec_enet_collect_events(fep, int_events);
>> -
>> -	if ((fep->work_tx || fep->work_rx) && fep->link) {
>> -		ret = IRQ_HANDLED;
>> +	if (!int_events)
>> +		return IRQ_NONE;
>>
>> +	if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
>>  		if (napi_schedule_prep(&fep->napi)) {
>>  			/* Disable the NAPI interrupts */
>>  			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
>>  			__napi_schedule(&fep->napi);
>> +			int_events &= ~(FEC_ENET_RXF | FEC_ENET_TXF);
>> +			if (!int_events)
>> +				return IRQ_HANDLED;
>> +		} else {
>> +			fep->events |= int_events;
>> +			pr_info("%s: couldn't schedule NAPI\n", __func__);
>>  		}
>>  	}
>>
>> -	if (int_events & FEC_ENET_MII) {
>> -		ret = IRQ_HANDLED;
>> +	writel(int_events, fep->hwp + FEC_IEVENT);
>> +	if (int_events & FEC_ENET_MII)
>>  		complete(&fep->mdio_done);
>> -	}
>>
>> -	if (fep->ptp_clock)
>> +	if ((int_events & FEC_ENET_TS_TIMER) && fep->ptp_clock)
>>  		fec_ptp_check_pps_event(fep);
>> -
> This is error in here.  FEC compare timer event is not TS timer.
> 
> 


So when should fec_ptp_check_pps_event be called ? On every interrupt ?

If napi is active, it is going to be delayed for a very long time.
Should it be moved to the napi routine?
