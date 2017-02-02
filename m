From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 02/11] net: mvpp2: handle too large value in
 mvpp2_rx_time_coal_set()
Date: Thu, 2 Feb 2017 17:11:21 +0100
Message-ID: <20170202171121.4540faf3@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943567-12483-3-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170106125923.GA14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55528 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751883AbdBBQLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:11:24 -0500
In-Reply-To: <20170106125923.GA14217@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell,

On Fri, 6 Jan 2017 12:59:24 +0000, Russell King - ARM Linux wrote:

> Beware of rounding and overflow errors.  usec and val are u32's.

[...]

Thanks for all the suggestions, I've taken this into account in my v3
that I've sent a few minutes ago? I've re-used almost exactly your
implementation, with a few changes (see below).

> static u32 usec_to_cycles(u32 usec, unsigned long clock_rate_hz)
> {
> 	u64 tmp = clock_rate_hz * usec;

I had to cast one of the variables to u64 here otherwise the
multiplication was done on 32 bits, and then the result was expanded to
64 bits.

> 	do_div(tmp, USEC_PER_SEC);
> 
> 	return tmp > 0xffffffff ? 0xffffffff : tmp;

I've used U32_MAX here.

> static u32 cycles_to_usec(u32 cycles, unsigned long clock_rate_hz)
> {
> 	u64 tmp = cycles * USEC_PER_SEC;
> 
> 	do_div(tmp, clock_rate_hz);
> 
> 	return tmp > 0xffffffff ? 0xffffffff : tmp;

Same comments for this function.

> and:
> 	u32 val = usec_to_cycles(usec, port->priv->tclk);
> 
> 	if (val > MVPP2_MAX_ISR_RX_THRESHOLD) {
> 		usec = cycles_to_usec(MVPP2_MAX_ISR_RX_THRESHOLD,
> 				      port->priv->tclk);
> 
> 		/* re-evaluate to get actual register value for usec */
> 		val = usec_to_cycles(usec, port->priv->tclk);
> 	}
> 
> >  	mvpp2_write(port->priv, MVPP2_ISR_RX_THRESHOLD_REG(rxq->id), val);
> >  
> >  	rxq->time_coal = usec;  
> 
> This function appears to be called from two places:
> 
> mvpp2_rxq_init():
>         mvpp2_rx_time_coal_set(port, rxq, rxq->time_coal);
> 
> mvpp2_ethtool_set_coalesce():
>                 rxq->time_coal = c->rx_coalesce_usecs;
>                 mvpp2_rx_time_coal_set(port, rxq, rxq->time_coal);
> 
> It seems rather pointless to pass in rxq->time_coal when you're also
> passing in rxq.

Indeed, so I've added another patch in the series that does this.

Thanks for the review!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
