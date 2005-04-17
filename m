From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Sun, 17 Apr 2005 14:00:11 +0100
Message-ID: <42625DDB.4090600@katalix.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	<1110334456.32556.21.camel@gaston>	<20050308194229.41c23707.davem@davemloft.net>	<1110340214.32524.32.camel@gaston> <57a429f8eb807987d88b06129861d507@freescale.com> <4230D1AC.5070506@katalix.com> <ba5d844255b5ba76b2685f9397faf689@freescale.com> <423734FB.40101@katalix.com> <96c50184a02557c88dee0e6d17f3a539@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        linuxppc-embedded@ozlabs.org,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <96c50184a02557c88dee0e6d17f3a539@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> Ok, here's the new patch with changes suggested by James Chapman:

I guess I still have questions about the way interrupts are used.

Using an interrupt to schedule a work queue which then sets a variable
that is used by a timer seems odd. Why not do all the work in the work
queue and schedule it from the interrupt handler or timer?

Many network devices have status bits in their interrupt status
registers to indicate PHY events. These bits are handled in the
network device driver; there is no separate irq. It would obviously be
good to change these drivers to hook up your abstraction layer to
handle PHY functions. You suggested previously that the network driver
and PHY driver could share the irq when the PHY's interrupt is
indicated through the network device's status registers. I still don't
see how SA_SHIRQ could work given that the PHY code uses
disable_irq_nosync() and enable_irq() when handling interrupts. If the
irq is shared with the net device interrupt, this will cause packet
interrupts to stop until the phy's work queue callback is called. If
the irq is shared with other possibly unrelated devices, other bad
effects could occur.

Perhaps the following code (taken from phy_change()) could be called
by the net driver when link state changes are detected by its
interrupt or NAPI poll handler?

if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state)) {
	phydev->state = PHY_CHANGELINK;
	schedule_work(&phydev->phy_queue);
}

In the above case, the net driver would use phy_connect() to connect
its PHY and phydev->irq would be -1 to disable use of PHY interrupts
by the PHY code. Would this work? If so, a new API function for net
drivers to call would be useful.

Also, did you mean to leave the #if 0 code in davicom.c?

/james
