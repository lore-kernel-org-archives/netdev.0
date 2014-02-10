From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Mon, 10 Feb 2014 17:14:59 +0100
Message-ID: <52F8FB03.6040606@keymile.com>
References: <7510122.cayuQ6qt8r@wuerfel> <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com> <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Matthew Garrett <matthew.garrett@nebula.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm currently trying to fix an issue for which this patch provides a 
partial solution, so apologies in advance for jumping into the 
discussion for my own purposes...

On 02/04/2014 09:39 PM, Florian Fainelli wrote:> 2014-01-17 Matthew 
Garrett <matthew.garrett@nebula.com>:
 >> Some hardware may be broken in interesting and board-specific ways, such
 >> that various bits of functionality don't work. This patch provides a
 >> mechanism for overriding mii registers during init based on the 
contents of
 >> the device tree data, allowing board-specific fixups without having to
 >> pollute generic code.
 >
 > It would be good to explain exactly how your hardware is broken
 > exactly. I really do not think that such a fine-grained setting where
 > you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
 > remain usable makes that much sense. In general, Gigabit might be
 > badly broken, but 100 and 10Mbits/sec should work fine. How about the
 > MASTER-SLAVE bit, is overriding it really required?
 >
 > Is not a PHY fixup registered for a specific OUI the solution you are
 > looking for? I am also concerned that this creates PHY troubleshooting
 > issues much harder to debug than before as we may have no idea about
 > how much information has been put in Device Tree to override that.
 >
 > Finally, how about making this more general just like the BCM87xx PHY
 > driver, which is supplied value/reg pairs directly? There are 16
 > common MII registers, and 16 others for vendor specific registers,
 > this is just covering for about 2% of the possible changes.

Good point. That would easily help me with my current issue, which 
requires autoneg to be disabled to begin with (by clearing BMCR_ANENABLE 
from register 0).
This would not however fix it entirely (I tried a quick hardwired 
implementation), as the whole PHY machinery would not take that into 
account and would re-enable autoneg anyway.
I also tried changing the patch so that phydev->support gets updated 
(instead of phydev->advertising):

 >> +               if (!of_property_read_u32(np, override->prop, &tmp)) {
 >> +                       if (tmp) {
 >> +                               *val |= override->value;
 >> +                               phydev->advertising |= 
override->supported;
 >> +                       } else {
 >> +                               phydev->advertising &= 
~(override->supported);
 >> +                       }
 >> +
 >> +                       *mask |= override->value;

What I find weird is that the only way phydev->autoneg could ever be set 
to disabled is from here (phy.c):

static void phy_sanitize_settings(struct phy_device *phydev)
{
	u32 features = phydev->supported;
	int idx;

	/* Sanitize settings based on PHY capabilities */
	if ((features & SUPPORTED_Autoneg) == 0)
		phydev->autoneg = AUTONEG_DISABLE;

which is in turn only called when phydev->autoneg is set to 
AUTONEG_DISABLE to begin with:

int phy_start_aneg(struct phy_device *phydev)
{
	int err;

	mutex_lock(&phydev->lock);

	if (AUTONEG_DISABLE == phydev->autoneg)
		phy_sanitize_settings(phydev);

So could someone please help me figure out what I'm missing here?

Thanks!
Gerlando
