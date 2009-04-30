From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Porting the ibm_newemac driver to use phylib (and other
	PHY/MAC questions)
Date: Fri, 01 May 2009 07:18:11 +1000
Message-ID: <1241126291.29501.41.camel@pasglop>
References: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
	<625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
	<f73f7ab80904201710m57472291yf7ff86760977b8e8@mail.gmail.com>
	<1240388476.17445.10.camel@pasglop>
	<f73f7ab80904300804j1f847b70ha0fe3cda07249110@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <f73f7ab80904300804j1f847b70ha0fe3cda07249110@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


> Ok, I've made some progress in the port, but right now I'm trying to
> puzzle out what the "gpcs" bits in the code are.  From the few
> publicly available docs and some mailing list posts, the gpcs address
> appears to be some kind of integrated virtual PHY used when 460GT-ish
> chips are communicating via an SGMII bus.  My current plan of action
> is to separate the "gpcs" out into a separate PHY device controlled by
> the emac code.

Well... GPCS is indeed some kind of internal PHY if you like but it's
not MDIO controlled and I don't really see a need to move it to the
phylib as it's so specific to the NIC itself. But if you think it cleans
the code up significantly... There are also some subtle differences in
how the NIC is programmed when using GPCS vs. xMII

> I'm also curious about the intent of the "mdio_instance" pointer (IE:
> the "mdio-device" property).  Is that used when all the PHY devices
> are attached to the MDIO bus of only one of the (multiple) emac
> devices? 

It's common especially on older SoCs using EMAC to have only one of
the EMAC instance with an MDIO bus for configuring the PHYs. This is one
of the reasons why I have the mutex in the low level MDIO access
routines since 2 EMACs can try to talk to the same MDIO, and this is the
problem I had with phylib back then which was doing everything in atomic
contexts.

> What keeps the emac_instance pointed
> to by the "mdio_instance" from going away while the other emac chipset
> is using it?

Nothing other than those are all in a SoC and so generally don't do
hotplug, but I suppose that with things like kvm which could potentially
hotplug devices between partitions, one would have to get a bit more
careful.
 
> In either case, I plan to have the device actually holding the MDIO
> bus run the mdiobus_alloc() and mdiobus_register() functions, then the
> other emac instance will simply take a reference to that MDIO bus
> (which would also pin down the emac instance that owns it).

Sounds good at first.

Cheers,
Ben.
