From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH net-next 5/7] qlcnic: fix default operating state of
 interface
Date: Wed, 22 Jun 2011 02:01:50 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FDEEEAA97@MNEXMB2.qlogic.org>
References: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
	<20110617.001035.1602476678651330954.davem@davemloft.net>
 <20110617120012.6feb524d@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:34319
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724Ab1FVHB7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 03:01:59 -0400
In-Reply-To: <20110617120012.6feb524d@nehalam.ftrdhcpuser.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> 
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> > Date: Thu, 16 Jun 2011 13:37:36 -0700
> >
> > > From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > >
> > > Currently interface shows status as RUNNING, even if there is no
> link.
> > > To fix this, netif_carrier_off should be called after
> register_netdev().
> > >
> > > netif_carrier_off calls linkwatch_fire_event(dev); only if netdev
> is registered,
> > > otherwise it skips. linkwatch_fire_event set default state of nic
> interface.
> > >
> > > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > > Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> >
> > You cannot do this.
> >
> > The exact second that register_netdev() is called, the device can
> > be brought up asynchronously and the link brought into the up state.
> >
> > Your netif_carrier_off() call will race with this.
> >
> > This is why no other (properly functioning) driver does what you're
> > trying to do here.
> 
> The proper place to do this is in the open() routine.
> When device is not open, the carrier state is undefined; and devices
> that are trying to save power turn off PHY when device is not in use.
> 
> Therefore the open() routine should ensure that the carrier is in
> the proper state when returning. Just doing something like:
> 
> static int qlcnic_open() {
> ...
> 	netif_carrier_off()
> 
>         err = __qlcnic_up();
> 	...
> }
> 
> static int __qlcnic_up() {
> 	...
> 	(lots of tests)
> 	...
> 
>         netif_carrier_on();
> 	adapter->reset_context = 0;
> 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
> 	return 0;
> }

netif_carrier_off() is ok, should be call from qlcnic_open().
netif_carrier_on() will be call during asynchronous notification from fw.

-Thanks.

