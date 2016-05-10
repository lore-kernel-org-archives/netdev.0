From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Tue, 10 May 2016 20:32:49 +0200
Message-ID: <57322951.3040109@gmx.de>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
 <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
 <20160428.171120.2028974436439452264.davem@davemloft.net>
 <HE1PR0501MB2026E62285B397A5C7CC9705CD790@HE1PR0501MB2026.eurprd05.prod.outlook.com>
 <572736D6.5030902@marvell.com>
 <HE1PR0501MB20265121CBDB2D48F66D408CCD7F0@HE1PR0501MB2026.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Noam Camus <noamca@mellanox.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	Tal Zilcer <talz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Elad Kanfi <eladkan@mellanox.com>,
	Lino Sanfilippo <lsanfil@marvell.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <HE1PR0501MB20265121CBDB2D48F66D408CCD7F0@HE1PR0501MB2026.eurprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Elad,

On 08.05.2016 15:44, Elad Kanfi wrote:

>   
> After reviewing the code and your suggestion, it seems that we can do without the flag tx_packet_sent and therefor the first issue becomes irrelevant.
> The indication that a packet was sent is (tx_skb != NULL) , and the sequence will be:
> 
> CPU A:
> 1. tx_skb = skb
> 2. wmb() /* make sure tx_skb reaches the RAM before the HW is informed and the IRQ is fired */
> 3. nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl.value); /* send frame */
> 
> CPU B:
> 1. read tx_skb 
> 2. if( tx_skb != NULL ) handle tx_skb
> 3. tx_skb = NULL 
> 
> 

Ok, without the tx_packet_sent flag the code becomes simpler. But it
does not mean that we can toss the smp_rmb in the irq handler
completely. We still have to use a read barrier there to ensure that we
see the most recent value of tx_skb. E.g like this:

if (priv->tx_skb != NULL ) {
	smp_rmb()
	/ * handle tx_skb */
}

With both barriers in place the code should work as expected.

Regards,
Lino
