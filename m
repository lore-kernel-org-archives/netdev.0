From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Wed, 25 Jan 2017 12:45:40 -0500
Message-ID: <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch> <1485309314-23942-2-git-send-email-andrew@lunn.ch> <87sho7123x.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44788 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdAYRqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:46:12 -0500
In-Reply-To: <87sho7123x.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory, Andrew,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

>> +	if (reg == MII_PHYSID2) {
>> +		/* The mv88e6390 internal PHYS don't have a model number.
>> +		 * Use the switch family model number instead.
>> +		 */
>> +		if (!(*val & 0x3ff)) {
>
> I tested this series on the Topaz switch but it failed because while I
> said we read 0x1410C00 actually we read 0x01410C01. With the
> MARVELL_PHY_ID_MASK we mask the 4 lower bits so that's why in my patch
> "phy: marvell: Add support for the PHY embedded in the topaz switch" I
> used the 0x01410C00 value for MARVELL_PHY_ID_88E6141.
>
> However with the mask you use it doesn't work.
>
> So this mask should be changed to 0x3f0 for the Topaz. Actually 0x3fe
> would be enough but it seems more logical to use the same mask that for
> MARVELL_PHY_ID_MASK.
>
> We could either use the same mask for both family and still use 6390 as
> they seem compatible or we use two different families based on the lower
> bit.

Since several chips have this issue, we can introduce a u16 physid2_mask
member in the mv88e6xxx_info structure and move the check in
mv88e6xxx_phy_read() so that the logic of device (as in Global2) helpers
are not affected by such (necessary) hack. Something like:

    static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
                                  int reg, u16 *val)
    {
        ...

        err = chip->info->ops->phy_read(chip, bus, addr, reg, val);
        if (err)
            return err;

        if (reg == MII_PHYSID2 && chip->info->physid2_mask) {
            /* Some internal PHYs don't have a model number,
             * so return the switch family model number directly.
             */
            if (!(*val & chip->info->physid2_mask))
                *val |= chip->info->prod_num;
        }

        return 0;
    }


Thanks,

        Vivien
