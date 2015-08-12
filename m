From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: Re: [PATCH v2 net-next] sky2: use random address if EEPROM is bad
Date: Wed, 12 Aug 2015 17:00:37 +0100
Message-ID: <20150812160037.GX20890@e106497-lin.cambridge.arm.com>
References: <55C2AB51.1040409@gmail.com>
 <1439303756-30333-1-git-send-email-Liviu.Dudau@arm.com>
 <20150811100132.49229f86@urahara>
 <20150812093005.GV20890@e106497-lin.cambridge.arm.com>
 <20150812082823.4d62ee26@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mirko Lindner <mlindner@marvell.com>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150812082823.4d62ee26@urahara>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2015 at 04:28:23PM +0100, Stephen Hemminger wrote:
> On Wed, 12 Aug 2015 10:30:05 +0100
> Liviu Dudau <Liviu.Dudau@arm.com> wrote:
>=20
> > On Tue, Aug 11, 2015 at 06:01:32PM +0100, Stephen Hemminger wrote:
> > > On Tue, 11 Aug 2015 15:35:56 +0100
> > > Liviu Dudau <Liviu.Dudau@arm.com> wrote:
> > >=20
> > > > On some embedded systems the EEPROM does not contain a valid MA=
C address.
> > > > In that case it is better to fallback to a generated mac addres=
s and
> > > > let init scripts fix the value later.
> > > >=20
> > > > Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
> > > > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > > > [Changed handcoded setup to use eth_hw_addr_random() instead]
> > > > Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
> > > > ---
> > > > I have tested this on my Juno platform and I can successfully d=
o an nfsroot boot.
> > > >=20
> > > > Best regards,
> > > > Liviu
> > > >=20
> > > >  drivers/net/ethernet/marvell/sky2.c | 7 +++++++
> > > >  1 file changed, 7 insertions(+)
> > > >=20
> > > > diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/=
ethernet/marvell/sky2.c
> > > > index d9f4498..c309879 100644
> > > > --- a/drivers/net/ethernet/marvell/sky2.c
> > > > +++ b/drivers/net/ethernet/marvell/sky2.c
> > > > @@ -4819,6 +4819,13 @@ static struct net_device *sky2_init_netd=
ev(struct sky2_hw *hw, unsigned port,
> > > >  		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
> > > >  			      ETH_ALEN);
> > > > =20
> > > > +	/* if the address is invalid, use a random value */
> > > > +	if (!is_valid_ether_addr(dev->dev_addr)) {
> > > > +		netdev_warn(dev,
> > > > +			"Invalid MAC address, defaulting to random\n");
> > > > +		eth_hw_addr_random(dev);
> > > > +	}
> > > > +
> > > >  	return dev;
> > > >  }
> > > > =20
> > >=20
> > > This is not enough, you need to program the hardware with the new=
 random MAC
> > > address. The easiest way is calling sky2_set_mac_address, but you=
 need to convert
> > > the address from array back to sockaddr.
> > >=20
> >=20
> > OK, I am a bit confused as to why sky2_set_mac_address is needed he=
re, as this was not
> > required by the existing function. Given that in my tests I get a r=
andom MAC address
> > assigned every time to the device and I can see the same MAC addres=
s with ifconfig, how
> > can I test the effect of sky2_set_mac_address if I add it?
>=20
> The network device address is stored in two places. One is in the
> kernel (dev->dev_addr) and is  used by networking stack.
> The other is the hardware (actually two places) and is used filtering=
 received packets
> in the PHY and for sending hardware generated pause frames.
>=20
> When a random address is generated, you need to tell the hardware
> to use that address as well. I suspect your hardware maybe limited in=
 functionality
> and not do the normal filtering.
>=20

I understand now, thanks for explaining it. I admit my tests were very =
limited and I did not
try to capture any packets using the interface. I thought the DHCP disc=
overy requires the
MAC address to be correct in the hardware to work, but it might be that=
 the kernel's DHCP
client is more thorough than userspace.

I will add the setting of the MAC address in v3.

Best regards,
Liviu

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    =C2=AF\_(=E3=83=84)_/=C2=AF
