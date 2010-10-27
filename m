From: Shawn Lin <shawn@dmp.com.tw>
Subject: Re: [PATCH 1/2] r6040: fix multicast operations
Date: Wed, 27 Oct 2010 09:19:03 +0800
Message-ID: <1288142343.1790.15.camel@shawn-desktop>
References: <201010202309.43812.florian@openwrt.org>
	 <1287629751.20865.220.camel@localhost>
	 <1287649654.1792.98.camel@shawn-desktop>
	 <20101026140209.GY13095@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 59-120-27-67.HINET-IP.hinet.net ([59.120.27.67]:3316 "EHLO
	www.dmp.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760769Ab0J0BTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 21:19:11 -0400
Received: from [59.120.27.68] by www.dmp.com.tw (GMS
 15.00.3626/AB6032.00.96a8e532) with ESMTP id sdqncbaa for
 netdev@vger.kernel.org; Wed, 27 Oct 2010 09:19:06 +0800
In-Reply-To: <20101026140209.GY13095@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-26 at 15:02 +0100, Ben Hutchings wrote:
> On Thu, Oct 21, 2010 at 04:27:34PM +0800, Shawn Lin wrote:
> [...]
> > > > +	/* Use internal multicast address registers
> > > > +	 * if the number of multicast addresses is not greater than MCAST_MAX.
> > > > +	 */
> > > > +	else if (netdev_mc_empty(dev)) {
> > > > +		for (i = 0; i < MCAST_MAX ; i++) {
> > > > +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> > > > +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> > > > +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> > > > +		}
> > > > +	} else if (netdev_mc_count(dev) <= MCAST_MAX) {
> > > > +		i = 0;
> > > > +		netdev_for_each_mc_addr(ha, dev) {
> > > > +			adrp = (u16 *) ha->addr;
> > > > +			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> > > > +			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> > > > +			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> > > > +			i++;
> > > > +		}
> > > 
> > > What about the unused exact match entries?  And why is the empty case
> > > special?
> > 
> > Unused exact match entries? I am not sure which entries are you
> > mentioned.
> 
> If there are 1 or 2 addresses in the multicast list then some of the
> exact match entries will be used and some will not.  But the loop
> above does not clear the unused entries.
> 

Yes, you are right.

> [...]
> > 2) if (netdev_mc_count(dev) <= 3)
> > There are two hardware features could be used to filter multicast
> > frames:
> [...]
> > 3) if (netdev_mc_empty(dev))
> > because we masked the multicast hash table flag before examine all
> > conditions, we only need to clear the addresses in the three
> > MAC/Multicast registers.
> [...]
> 
> But why is this so different from the case of 1-3 addresses?  I would
> write these two cases as:
> 
> else if (netdev_mc_count(dev) <= MCAST_MAX) {
> 	i = 0;
> 	netdev_for_each_mc_addr(ha, dev) {
> 		adrp = (u16 *) ha->addr;
> 		iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> 		iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> 		iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> 		i++;
> 	}
> 	while (i < MCAST_MAX) {
> 		iowrite16(0, ioaddr + MID_1L + 8 * i);
> 		iowrite16(0, ioaddr + MID_1M + 8 * i);
> 		iowrite16(0, ioaddr + MID_1H + 8 * i);
> 		i++;
> 	}
> } 
> 
> Ben.
> 

Thanks.

I will fix the issues you mentioned and resubmit the code.

--
Regards,

Shawn Lin


===========================================================================================
The privileged confidential information contained in this email is intended for use only by the addressees as indicated by the original sender of this email. 
If you are not the addressee indicated in this email or are not responsible for delivery of the email to such a person, please kindly reply to the sender indicating this fact and delete all copies of it from your computer and network server immediately. 
Your cooperation is highly appreciated. It is advised that any unauthorized use of confidential information of DM&P Group is strictly prohibited; and any information in this email irrelevant to the official business of DM&P Group shall be deemed as neither given nor endorsed by DM&P Group.

===========================================================================================
