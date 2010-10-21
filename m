From: Shawn Lin <shawn@dmp.com.tw>
Subject: Re: [PATCH 1/2] r6040: fix multicast operations
Date: Thu, 21 Oct 2010 16:27:34 +0800
Message-ID: <1287649654.1792.98.camel@shawn-desktop>
References: <201010202309.43812.florian@openwrt.org>
	 <1287629751.20865.220.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 59-120-27-67.HINET-IP.hinet.net ([59.120.27.67]:4606 "EHLO
	www.dmp.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab0JUIjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:39:51 -0400
Received: from [59.120.27.68] by www.dmp.com.tw (GMS
 15.00.3626/AB6032.00.96a8e532) with ESMTP id emnmcbaa for
 netdev@vger.kernel.org; Thu, 21 Oct 2010 16:27:43 +0800
In-Reply-To: <1287629751.20865.220.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ben,

I help to answer your questions.

On Thu, 2010-10-21 at 03:55 +0100, Ben Hutchings wrote:
> On Wed, 2010-10-20 at 22:25 +0100, Florian Fainelli wrote:
> > This patch fixes the following issues with the r6040 NIC operating in
> > multicast:
> > 
> > 1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC hash
> >    table registers to make it process multicast traffic
> > 2) When the number of multicast address to handle is smaller than MCAST_MAX
> >    we should use the NIC multicast registers MID1_{L,M,H}.
> > 3) The hashing of the address was not correct, due to an invalid substraction
> >    (15 - (crc & 0x0f)) instead of (crc & 0x0f)
> 
> > Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> > Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> > Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
> > Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
> > CC: stable@kernel.org
> 
> Remember you'll need to provide a different version for 2.6.27.y and
> 2.6.32.y.
> 
> > ---
> > diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> > index 68a8419..3843363 100644
> > --- a/drivers/net/r6040.c
> > +++ b/drivers/net/r6040.c
> > @@ -852,74 +852,90 @@ static void r6040_multicast_list(struct net_device *dev)
> >  	struct r6040_private *lp = netdev_priv(dev);
> >  	void __iomem *ioaddr = lp->base;
> >  	u16 *adrp;
> > -	u16 reg;
> >  	unsigned long flags;
> >  	struct netdev_hw_addr *ha;
> >  	int i;
> >  
> > -	/* MAC Address */
> > -	adrp = (u16 *)dev->dev_addr;
> > -	iowrite16(adrp[0], ioaddr + MID_0L);
> > -	iowrite16(adrp[1], ioaddr + MID_0M);
> > -	iowrite16(adrp[2], ioaddr + MID_0H);
> > -
> > -	/* Promiscous Mode */
> >  	spin_lock_irqsave(&lp->lock, flags);
> >  
> >  	/* Clear AMCP & PROM bits */
> > -	reg = ioread16(ioaddr) & ~0x0120;
> > -	if (dev->flags & IFF_PROMISC) {
> > -		reg |= 0x0020;
> > +	lp->mcr0 = ioread16(ioaddr) & ~0x0120;
> > +
> > +	/* Promiscuous Mode */
> > +	if (dev->flags & IFF_PROMISC)
> >  		lp->mcr0 |= 0x0020;
> > -	}
> > -	/* Too many multicast addresses
> > -	 * accept all traffic */
> > -	else if ((netdev_mc_count(dev) > MCAST_MAX) ||
> > -		 (dev->flags & IFF_ALLMULTI))
> > -		reg |= 0x0020;
> >  
> > -	iowrite16(reg, ioaddr);
> > -	spin_unlock_irqrestore(&lp->lock, flags);
> > +	/* Enable multicast hash table function to
> > +	 * receive all multicast packets.
> > +	 */
> > +	else if (dev->flags & IFF_ALLMULTI) {
> > +		lp->mcr0 |= 0x0100;
> 
> Please give these flags names.
> 
> >  
> > -	/* Build the hash table */
> > -	if (netdev_mc_count(dev) > MCAST_MAX) {
> > -		u16 hash_table[4];
> > +		for (i = 0; i < MCAST_MAX ; i++) {
> > +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> > +		}
> > +
> > +		iowrite16(0xffff, ioaddr + MAR0);
> > +		iowrite16(0xffff, ioaddr + MAR1);
> > +		iowrite16(0xffff, ioaddr + MAR2);
> > +		iowrite16(0xffff, ioaddr + MAR3);
> > +	}
> > +
> > +	/* Use internal multicast address registers
> > +	 * if the number of multicast addresses is not greater than MCAST_MAX.
> > +	 */
> > +	else if (netdev_mc_empty(dev)) {
> > +		for (i = 0; i < MCAST_MAX ; i++) {
> > +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> > +		}
> > +	} else if (netdev_mc_count(dev) <= MCAST_MAX) {
> > +		i = 0;
> > +		netdev_for_each_mc_addr(ha, dev) {
> > +			adrp = (u16 *) ha->addr;
> > +			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> > +			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> > +			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> > +			i++;
> > +		}
> 
> What about the unused exact match entries?  And why is the empty case
> special?

Unused exact match entries? I am not sure which entries are you
mentioned.

There are five match entries in the code:

1) if (dev->flags & IFF_PROMISC)
then write a hardware flag to enable promiscuous function.


2) if (netdev_mc_count(dev) <= 3)
There are two hardware features could be used to filter multicast
frames:

[1] Three extra MAC/Multicast registers that could be used to get the
exact frames from specified multicast addresses.

[2] Multicast hash table registers.

I follow the original code to write exact multicast addresses to the
three registers when they are not greater than 3.


3) if (netdev_mc_empty(dev))
because we masked the multicast hash table flag before examine all
conditions, we only need to clear the addresses in the three
MAC/Multicast registers.


4) if (dev->flags & IFF_ALLMULTI)
then enable multicast hash table function and write 0xffff to all
multicast hash table registers.


5) else
to enablue multicast hash table and calculate corresponding bit
according to each multicast address.

> 
> > +	}
> > +	/* Otherwise, Enable multicast hash table function. */
> > +	else {
> > +		u16 hash_table[4] = { 0, };
> >  		u32 crc;
> >  
> > -		for (i = 0; i < 4; i++)
> > -			hash_table[i] = 0;
> > +		lp->mcr0 |= 0x0100;
> >  
> > +		for (i = 0; i < MCAST_MAX ; i++) {
> > +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> > +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> > +		}
> > +
> > +		/* Build multicast hash table */
> >  		netdev_for_each_mc_addr(ha, dev) {
> >  			char *addrs = ha->addr;
> >  
> >  			if (!(*addrs & 1))
> >  				continue;
> >  
> > -			crc = ether_crc_le(6, addrs);
> > +			crc = ether_crc(ETH_ALEN, addrs);
> 
> You're reversing the order of bits in the CRC, which is not mentioned in
> the commit message; are you sure that's right?

This hash alogorithm is provided by RDC's engineers.

We also verified on different hardware platforms.

I will double confirm it with RDC's engineers.

> 
> >  			crc >>= 26;
> > -			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
> > +			hash_table[crc >> 4] |= 1 << (crc & 0xf);
> >  		}
> > +
> >  		/* Fill the MAC hash tables with their values */
> >  		iowrite16(hash_table[0], ioaddr + MAR0);
> >  		iowrite16(hash_table[1], ioaddr + MAR1);
> >  		iowrite16(hash_table[2], ioaddr + MAR2);
> >  		iowrite16(hash_table[3], ioaddr + MAR3);
> >  	}
> > -	/* Multicast Address 1~4 case */
> > -	i = 0;
> > -	netdev_for_each_mc_addr(ha, dev) {
> > -		if (i < MCAST_MAX) {
> > -			adrp = (u16 *) ha->addr;
> > -			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> > -			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> > -			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> > -		} else {
> > -			iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
> > -			iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
> > -			iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
> > -		}
> 
> This conflicts with my patch in
> <http://article.gmane.org/gmane.linux.network/174926> which Dave has
> already applied (but not pushed out).
> 
> Ben.
> 
> > -		i++;
> > -	}
> > +	iowrite16(lp->mcr0, ioaddr);
> > +
> > +	spin_unlock_irqrestore(&lp->lock, flags);
> >  }
> >  
> >  static void netdev_get_drvinfo(struct net_device *dev,
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 

Hope some issues have been clarified.

--
Regards,

Shawn Lin


===========================================================================================
The privileged confidential information contained in this email is intended for use only by the addressees as indicated by the original sender of this email. 
If you are not the addressee indicated in this email or are not responsible for delivery of the email to such a person, please kindly reply to the sender indicating this fact and delete all copies of it from your computer and network server immediately. 
Your cooperation is highly appreciated. It is advised that any unauthorized use of confidential information of DM&P Group is strictly prohibited; and any information in this email irrelevant to the official business of DM&P Group shall be deemed as neither given nor endorsed by DM&P Group.

===========================================================================================
