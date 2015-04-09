From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Fri, 10 Apr 2015 00:10:54 +0200
Message-ID: <5526F8EE.1010108@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr> <5526CC5A.1080504@gmail.com> <5526D359.1050202@free.fr> <5526E058.2080408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:31413 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbbDIWLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 18:11:05 -0400
In-Reply-To: <5526E058.2080408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> Mason wrote:
>> Florian Fainelli wrote:
>>> Quoting IEEE 802.3 section 2, paragraph 22.2.4.1:
>>>
>>> "Resetting a PHY is accomplished by setting bit 0.15 to a logic one.
>>> This action shall set the status and control registers to their 
>>> default states. As a consequence this action may change the internal 
>>> state of the PHY and the state of the physical link associated with 
>>> the PHY. This bit is self-clearing, and a PHY shall return a value
>>> of one in bit 0.15 until the reset process is completed. A PHY is
>>> not required to accept a write transaction to the control register 
>>> until the reset process is completed, and writes to bits of the 
>>> control register other than 0.15 may have no effect until the reset 
>>> process is completed. The reset process shall be completed within
>>> 0.5 s from the setting of bit 0.15"
>>>
>>> So even though this is not extremely specific about whether or not doing
>>> a RMW instead of W is accepted, considering that this resets the PHY
>>> internal state, and the fact that there is a lack of clarify on whether
>>> setting any bits other than 15 is going to fall under the "A PHY is not
>>> required to accept a write transaction to the control register until the
>>> reset process is completed" statement, setting only this bit at least
>>> guarantees that you are back into your reset defaults.
>>>
>>> As Daniel suggested, I would be looking for undocumented/proprietary
>>> registers for reasons as to why your PHY is not working, in particular
>>> (RG)MII tuning.
>>
>> Am I the only having problems with the AR8035? :-(
>>
>> The standard driver works for everyone but me? 
>>
>> Did you take a look at the data sheet? Do you understand the
>> difference between "Hardware Reset" and "Software Reset"?
> 
> I did not.

If I understand your quote from the standard correctly,
then the behavior documented in the data sheet looks
very non-compliant to my untrained eye.

>> Also, why do you say the PHY is not working? When I apply the
>> patch I proposed, it doesn't malfunction.
> 
> There are no BMCR registers that would affect directly the passing of
> unicast or broadcast traffic with distinction, which is how you
> originally reported the problem, or maybe that was a bad description of
> the issue?

I didn't say anything about unicast vs broadcast.

When I run the unpatched code, it looks like the PHY negotiates
only 10 Mbps Half-duplex, then DHCP appears to succeed (IIUC
only the very first packets are broadcast), and then the system
hangs trying to mount the root filesystem over NFS.

I actually left it running over lunch break, and according
to the kernel's time stamps, the system seems to have managed
to mount the root file system after 2000+ seconds.

> Have you checked the Ethernet MAC MIB counters to see if there are any
> errors reported differently from the working case to the non-working
> case? What about your link partner, what does it looks like on its end
> when it does not work?

Should I use ethtool for this?

Or do it directly with kernel code? (If so which API?)

The catch is that I need the network to get a running system.
No network, no root file system.

Maybe I need to write the kernel to non-volatile storage.


Going on a wild goose hunt...

Somewhat related discussion
https://community.freescale.com/thread/289362

Let me check how u-boot handles the AR8035.
http://git.denx.de/?p=u-boot.git;a=blob;f=drivers/net/phy/atheros.c

static int ar8035_config(struct phy_device *phydev)
{
	int regval;

	phy_write(phydev, MDIO_DEVAD_NONE, 0xd, 0x0007);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xe, 0x8016);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xd, 0x4007);
	regval = phy_read(phydev, MDIO_DEVAD_NONE, 0xe);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xe, (regval|0x0018));

	phy_write(phydev, MDIO_DEVAD_NONE, 0x1d, 0x05);
	regval = phy_read(phydev, MDIO_DEVAD_NONE, 0x1e);
	phy_write(phydev, MDIO_DEVAD_NONE, 0x1e, (regval|0x0100));

	phydev->supported = phydev->drv->features;

	return 0;
}

Data sheet states:
Register 0xd = "MMD Access Control". 
Register 0xe = "MMD Access Control Data".

MMD register access:
See detail in register description
example: Write 0x8000 to Register 0 of MMD3
1. Write 0x3 to register 0xD: 
0xD=0x0003;(function= address; set the device address)
2. Write 0x0 to register 0xE: 0xE=0x0; (set the register offset address)
3. Write 0x4003 to register 
0xD:0xD=0x4003;(function=data; keep the device address)
4. Read register 0xE:0xE==(data from register 0x0 of MMD3)
5. Write 0x8000 to register 0xE 
:0xE=0x8000(write 0x8000 to register 0x0 of MMD3)
Please Note:Read operation please refers to process 1 ~ 4

Important note:
CLK_25M default outputs 25MHz, can be configured to
50MHz, 62.5MHz, or 125MHz by register MMD7 8016[4:3].

Ah yes, there it is on page 58:
Device address = 7, address offset = 0x8016 (Hex)
4:3 Select_clk125m
CLK_25M output clock select
00=25M
01=50M
10=62.5M
11=125M


So...

	phy_write(phydev, MDIO_DEVAD_NONE, 0xd, 0x0007);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xe, 0x8016);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xd, 0x4007);
	regval = phy_read(phydev, MDIO_DEVAD_NONE, 0xe);
	phy_write(phydev, MDIO_DEVAD_NONE, 0xe, (regval|0x0018));

R[0xd] = 0x0007  ; select MMD7
R[0xe] = 0x8016  ; offset 0x8016, so 
R[0xd] = 0x4007  ; select "data, no post increment" for MMD7
then we read the current value of MMD7/offset=0x8016
and set bits 3 and 4 on top of that => 125 MHz clock

HW reset val = 0
SW reset val = retain previous value
so the reset in Linux shouldn't affect this...


	phy_write(phydev, MDIO_DEVAD_NONE, 0x1d, 0x05);
	regval = phy_read(phydev, MDIO_DEVAD_NONE, 0x1e);
	phy_write(phydev, MDIO_DEVAD_NONE, 0x1e, (regval|0x0100));

set debug port offset to 5 (DR5)
read current value
set bit 8 (rgmii_tx_clk_dly)

Rgmii tx clock delay control bit:
1 = rgmii tx clock delay enable
0 = rgmii tx clock delay disable.

AFAICT, the Linux code doesn't RMW, it just blindly writes
AT803X_DEBUG_RGMII_TX_CLK_DLY. Dunno if it makes any difference...

Meh, I'm still grasping at straws...

Regards.
