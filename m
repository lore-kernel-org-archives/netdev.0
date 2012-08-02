From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Thu, 2 Aug 2012 12:53:58 +0200
Message-ID: <20120802105358.GA23787@hposo>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be>
 <50166BF2.9000700@pengutronix.de>
 <20120730133323.GA13941@hposo>
 <5017ABC6.7030307@pengutronix.de>
 <20120731130650.GA23541@hposo>
 <5017DD5B.2030701@pengutronix.de>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45058 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab2HBKyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 06:54:07 -0400
Content-Disposition: inline
In-Reply-To: <5017DD5B.2030701@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Jul 31, 2012 at 03:27:55PM +0200, Marc Kleine-Budde wrote:
> We can continue the review process, this problem has to be sorted out
> before I can apply this patch to linux-can-next tree.

Ok.

> > 1) With the short circuit:
> > 
> > I perform the test you described. It showed that the Kvaser passes from
> > ERROR-WARNING to ERROR-PASSIVE and then BUS-OFF. But after going to the
> > state BUS-OFF it comes back to ERROR-WARNING.
> > 
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> 
> Why don't we have any rx/tx numbers in the error frame?

Because the hardware seems to not update the tx/rx_errors_count
fields :-(

> From the hardware point of view the short circuit and open end tests
> look good. Please adjust the driver to turn off the CAN interface in
> case of a bus off if restart_ms is 0.

And in the case where restart_ms is not 0? Don't I've to put it off so
and drop the frame?
I actually implemeted it as you said and here is what I observed in
candump output with restart_ms set to 100 ms:

t0: Short circuit between CAN-H and CAN-L + cansend can1 123#1122
  can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
	controller-problem{rx-error-warning}
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-error
  can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
	controller-problem{rx-error-passive}
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-error
  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-off
	bus-error
...
  can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
	controller-problem{rx-error-warning}
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-error
  can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
	controller-problem{rx-error-passive}
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-error
  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
	bus-off
	bus-error

t1: short circuit removed
  can1  123  [2] 11 22
  can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
	restarted-after-bus-of

The echo coming before the restart looks weird? No?
Shouldn't we drop the frame once BUF-OFF is reached?

> >>>>> +		if ((priv->can.state == CAN_STATE_ERROR_WARNING) ||
> >>>>> +		    (priv->can.state == CAN_STATE_ERROR_PASSIVE)) {
> >>>>> +			cf->data[1] = (txerr > rxerr) ?
> >>>>> +				CAN_ERR_CRTL_TX_PASSIVE
> >>>>> +				: CAN_ERR_CRTL_RX_PASSIVE;
> 
> Please use CAN_ERR_CRTL_RX_WARNING, CAN_ERR_CRTL_TX_WARNING where
> appropriate.

Ok. As the hardware doesn't report good values for txerr and rxerr, I'll
also remove the tests on txerr and rxerr.
I observed the same behavior with the original driver.
I asked Kvaser for this problem. I've to wait before their developer is
back (same for the GPL issue).

> >>>>> +static int kvaser_usb_get_berr_counter(const struct net_device *netdev,
> >>>>> +				       struct can_berr_counter *bec)
> >>>>> +{
> >>>>> +	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
> >>>>> +
> >>>>> +	bec->txerr = priv->bec.txerr;
> >>>>> +	bec->rxerr = priv->bec.rxerr;
> 
> I think you can copy the struct like this:
> 
> 	*bec = priv->bec;

Thanks. I'll remove the function kvaser_usb_get_berr_counter as the
hardware seems to never report txerr and rxerr.

I'll look deeper at this driver during the week-end if possible...

Thanks a lot for your help,

-- 
Olivier
