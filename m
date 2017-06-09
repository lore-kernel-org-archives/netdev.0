From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 16:49:36 +0200
Message-ID: <20170609144936.GF20756@lunn.ch>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain> <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com,
 Florian Fainelli <f.fainelli@gmail.com>, jason@lakedaemon.net,
 netdev@vger.kernel.org, linux@armlinux.org.uk,
 gregory.clement@free-electrons.com, mw@semihalf.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170609140922.GD31464@kwain>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2017 at 04:09:22PM +0200, Antoine Tenart wrote:
> Hi Andrew,
> 
> On Fri, Jun 09, 2017 at 03:26:24PM +0200, Andrew Lunn wrote:
> > On Fri, Jun 09, 2017 at 10:25:41AM +0200, Antoine Tenart wrote:
> > > On Thu, Jun 08, 2017 at 09:42:21AM -0700, Florian Fainelli wrote:
> > > > 
> > > > If I get this right, the xMDIO controller is actually a superset of the
> > > > MDIO controller and has an extra MVMDIO_XSMI_ADDR_REG register to
> > > > preform C45 accesses?
> > > 
> > > This is also a mistake. It's not a superset as the register offsets are
> > > different. So we can't use the same smi operations in both cases. We
> > > would need dedicated xmdio smi operations, but I don't think there is a
> > > board where a c22 PHY is connected to the xMDIO interface.
> > 
> > Is it described as one device, which can do c22 via one set of
> > registers, and c45 by another set of registers?
> > 
> > Or are there two separate devices. In particular, does each device
> > have there own MDC and MDIO pins? Do we have an C22 only device/bus,
> > and a C45 only device/bus?
> 
> The MDIO/xMDIO registers are embedded into the network controller. The
> mvmdio driver was created at first to abstract this functionality
> outside the network controller driver because it is shared between all
> ports and used in different IPs. So it's not really devices per say.
> 
> Looking at the datasheet/schematics there are two hardware buses, one
> for c22 and one for c45. So we should keep two separate nodes to
> describe the two interfaces. From what I read c45 is backward
> compatible with c22 so the xSMI interface should be capable to speak to
> c22 PHYs as well.

The on the wire protocol of c45 is backwards compatible with c22, in
that a c22 device will not get confused by a c45 transaction on the
bus. A c22 device will just ignore it. You cannot talk to a c22 device
using c45.

>From what you are saying, you have a hardware block generating c45
transactions and a hardware block which generates c22 transactions.
What is not clear to me is if these two hardware blocks are using the
same physical MDC/MDIO pins, i.e. there is just one MDIO bus to the
outside world, or are there two busses?

> And by looking at the datasheet this seems possible, although it's
> not completely clear. But anyway this wouldn't impact the dt
> bindings.

What i'm worried about is there being one set of MDC/MDIO lines. You
should not expose that to linux as two mdio busses. It is one bus.

The phylib will poll each phy on the bus once per second to check its
state. The phylib serialises the read/writes at a bus level. So if you
have one physical bus registered as two logical bus, at some point you
are going to get simultaneous read/writes, and you are going to need a
mutex low down to serialise this for physical bus access.

And in the end, this would affect the dt binding. If it is one
physical bus, you want one binding representing both c22 and c45
transactions.

      Andrew
