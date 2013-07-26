From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Fri, 26 Jul 2013 16:31:52 +0100
Message-ID: <1374852712.1666.20.camel@bwh-desktop.uk.level5networks.com>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
	 <20130725090352.574b874d@nehalam.linuxnetplumber.net>
	 <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"Li Frank-B20596" <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9942 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab3GZPb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:31:58 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 09:35 +0000, Duan Fugang-B38611 wrote:
> On Fir, 26 Jul 2013 12:04, Stephen Hemminger wrote:
> >> diff --git a/drivers/net/ethernet/freescale/fec_main.c 
> >> b/drivers/net/ethernet/freescale/fec_main.c
> >> index 0642006..631bd5a 100644
> >> --- a/drivers/net/ethernet/freescale/fec_main.c
> >> +++ b/drivers/net/ethernet/freescale/fec_main.c
> >> @@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >>  	unsigned short	status;
> >>  	unsigned int index;
> >>  
> >> -	if (!fep->link) {
> >> -		/* Link is down or auto-negotiation is in progress. */
> >> -		return NETDEV_TX_BUSY;
> >> -	}
> >> -
> >
> >That is a bug anyway. Since it would cause spin loop in transmit code (even without -rt).
> >If the driver cared to test it (most drivers just let hardware deal with this situation),
> >then it should free packet and return TX_OK.
> 
> When link is down, the logic is
> 	- call netif_stop_queue() to stop queue
> 	- and then notify there have no link using netif_carrier_off().

netif_stop_queue() *must not* be called before netif_carrier_off(),
otherwise the TX watchdog can fire immediately.  The TX watchdog only
knows when the last packet was passed to the driver, not when the queue
was stopped.  The last packet could have been added an arbitrarily long
time before the link went down, therefore it may appear that the timeout
has already expired..

Although it is safe to call netif_stop_queue() after
netif_carrier_off(), it is not useful.  netif_stop_queue() should only
be called from your ndo_start_xmit operation and only because the queue
is full.  Any other reason to stop should be communicated to the kernel
using netif_carrier_off() or netif_device_detach().

Ben.

> But the flow must be handled in fec_enet_adjust_link() function, not in xmit().

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
