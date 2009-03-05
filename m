From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [i4l] stop address leakage when shutting down an i4l ppp
	interface
Date: Thu, 05 Mar 2009 14:00:58 +0100
Message-ID: <1236258058.2644.25.camel@x41.thuisdomein>
References: <1231764889.7132.23.camel@test.thuisdomein>
	 <20090114.145035.194024897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:52800 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbZCENBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 08:01:02 -0500
In-Reply-To: <20090114.145035.194024897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It took longer than I hoped to respond to your message.

On Wed, 2009-01-14 at 14:50 -0800, David Miller wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
> > @@ -1336,6 +1336,13 @@ isdn_net_close(struct net_device *dev)
> >  	}
> >  	isdn_net_hangup(dev);
> >  	isdn_unlock_drivers();
> > +#ifdef CONFIG_ISDN_PPP
> > +	/* make sure arp_mc_map() handles this device properly */
> > +	if (dev->type == ARPHRD_PPP) {
> > +		dev->type = ARPHRD_ETHER;
> > +		dev->addr_len = ETH_ALEN;
> > +	}
> > +#endif
> >  	return 0;
> >  }
>
> I think it's pretty much illegal to change the device type after the
> device has been registered.

But isn't that what the i4l code already does?

Bringing up an i4l ppp interface will (in Fedora's ifup-ippp script) do
(among a lot of other stuff):
    isdnctrl addif ippp0
and then: 
    isdnctrl encap ippp0 syncppp

On the kernel side this will result (assuming, of course, I correctly
interpreted the relevant code) in these events: 
    isdn_ioctl(IIOCNETAIF)
    isdn_net_new()
    alloc_netdev()
    _isdn_setup()
    ether_setup()
        [...]
	dev->type = ARPHRD_ETHER
	dev->addr_len = ETH_ALEN
        [...]
    register_netdev() 
    [...]

followed by these events:
    isdn_ioctl(IIOCNETSCF)
    isdn_net_setcfg()
        [...]
        case ISDN_NET_ENCAP_SYNCPPP:
	    p->dev->type = ARPHRD_PPP
	    p->dev->addr_len = 0

This looks to me like it's changing the device type after the device has
been registered. Or were you referring to something else?


Paul

