From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 6/7] can: m_can: update to support CAN FD features
Date: Thu, 30 Oct 2014 10:42:29 +0800
Message-ID: <20141030024226.GA29572@shlinux1.ap.freescale.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
 <1414579527-31100-6-git-send-email-b29396@freescale.com>
 <54513E38.4020703@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <mkl@pengutronix.de>,
	<wg@grandegger.com>, <varkabhadram@gmail.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54513E38.4020703@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 08:21:28PM +0100, Oliver Hartkopp wrote:
> Hello Dong,
> 
> thanks for your update to support CAN FD with the 3.0.x M_CAN IP core.
> 
> AFAIK from the last CAN in Automation (CiA) Plugfest which took place in
> Nuremberg yesterday, there are two more IP cores on the way:
> 
> v3.0.1 / v3.0.2 (the current spec from the Bosch website)
> 
> v3.1.0 which will support per-frame CAN/CANFD switching in the tx path
> (the FDF/(former)EDL bit and the BRS bit appear in the TX buffer element at
> the bit position you know from reading the RX FIFO element)
> 
> v3.2.0 which will support the final(?) ISO specification with a bitstuffing
> counter before the CRC in the frame on the wire.
> 

Sounds good.

> So first I would suggest to check the core release register (CREL) to be
> version 3.0.x and quit the driver initialization if it doesn't fit this
> version. I would suggest to provide a separate patch for that check. What
> about printing the core release version into the kernel log at driver
> initialization time?
> 

One question is that if v3.1.0 and v3.2.0 will be backward compatible with
v3.0.1, if yes, how about let the driver still work for them instead of
simply quit?
And then we can add new features according new released IP version.

> Regarding the CAN FD support in this patch I have some remarks in the text ...
> 
> On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> 
> >  /* Rx Buffer Element */
> > +/* R0 */
> >  #define RX_BUF_ESI		BIT(31)
> >  #define RX_BUF_XTD		BIT(30)
> >  #define RX_BUF_RTR		BIT(29)
> > +/* R1 */
> > +#define RX_BUF_ANMF		BIT(31)
> > +#define RX_BUF_EDL		BIT(21)
> > +#define RX_BUF_BRS		BIT(20)
> >  
> >  /* Tx Buffer Element */
> > +/* R0 */
> >  #define TX_BUF_XTD		BIT(30)
> >  #define TX_BUF_RTR		BIT(29)
> >  
> > @@ -327,11 +357,12 @@ static inline void m_can_disable_all_interrupts(const struct m_can_priv *priv)
> >  	m_can_write(priv, M_CAN_ILE, 0x0);
> >  }
> >  
> > -static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
> > +static void m_can_read_fifo(const struct net_device *dev, struct canfd_frame *cf,
> >  			    u32 rxfs)
> >  {
> >  	struct m_can_priv *priv = netdev_priv(dev);
> >  	u32 id, fgi;
> > +	int i;
> >  
> >  	/* calculate the fifo get index for where to read data */
> >  	fgi = (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
> > @@ -341,15 +372,23 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
> >  	else
> >  		cf->can_id = (id >> 18) & CAN_SFF_MASK;
> >  
> > +	if (id & RX_BUF_ESI) {
> > +		cf->flags |= CANFD_ESI;
> > +		netdev_dbg(dev, "ESI Error\n");
> > +	}
> > +
> >  	if (id & RX_BUF_RTR) {
> >  		cf->can_id |= CAN_RTR_FLAG;
> 
> When RX_BUF_EDL is set you should not check for RX_BUF_RTR as RTR is not
> allowed for CAN FD.
> 

Right, will change it.

> >  	} else {
> >  		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> > -		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
> > -		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
> > -							 M_CAN_FIFO_DATA(0));
> > -		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
> > -							 M_CAN_FIFO_DATA(1));
> > +		cf->len = can_dlc2len(get_canfd_dlc((id >> 16) & 0x0F));
> > +
> > +		if (id & RX_BUF_BRS)
> > +			cf->flags |= CANFD_BRS;
> > +
> > +		for (i = 0; i < cf->len; i += 4)
> > +			*(u32 *)(cf->data + i) =
> > +				m_can_fifo_read(priv, fgi, M_CAN_FIFO_DATA(i / 4));
> >  	}
> >  
> >  	/* acknowledge rx fifo 0 */
> > @@ -361,7 +400,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
> >  	struct m_can_priv *priv = netdev_priv(dev);
> >  	struct net_device_stats *stats = &dev->stats;
> >  	struct sk_buff *skb;
> > -	struct can_frame *frame;
> > +	struct canfd_frame *frame;
> >  	u32 pkts = 0;
> >  	u32 rxfs;
> >  
> > @@ -375,7 +414,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
> >  		if (rxfs & RXFS_RFL)
> >  			netdev_warn(dev, "Rx FIFO 0 Message Lost\n");
> >  
> > -		skb = alloc_can_skb(dev, &frame);
> > +		skb = alloc_canfd_skb(dev, &frame);
> 
> You are *always* allocating CAN FD frames now?
> 

Yes, currently it is.
The test seemed ok using CAN FD frames even receive normal frame.

The issue i know is that candump seemed can not recognize remote frame reported
by the driver.
Not sure if it's caused by canfd_frame used.
Will test and check.

> Depending on RX_BUF_EDL in the RX FIFO message you should create a CAN or CAN
> FD frame.
> 
> Of course you can use the struct canfd_frame in m_can_read_fifo() as the
> layout of the struct can_frame is identical when filled with 'normal' CAN
> frame content.
> 
> But you need to distinguish whether it is a CAN or CAN FD frame when
> allocating the skb based on the RX_BUF_EDL value.
> 

Yes, i think it's good to do that.
One obvious benefit is it saves memory at least.

> >  		if (!skb) {
> >  			stats->rx_dropped++;
> >  			return pkts;
> > @@ -384,7 +423,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
> >  		m_can_read_fifo(dev, frame, rxfs);
> >  
> >  		stats->rx_packets++;
> > -		stats->rx_bytes += frame->can_dlc;
> > +		stats->rx_bytes += frame->len;
> >  
> >  		netif_receive_skb(skb);
> >  
> 
> The rest of your entire patch set looks very good from my perspective.
> 

Thanks for the review. :-)

> Best regards,
> Oliver
> 
> 

Regards
Dong Aisheng
