From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY
 ID on mv88e6390
Date: Wed, 25 Jan 2017 20:30:40 +0100
Message-ID: <20170125193040.GE6611@lunn.ch>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
 <1485309314-23942-2-git-send-email-andrew@lunn.ch>
 <87sho7123x.fsf@free-electrons.com>
 <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <87r33r3tkw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45961 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751446AbdAYTar (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 14:30:47 -0500
Content-Disposition: inline
In-Reply-To: <87r33r3tkw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 01:03:43PM -0500, Vivien Didelot wrote:
> Andrew,
> 
> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
> 
> > Since several chips have this issue, we can introduce a u16 physid2_mask
> > member in the mv88e6xxx_info structure and move the check in
> > mv88e6xxx_phy_read() so that the logic of device (as in Global2) helpers
> > are not affected by such (necessary) hack. Something like:
> >
> >     static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
> >                                   int reg, u16 *val)
> >     {
> >         ...
> >
> >         err = chip->info->ops->phy_read(chip, bus, addr, reg, val);
> >         if (err)
> >             return err;
> >
> >         if (reg == MII_PHYSID2 && chip->info->physid2_mask) {
> >             /* Some internal PHYs don't have a model number,
> >              * so return the switch family model number directly.
> >              */
> >             if (!(*val & chip->info->physid2_mask))
> >                 *val |= chip->info->prod_num;
> 
>           if (reg == MII_PHYSID2 && (*val & 0xfff0) == 0)

This should be 0x3f0. There are 10 bits for the device model, of which
Marvell uses the lowest 4 for version.

>               *val |= chip->info->prod_num << 4;

#define PORT_SWITCH_ID_PROD_NUM_6190    0x190
#define PORT_SWITCH_ID_PROD_NUM_6190X   0x0a0
#define PORT_SWITCH_ID_PROD_NUM_6191    0x191
#define PORT_SWITCH_ID_PROD_NUM_6290    0x290
#define PORT_SWITCH_ID_PROD_NUM_6390    0x390
#define PORT_SWITCH_ID_PROD_NUM_6390X   0x0a1

That still gives us 6 different PHY IDs, and the shift will cause is
to modify the OUI, so it is no longer a Marvell OUI.

   Andrew
