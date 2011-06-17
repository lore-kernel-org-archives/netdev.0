From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 5/7] qlcnic: fix default operating state of
 interface
Date: Fri, 17 Jun 2011 12:00:12 -0700
Message-ID: <20110617120012.6feb524d@nehalam.ftrdhcpuser.net>
References: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
	<20110617.001035.1602476678651330954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anirban.chakraborty@qlogic.com, netdev@vger.kernel.org,
	amit.salecha@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53897 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757172Ab1FQTAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 15:00:17 -0400
In-Reply-To: <20110617.001035.1602476678651330954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jun 2011 00:10:35 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Date: Thu, 16 Jun 2011 13:37:36 -0700
> 
> > From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > 
> > Currently interface shows status as RUNNING, even if there is no link.
> > To fix this, netif_carrier_off should be called after register_netdev().
> > 
> > netif_carrier_off calls linkwatch_fire_event(dev); only if netdev is registered,
> > otherwise it skips. linkwatch_fire_event set default state of nic interface.
> > 
> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> 
> You cannot do this.
> 
> The exact second that register_netdev() is called, the device can
> be brought up asynchronously and the link brought into the up state.
> 
> Your netif_carrier_off() call will race with this.
> 
> This is why no other (properly functioning) driver does what you're
> trying to do here.

The proper place to do this is in the open() routine.
When device is not open, the carrier state is undefined; and devices
that are trying to save power turn off PHY when device is not in use.

Therefore the open() routine should ensure that the carrier is in
the proper state when returning. Just doing something like:

static int qlcnic_open() {
...
	netif_carrier_off()

        err = __qlcnic_up();
	...
}

static int __qlcnic_up() {
	...
	(lots of tests)
	...

        netif_carrier_on();
	adapter->reset_context = 0;
	set_bit(__QLCNIC_DEV_UP, &adapter->state);
	return 0;
}
