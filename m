From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Fri, 02 Mar 2007 11:23:25 -0800 (PST)
Message-ID: <20070302.112325.39160082.davem@davemloft.net>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
	<m3zm6vk6kd.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965149AbXCBTX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 14:23:26 -0500
In-Reply-To: <m3zm6vk6kd.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Fri, 02 Mar 2007 16:29:06 +0100

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> >> However, in 
> >> drivers/net/wan/hdlc_cisco.c, in function static int cisco_ioctl(struct 
> >> net_device *dev, struct ifreq *ifr), where dev->hard_header is assigned a valid 
> >> function, and dev->hard_header_cache is assigned a known value (NULL), dev-
> >> >header_cache_update is not set to a known value:
> 
> Right, it seems I was never aware of dev->header_cache_update existence.
> I wonder where does the non-NULL value come from? Nevermind.
> 
> > diff -puN drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update drivers/net/wan/hdlc_cisco.c
> > --- a/drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update
> > +++ a/drivers/net/wan/hdlc_cisco.c
> > @@ -366,6 +366,7 @@ static int cisco_ioctl(struct net_device
> >  		dev->hard_start_xmit = hdlc->xmit;
> >  		dev->hard_header = cisco_hard_header;
> >  		dev->hard_header_cache = NULL;
> > +		dev->header_cache_update = NULL;
> >  		dev->type = ARPHRD_CISCO;
> >  		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
> >  		dev->addr_len = 0;
> > _
> 
> ACK, I think it's the best place.

I disagree, you can't leave dangling references to functions
which are potentially inside of unloaded modules, as this code
does.

Rather, HDLC Cisco should implement a proper protocol destructor
method to clean up these function pointers.

