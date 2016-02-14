From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Revert "net: phy: turn carrier off on phy attach"
Date: Sun, 14 Feb 2016 10:56:05 -0800
Message-ID: <74B0B2A9-72EA-4B9B-BC93-5A7E5E46C046@gmail.com>
References: <1455300113-2335-1-git-send-email-clemens.gruber@pqgruber.com> <56BE2AC4.2040908@gmail.com> <20160214182530.GA1498@archie.tuxnet.lan>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160214182530.GA1498@archie.tuxnet.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On February 14, 2016 10:25:30 AM PST, Clemens Gruber <clemens.gruber@pqgruber.com> wrote:
>On Fri, Feb 12, 2016 at 10:56:04AM -0800, Florian Fainelli wrote:
>> On 12/02/16 10:01, Clemens Gruber wrote:
>> > Commit 113c74d83eef ("net: phy: turn carrier off on phy attach")
>breaks
>> > the eth0 link coming up on all my i.MX6Q boards with a Marvell
>88E1510.
>> > If I then do a ifconfig eth0 down/up cycle I first get a MDIO read
>> > timeout but then the link becomes ready and everything is back to
>> > normal.
>> > Without this step however, the link stays down forever, an
>unusually
>> > high amount of phy interrupts occur (about 10000/second) and
>kworker/0:2
>> > is constantly using over 60% of the CPU.
>> > 
>> > Reverting it fixes the problems with the link not coming up at boot
>as
>> > well as the high amount of phy interrupts and kworker load in that
>> > state.
>> 
>> You are seeing this with the FEC driver right? We probably want to
>> carefully audit the driver and understand what could be going wrong,
>the
>> initial change is correct, so there must be something else going on
>here.
>
>I think I found the underlying problem!
>It was not the fec driver but the marvell phy driver, more specifically
>the marvell_of_reg_init call being made too late, which lead to the
>observed problem at half the boot ups where the link never came up.
>
>With the marvell,reg-init device tree parameter, a flag needs to be set
>to tell the Marvell 88E1510 that it should enable the interrupt output.
>(At a specific pin, in my case LED[2])
>If this is not set (or set too late), the phydev->state is set to UP in
>phy_start (called from fec_enet_open) but then, the auto-negotiation
>never starts.
>In comparison, now, after I called marvell_of_reg_init not in
>m88e1510_config_aneg but in marvell_probe, everything works again :)
>About a second after the fec_enet_open/phy_start calls, the
>auto-negotiation starts (m88e1510_config_aneg) and the phy state
>changes
>from UP to AN, to CHANGELINK and finally to RUNNING.
>
>I will send a patch shortly, calling marvell_of_reg_init from a new
>m88e1510_probe function instead of the m88e1510_config_aneg function.

config_init is more appropriate here since this call back will be called even if there is a software reset (e.g: from phy_init_hw). config_aneg is definitely too late, thanks for finding this!

-- 
Florian
